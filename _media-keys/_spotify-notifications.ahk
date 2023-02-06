global _mediaTT

_Spot_RecycleTT()
global hits := 0

_Spot_CreateMediaTT() {
    ttx := TT("ClickTrough", "", "")
    ttx.SETWINDOWTHEME("")
    ttx.Color("White", "Black")
    ttx.SETMARGIN(15, 15, 15, 15)
    ttx.Font("S18, Segoe UI")
    return ttx
}

_Spot_RecycleTT() {
    global _mediaTT
    if (_mediaTT) {
        _mediaTT.Remove()
    }
    _mediaTT := _Spot_CreateMediaTT()
}

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
    case "spin":
        switch arg {
            case "song":
                return "☁️ Song ☁️"
            case "artist":
                return "☁️ Artist ☁️"
            case "album":
                return "☁️ Album ☁️"
        }
    case "heart":
        return "❤️ " Format("{:T}", arg)
    }
}

_HideSpotifyTT() {
    global hits
    hits++
    if (hits > 5) {
        hits := 0
        _Spot_RecycleTT()
    } else {
        _mediaTT.Hide()
    }
    SetTimer, _HideSpotifyTT, Off
}

OnSpotifyAction(action, status, error = "") {
    if (gWin_IsFullScreen()) {
        return
    }
    actionText := GetTextForAction(action)
    DetectHiddenWindows, On
    SetTitleMatchMode, RegEx
    WinGetTitle, title, % "ahk_exe i).*\\Spotify.exe"
    if (title == "") {
        title := "[No Window]"
    }
    tipIcon := ""
    switch status {
    case "RUNNING":
        _mediaTT.Color("White", "Black")
        _mediaTT.Title(actionText, 1)
        _mediaTT.Text("⏳ " title " ⏳")
        _mediaTT.Show(,A_ScreenWidth - 200, A_ScreenHeight - 200)
        SetTimer, _HideSpotifyTT, Off
        SetTimer, _HideSpotifyTT, 1000
    case "SUCCESS":
        DetectHiddenWindows, On
        WinGetTitle, title, % "ahk_exe Spotify.exe"
        _mediaTT.Text("❧ " title " ☙")
        Sleep 500

        _mediaTT.Hide()
        SetTimer, _HideSpotifyTT, Off
    case "ERROR":
        _mediaTT.Icon(3)
        _mediaTT.Title(actionText, 1)
        _mediaTT.Text("⛔ "error " ⛔")
        _mediaTT.Color("", "Red")
        SetTimer, _HideSpotifyTT, 500

    }

}

Spotify.OnAction(Func("OnSpotifyAction"))
