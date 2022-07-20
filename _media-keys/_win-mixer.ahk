_GetAppVolumeControl(PID) {
    ; Just sleep for 100 to calm the script down

    IMMDeviceEnumerator := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
    DllCall(NumGet(NumGet(IMMDeviceEnumerator+0)+4*A_PtrSize), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 1, "UPtrP", IMMDevice, "UInt")
    ObjRelease(IMMDeviceEnumerator)

    VarSetCapacity(GUID, 16)
    DllCall("Ole32.dll\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "UPtr", &GUID)
    DllCall(NumGet(NumGet(IMMDevice+0)+3*A_PtrSize), "UPtr", IMMDevice, "UPtr", &GUID, "UInt", 23, "UPtr", 0, "UPtrP", IAudioSessionManager2, "UInt")
    ObjRelease(IMMDevice)

    DllCall(NumGet(NumGet(IAudioSessionManager2+0)+5*A_PtrSize), "UPtr", IAudioSessionManager2, "UPtrP", IAudioSessionEnumerator, "UInt")
    ObjRelease(IAudioSessionManager2)

    DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+3*A_PtrSize), "UPtr", IAudioSessionEnumerator, "UIntP", SessionCount, "UInt")
    Loop % SessionCount
    {
        DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+4*A_PtrSize), "UPtr", IAudioSessionEnumerator, "Int", A_Index-1, "UPtrP", IAudioSessionControl, "UInt")
        IAudioSessionControl2 := ComObjQuery(IAudioSessionControl, "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}")
        ObjRelease(IAudioSessionControl)

        DllCall(NumGet(NumGet(IAudioSessionControl2+0)+14*A_PtrSize), "UPtr", IAudioSessionControl2, "UIntP", ProcessId, "UInt")
        If (PID == ProcessId)
        {
            ISimpleAudioVolume := ComObjQuery(IAudioSessionControl2, "{87CE5498-68D6-44E5-9215-6DA47EF883D8}")
            invoker:= gSys_ComVTableInvoker(ISimpleAudioVolume, [IAudioSessionControl2, IAudioSessionEnumerator])
            return new VolumeController(invoker)
        }
    }
    Return new VolumeController("")
}

class VolumeController extends gMemberCheckingProxy {
    _invoker := ""
    __New(invoker) {
        this._invoker := invoker
    }

    IsValid[] {
        get {
            return !!this._invoker
        }
    }

    AssertHasSound() {
        if (!this._invoker) {
            gEx_Throw("No internal volume controller.")
        }
    }

    GetVolume() {
        this.AssertHasSound()
        MyVolume:=""
        VarSetCapacity(MyVolume, 4)
        this._invoker.VtableCall(4, "Ptr", &MyVolume, "UInt")
        MyVolume:=NumGet(MyVolume, "Float")
        return Round(MyVolume * 100)
    }

    SetVolume(NewVolume) {
        this.AssertHasSound()
        NewVolume := NewVolume > 100 ? 100 : NewVolume
        this._invoker.VtableCall(3, "Float", NewVolume / 100, "UPtr", 0, "UInt")
    }

    GetMute() {
        this.AssertHasSound()
        MyMute:= ""
        VarSetCapacity(MyMute, 4)
        this._invoker.VtableCall(6, "Ptr", &MyMute, "UInt")
        return NumGet(MyMute)
    }

    SetMute(mute) {
        this.AssertHasSound()
        this._invoker.VtableCall(5, "Int", Mute ? 1 : 0, "UInt")
    }

    Dispose() {
        this._invoker.Dispose()
    }
}

ModAppVolume(hwnd, mod) {
    WinGet, LastPid, PID, ahk_id %hwnd%
    VolumeControl := _GetAppVolumeControl(LastPid) 
    if (!VolumeControl.IsValid) {
        _NotifyModifiedVolume("", hwnd)
        return
    } 
    VolumeControl.SetMute(0)
    curVol := VolumeControl.GetVolume()
    VolumeControl.SetVolume(curVol + mod)
    newVol := VolumeControl.GetVolume()
    _NotifyModifiedVolume(newVol, hwnd)
    VolumeControl.Dispose()
    Sleep 50
}

MuteApp(hwnd) {
    WinGet, LastPid, PID, ahk_id %hwnd%
    VolumeControl := _GetAppVolumeControl(LastPid)
    if (!VolumeControl.IsValid) {
        _NotifyModifiedVolume("", hwnd)
        return
    }
    curMute := VolumeControl.GetMute()
    VolumeControl.SetMute(!curMute)
    volNotify := curMute ? VolumeControl.GetVolume() : -10
    _NotifyModifiedVolume(volNotify, hwnd)
    VolumeControl.Dispose()
    Sleep 50 
}

_GetTipIcon(vol) {
    if (vol = ""9) {
        return 3
    }
    return 1
}

_GetPercentDisplay(vol) {
    if (vol = "") {
        return ""
    }
    if (vol < 0) {
        return " ✖"
    }
    else {
        vol := vol "%"
    }
    return gStr_PadLeft(vol, 4, " ")
}

_GetSpeakerIcon(vol) {
    if (vol = "") {
        return "🔇"
    }
    return "🔊"

}

_GetProgress(what) {
    progress:="" 
    Loop, 10 {
        progress := progress (A_Index * 10 <= what ? "⬛" : "⬜")
    }
    Return _GetSpeakerIcon(what) progress 
}

_ShowTT(TT, time) {
    TT.Show()
    Sleep, % time
    TT.Hide()
    Return
}

_HideSoundTT() {
    _mediaTT.Hide()
}
global LastIcon := ""
_NotifyModifiedVolume(vol, hwnd) {
    if (gWin_IsFullScreen(hwnd)) {
        return
    } 
    WinGetTitle, which, ahk_id %hwnd%
    progress:=_GetProgress(vol)
    Percent:=_GetPercentDisplay(vol)
    Icon:=_GetTipIcon(vol)
    _mediaTT.Color("White", "Gray")

    _mediaTT.Title(which, Icon)
    _mediaTT.Text(progress Percent)

    _mediaTT.Show(, A_ScreenWidth - 200, A_ScreenHeight - 200)
    SetTimer, _HideSoundTT, Off
    SetTimer, _HideSoundTT, 500
}