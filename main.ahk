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

#Maxthreads, 100
#MaxThreadsPerHotkey, 4
#include <sizeof>
#include <_Struct>
#include <gutils>
#include <TT>

gUtils(true)
; Required definition for TT.ahk
Struct(Structure,pointer:=0,init:=0){
    return new _Struct(Structure,pointer,init)
} 

#Include _win-mixer.ahk
#include _spotify-automator.ahk
#include _spotify-notifications.ahk
#Include _desktops.ahk

#include windows-desktop-switcher.ahk

#include super-media-keys.ahk