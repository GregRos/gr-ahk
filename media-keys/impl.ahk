Menu, Tray, Add, MediaKeys Help, OnHelp_MediaKeys

OnHelp_MediaKeys() {
    Run, % A_ScriptDir "\media-keys\media-keys.html"
}

#Include _win-mixer.ahk
#include _spotify-automator.ahk
#include _spotify-notifications.ahk