#Persistent
#SingleInstance, Force
FixJB_UnshrinkTinyWindow(w) {
    WinGetPos, X, Y, Width, Height
    if (Width == 0 || Height == 0) {
        OutputDebug, Window %w% has 0,0. Skipping it.
        ; In this case, the window hasn't finished loading.
        return
    }
    Sleep 200
    if (!WinExist("ahk_id " w)) {
        OutputDebug, Window %w% doesn't exist anymore.
        return
    }
    if (Width < 200 && Height < 60) {
        if (Y < 0) {
            ; Sometimes windows render above the screen, this fixes them
            FixY := 0
        }
        OutputDebug, % "Found tiny window " w " with: " Width "," Height ". Fixing."
        WinMove, % "ahk_id " w, , , % FixY , 1500, 1000
        WinActivate, % "ahk_id" w
    }
    
}

CheckJBs() {
    SetTitleMatchMode, RegEx
    winFilter := "^…/.*@Greg-WSL2$ ahk_class ^vcxsrv/x X rl$"
    WinWaitActive, % winFilter
    last:=WinExist()
    FixJB_UnshrinkTinyWindow(last)
    SetTimer, CheckJBs, -250
}

SetTimer, CheckJBs, -250