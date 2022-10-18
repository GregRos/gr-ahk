#SingleInstance, Force
SetTitleMatchMode, RegEx
; Globals
DesktopCount := 2 ; Windows starts with 2 desktops at boot
CurrentDesktop := 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)
LastOpenedDesktop := 1
global _g_desktopIdToName := {}
; DLL
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\_desktop-switcher\VirtualDesktopAccessor.dll", "Ptr")
global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnDesktopNumber", "Ptr")
global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
Menu, Tray, Add, Help: DesktopSwitcher, OnHelp_WindowsDesktopSwitcher

OnHelp_WindowsDesktopSwitcher() {
    Run, % A_ScriptDir "\_desktop-switcher\desktop-switcher.html"
}
; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [DesktopSwitcher] desktops: %DesktopCount% current: %CurrentDesktop%

; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
; On Windows 11 the current desktop UUID appears to be in the same location
; On previous versions in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
;
mapDesktopsFromRegistry()
{
    global CurrentDesktop, DesktopCount
    desktopIdToName := {}
    ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
    IdLength := 32
    SessionId := getSessionId()
    if (SessionId) {
        RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, CurrentVirtualDesktop
        if ErrorLevel {
            RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
        }

        if (CurrentDesktopId) {
            IdLength := StrLen(CurrentDesktopId)
        }
    }

    ; Get a list of the UUIDs for all virtual desktops on the system
    vdKey := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
    RegRead, DesktopList, % vdKey, VirtualDesktopIDs
    if (DesktopList) {
        DesktopListLength := StrLen(DesktopList)
        ; Figure out how many virtual desktops there are
        DesktopCount := floor(DesktopListLength / IdLength)
    }
    else {
        DesktopCount := 1
    }

    ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
    i := 0
    while (CurrentDesktopId and i < DesktopCount) {
        StartPos := (i * IdLength) + 1
        DesktopIter := SubStr(DesktopList, StartPos, IdLength)
        desktopIdToName[i + 1] := DesktopIter
        ; Break out if we find a match in the list. If we didn't find anything, keep the
        ; old guess and pray we're still correct :-D.
        if (DesktopIter = CurrentDesktopId) {
            CurrentDesktop := i + 1
        }
        i++
    }

    for i, BinId in desktopIdToName {
        LastBinIdPart := SubStr(BinId, -7)
        hit := False
        Loop, Reg, % vdKey "\Desktops", RV
        {
            if (A_LoopRegName != "Name") {
                Continue
            }
            LastSubkeyPart := StrSplit(A_LoopRegSubkey, "\")
            LastSubkeyPart := Trim(LastSubkeyPart[LastSubkeyPart.MaxIndex()], "{}")
            LastRegIdPart := SubStr(LastSubkeyPart, -7)

            if (LastBinIdPart = LastRegIdPart) {
                RegRead, Name,% A_LoopRegKey "\" A_LoopRegSubkey, Name
                if (!ErrorLevel) {
                    desktopIdToName[i] := name
                    hit := true
                    break
                }
            }
        }
        if (!hit) {
            desktopIdToName[i] := "Desktop " i
        } 
        name := desktopIdToName[i]
    }
    _g_desktopIdToName := desktopIdToName
}

;
; This functions finds out ID of current session.
;
getSessionId() {
    ProcessId := DllCall("GetCurrentProcessId", "UInt")
    if ErrorLevel {
        OutputDebug, Error getting current process id: %ErrorLevel%
        return
    }

    DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
    if ErrorLevel {
        OutputDebug, Error getting session id: %ErrorLevel%
        return
    }
    return SessionId
}

_switchDesktopToTarget(targetDesktop) {
    ; Globals variables should have been updated via updateGlobalVariables() prior to entering this function
    global CurrentDesktop, DesktopCount, LastOpenedDesktop
    prevDesktop := CurrentDesktop
    ; Don't attempt to switch to an invalid desktop
    if (targetDesktop > DesktopCount || targetDesktop < 1 || targetDesktop == CurrentDesktop) {
        OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
        return
    }

    LastOpenedDesktop := CurrentDesktop

    ; Fixes the issue of active windows in intermediate desktops capturing the switch shortcut and therefore delaying or stopping the switching sequence. This also fixes the flashing window button after switching in the taskbar. More info: https://github.com/pmb6tz/windows-desktop-switcher/pull/19
    WinActivate, ahk_class Shell_TrayWnd

    ; Go right until we reach the desktop we want
    while(CurrentDesktop < targetDesktop) {
        Send {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}
        CurrentDesktop++
        OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
    }

    ; Go left until we reach the desktop we want
    while(CurrentDesktop > targetDesktop) {
        Send {LWin down}{LCtrl down}{Left down}{Lwin up}{LCtrl up}{Left up}
        CurrentDesktop--
        OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
    }
    ; Makes the WinActivate fix less intrusive
    Sleep, 50
    focusTheForemostWindow(targetDesktop)
    _notifyDesktopSwitched(prevDesktop, CurrentDesktop)

}


updateGlobalVariables() {
    ; Re-generate the list of desktops and where we fit in that. We do this because
    ; the user may have switched desktops via some other means than the script.
    mapDesktopsFromRegistry()
}


switchDesktopByNumber(targetDesktop) {
    global CurrentDesktop, DesktopCount
    updateGlobalVariables()
    _switchDesktopToTarget(targetDesktop)
}

switchDesktopToLastOpened() {
    global CurrentDesktop, DesktopCount, LastOpenedDesktop
    updateGlobalVariables()
    _switchDesktopToTarget(LastOpenedDesktop)
}

switchDesktopToRight() {
    global CurrentDesktop, DesktopCount
    updateGlobalVariables()
    _switchDesktopToTarget(CurrentDesktop + 1)
}

switchDesktopToLeft() {
    global CurrentDesktop, DesktopCount
    updateGlobalVariables()
    _switchDesktopToTarget(CurrentDesktop - 1)
}

focusTheForemostWindow(targetDesktop) {
    foremostWindowId := getForemostWindowIdOnDesktop(targetDesktop)
    if isWindowNonMinimized(foremostWindowId) {
        WinActivate, ahk_id %foremostWindowId%
    }
}

isWindowNonMinimized(windowId) {
    WinGet MMX, MinMax, ahk_id %windowId%
    return MMX != -1
}

getForemostWindowIdOnDesktop(n) {
    n := n - 1 ; Desktops start at 0, while in script it's 1

    ; winIDList contains a list of windows IDs ordered from the top to the bottom for each desktop.
    WinGet winIDList, list
    Loop % winIDList {
        windowID := % winIDList%A_Index%
        windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, windowID, UInt, n)
        ; Select the first (and foremost) window which is in the specified desktop.
        if (windowIsOnDesktop == 1) {
            return windowID
        }
    }
}


