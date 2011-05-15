/*
*****************
* MC Server GUI *
*      by       *
*  dumptruckman *
*****************
*/
VersionNumber := ".6.10"

;Include Libraries
#Include lib\RichEdit.ahk

;Initialize Internal Global Variables
ServerWindowPID = 0
ServerWindowID = 0
Process, Exist
GUIPID := ErrorLevel
InitializeVariables()

;Initialize AHK Config
DetectHiddenWindows, On

;Initialize GUI Config Globals
GUIPATH = %A_WorkingDir%
FloatingPointPrecision = .1
;Prepare initial netstat data
netstatFile := GUIPATH . "\guinetwork.dat"
SetFormat, FloatFast, %FloatingPointPrecision%
RunWait %comspec% /c ""Netstat" "-e" >"%netstatFile%"",, Hide
FileReadLine, BytesData, % netstatFile, 5
StringReplace, BytesData, BytesData, Bytes,
BytesData = %BytesData%
LastBytesDataRx := SubStr(BytesData, 1, InStr(BytesData, " "))
LastBytesDataTx := SubStr(BytesData, InStr(BytesData, " "))
LastBytesDataTx = %LastBytesDataTx%
InitializeConfig()                                  ;Initialize guiconfig.ini
ServerProperties := ReadServerProps()               ;Grab data from server.properties



;Load GUI and Menu Source
#Include source\gui.ahk
#Include source\menus.ahk
If (DebugMode) {
  #Include source\debug.ahk
}


;SHOW DAS GUI
;Gui, +Resize +MinSize
Gui, Show, Restore, %WindowTitle%
Menu, Tray, NoIcon


/*
****************
* AUTO-EXECUTE *
****************
*/
OnMessage(0x200, "WM_MOUSEMOVE")
SetTimer, MainTimer, 250
SetTimer, NetworkMonitor, 1000
SetTimer, GetCharKeyPress, 100
OnExit, GuiClose
Hotkey, IfWinActive, ahk_pid %GUIPID%
If (DebugMode()) {
  Debug := Object()
}

If ((MCServerJar = "Set this") or (MCServerJar = "")) {
  ServerJar := AutoDetectServerJar()
  If (ServerJar) {
    MCServerJar := ServerJar
    SplitPath, MCServerJar, MCServerJar, MCServerPath
    SetConfigKey("Folders", "ServerPath", MCServerPath)
    SetConfigKey("ServerArguments", "ServerJarFile", MCServerJar)
    AddText("[GUI] Autodetected " . MCServerJar . " as your Minecraft server jar file.  Please make corrections in Server Config if this is wrong.")
  }
  else {
    AddText("[GUI] Could not locate a server jar file.  Please set this manually under Server Config.")
  }
}

If (ServerStartOnStartup) {
  StartServer()
}

return



;Load Remaining Source
#Include source\timers.ahk
#Include source\guicontrol.ahk
#Include source\datahandling.ahk
#Include source\serverprocesses.ahk
#Include source\automation.ahk
#Include source\conversion.ahk
#Include source\cpumem.ahk


MainProcess() {
  Global ServerWindowPID
  Global ConsoleBox
  Global GUIPID
  
  If (ServerIsRunning()) {
    Global IsAutomated
    Global ServerStarted
    
    ControlSwitcher("ON")

    ;SetTimer, ServerRunningTimer, On
    CheckForLogChanges()

    CommitSize := GetProcessMemory_CommitSize(ServerWindowPID, "M")
    WorkingSet := GetProcessMemory_WorkingSet(ServerWindowPID, "M")
    GuiControl,, ServerMemUse, Memory Usage: %WorkingSet% M / %CommitSize% M
    CPULoad := GetServerProcessTimes(ServerWindowPID)
    GuiControl,, ServerCPUUse, CPU Load: %CPULoad%`%
    
    If ((CheckForRestarts()) and (!IsAutomated)) {
      Global WhatTerminated
      WhatTerminated := "AUTO"
      InitiateAutomaticRestart()
    }

    ;IfWinActive, ahk_pid %GUIPID%
    ;{
      GuiThreadInfoSize = 48
      VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
      NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
      if not DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo) {
          return
      }
      FocusedHWND := NumGet(GuiThreadInfo, 12)  ; Retrieve the hwndFocus field from the struct.
      Global ConsoleBox
      If (FocusedHWND != ConsoleBox) {
        RichEdit_GetSel(ConsoleBox, selMin, selMax)
        If ((selMax - selMin) = 0) {
          EoT := RichEdit_GetTextLength(ConsoleBox)
          RichEdit_SetSel(ConsoleBox, EoT)
          RichEdit_LineScroll(ConsoleBox,,2)
        }
      }
    ;}
  }
  else {
    Global ServerState
    
    If (ServerState == "ON" AND ServerStarted) {
      StopServer()
    }
    ControlSwitcher("OFF")
    ;SetTimer, ServerRunningTimer, Off
    ;SetTimer, ServerUpTimer, Off
  }
  WorkingSet := GetProcessMemory_WorkingSet(GUIPID, "M")
  GuiControl,, GUIMemUse, Memory Usage: %WorkingSet% M
  GUICPULoad := GetGUIProcessTimes(GUIPID)
  GuiControl,, GUICPUUse, CPU Load: %GUICPULoad%`%
}