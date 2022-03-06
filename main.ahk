#SingleInstance, Force
#NoEnv
SendMode Input
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 2
DetectHiddenWindows, On
SetNumLockState, AlwaysOn
SetCapsLockState, AlwaysOff
Menu, Tray, Icon, images\icon.ico
Menu, Tray, Tip, GR-AHK
Menu, Tray, NoStandard
#Maxthreads, 100
#MaxThreadsPerHotkey, 4
#include <sizeof>
#include <_Struct>
#include <gutils>
#include <TT>

; Required definition for TT.ahk
Struct(Structure,pointer:=0,init:=0){
    return new _Struct(Structure,pointer,init)
}

global LoadedIndex := 1

Loaded(name) {
    OutputDebug, [LOADER] (%LoadedIndex%) Component %name% loaded
    LoadedIndex:= LoadedIndex + 1
}


#include _desktop-switcher\
#include impl.ahk
Loaded("DesktopSwitcher")

#include ..\_media-keys\
#include impl.ahk
Loaded("MediaKeys")

#include ..\_fix-wsl2-x11-dolphin
#include impl.ahk
Loaded("Fix-WSL2-X11-Dolphin")

#include ..\
#include _desktop-switcher\bindings.ahk
#include _media-keys\bindings.ahk
Loaded("Hotkeys")
