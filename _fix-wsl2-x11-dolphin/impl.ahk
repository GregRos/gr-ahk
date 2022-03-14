#Persistent
#SingleInstance, Force
FWXD_ModifyWindowStyle(w) {
    WinGet, MyStyle, Style, % "ahk_id " w
    rightStyle := 0x30000
    hasRightStyles := MyStyle & rightStyle
    if (!hasRightStyles) {
        OutputDebug, % "Dolphin instance " w " has missing buttons. Adding buttons." 
        WinSet, Style, +%rightStyle%, % "ahk_id " w
    }
}

FWXD_CheckDolphins() {
    SetTitleMatchMode, 2
    WinWaitActive, Dolphin@Greg-WSL2
    last:=WinExist()
    FWXD_ModifyWindowStyle(last)
    SetTimer, FWXD_CheckDolphins, -250
}

SetTimer, FWXD_CheckDolphins, -250
Loaded("Fix-WSL2-X11-Dolphin")