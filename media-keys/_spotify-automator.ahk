global pythonMain := A_ScriptDir "\media-keys\python\main.py"
OutputDebug, % pythonMain
global Shell := ComObjCreate("Wscript.Shell")
class SpotifyAutomator extends gDeclaredMembersOnly {
    _process := ""
    _onAction := []
    _cancelling := false
    _lastAction := ""
    _origAction := ""
    __New() {
        this.StartProcess()
    }

    KillProcess() {
        Process, Close, % this._process.ProcessId
    }

    CancelSpotifyAction() {
        if (this._cancelling) {
            return
        }
        this.NotifyAction(this._origAction, "ERROR", "Cancelled")
        this._cancelling := true
        processId := this._process.ProcessId
        OutputDebug, % "Cancelling"
        Process, Close, % this._process.ProcessId
        OutputDebug, % "Close: " ErrorLevel
        Sleep 500
        this.StartProcess()

    }

    StartProcess() {
        line := "python.exe " pythonMain
        this._process := Shell.Exec(line)
        Sleep 100
        WinHide, % "ahk_pid " this._process.ProcessId
        OutputDebug, % this._process.StdOut.ReadLine()
        Sleep 100
        this._cancelling := false
    }

    ReadNextLine() {
        while (true) {
            Sleep 50
            line := this._process.STdOut.ReadLine()
            if (line != ".") {
                return line
            }
        }
    }

    OnAction(func) {
        this._onAction.Push(func)
    }

    NotifyAction(args, result, err:="") {
        for i, v in this._onAction {
            v.Call(args, result, err)
        }
    }

    Exec(cmd) {
        try {
            Random, rnd, 1, 10000000
            if (this._lastAction) {
                OutputDebug, % "Old task hasn't finished."
                Sleep 50
                return
            }
            origCmd := cmd
            this._origAction := origCmd
            this._lastAction := rnd
            cmd := rnd " " cmd
            OutputDebug, % cmd
            this.NotifyAction(origCmd, "RUNNING")
            this._process.StdIn.WriteLine(cmd)
            line := this.ReadNextLine()
            parts := StrSplit(line, " ")
            OutputDebug, % "RESULT " line
            this.NotifyAction(origCmd, parts[3], gStr_Join(gArr_Slice(parts, 4), " "))
            if (parts[1] != this._lastAction) {
                OutputDebug, % "Weird action difference"
            }
        } catch err {
            MsgBox, % err.Message "`nGoing to restart process"
            this.CancelSpotifyAction()
        } finally {
            this._lastAction := ""
        }

    }
}

Spotify := new SpotifyAutomator()
