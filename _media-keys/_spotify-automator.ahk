global pythonMain := A_ScriptDir "\_media-keys\python\main.pyw"
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
        SetTitleMatchMode, 2
        ; This is a fix for Windows 11 terminal replacement
        ; In this case, the WT window is not connected directly to the created process.
        WinWaitActive, python.exe ahk_exe WindowsTerminal.exe
        if (ErrorLevel == 0) {
            WinHide
        } else {
            ; Expecting an normal CMD window instead
            OutputDebug, % "Opened process " this._process.ProcessId
            WinHide, % "ahk_pid " this._process.ProcessId
        }
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
        if (this._lastAction) {
            OutputDebug, % "Old task hasn't finished."
            Sleep 50
            return
        }
        try {
            Random, rnd, 1, 10000000
            this._origAction := origCmd
            this._lastAction := rnd
            origCmd := cmd
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
