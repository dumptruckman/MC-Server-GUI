/*
*****************
* MC Server GUI *
*      by       *
*  dumptruckman *
*****************
*/
VersionNumber := ".6.3"

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



/*
****************
* AUTO-EXECUTE *
****************
*/
OnMessage(0x200, "WM_MOUSEMOVE")
SetTimer, MainTimer, 250
SetTimer, NetworkMonitor, 1000
SetTimer, GetCharKeyPress, 100
If (DebugMode()) {
  Debug := Object()
  ;Debug("MainTimer", "250")
  ;Debug("NetworkMonitor(Timer)", "1000")
  ;Debug("GetCharKeyPress(Timer)", "100")
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


;Main Process that runs at %UpdateRate% intervals
MainProcess() {
  Global ServerWindowPID
  Global ConsoleBox
  Global GUIPID
  
  If (ServerIsRunning()) {
    ControlSwitcher("ON")
    
    CommitSize := GetProcessMemory_CommitSize(ServerWindowPID, "M")
    WorkingSet := GetProcessMemory_WorkingSet(ServerWindowPID, "M")
    GuiControl,, ServerMemUse, Memory Usage: %WorkingSet% M / %CommitSize% M
    CPULoad := GetServerProcessTimes(ServerWindowPID)
    GuiControl,, ServerCPUUse, CPU Load: %CPULoad%`%
  }
  else {
    Global ServerState
    
    If (ServerState == "ON") {
      StopServer()
    }
    ControlSwitcher("OFF")
    SetTimer, ServerRunningTimer, Off
    SetTimer, ServerUpTimer, Off
    If (DebugMode()) {
      Debug("ServerRunningTimer", "Off")
      Debug("ServerUpTimer", "Off")
    }
    ;SetTimer, RestartAtScheduler, Off
  }
  WorkingSet := GetProcessMemory_WorkingSet(GUIPID, "M")
  GuiControl,, GUIMemUse, Memory Usage: %WorkingSet% M
  GUICPULoad := GetGUIProcessTimes(GUIPID)
  GuiControl,, GUICPUUse, CPU Load: %GUICPULoad%`%
}