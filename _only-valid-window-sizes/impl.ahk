
OVWS_SizeRule(target) {
    if (target.w + target.h < 800) {
        return "TotalTooSmall"
    }
    if (target.h < 400) {
        return "HeightTooLow"
    }
    if (target.w < 500) {
        return "WidthTooLow"
    }
    return ""
}

OVWS_FixSize(target) {
    rule := OVWS_SizeRule(target)
    if (rule != "") {
        target.rules.Push(rule)
        target.w := target.w > 900 ? target.w : 900
        target.h := target.h > 500 ? target.h : 500
    }
}

OVWS_Action(w) {
    if (!w) {
        return
    }
    WinGetPos, X, Y, Width, Height, ahk_id %w%
    target:= {y: y, x: x, h: height, w: width, rules: []}
    if (GetKeyState("LButton", "P")) {
        return
    }
    if (Y < -15) {
        target.y := 0
        target.rules.Push("TopOutOfBounds")
    }
    OVWS_FixSize(target)
    if (target.rules.MaxIndex() > 0) {
        rulesBroken:=gStr_Join(target.rules, ", ")
        OutputDebug, [WeirdWindowFixer] Found %w% being naughty. BROKE RULES: %rulesBroken%
        WinMove, ahk_id %w%, , % target.x, % target.y, % target.w, % target.h
    }
}

OVWS_Check() {
    last:=WinExist("A")
    OVWS_Action(last)
    SetTimer, OVWS_Check, -250
}

OVWS_Start() {
    SetTimer, OVWS_Check, -1000
    Loaded("OnlyValidWindowSizes")
}

