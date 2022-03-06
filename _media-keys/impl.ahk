Menu, Tray, Add, Help: MediaKeys, OnHelp_MediaKeys

OnHelp_MediaKeys() {
    Run, % A_ScriptDir "\_media-keys\media-keys.html"
}

#Include _win-mixer.ahk
#include _spotify-automator.ahk
#include _spotify-notifications.ahk