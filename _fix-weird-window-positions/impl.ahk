#Persistent
#SingleInstance, Force

FWWP_Action(w) {
    WinGetPos, X, Y, Width, Height, ahk_id %w%
    if (Y < 0) {
        OutputDebug, [WeirdWindowFixer] Found %w% being naughty. Spanking.
        ; I am not ashamed of myself.
        WinMove, ahk_id %w%, , , 0
    }
}

FWWP_Check() {
    SetTitleMatchMode, 2
    last:=WinExist("A")
    ModifyWindowStyle(last)
    SetTimer, CheckDolphins, -250
}

SetTimer, FWWP_Check, -250
Loaded("FWWP_Action")
