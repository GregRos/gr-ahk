#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
global VD_DesktopStack := []
global VD_LastDesktop := "~"
global VD_LastWindow := ""

class DesktopWindowState {
    __New(desktopIndex, activeHwnd) {
        this.desktopIndex := desktopIndex
        this.activeHwnd := activeHwnd
    }
}
global VD_DontUpdateHistory := False
VD_DesktopUpdateTimer() {
    ; I know the callback for desktop switch exists, but it's better
    ; to just do it like this.
    if (VD_DontUpdateHistory) {
        return
    }
    hwnd := WinExist("A")
    if (VD_LastWindow != hwnd) {
        VD_LastWindow := hwnd
    }
    current := vd.getCurrentDesktopNum()
    if (VD_LastDesktop == current) {
        return
    }
    if (VD_DesktopStack.MaxIndex() > 1000) {
        VD_DesktopStack := []
    }
    VD_DesktopStack.Push(new DesktopWindowState(VD_LastDesktop, VD_LastWindow))
    VD_LastDesktop := current
}

VD_GetLastDesktopPosWithVisibleWindow() {
    DetectHiddenWindows, On
    WinGet, Window, List
    lastDesktop := 0
    Loop, %Window% {
        cur := Window%A_Index%
        curDesktopNum := vd.getDesktopNumOfWindow("ahk_id " cur)
        if (curDesktopNum > lastDesktop) {
            lastDesktop := curDesktopNum
        }
    }
    return lastDesktop
}

VD_GotoPreviousDesktop() {
    try {      
        VD_DontUpdateHistory := True  
        ; Maybe there is a condition where it can become 0, don't care
        if (VD_DesktopStack.MaxIndex() <= 1) {
            return
        }
        lastDesktop := VD_DesktopStack.Pop()
        vd.goToDesktopNum(lastDesktop.desktopIndex)
        if (lastDesktop.activeHwnd != "0x0") {
            WinActivate, % "ahk_id " lastDesktop.activeHwnd
        }
    } finally {
        VD_DontUpdateHistory := False
    }
}

_vd_getJetBrainsProjectName(hwnd) {
    WinGetTitle, windowTitle, % "ahk_id " hwnd
    ; Main Window
    OutputDebug, % windowTitle
    enDash := Chr(0x2013)
    results := StrSplit(windowTitle, [" " enDash " ", " - "])
    if (results.MaxIndex() > 1) {
        RegExMatch(results[1], "O)(.*?) \[.*", Output)
        if (Output) {
            project := Output.Value(1)
        } else {
            if (results.MaxIndex() > 1) {
                project := results[2]
            }
            if (!project) {
                return "ahk_id " hwnd
            }
        }
    }

regex = i).*( (?:-|\Q%enDash%\E) \Q%project%\E|\Q%project%\E(?: [^\[] )?\Q%enDash%\E ).*
return regex
}

_vd_getSmartGitProjectName(hwnd) {
    WinGetTitle, windowTitle, % "ahk_id " hwnd
    return "\Q" windowTitle "\E"
}

