GetNumpadMode() {
    isNumpad0 := GetKeyState("Numpad0", "P")
    isNumpadDot := GetKeyState("NumpadDot", "P")
    if (!isNumpad0 && !isNumpadDot) {
        return "none"
    } else if (isNumpad0) {
        return "zero"
    } else if (isNumpadDot) {
        return "dot"
    }
}

NumpadEnter::
    spotify.CancelSpotifyAction()
return

#if GetNumpadMode() = "none"
    NumpadAdd::Volume_Up
NumpadSub::Volume_Down
NumpadMult::Volume_Mute
NumpadDiv::
    SoundSet, 100
Return

Numpad4::
    spotify.Exec("previous-track")
Return

Numpad6::
    spotify.Exec("next-track")
Return

Numpad5::
    spotify.Exec("toggle-play")
Return

Numpad3::
    spotify.Exec("seek 30")
Return

Numpad1::
    spotify.Exec("seek -30")
Return

Numpad2::
    spotify.Exec("restart-track")
Return

Numpad8::
    spotify.Exec("heart")
Return

NumLock::
    WinGet, hwnd, ID, ahk_exe Spotify.exe
    WinActivate, ahk_exe Spotify.exe
Return
#if
#if GetNumpadMode() = "zero"
Numpad2::
spotify.Exec("restart-thing")
Return

NumpadAdd::
    WinGet, hwnd, ID, ahk_exe Spotify.exe
    ModAppVolume(hwnd, 10)
Return

NumpadSub::
    WinGet, hwnd, ID, ahk_exe Spotify.exe
    ModAppVolume(hwnd, -10)
Return

NumpadMult::
    WinGet, hwnd, ID, ahk_exe Spotify.exe
    MuteApp(hwnd)
Return

Numpad4::
    spotify.Exec("repeat track")
Return

Numpad5::
    spotify.Exec("repeat context")
Return

Numpad6::
    spotify.Exec("repeat off")
Return
#if
    #if GetNumpadMode() = "dot"

NumpadAdd::
    WinGet, hwnd, ID, A
    ModAppVolume(hwnd, 10)
Return

NumpadSub::
    WinGet, hwnd, ID, A
    ModAppVolume(hwnd, -10)
Return

NumpadMult::
    WinGet, hwnd, ID, A
    MuteApp(hwnd)
Return

Numpad1::
    spotify.Exec("start-playlist 36VDQ8dEZlqteRrGQTTJTw")
Return

Numpad2::
    spotify.Exec("start-playlist 3aCWycDjhkVtsx1G8OyULu")
#if

Numpad0::
Return

Numpad0 Up::
Return

NumpadDot::
Return

NumpadDot Up::
Return