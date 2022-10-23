ComObjArrayToString(arr) {
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
6::vd.goToDesktopNum(6)
7::vd.goToDesktopNum(7)
8::vd.goToDesktopNum(8)
9::vd.goToDesktopNum(9)
d::vd.goToDesktopNum(vd.getCurrentDesktopNum() + 1)
a::vd.goToDesktopNum(vd.getCurrentDesktopNum() - 1)
c::VD_GotoPreviousDesktop()
e::vd.goToDesktopNum(VD_GetLastDesktopPosWithVisibleWindow())
#if GetHotkeyMode() = "CL"
d::_moveWindowRelAndFollow(1)
a::_moveWindowRelAndFollow(-1)
1::_moveWindowAndFollow(1)
2::_moveWindowAndFollow(2)
3::_moveWindowAndFollow(3)
4::_moveWindowAndFollow(4)
5::_moveWindowAndFollow(5)
6::_moveWindowAndFollow(6)
7::_moveWindowAndFollow(7)
8::_moveWindowAndFollow(8)
9::_moveWindowAndFollow(9)
q::VD.TogglePinWindow("A")
#if GetHotkeyMode() = "CR"
d::_moveWindowAndRelatedDesktopRelative(1)
a::_moveWindowAndRelatedDesktopRelative(-1)
1::_moveActiveAndRelatedWindowToDesktop(1)
2::_moveActiveAndRelatedWindowToDesktop(2)
3::_moveActiveAndRelatedWindowToDesktop(3)
4::_moveActiveAndRelatedWindowToDesktop(4)
5::_moveActiveAndRelatedWindowToDesktop(5)
6::_moveActiveAndRelatedWindowToDesktop(6)
7::_moveActiveAndRelatedWindowToDesktop(7)
8::_moveActiveAndRelatedWindowToDesktop(8)
9::_moveActiveAndRelatedWindowToDesktop(9)


#if
#IfWinActive, ahk_exe chrome.exe
!q::
Send, +^a
#if

