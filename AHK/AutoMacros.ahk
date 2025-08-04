#Requires AutoHotKey >=2.0
#SingleInstance Force
Persistent

; Defines
global VERSION := "5.1"
global MAX_COUNTS := 5 ; 30
global TIMEOUT := 10000 ; 60000
;global DESKTOP_FILES := EnvGet("OneDrive") . "\Desktop\*.lnk"

; Globals
global gToggle := false
global gCount := 0

SetNumlockState("AlwaysOn")
SetCapsLockState("AlwaysOff")
SetScrollLockState("AlwaysOff")
SetTimer(TimerFunction, TIMEOUT)
SetupMenu()

; Paste without formatting
; Convert any copied files, HTML, or other formatted text to plain text
; ^+v:: { ; Ctrl+Shift+v
;     A_Clipboard := A_Clipboard
;     SendInput("^v")
; }

; Move function toggle
^+s:: { ; Ctrl+Shift+s
    global gToggle := !gToggle
}

; Disable Left Windows Key
LWin:: return

SetupMenu() {
    tray := A_TrayMenu
    tray.delete()
    tray.add()
    tray.add("About", MenuAbout)
    tray.add("Exit", (*) => ExitApp())
}

MenuAbout(*) {
    status := (gToggle) ? "ON" : "OFF"
    text := "Auto Macros v" . VERSION
    ; text .= "`n - Paste without formatting. Ctrl+Shift+v"
    text .= "`n - Caps Lock set to always off"
    text .= "`n - Scroll Lock set to always off"
    text .= "`n - Num Lock set to always on"
    text .= "`n - Left Windows Key Disabled"
    text .= "`n - Mouse/Screen move function"
    text .= "`n     Ctrl+Shift+s (Status: " . status . ")"
    MsgBox(text, "About")
}

TimerFunction() {
    global
    if (gToggle) {
        inactive := (A_TimeIdle > TIMEOUT)
        overcount := (gCount > MAX_COUNTS)
        if (inactive) {
            if (!overcount) {
                TrayTip("Auto Macros v" . VERSION, "Pre-Sleep: " . gCount)
                Sleep(Random(1, TIMEOUT))
                MouseMove(10, 10, 10, "R")
                MouseMove(-10, -10, 10, "R")
                gCount++
                return
            }
            TrayTip("Auto Macros v" . VERSION, "Sleep Mode")
            return
        }
        if (gCount > 1) {
            TrayTip("Auto Macros v" . VERSION, "Limbo")
            return
        }
    }
    gCount := 0
    TrayTip("Auto Macros v" . VERSION, "OFF")

    ; if (FileExist(DESKTOP_FILES)) {
    ;     FileDelete(DESKTOP_FILES)
    ; }
}
