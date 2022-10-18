#SingleInstance, Force
#NoEnv
SendMode Input
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 2

SetNumLockState, AlwaysOn
SetCapsLockState, AlwaysOff
Menu, Tray, Icon, images\icon.ico
Menu, Tray, Tip, GR-AHK
Menu, Tray, NoStandard

#include <sizeof>
#include <_Struct>
#include <gutils>
#include <TT>
#include bundled\winhook.ahk
; Required definition for TT.ahk
Struct(Structure,pointer:=0,init:=0){
    return new _Struct(Structure,pointer,init)
}

OnRealExit() {
    ExitApp
}

OnRealSuspend() {
    Suspend, Toggle
}

OnRealRestart() {
    Reload
}


global LoadedIndex := 1

Loaded(name) {
    OutputDebug, [LOADER] (%LoadedIndex%) Component %name% loaded
    LoadedIndex:= LoadedIndex + 1
}

Menu, Tray, Add, Suspend, OnRealSuspend
Menu, Tray, Add, Restart, OnRealRestart
Menu, Tray, Add, Exit, OnRealExit

#include _vd
#include _vd.ahk
#include ..

#include _vd_system
#include impl.ahk
#include ..

#include _media-keys
#include impl.ahk
#include ..

#include _fix-wsl2-x11-dolphin
#include impl.ahk
#include ..

#include _only-valid-window-sizes
#include impl.ahk
#include ..

OnLoaded() {
    FWXD_Start()
    OVWS_Start()
    MK_Start()
    VD_START()
}


SetTimer, OnLoaded, -500

#include _vd_system\bindings.ahk
#include _media-keys\bindings.ahk

