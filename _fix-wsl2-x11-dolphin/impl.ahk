#Persistent
#SingleInstance, Force
FWXD_ModifyWindowStyle(w) {
    WinGet, MyStyle, Style, % "ahk_id " w
    if (!hasRightStyles) {
        WinGetPos, X, Y, Width, Height, % "ahk_id " w
        OutputDebug, % "Dolphin instance " w " has missing buttons. Adding buttons." 
        if (Y > 0) {
            OutputDebug, % "Also adding maximize"
            WinSet, Style, +0x30000, ahk_id %w%
        } else {
            WinSet, Style, +0x20000, ahk_id %w%
        }
    }

}

FWXD_CheckDolphins() {
    SetTitleMatchMode, 2
    WinWaitActive, Dolphin@Greg-WSL2
    last:=WinExist()
    FWXD_ModifyWindowStyle(last)
    SetTimer, FWXD_CheckDolphins, -350
}

SetTimer, FWXD_CheckDolphins, -350
Loaded("Fix-WSL2-X11-Dolphin")