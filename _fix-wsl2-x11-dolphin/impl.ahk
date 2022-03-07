ModifyWindowStyle(w) {
    WinGet, MyStyle, Style, % "ahk_id " w
    hasRightStyles := MyStyle & (0x20000 | 0x10000)
    if (!hasRightStyles) {
        OutputDebug, % "Dolphin instance " w " has missing buttons. Adding buttons." 
    }
    WinSet, Style, +0x20000, % "ahk_id " w
    WinSet, Style, +0x10000, % "ahk_id " w
}

CheckDolphins() {
    SetTitleMatchMode, 2
    WinWaitActive, Dolphin@Greg-WSL2
    last:=WinExist()
    ModifyWindowStyle(last)
    SetTimer, CheckDolphins, -250
}

SetTimer, CheckDolphins, -250