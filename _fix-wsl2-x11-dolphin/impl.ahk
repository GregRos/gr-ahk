#Persistent
#SingleInstance, Force
ModifyWindowStyle(w) {
    WinGet, MyStyle, Style, % "ahk_id " w
    rightStyle := 0x30000
    hasRightStyles := MyStyle & rightStyle
    if (!hasRightStyles) {
        OutputDebug, % "Dolphin instance " w " has missing buttons. Adding buttons." 
        WinSet, Style, +%rightStyle%, % "ahk_id " w
    }
}

CheckDolphins() {
    SetTitleMatchMode, 2
    WinWaitActive, Dolphin@Greg-WSL2
    last:=WinExist()
    ModifyWindowStyle(last)
    SetTimer, CheckDolphins, -250
}

SetTimer, CheckDolphins, -250
Loaded("Fix-WSL2-X11-Dolphin")