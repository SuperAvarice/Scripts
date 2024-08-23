#Requires AutoHotKey >=2.0
#SingleInstance Force
Persistent

global version := "4.2"
global toggle := false

SetNumlockState("AlwaysOn")
SetCapsLockState("AlwaysOff")
SetScrollLockState("AlwaysOff")
SetTimer(TimerFunction, 60000)
SetupMenu()

; Paste without formatting
; ^+v::{ ; Ctrl+Shift+v
;     A_Clipboard := A_Clipboard ; Convert any copied files, HTML, or other formatted text to plain text
;     SendInput("^v")
; }

; Move function toggle
^+s::{ ; Ctrl+Shift+s
    global toggle := !toggle
}

; Disable Left Windows Key
LWin::return

SetupMenu() {
    tray := A_TrayMenu
    tray.delete()
    tray.add()
    tray.add("About", MenuAbout)
    tray.add("Exit", (*) => ExitApp())
}

MenuAbout(*) {
    status := (toggle) ? "ON" : "OFF"
    text := "Auto Macros v" . version
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
    if (A_TimeIdle > 60000 && toggle) {
        Sleep(Random(1, 60000))
        MouseMove(10, 10, 10, "R")
        MouseMove(-10, -10, 10, "R")
    }
}
