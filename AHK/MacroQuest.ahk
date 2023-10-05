#Requires AutoHotKey >=2.0
#SingleInstance Force
Persistent
SetKeyDelay(50)

; Globals
global gVersion := "3.3"
global gToggle := false
global WorkerActive := false

; Defines
global INI_FILE := "MacroQuest.ini"
global DEFAULT_WINDOW_NAME := "Client1"
global DEFAULT_DELAY_STR := "1|1|1|1|1|1|1|1|1|30"
global DEFAULT_ENABLED_STR := "1|1|1|1|1|1|1|1|1|1"


; ---------------- Main ----------------

global TheGui := Gui()
TheGui.Opt("+AlwaysOnTop -MaximizeBox")
TheGui.SetFont(, "Tahoma")
TheGui.Title := "MacroQuest - " gVersion
TheGui.MarginX := 20
TheGui.MarginY := 20

TheGui.ScriptButton := TheGui.Add("Button", "xm y+50 w100", "Start")
TheGui.ScriptButton.OnEvent("Click", Script_Btn)
TheGui.ProgressCtrl := TheGui.Add("Progress", "xm y+5 w100 h20 cBlue")
TheGui.Add("Text", "xm y+15 w110", "Target Window Name")
TheGui.TargetWindowName := TheGui.Add("Edit", "xm y+5 w100")
TheGui.Add("Button", "xm y+20 w100", "Save").OnEvent("Click", Save_Btn)
TheGui.Add("Button", "xm y+5 w100", "Exit").OnEvent("Click", (*)=> ExitApp())
TheGui.Add("Text", "xm y+15 w120", "Usage: Hot Buttons are pressed in sequential order (1 - 10). Delay in seconds after button press.")

TheGui.Add("Text", "xm+135 ym w50", "Enabled")
TheGui.Add("Text", "xm+190 ym  w25", "Key")
TheGui.CheckBoxArray := Array()
Loop (10) {
    TheGui.CheckBoxArray.Push(TheGui.Add("CheckBox", "xm+150 y+15 w100", " Hot Button " A_Index))
}

TheGui.Add("Text", "xm+250 ym w50", "Delay (S)")
TheGui.EditArray := Array()
TheGui.EditArray.Push(TheGui.Add("Edit", "xm+250 y+12 h20 w40"))
Loop (9) {
    TheGui.EditArray.Push(TheGui.Add("Edit", "xm+250 y+8 h20 w40"))
}

Load_Data() ; set defaults
TheGui.Show()

SetTimer(TimerWorkerFunction, 1000)

; ---------------- Functions ----------------

Script_Btn(*) {
    global gToggle := !gToggle
    global TheGui

    TheGui.ProgressCtrl.Value := 0
    if (gToggle) {
        TheGui.ScriptButton.Text := "Stop"
    } else {
        TheGui.ScriptButton.Text := "Start"
    }
}

Save_Btn(*) {
    global TheGui

    IniWrite(TheGui.TargetWindowName.Value, INI_FILE, "DATA", "Window_Name")
    iniStr := ""
    for (element in TheGui.EditArray) {
        iniStr .= ((StrLen(iniStr) != 0) ? "|" : "") element.Value
    }
    IniWrite(iniStr, INI_FILE, "DATA", "Key_Delay")
    iniStr := ""
    for (element in TheGui.CheckBoxArray) {
        iniStr .= ((StrLen(iniStr) != 0) ? "|" : "") element.Value
    }
    IniWrite(iniStr, INI_FILE, "DATA", "Key_Enabled")
}

Load_Data() {
    global TheGui

    TheGui.TargetWindowName.Value := IniRead(INI_FILE, "DATA", "Window_Name", DEFAULT_WINDOW_NAME)
    iniStr := IniRead(INI_FILE, "DATA", "Key_Delay", DEFAULT_DELAY_STR)
    TempArray := StrSplit(iniStr, "|")
    Loop (10) {
        TheGui.EditArray[A_Index].Value := TempArray[A_Index]
    }
    iniStr := IniRead(INI_FILE, "DATA", "Key_Enabled", DEFAULT_ENABLED_STR)
    TempArray := StrSplit(iniStr, "|")
    Loop (10) {
        TheGui.CheckBoxArray[A_Index].Value := TempArray[A_Index]
    }
}

TimerWorkerFunction() {
    global WorkerActive
 
    if (!WorkerActive) {
        WorkerActive := true
        WorkerFunction()
        WorkerActive := false
    }
}

WorkerFunction() {
    global gToggle
    global TheGui
 
    index := 1
    while (gToggle) {
        if (WinExist(TheGui.TargetWindowName.Value)) {
            WinActivate()
        } else {
            gToggle := false
            MsgBox("Window (EverQuest) not found!", "Alert", "0x1000")
            return
        }
        strKey := (index != 10) ? String(index) : "0" 
        if (TheGui.CheckBoxArray[index].Value = 1) {
            TheGui.CheckBoxArray[index].Opt("+Disabled")
            TheGui.EditArray[index].Opt("+Disabled")
            Send(strKey)
            TheGui.ProgressCtrl.Value := 0
            increment := Float(10 / TheGui.EditArray[index].Value)
            count := Float(0)
            Loop (TheGui.EditArray[index].Value * 10) {
                Sleep (100)
                count += increment
                TheGui.ProgressCtrl.Value := Integer(count)
                if (!gToggle) {
                    break
                }
            }
            TheGui.CheckBoxArray[index].Opt("-Disabled")
            TheGui.EditArray[index].Opt("-Disabled")
        }
        index := (index >= 10) ? 1 : ++index        
    }
    TheGui.ProgressCtrl.Value := 0
    TheGui.ScriptButton.Text := "Start"
}
