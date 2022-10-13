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
d::VD.goToDesktopNum(VD.MoveWindowToRelativeDesktopNum("A", 1))
a::VD.goToDesktopNum(VD.MoveWindowToRelativeDesktopNum("A", -1))
1::VD.goToDesktopNum(VD.MoveWindowToDesktopNum("A", 1))
2::VD.goToDesktopNum(VD.MoveWindowToDesktopNum("A", 2))
3::VD.goToDesktopNum(VD.MoveWindowToDesktopNum("A", 3))
4::VD.goToDesktopNum(VD.MoveWindowToDesktopNum("A", 4))
5::VD.goToDesktopNum(VD.MoveWindowToDesktopNum("A", 5))
#if GetHotkeyMode() = "CR"
d::VD.MoveWindowToRelativeDesktopNum("A", 1)
a::VD.MoveWindowToRelativeDesktopNum("A", -1)
1::VD.MoveWindowToDesktopNum("A", 1)
2::VD.MoveWindowToDesktopNum("A", 2)
3::VD.MoveWindowToDesktopNum("A", 3)
4::VD.MoveWindowToDesktopNum("A", 4)
5::VD.MoveWindowToDesktopNum("A", 5)

#if
#IfWinActive, ahk_exe chrome.exe
!q::
Send, +^a
#if

