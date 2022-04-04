#Persistent
#SingleInstance, Force

KSN_Action(w) {
    OutputDebug, Found nag %w%! Stop nagging!!
    WinClose, ahk_id %w%
}

KSN_Check() {
    SetTitleMatchMode, 2
    WinWait, This is an unregistered
    KSN_Action(WinExist())
    SetTimer, KSN_Check, -250
}

KSN_Start() {
    SetTimer, KSN_Check, -1000
    Loaded("KillSublimeNag")
}

