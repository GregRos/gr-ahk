#Persistent
#SingleInstance, Force

FWWP_Action(w) {
    if (!w) {
        return
    }
    WinGetPos, X, Y, Width, Height, ahk_id %w%
    if (Y < -15  && !GetKeyState("LButton", "P")) {
        OutputDebug, [WeirdWindowFixer] Found %w% being naughty. Spanking.
        ; I am not ashamed of myself.
        WinMove, ahk_id %w%, , , 0
    }
}

FWWP_Check() {
    SetTitleMatchMode, 2
    last:=WinExist("A")
    FWWP_Action(last)
    SetTimer, FWWP_Check, -250
}

SetTimer, FWWP_Check, -250
Loaded("Fix-Weird-Window-Positions")
