#Requires AutoHotKey >=2.0
#SingleInstance Force
Persistent
SetKeyDelay(50)

; Globals
global gVersion := "2.1"
global gToggle := false
global gWindowName
global gDelayArray := []
global gEnabledArray := []
global WorkerActive := false

; Defines
global INI_FILE := "MacroQuest.ini"
global DEFAULT_WINDOW_NAME := "Client1"
global DEFAULT_DELAY_STR := "1|1|1|1|1|1|1|1|1|30"
global DEFAULT_ENABLED_STR := "1|1|1|1|1|1|1|1|1|1"


; ---------------- Main ----------------

Load_Btn() ; set defaults

global TheGui := Gui()
TheGui.Opt("+AlwaysOnTop")
TheGui.SetFont(, "Tahoma")
TheGui.Title := "MacroQuest - " gVersion
TheGui.MarginX := 20
TheGui.MarginY := 20

TheGui.Add("Button", "xm y+50 w100 vStartStop", "Start").OnEvent("Click", Script_Btn)
TheGui.Add("Progress", "xm y+5 w100 h20 cBlue vMyProgress")
TheGui.Add("Text", "xm y+15 w110", "Target Window Name")
TheGui.Add("Edit", "xm y+5 w100", gWindowName).OnEvent("Change", (GuiCtrlObj,*)=>(gWindowName := GuiCtrlObj.text))
;TheGui.Add("Button", "xm y+5 w100", "Load").OnEvent("Click", Load_Btn)
TheGui.Add("Button", "xm y+20 w100", "Save").OnEvent("Click", Save_Btn)
TheGui.Add("Button", "xm y+5 w100", "Exit").OnEvent("Click", (*)=> ExitApp())
TheGui.Add("Text", "xm y+15 w120", "Usage: Hot Buttons are pressed in sequential order (1 - 10). Delay in seconds after button press.")

TheGui.Add("Text", "xm+135 ym w50", "Enabled")
TheGui.Add("Text", "xm+190 ym  w25", "Key")
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck1", " Hot Button 1").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[1] := GuiCtrlObj.value))
TheGui["Check1"].value := gEnabledArray[1]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck2", " Hot Button 2").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[2] := GuiCtrlObj.value))
TheGui["Check2"].value := gEnabledArray[2]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck3", " Hot Button 3").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[3] := GuiCtrlObj.value))
TheGui["Check3"].value := gEnabledArray[3]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck4", " Hot Button 4").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[4] := GuiCtrlObj.value))
TheGui["Check4"].value := gEnabledArray[4]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck5", " Hot Button 5").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[5] := GuiCtrlObj.value))
TheGui["Check5"].value := gEnabledArray[5]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck6", " Hot Button 6").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[6] := GuiCtrlObj.value))
TheGui["Check6"].value := gEnabledArray[6]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck7", " Hot Button 7").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[7] := GuiCtrlObj.value))
TheGui["Check7"].value := gEnabledArray[7]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck8", " Hot Button 8").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[8] := GuiCtrlObj.value))
TheGui["Check8"].value := gEnabledArray[8]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck9", " Hot Button 9").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[9] := GuiCtrlObj.value))
TheGui["Check9"].value := gEnabledArray[9]
TheGui.Add("CheckBox", "xm+150 y+15 w100 vCheck0", " Hot Button 0").OnEvent("Click", (GuiCtrlObj,*)=>(gEnabledArray[10] := GuiCtrlObj.value))
TheGui["Check0"].value := gEnabledArray[10]

TheGui.Add("Text", "xm+250 ym w50", "Delay (S)")
TheGui.Add("Edit", "xm+250 y+12 h20 w40", gDelayArray[1]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[1] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[2]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[2] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[3]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[3] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[4]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[4] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[5]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[5] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[6]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[6] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[7]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[7] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[8]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[8] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[9]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[9] := GuiCtrlObj.text))
TheGui.Add("Edit", "xm+250 y+8 h20 w40", gDelayArray[10]).OnEvent("Change", (GuiCtrlObj,*)=>(gDelayArray[10] := GuiCtrlObj.text))

TheGui.Show()

SetTimer(TimerProgressFunction, 100)
SetTimer(TimerWorkerFunction, 1000)

; ---------------- Functions ----------------

Script_Btn(*) {
    global gToggle := !gToggle
    global TheGui

    TheGui["MyProgress"].Value := 0
    if (gToggle) {
        TheGui["StartStop"].Text := "Stop"
    } else {
        TheGui["StartStop"].Text := "Start"
    }
}

Load_Btn(*) {
    global gWindowName
    global gDelayArray
    global gEnabledArray

    gWindowName := IniRead(INI_FILE, "DATA", "Window_Name", DEFAULT_WINDOW_NAME)
    iniStr := IniRead(INI_FILE, "DATA", "Key_Delay", DEFAULT_DELAY_STR)
    gDelayArray := StrSplit(iniStr, "|")
    iniStr := IniRead(INI_FILE, "DATA", "Key_Enabled", DEFAULT_ENABLED_STR)
    gEnabledArray := StrSplit(iniStr, "|")
}

Save_Btn(*) {
    global gWindowName
    global gDelayArray
    global gEnabledArray

    IniWrite(gWindowName, INI_FILE, "DATA", "Window_Name")
    iniStr := ""
    for (element in gDelayArray) {
        iniStr .= ((StrLen(iniStr) != 0) ? "|" : "") element
    }
    IniWrite(iniStr, INI_FILE, "DATA", "Key_Delay")
    iniStr := ""
    for (element in gEnabledArray) {
        iniStr .= ((StrLen(iniStr) != 0) ? "|" : "") element
    }
    IniWrite(iniStr, INI_FILE, "DATA", "Key_Enabled")
}

TimerProgressFunction() {
    global gToggle
    global TheGui

    if (gToggle) {
        if (TheGui["MyProgress"].Value = 100) {
            TheGui["MyProgress"].Value := 0
        } else {
            TheGui["MyProgress"].Value += 1
        }
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
    global gWindowName
    global gDelayArray
    global gEnabledArray
 
    index := 1
    while (gToggle) {
        if (WinExist(gWindowName)) {
            WinActivate()
        } else {
            gToggle := false
            TheGui["MyProgress"].Value := 0
            MsgBox("Window (EverQuest) not found!", "Alert", "0x1000")
            return
        }
        strKey := (index != 10) ? String(index) : "0" 
        if (gEnabledArray[index] = 1) {
            Send(strKey)
            ; Sleep(333)
            ; Send(strKey)
            ; Sleep(333)
            ; Send(strKey)
            Loop (gDelayArray[index]) {
                Sleep(1000)
                if (!gToggle)
                    return
            }
        }
        index := (index >= 10) ? 1 : ++index        
    }
}
