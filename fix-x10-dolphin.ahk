ModifyWindowStyle(w) {
    WinSet, Style, +0x20000, % "ahk_id " w
    WinSet, Style, +0x10000, % "ahk_id " w
}
OutputDebug, Hello
Loop
{
    SetTitleMatchMode, 2
    WinWaitActive, Dolphin ahk_exe VcXsrv.exe ahk_class vcxsrv/x X rl
    last:=WinExist()
    ModifyWindowStyle(last)
    Sleep 1000
}