MoveCurrentWindowToDesktop(desktopNumber, follow) {
    WinGet, activeHwnd, ID, A
    _moveWindowAndRelatedToDesktop(activeHwnd, desktopNumber)
    if (follow) {
        switchDesktopByNumber(desktopNumber)
    }
}

MoveCurrentWindowToRightDesktop(follow) {
    global CurrentDesktop, DesktopCount
    updateGlobalVariables()
    WinGet, activeHwnd, ID, A
    targetDesktop := CurrentDesktop + 1
    if (CurrentDesktop >= DesktopCount) {
        return
    }
    MoveCurrentWindowToDesktop(targetDesktop, follow)
}

MoveCurrentWindowToLeftDesktop(follow) {
    global CurrentDesktop, DesktopCount
    updateGlobalVariables()
    if (CurrentDesktop == 1) {
        return
    }
    targetDesktop := CurrentDesktop - 1
    MoveCurrentWindowToDesktop(targetDesktop, follow)
}

;
; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop() {
    global CurrentDesktop, DesktopCount
    Send, #^d
    DesktopCount++
    CurrentDesktop := DesktopCount
    OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}

;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop() {
    global CurrentDesktop, DesktopCount, LastOpenedDesktop
    Send, #^{F4}
    if (LastOpenedDesktop >= CurrentDesktop) {
        LastOpenedDesktop--
    }
    DesktopCount--
    CurrentDesktop--
    OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
DS_Start() {
    Loaded("DesktopSwitcher")
}
