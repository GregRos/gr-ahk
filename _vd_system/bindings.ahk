﻿ComObjArrayToString(arr) {
    res := ""
    for x in arr {
        res .= chr(x)
    }
    return res
}

GetHotkeyMode() {
    if (!GetKeyState("CapsLock", "P")) {
        return ""
    }
    if (GetKeyState("RButton", "P")) {
        return "CR"
    } else if (GetKeyState("LButton", "P")) {
        return "CL"
    } else {
        return "C"
    }
}

CapsLock::
    if (GetKeyState("CapsLock", "T")) {
        SetCapsLockState, AlwaysOff
    }
    return

#if GetHotkeyMode() != ""
RButton::
    if (GetHotkeyMode() == "") {
        SendInput, {RButton down}
    }
    Return
LButton::
    if (GetHotkeyMode() == "") {
        SendInput, {LButton down}
    }
    Return



#if GetHotkeyMode() = "C"
1::vd.goToDesktopNum(1)
2::vd.goToDesktopNum(2)
3::vd.goToDesktopNum(3)
4::vd.goToDesktopNum(4)
5::vd.goToDesktopNum(5)
d::vd.goToDesktopNum(vd.getCurrentDesktopNum() + 1)
a::vd.goToDesktopNum(vd.getCurrentDesktopNum() - 1)
z::VD_GotoPreviousDesktop()
#if GetHotkeyMode() = "CL"
d::_moveWindowRelAndFollow(1)
a::_moveWindowRelAndFollow(-1)
1::_moveWindowAndFollow(1)
2::_moveWindowAndFollow(2)
3::_moveWindowAndFollow(3)
4::_moveWindowAndFollow(4)
5::_moveWindowAndFollow(5)
q::VD.TogglePinWindow("A")
#if GetHotkeyMode() = "CR"
d::_moveWindowAndRelatedDesktopRelative(1)
a::_moveWindowAndRelatedDesktopRelative(-1)
1::_moveActiveAndRelatedWindowToDesktop(1)
2::_moveActiveAndRelatedWindowToDesktop(2)
3::_moveActiveAndRelatedWindowToDesktop(3)
4::_moveActiveAndRelatedWindowToDesktop(4)
5::_moveActiveAndRelatedWindowToDesktop(5)

#if
#IfWinActive, ahk_exe chrome.exe
!q::
Send, +^a
#if

