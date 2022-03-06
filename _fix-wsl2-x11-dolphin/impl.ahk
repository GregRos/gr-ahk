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
    WinWaitActive, Dolphin ahk_exe VcXsrv.exe ahk_class vcxsrv/x X rl
    last:=WinExist()
    ModifyWindowStyle(last)
    SetTimer, CheckDolphins, -250
}

SetTimer, CheckDolphins, -250