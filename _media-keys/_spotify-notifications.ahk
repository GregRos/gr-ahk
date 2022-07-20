global _mediaTT = TT("", "", "⚡ Spotify")
_mediaTT.SETWINDOWTHEME("")
_mediaTT.Color("White", "Black")
_mediaTT.SETMARGIN(15, 15, 15, 15)
_mediaTT.Font("S14, Segoe UI")

GetTextForAction(action) {
    cmd:= StrSplit(action, " ")
    command:= cmd[1]
    arg:= cmd[2]
    switch command {
case "start-playlist":
    return "💿 playlist"
    case "next-track":
    return "⏭️ Next"
case "previous-track":
return "⏮️ Previous"
case "toggle-play":
return "⏯️ Play/Pause"
case "seek":
    if (arg > 0) {
        return "⏩ Seek +" arg
    } else {
        return "⏪ Seek " arg
    }
case "restart-track":
return "🔁 Track"
case "restart-thing":
return "⏬ Playlist"
case "repeat":
    switch arg {
    case "track":
    return "🔂 Track"
case "context":
return "🔁 Context"
case "off":
return "🔁 Off"
}
return "🔁 " arg
case "heart":
return "❤️ " Format("{:T}", arg)
}
}

_HideSpotifyTT() {
    _mediaTT.Hide()
    SetTimer, _HideSpotifyTT, Off
}

OnSpotifyAction(action, status, error = "") {
    if (gWin_IsFullScreen()) {
        return
    }
    actionText := GetTextForAction(action)
    win := gWin_Get({title: "ahk_exe Spotify.exe"})
    title := !win ? "Spotify" : win.Title
    tipIcon := ""
    switch status {
    case "RUNNING":
        _mediaTT.Color("White", "Black")
        _mediaTT.Title(actionText, 1)
        _mediaTT.Text(title)
        _mediaTT.Show(,A_ScreenWidth - 200, A_ScreenHeight - 200)
        SetTimer, _HideSpotifyTT, Off
        SetTimer, _HideSpotifyTT, 1000
    case "SUCCESS":
        _mediaTT.Hide()
        SetTimer, _HideSpotifyTT, Off
    case "ERROR":
        _mediaTT.Icon(3)
        _mediaTT.Text(error)
        _mediaTT.Color("", "Red")
        SetTimer, _HideSpotifyTT, 500

    }

}

Spotify.OnAction(Func("OnSpotifyAction"))
