#Requires AutoHotKey >=2.0
#SingleInstance Force
Persistent

global VERSION := "5.1"
global MAX_TIMEOUT := (1000 * 60) * 60 ; 60 Minutes
global TIMEOUT := (1000 * 60) * 5 ; 5 Minutes
global gToggle := false
global gInfoMode := false

;global DESKTOP_FILES := EnvGet("OneDrive") . "\Desktop\*.lnk"
;if (FileExist(DESKTOP_FILES)) { FileDelete(DESKTOP_FILES) }

SetNumlockState("AlwaysOn")
SetCapsLockState("AlwaysOff")
SetScrollLockState("AlwaysOff")
SetTimer(TimerFunction, TIMEOUT)
InstallMouseHook()
SetupMenu()

; Paste without formatting
; Convert any copied files, HTML, or other formatted text to plain text
^+v:: { ; Ctrl+Shift+v
    A_Clipboard := A_Clipboard
    SendInput("^v")
}

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
    global VERSION, gToggle
    status := (gToggle) ? "ON" : "OFF"
    text := "Auto Macros v" . VERSION
    text .= "`n - Paste without formatting. Ctrl+Shift+v"
    text .= "`n - Caps Lock set to always off"
    text .= "`n - Scroll Lock set to always off"
    text .= "`n - Num Lock set to always on"
    text .= "`n - Left Windows Key Disabled"
    text .= "`n - Mouse/Screen move function"
    text .= "`n     Ctrl+Shift+s (Status: " . status . ")"
    MsgBox(text, "About")
}

InfoFunction(msg) {
    global gInfoMode, VERSION
    if (gInfoMode) {
        TrayTip("Auto Macros v" . VERSION, msg)
    }
}

TimerFunction() {
    global gToggle, TIMEOUT, MAX_TIMEOUT
    if (gToggle) {
        if (A_TimeIdlePhysical > MAX_TIMEOUT) {
            InfoFunction("Sleep timeout reached.")
            return
        }
        if (A_TimeIdlePhysical > TIMEOUT) {
            InfoFunction("Moving mouse to prevent sleep.")
            Sleep(Random(10, 1000))
            MouseMove(10, 10, 10, "R")
            Sleep(100)
            MouseMove(-10, -10, 10, "R")
        }
    }
}
