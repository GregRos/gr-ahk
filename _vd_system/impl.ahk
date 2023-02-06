#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
VD_DesktopStack := []
VD_LastDesktop := "1"
VD_LastWindow := ""
class DesktopWindowState {
    __New(desktopIndex, activeHwnd) {
        this.desktopIndex := desktopIndex
        this.activeHwnd := activeHwnd
    }
}

VD_DesktopUpdateTimer() {
    ; I know the callback for desktop switch exists, but it's better
    ; to just do it like this.
    global VD_DesktopStack, VD_LastDesktop, VD_LastWindow
    hwnd := gWin_Get({title: ""})
    if (VD_LastWindow != hwnd) {
        VD_LastWindow := hwnd
    }
    current := vd.getCurrentDesktopNum()
    if (VD_LastDesktop == current) {
        return
    }
    if (VD_DesktopStack.MaxIndex() > 1000) {
        VD_DesktopStack := []
    }
    VD_DesktopStack.Push(new DesktopWindowState(VD_LastDesktop, VD_LastWindow))
    VD_LastDesktop := current
}

VD_START() {
    ; Init the different implementations
    VD.init()
    SetTimer, VD_DesktopUpdateTimer, 350
    Loaded("VirtualDesktops VD")
}

VD_GotoPreviousDesktop() {
    global VD_DesktopStack
    ; Maybe there is a condition where it can become 0, don't care
    if (VD_DesktopStack.MaxIndex() <= 1) {
        return
    }
    lastDesktop := VD_DesktopStack.Pop()
    vd.goToDesktopNum(lastDesktop.desktopIndex)
}
