#Requires AutoHotKey >=2.0
#SingleInstance Force
Persistent

Global version := "4.1"

SetNumlockState("AlwaysOn")
SetCapsLockState("AlwaysOff")
SetScrollLockState("AlwaysOff")
;SetTimer(TimerFunction, 60000)
SetupMenu()

; Paste without formatting
^+v::{ ; Ctrl+Shift+v
    A_Clipboard := A_Clipboard ; Convert any copied files, HTML, or other formatted text to plain text
    SendInput("^v")
}

; Disable Left Windows Key
LWin::return

SetupMenu() {
    tray := A_TrayMenu
    tray.delete()
    tray.add()
    tray.add("About", MenuAbout)
    tray.add("Exit", MenuExit)
}

MenuAbout(*) {
    text := "Auto Macros v" . version
    text .= "`n - Paste without formatting. Ctrl+Shift+v"
    text .= "`n - Caps Lock set to always off"
    text .= "`n - Scroll Lock set to always off"
    text .= "`n - Num Lock set to always on"
    text .= "`n - Left Windows Key Disabled"
    text .= "`n - Mouse/Screen move function"
    MsgBox(text, "About")
}

MenuExit(*) {
    ExitApp()
}

TimerFunction() {
    if (A_TimeIdle > 60000) {
        Sleep(Random(1, 60000))
        MouseMove(10, 10, 10, "R")
        MouseMove(-10, -10, 10, "R")
    }   
}
