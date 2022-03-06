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


#include desktop-switcher\
#include impl.ahk

#include ..\media-keys\
#include impl.ahk


#include ..\
#include desktop-switcher\bindings.ahk
#include media-keys\bindings.ahk