_vd_searchSiblingWindows(hwnd, searchTitle) {
    DetectHiddenWindows, On
    WinGet, pid, PID, % "ahk_id " hwnd
    search := searchTitle " ahk_pid " pid
    WinGet, hwndArray, List, % search
    Windows := []
    Loop, %hwndArray% {
        Current := hwndArray%A_Index%
        WinGetTitle, Title, % "ahk_id " Current
        OutputDebug, % "Related Window: " Title`
        Windows.Push(Current)
    }
    OutputDebug, % "Found " Windows.MaxIndex() " Windows"
    return Windows
}

_vd_isJetBrains(hwnd) {
    WinGet, activePath, ProcessPath, % "ahk_id " hwnd
    return InStr(activePath, "JetBrains")
}

_vd_isChromium(hwnd) {
    WinGet, activePath, ProcessPath, % "ahk_id " hwnd
    return InStr(activePath, ".local-chromium")
}

_vd_isSmartGit(hwnd) {
    WinGet, activePath, ProcessPath, % "ahk_id" hwnd
    return InStr(activePath, "smartgit.exe")
}

_getRelatedWindows(hwnd) {
    if (_vd_isChromium(hwnd)) {
        return _vd_searchSiblingWindows(hwnd, "ahk_exe i)^.*.local-chromium.*$")
    }
    else if (_vd_isSmartGit(hwnd)) {
        return _vd_searchSiblingWindows(hwnd, _vd_getSmartGitProjectName(hwnd))
    }
    return [hwnd]

}

_isOutOfBounds(desktop) {
    if (desktop <= 0 || desktop > vd.getCount()) {
        return True
    }
    Return False
}

_moveActiveAndRelatedWindowToDesktop(desktopNumber, hwnd := "") {
    if (hwnd == "") {
        hwnd := _getWindowUnderCursor()
    }
    if (_isOutOfBounds(desktopNumber)) {
        return
    }
    DetectHiddenWindows, On
    for key, curHwnd in _getRelatedWindows(hwnd) {
        vd.MoveWindowToDesktopNum("ahk_id " curHwnd, desktopNumber)
    }
}

_getWindowUnderCursor() {
    MouseGetPos,,,guideUnderCursor
    return guideUnderCursor
}

_moveWindowAndRelatedDesktopRelative(desktopRel, hwnd := "") {
    if (hwnd == "") {
        hwnd := _getWindowUnderCursor()
    }
    if (_isOutOfBounds(desktopRel + vd.getCurrentDesktopNum())) {
        return
    }
    for key, curHwnd in _getRelatedWindows(hwnd) {
        targetDeskto5p := vd.MoveWindowToRelativeDesktopNum("ahk_id " hwnd, desktopRel)
    }
    return targetDesktop
}

_moveWindowAndFollow(desktopNum) {
    if (_isOutOfBounds(desktopNum)) {
        return
    }
    hwnd := _getWindowUnderCursor()
    vd.goToDesktopNum(desktopNum)
    Sleep 100
    _moveActiveAndRelatedWindowToDesktop(desktopNum, hwnd)
}

_moveWindowRelAndFollow(rel) {
    targetDesktop := vd.getCurrentDesktopNum() + rel
    _moveWindowAndFollow(targetDesktop)
}

_notifyDesktopSwitched(oldDesktop, newDesktop) {
    Sleep 50
    oldDesktopName := vd.getNameFromDesktopNum(oldDesktop)
    newDesktopName := vd.getNameFromDesktopNum(newDesktop)
    caption = %newDesktopName%
    if (gStr_Len(caption) < 8) {
        dif := 8 - gStr_Len(caption)
        left := dif // 2
        right := dif - left
        caption := gStr_Repeat(" ", left) caption gStr_Repeat(" ", right)
    }
    _desktopTT.Text(newDesktop ") " caption)
    _desktopTT.Show("", A_ScreenWidth - 200, A_ScreenHeight - 200)
    SetTimer, _d_hideTT, 2000
}

_d_hideTT() {
    _desktopTT.Hide()
    SetTimer, _d_hideTT, Off
}

VD_DesktopChanged(oldDesktop, newDesktop) {
    _notifyDesktopSwitched(oldDesktop, newDesktop)
    VD_DesktopUpdateTimer()
}
global _desktopTT := TT("ClickTrough", "", "")

VD_START() {
    _desktopTT.SETWINDOWTHEME("")
    _desktopTT.Font("S20 bold, Consolas")
    _desktopTT.Color("White", "Red")
    _desktopTT.SETMARGIN(30, 30, 30, 30)
    ; Init the different implementations
    VD.init()
    vd.RegisterDesktopNotifications()
    vd.CurrentVirtualDesktopChanged := Func("VD_DesktopChanged")
    Loaded("VirtualDesktops VD")
}


VD_Out(text) {
    
}