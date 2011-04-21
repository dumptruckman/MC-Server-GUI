;Include RichEdit lib
#Include RichEdit.ahk

;Initialize Internal Global Variables
ServerWindowPID = 0
ServerWindowID = 0
InitializeVariables()

;Initialize AHK Config
DetectHiddenWindows, On

;Initialize GUI Config Globals
GUIPATH = %A_WorkingDir%
InitializeConfig()
ServerProperties := ReadServerProps()




;Pre GUI Phase




/*
*************
* GUI SETUP *
*************
*/
Gui, Add, Tab2, Buttons gGUIUpdate vThisTab, Main Window||Server Config|GUI Config

;Version information
Gui, Add, Text, xp+835 yp, Version .5.0-Alpha


;FIRST TAB - Main Window
Gui, Tab, Main Window

;Picture control contains RichEdit control for the "Console Box"
Gui, Add, Picture, x10 y30 w700 h275 HwndREparent1
ConsoleBox := RichEdit_Add(REParent1, 0, 0, 700, 275, "READONLY VSCROLL MULTILINE")
RichEdit_SetBgColor(ConsoleBox, "0x" . BGColor)

Gui, Add, TreeView, x715 y30 r17 w200 AltSubmit -Buttons -Lines
LV_ModifyCol(1, 125)
LV_ModifyCol(2, 60)

;Console input field + button
Gui, Add, GroupBox, x10 y305 w700, Console Input
Gui, Add, Edit, xp+10 yp+20 w620 vConsoleInput
Gui, Add, Button, xp+630 yp-2 Default gSubmit vSubmit, Submit
GuiControl, Disable, Submit

;Server Control buttons
Gui, Add, Button, x10 gStartServer vStartServer, Start Server
Gui, Add, Button, yp xp+75 gSaveWorlds vSaveWorlds, Save Worlds
Gui, Add, Button, yp xp+80 gWarnRestart vWarnRestart, Warn Restart
Gui, Add, Button, yp xp+82 gImmediateRestart vImmediateRestart, Immediate Restart
Gui, Add, Button, yp xp+105 gStopServer vStopServer, Stop Server
Gui, Add, Button, yp xp+120 vJavaToggle gJavaToggle, Show Java Console
GuiControl, Disable, JavaToggle ;Disable toggle at startup
GuiControl, Disable, SaveWorlds
GuiControl, Disable, WarnRestart
GuiControl, Disable, ImmediateRestart
GuiControl, Disable, StopServer

;Main Window backup control
Gui, Add, CheckBox, x10 yp+30 vWorldBackupsMainWindow gWorldBackupsMainWindow, World Backups
GuiControl,, WorldBackupsMainWindow, %WorldBackups%

;Memory counter text control
Gui, Add, Text, yp xp+120 w300 vServerMemUse, Memory Usage: NA
Gui, Add, Text, yp xp+500 w100 vServerStatus cRed Bold, Not Running


;SECOND TAB - SERVER CONFIG
Gui, Tab, Server Config

;Java Arguments box
Gui, Add, GroupBox, x10 y30 w300 h230, Server Arguments
;Server Jar File Location field
Gui, Add, Text, x20 y53, Server Jar File: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap -multi r1 vMCServerJar, %MCServerJar%
Gui, Add, Button, xp+150 yp-2 gMCServerJarBrowse, Browse
;Xmx memory field
Gui, Add, Text, x20 yp+30, Xmx Memory: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap -multi vServerXmx, %ServerXmx%
;Xms memory field
Gui, Add, Text, x20 yp+30, Xms Memory: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap -multi vServerXms, %ServerXms%
;Checkboxes for various arguments
Gui, Add, CheckBox, x20 yp+25 vUseConcMarkSweepGC, -XX:+UseConcMarkSweepGC
GuiControl,, UseConcMarkSweepGC, %UseConcMarkSweepGC%
Gui, Add, CheckBox, x20 yp+18 vUseParNewGC, -XX:+UseParNewGC
GuiControl,, UseParNewGC, %UseParNewGC%
Gui, Add, CheckBox, x20 yp+18 vCMSIncrementalPacing, -XX:+CMSIncrementalPacing
GuiControl,, CMSIncrementalPacing, %CMSIncrementalPacing%
Gui, Add, CheckBox, x20 yp+18 vAggressiveOpts, -XX:+AggressiveOpts
GuiControl,, AggressiveOpts, %AggressiveOpts%
;ParallelGCThreads field
Gui, Add, Text, x20 yp+20, ParallelGCThreads:
Gui, Add, Edit, xp+91 yp-3 w30 number -wrap -multi vParallelGCThreads, %ParallelGCThreads%
;Field for extra arguments
Gui, Add, Text, x20 yp+27, Extra Arguments:
Gui, Add, Edit, xp+91 yp-3 w190 -wrap -multi vExtraRunArguments, %ExtraRunArguments%

;Info
Gui, Add, Text, x20 yp+170 cRed, Once changes are complete, simply click on another tab to save.

;Server.properties edit box
Gui, Add, Text, x322 y30, Edit server.properties here: (Server must not be running) 
Gui, Add, Edit, x322 yp+20 w300 r20 -wrap vServerProperties, %ServerProperties%


;THIRD TAB - GUI CONFIG
Gui, Tab, GUI Config

;Box for file/folder information controls
Gui, Add, GroupBox, x10 y30 w300 h140, Folders/Executable
;MC Server Path field
Gui, Add, Text, x20 y53, MC Server Path: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap -multi r1 vMCServerPath, %MCServerPath%
Gui, Add, Button, xp+150 yp-2 gMCServerPathBrowse, Browse
;MC Backup Path field
Gui, Add, Text, x20 yp+30, MC Backup Path: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap -multi r1 vMCBackupPath, %MCBackupPath%
Gui, Add, Button, xp+150 yp-2 gMCBackupPathBrowse, Browse
;Java Executable field
Gui, Add, Text, x20 yp+30, Java Executable: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap -multi r1 vJavaExec, %JavaExec%
Gui, Add, Button, xp+150 yp-2 gJavaExecutableBrowse, Browse

;Title of GUI's window
Gui, Add, Text, x20 yp+80, GUI Window Title:
Gui, Add, Edit, xp+90 yp-3 w195 vWindowTitle, %WindowTitle%

;Box for rate at which GUI updates the console readout of the server
Gui, Add, Text, x20 yp+27, Update Rate: 
Gui, Add, Edit, xp+70 yp-3 w215 number vUpdateRate, %UpdateRate%
Gui, Add, Text, x20 yp+22, (How often the console window is refreshed in miliseconds)

;Info
Gui, Add, Text, x20 yp+171 cRed, Once changes are complete, simply click on another tab to save.

;Backup information controls
Gui, Add, GroupBox, x312 y30 w300 h335, Backups
;Checkboxes for whether or not to backup worlds/log
Gui, Add, CheckBox, x322 y53 vWorldBackups, Run World Backups
GuiControl,, WorldBackups, %WorldBackups%
Gui, Add, CheckBox, x322 yp+20 vLogBackups, Run Log Backups (Highly Recommended)
GuiControl,, LogBackups, %LogBackups%
;Names of world field
Gui, Add, Text, x322 yp+20, Enter names of worlds below:`n  (separate each one with a comma and NO spaces)
Gui, Add, Edit, x322 yp+35 w280 -multi vWorldList, %WorldList%
;Restart times field
Gui, Add, Text, x322 yp+30, Enter the time at which you would like to run automated`n restarts in HH:MM:SS (24-hour) format.  Separate each `n time by commas with NO spaces: (Leave blank for none)
Gui, Add, Edit, x322 yp+45 w280 -multi vRestartTimes, %RestartTimes%
;Restart warning periods field
Gui, Add, Text, x322 yp+30, Enter the times, at which automated restarts will warn the`n the server, in Seconds.  List them in descending order,`n separated by commas with NO Spaces:
Gui, Add, Edit, x322 yp+45 w280 -multi vWarningTimes, %WarningTimes%
;Field for amount of time to add to the warning period to tell players to reconnect
Gui, Add, Text, x322 yp+30, Amount of time to tell players to wait to reconnect:`n (This will be added to the current warning's time)`n (In seconds)
Gui, Add, Edit, xp+235 yp-3 w30 number -multi vTimeToReconnect, %TimeToReconnect%

;Style customization controls
Gui, Add, GroupBox, x614 y30 w300 h200, Style Controls
Gui, Add, Text, x624 y53, All colors must be in RRGGBB format
Gui, Add, Text, x624 yp+20, Console Background Color:
Gui, Add, Edit, xp+130 yp-3 vBGColor, %BGColor%
Gui, Add, Text, x624 yp+25, Console Font:
Gui, Add, Edit, xp+67 yp-3 w150 vFontFace, %FontFace%
Gui, Add, Text, x624 yp+25, Console Font Color:
Gui, Add, Edit, xp+94 yp-3 vFontColor, %FontColor%
Gui, Add, Text, x624 yp+25, Console Font Size:
Gui, Add, Edit, xp+90 yp-3 w30 vFontSize, %FontSize%
Gui, Add, Text, x624 yp+25, [INFO] Color:
Gui, Add, Edit, xp+63 yp-3 vINFOColor, % TagColors["INFO"]
Gui, Add, Text, x624 yp+25, [WARNING] Color:
Gui, Add, Edit, xp+90 yp-3 vWARNINGColor, % TagColors["WARNING"]
Gui, Add, Text, x624 yp+25, [SEVERE] Color:
Gui, Add, Edit, xp+80 yp-3 vSEVEREColor, % TagColors["SEVERE"]

;SHOW DAS GUI
Gui, Show, Restore, %WindowTitle%



/*
**************
* MAIN PHASE *
**************
*/
SetTimer, MainTimer, 250
SetTimer, RestartScheduler, 1000
return



/*
**********
* TIMERS *
**********
*/
MainTimer:
  MainProcess()
return


ServerRunningTimer:
  ProcessLog()
return


RestartScheduler:
  If (CheckForRestarts())
  {
    InitiateAutomaticRestart()
  }
return


ServerStopTimer:
  If (!ServerIsRunning())
  {
    PlayerList.Remove(PlayerList.MinIndex(), PlayerList.MaxIndex())
    TV_Delete()
    SetTimer, ServerStopTimer, Off
    SetTimer, ServerRunningTimer, Off
    ServerWindowPID = 0
    ServerWindowID = 0
    GuiControl, Disable, JavaToggle
    GuiControl, , JavaToggle, Show Java Console
    GuiControl, Enable, ServerProperties
    GuiControl, Enable, StartServer
    GuiControl, Disable, SaveWorlds
    GuiControl, Disable, WarnRestart
    GuiControl, Disable, ImmediateRestart
    GuiControl, Disable, StopServer
    GuiControl, Disable, Submit
    GuiControl,, ServerStatus, Not Running
    Backup()
  }
  StopTimeout := StopTimeout + 1
  If (StopTimeout = 60)
  {
    Process, Close, ServerWindowPID
  }
return


WaitForRestartTimer:
  If (!ServerIsRunning())
  {
    If (!IsBackingUp)
    {
      SetTimer, WaitForRestartTimer, Off
      StartServer()
    }
  }
return


AutomaticRestartTimer:
  If ((WarningTimesIndex > WarningTimesArray.MaxIndex()) or (WarningTimesArray[WarningTimesIndex] = ""))
  {
    If (RestartCountDown = 0)
    {
      AutomaticRestart()
      SetTimer, AutomaticRestartTimer, Off
      return
    }
  }
  else
  {
    If (WarningTimesArray[WarningTimesIndex] = RestartCountDown)
    {
      WarningTimesIndex := WarningTimesIndex + 1
      SendServer("say Automatic restart in " . RestartCountDown . " seconds.  Please reconnect in approximately " . (RestartCountDown + TimeToReconnect) . " seconds.")
    }
  }
  RestartCountDown := RestartCountDown - 1
return



/*
*************
* FUNCTIONS *
*************
*/
;Main Process that runs at %UpdateRate% intervals
MainProcess()
{
  Global ServerWindowPID
  Global ConsoleBox
  
  If (ServerIsRunning())
  {
    Gui, Font, cGreen Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, Running
    
    PeakWorkingSet := GetProcessMemory_PeakWorkingSet(ServerWindowPID, "M")
    WorkingSet := GetProcessMemory_WorkingSet(ServerWindowPID, "M")
    GuiControl,, ServerMemUse, Memory Usage: %WorkingSet% M / %PeakWorkingSet% M
  }
  else
  {
    GuiControl,, ServerMemUse, Memory Usage: NA
    Gui, Font, cRed Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, Not Running
    SetTimer, ServerRunningTimer, Off
  }
}


ProcessLog()
{
  Global MCServerPath
  
  TempDir = %A_WorkingDir%
  SetWorkingDir, %MCServerPath%
  
  ;Reads the log file size and compares it to the last checked size... (Detects log changes and updates GUI)
  FileGetSize, NewLogSize, server.log
  FileGetVersion, trash, server.log       ;This is necessary to "refresh" the log file
  
  if (NewLogSize != LastLogSize)          ;Changes found
  {
    GetLog()                        
    LastLogSize := NewLogSize             ;Updates last checked filesize
  }
  
  SetWorkingDir, %TempDir%
}


;Resets Variables to initial values
InitializeVariables()
{
  Global LogSize
  Global FileLine
  Global LogFilePointer
  Global PlayerList
  
  FileGetSize, LogSize, server.log
  FileLine = 1
  LogFilePointer = 0
  
  If (!IsObject(PlayerList))
  {
    PlayerList := Object()
  }
}


;Retrieves values from guiconfig.ini data or creates defaults if missing
InitializeConfig()
{
  global
  
  MCServerPath := GetConfigKey("Folders", "ServerPath", GUIPATH)
  MCBackupPath := GetConfigKey("Folders", "BackupPath", GUIPATH . "\backup")
  JavaExec := GetConfigKey("Exec", "JavaExec", "java.exe")
  MCServerJar := GetConfigKey("ServerArguments", "ServerJarFile", "Set this")
  ServerXmx := GetConfigKey("ServerArguments", "Xmx", "1024M")
  ServerXms := GetConfigKey("ServerArguments", "Xms", "1024M")
  UseConcMarkSweepGC := GetConfigKey("ServerArguments", "UseConcMarkSweepGC", "0")
  UseParNewGC := GetConfigKey("ServerArguments", "UseParNewGC", "0")
  CMSIncrementalPacing := GetConfigKey("ServerArguments", "CMSIncrementalPacing", "0")
  AggressiveOpts := GetConfigKey("ServerArguments", "AggressiveOpts", "0")
  ParallelGCThreads := GetConfigKey("ServerArguments", "ParallelGCThreads", "")
  ExtraRunArguments := GetConfigKey("ServerArguments", "Extra", "")
  WindowTitle := GetConfigKey("Names", "GUIWindowTitle", "MC Server GUI")
  UpdateRate := GetConfigKey("Timing", "UpdateRate", "250")
  RestartTimes := GetConfigKey("Timing", "RestartTimes", "")
  WarningTimes := GetConfigKey("Timing", "WarningTimes", "30,15,5")
  TimeToReconnect := GetConfigKey("Timing", "TimeToReconnect", "30")
  WorldBackups := GetConfigKey("Backups", "RunWorldBackups", "1")
  LogBackups := GetConfigKey("Backups", "RunLogBackups", "1")
  WorldList := ReadWorlds()
  If (WorldList = "ERROR")
  {
    WriteWorlds("world")
    WorldList := "world"
  }
  BGColor := GetConfigKey("Colors", "BGColor", "999999")
  Tag := Array("INFO", "WARNING", "SEVERE")
  TagColors := Object("INFO", "", "WARNING", "", "SEVERE", "")
  TagColors["INFO"] := GetConfigKey("Colors", "INFO", "FFFF66")
  TagColors["WARNING"] := GetConfigKey("Colors", "WARNING", "FF9933")
  TagColors["SEVERE"] := GetConfigKey("Colors", "SEVERE", "FF0000")
  FontColor := GetConfigKey("Font", "Color", "000000")
  FontSize := GetConfigKey("Font", "Size", "10")
  FontFace := GetConfigKey("Font", "Face", "Roman")
}


;Retrieves a key from the config file, if it doesn't exist, it sets it to Default
GetConfigKey(Category, Key, Default = "")
{
  Global GUIPATH
  
  Temp = %A_WorkingDir%
  SetWorkingDir, %GUIPATH%
  
  IniRead, RetrievedKey, guiconfig.ini, %Category%, %Key%
  if (RetrievedKey = "ERROR")
  {
    SetConfigKey(Category, Key, Default)
    RetrievedKey := Default
  }
  
  SetWorkingDir, %TEMP%
  return RetrievedKey
}


;Sets a key in the config file to Value
SetConfigKey(Category, Key, Value)
{
  Global GUIPATH
  
  Temp = %A_WorkingDir%
  SetWorkingDir, %GUIPATH%
  IniWrite, %Value%, guiconfig.ini, %Category%, %Key%
  SetWorkingDir, %TEMP%
}


ReadWorlds()        ;Returns all worlds in the config, one per line
{
  Global GUIPATH
  Worlds := ""
  
  loop
  {
    WorldIndex := "World" . A_Index
    IniRead, WorldName, %GUIPATH%\guiconfig.ini, Worlds, %WorldIndex%
    If (WorldName = "ERROR")
    {
      If (A_Index = 1)
      {
        return "ERROR"
      }
      break
    }
    Worlds := Worlds . WorldName . ","
  }
  Return Worlds
}


WriteWorlds(Worlds)
{
  Global GUIPATH
  
  Loop, Parse, Worlds, `,
  {
    If (A_LoopField != "")
    {
      WorldIndex := "World" . A_Index
      IniWrite, %A_LoopField%, %GUIPATH%\guiconfig.ini, Worlds, %WorldIndex%
    }
  }
}


ReadServerProps()
{
  Global MCServerPath
  
  FileRead, ReadInto, %MCServerPath%\server.properties
  if (ErrorLevel)
  {
    return ""
  }
  return ReadInto
}


WriteServerProps(ByRef ServerProperties)
{
  Global MCServerPath

  FileDelete, %MCServerPath%\server.properties
  FileAppend, %ServerProperties%, %MCServerPath%\server.properties
}


CSVtoArray(ByRef ToProcess)
{
  Index = 1
  TempArray := Object()
  Loop, Parse, ToProcess, `,
  {
    Test := TempArray.Insert(A_LoopField)
    If (!Test)
      MsgBox, Fail
    Index := Index + 1
  }
  return TempArray
}


BuildRunLine()
{
  Global JavaExec
  Global MCServerJar
  Global ServerXmx
  Global ServerXms
  Global UseConcMarkSweepGC
  Global UseParNewGC
  Global CMSIncrementalPacing
  Global AggressiveOpts
  Global ParallelGCThreads
  Global ExtraRunArguments
  
  ServerArgs := "-Xmx" . ServerXmx . " -Xms" . ServerXms
  If (UseConcMarkSweepGC)
  {
    ServerArgs := ServerArgs . " -XX:+UseConcMarkSweepGC"
  }
  If (UseParNewGC)
  {
    ServerArgs := ServerArgs . " -XX:+UseParNewGC"
  }
  If (CMSIncrementalPacing)
  {
    ServerArgs := ServerArgs . " -XX:+CMSIncrementalPacing"
  }
  If (AggressiveOpts)
  {
    ServerArgs := ServerArgs . " -XX:+AggressiveOpts"
  }
  If (ParallelGCThreads != "")
  {
    ServerArgs := ServerArgs . " -XX:ParallelGCThreads=" . ParallelGCThreads
  }
  If (ExtraRunArguments != "")
  {
    ServerArgs := ServerArgs . " " . ExtraRunArguments
  }
  ServerArgs := ServerArgs . " -jar " . MCServerJar . " nogui"
  
  RunLine := "" . JavaExec . " " . ServerArgs
  return RunLine
}


VerifyPaths()
{
  Global MCServerPath
  Global MCBackupPath
  
  IfExist, %MCServerPath%
  {
    IfExist, %MCBackupPath%
    {
      return 1
    }
    else
    {
      MsgBox, MC Backup Path points to a non-existant folder!
      return 0
    }
  }
  else
  {
    MsgBox, MC Server Path points to a non-existant folder!
    return 0
  }
}


ServerIsRunning()
{
  Global ServerWindowPID
  
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  return ErrorLevel
}


SetServerStartTime()
{
  Global ServerStartDateTime
  
  ServerStartDateTime := A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec
}


;Runs the server and sets ServerWindowPID
StartServer()
{
  Global MCServerJar
  
  if (MCServerJar != "Set this")
  {
    If (VerifyPaths() = 1)
    {
      Global MCServerPath
      Global ServerWindowPID
      Global ServerWindowID
      Global UpdateRate

      SetWorkingDir, %MCServerPath%
      
      FileGetSize, LogFileSize, server.log, K
      If (LogFileSize > 2048)
      {
        MsgBox, 4, Large Log File, Your log file is %LogFileSize% KB.  This is quite large.  Would you like to back it up and start a new one?  This window will time out in 10 seconds, 10
      }
      IfMsgBox Yes
      {
        BackupLog()
        Sleep 2000
      }
      
      InitializeVariables()
      
      GuiControl, Disable, ServerProperties
      GuiControl, Enable, JavaToggle
      GuiControl,, JavaToggle, Show Java Console
      GuiControl, Disable, StartServer
      GuiControl, Enable, SaveWorlds
      GuiControl, Enable, WarnRestart
      GuiControl, Enable, ImmediateRestart
      GuiControl, Enable, StopServer
      GuiControl, Enable, Submit
      RunThis := BuildRunLine()
      SetServerStartTime()
      Run, %RunThis%, %MCServerPath%, Hide, ServerWindowPID
      InitializeLog()
      WinGet, ServerWindowID, ID, ahk_pid %ServerWindowPID% ahk_class ConsoleWindowClass
      ReplaceText()
      SetTimer, ServerRunningTimer, %UpdateRate%
    }
    else
    {
      ReplaceText("Your paths are not set up properly, please make corrections in GUI Config before continuing.")
    }
  }
  else
  {
    ReplaceText("Please take a look at the Server Configuration...  You must specify the MC Server Jar file.")
  }
}


StopServer()
{
  Global StopWait
  Global StopTimeout
 
  SendServer("Stop")
  StopTimeout = 0
  SetTimer, ServerStopTimer, 1000
}


SendServer(textline = "")
{
  Global ServerWindowID
   
  ControlSend,,%textline%, ahk_id %ServerWindowID%
  ControlSend,,{Enter}, ahk_id %ServerWindowID%
}


Backup()
{
  Global LogBackups
  Global WorldBackups
  Global IsBackingUp
  
  IsBackingUp = 1
  
  if (LogBackups = "1")     ;Runs log backups if suppose to
  {
    BackupLog()
  } 
  
  if (WorldBackups = "1")   ;Runs world backups if suppose to
  {
    Global WorldList
    
    WorkingOn = 1           ;Loop index
    Loop, Parse, WorldList, `,
    {
      If (A_LoopField != "")
      {
        BackupWorld(A_LoopField)
      }
    }
  }
  
  IsBackingUp = 0
}


BackupWorld(world = "world")
{
  Global MCServerPath
  Global MCBackupPath
  
  AddText("`nBacking up " . world . "...")
	SetWorkingDir, %MCServerPath%
  FileGetTime, filetime, %MCServerPath%\%world%
  FormatTime, newfiletime, filetime, yyyyMMddHHmmss
  newfiletime := substr(newfiletime, 1, 4) . "-" . substr(newfiletime, 5, 2) . "-" . substr(newfiletime, 7, 2) . " " . substr(newfiletime, 9, 2) . "." . substr(newfiletime, 11, 2) . "." . substr(newfiletime, 13, 2)
  filename = %MCBackupPath%\%world%%newfiletime%
  FileCopyDir, %MCServerPath%\%world%, %filename%
  IfExist, %filename%
  {
    AddText("Complete!")
  }
}


BackupLog()
{
  Global MCServerPath
  Global MCBackupPath
  Global ConsoleBox
  
  AddText("`nBacking up server.log...")
	SetWorkingDir, %MCServerPath%
  FileGetTime, filetime, %MCServerPath%\server.log
  FormatTime, newfiletime, filetime, yyyyMMddHHmmss
  newfiletime := substr(newfiletime, 1, 4) . "-" . substr(newfiletime, 5, 2) . "-" . substr(newfiletime, 7, 2) . " " . substr(newfiletime, 9, 2) . "." . substr(newfiletime, 11, 2) . "." . substr(newfiletime, 13, 2)
  filename = %MCBackupPath%\%newfiletime%.log
  FileCopy, %MCServerPath%\server.log, %filename%
  IfExist, %filename%
  {
    FileDelete, %MCServerPath%\server.log
    FileAppend, ,%MCServerPath%\server.log
    AddText("Complete!")
  }
}


InitializeLog()
{
  ;Retrieve required globals
  Global MCServerPath
  Global LogFilePointer
  Global ServerStartDateTime
   
  TempDir = %A_WorkingDir%
  SetWorkingDir, %MCServerPath%
  
  ReplaceText("Initializing console readout... If this takes a while, consider backing up your logs...")
  Sleep 1000
  FileGetVersion, trash, %Temp%                     ;"Refreshes" the log file... Not sure if necessary
  LogFile := FileOpen("server.log", "r")            ;Open the log file
  OriginalLogContents := LogFile.Read()   ;Read the whole log into OriginalLogContents
  LogFile.Close()                         ;Close the log file
  
  Position = 1
  Loop
  {
    Position := InStr(OriginalLogContents, " [INFO] Starting", false, Position)     ;Find the first position of the date the server was started
    LineDateTime := SubStr(OriginalLogContents, (Position-19), 19)
    If (TimeIsAfter(ServerStartDateTime, LineDateTime) = 1)
    {
      LogFilePointer := Position - 20
      break
    }
    else
    {
      Position := InStr(OriginalLogContents, "minecraft", false, Position)
    }    
  }
  
  SetWorkingDir, %TempDir%
}


TimeIsAfter(startTime, afterTime)
{
  startTime := substr(startTime, 1, 4) . substr(startTime, 6, 2) . substr(startTime, 9, 2) . substr(startTime, 12, 2) . substr(startTime, 15, 2) . substr(startTime, 18, 2)
  afterTime := substr(afterTime, 1, 4) . substr(afterTime, 6, 2) . substr(afterTime, 9, 2) . substr(afterTime, 12, 2) . substr(afterTime, 15, 2) . substr(afterTime, 18, 2)
  if (afterTime >= startTime)
  {
    return 1
  }
  else
  {
    return 0
  }
}


;This retrieves the server log line by line, picking up where last left off, and adds it to the GUI
GetLog()          
{
  Global MCServerPath
  Global LogFilePointer
  
  TempDir = %A_WorkingDir%
  SetWorkingDir, %MCServerPath%
  
  LogFile := FileOpen("server.log", "r")
  LogFile.Seek(LogFilePointer)

  loop                                    ;Loops through log file line by line after last left off position
  {
    If (LogFile.AtEOF)
    {
      LogFilePointer := LogFile.Tell()
      break
    }
    Line := LogFile.ReadLine()
    ParseLogIntake(Line)
  }
  LogFile.Close()
  
  SetWorkingDir, %TempDir%
}


ParseLogIntake(ByRef Line)
{
  Global Tag
  Global TagColors
  Global FontColor
  Global ConsoleBox

  BeenParsed = 0
  Loop
  {
    TagInLine := InStr(Line, Tag[A_INDEX])
    If (TagInLine)
    {
      LengthOfTag := StrLen(Tag[A_INDEX])

      beforeTag := SubStr(Line, 1, (TagInLine - 1))
      afterTag := SubStr(Line, (TagInLine + LengthOfTag))
      
      AddText(beforeTag)
      AddText(Tag[A_Index], TagColors[Tag[A_Index]])
      AddText(afterTag)
      
      BeenParsed = 1
      break
    }
    If (A_INDEX = Tags.MaxIndex())
    {
      break
    }
  }
  
  If (InStr(Line, "logged in"))
  {
    Global PlayerList
    AfterInfoTagPos := InStr(Line, "[INFO]") + 7
    NameLength := (InStr(Line, "[/") - 1) - AfterInfoTagPos
    PlayerName := SubStr(Line, AfterInfoTagPos, NameLength)
    
    ErrorCheck := PlayerList.Insert(PlayerName)
    If (!ErrorCheck)
    {
      MsgBox, Not enough memory
    }
    PlayerListTreeNum := TV_Add(PlayerName, "", "Sort")
    PlayerList.Insert(PlayerName, PlayerListViewRowNum)
  }
  PlayerQuit := InStr(Line, "lost connection")
  If (PlayerQuit)
  {
    Global PlayerList
    AfterInfoTagPos := InStr(Line, "[INFO]") + 7
    NameLength := PlayerQuit - 1 - AfterInfoTagPos
    PlayerName := SubStr(Line, AfterInfoTagPos, NameLength)
    
    RemoveFromPlayerList(PlayerName)
    
    TV_Delete(PlayerList[PlayerName])
    PlayerList.Remove(PlayerName)
  }
  
  If (!BeenParsed)
  {
    AddText(Line)
  }
  
  return
}


RemoveFromPlayerList(name)
{
  Global PlayerList
  
  loop
  {
    If (A_Index > PlayerList.MaxIndex())
    {
      break
    }
    If (PlayerList[A_Index] = name)
    {
      PlayerList.Remove(A_Index)
    }
  }
}

/*
UpdatePlayerListView(Operation = "", opt1 = "")
{
  If (Operation = "add")
  {
    ErrorCheck := LV_Add("", opt1)
    If (!ErrorCheck)
    {
      MsgBox, Error with LV_Add(`"`", %opt1%) in UpdatePlayerList()
    }
    else
    {
      Return %ErrorCheck%
    }
  }
  If (Operation = "rm")
  {
    If (opt1 = "all")
    {
      LV_Delete()
    }
    else
    {
      ErrorCheck := LV_Delete(opt1)
      If (!ErrorCheck)
      {
        MsgBox, Error with LV_Delete(%opt1%) in UpdatePlayerList()
      }
    }
  }
  return
}
*/


GetProcessMemory_PeakWorkingSet(ProcID, Units="K") 
{
  Process, Exist, %ProcID%
  pid := Errorlevel

  ; get process handle
  hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

  ; get memory info
  PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
  DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
  DllCall( "CloseHandle", UInt, hProcess )

  SetFormat, Float, 0.0 ; round up K

  PrivateBytes := NumGet(memCounters, 8, "UInt")
  if (Units == "B")
      return PrivateBytes
  if (Units == "K")
      Return PrivateBytes / 1024
  if (Units == "M")
      Return PrivateBytes / 1024 / 1024
}


GetProcessMemory_WorkingSet(ProcID, Units="K") 
{
  Process, Exist, %ProcID%
  pid := Errorlevel

  ; get process handle
  hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

  ; get memory info
  PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
  DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
  DllCall( "CloseHandle", UInt, hProcess )

  SetFormat, Float, 0.0 ; round up K

  PrivateBytes := NumGet(memCounters, 12, "UInt")
  if (Units == "B")
      return PrivateBytes
  if (Units == "K")
      Return PrivateBytes / 1024
  if (Units == "M")
      Return PrivateBytes / 1024 / 1024
}


CheckForRestarts()
{
  Global RestartTimes
  
  CurrentTime := A_Hour . ":" . A_Min . ":" . A_Sec
  If (InStr(RestartTimes, CurrentTime))
  {
    return 1
  }
  return 0
}


InitiateAutomaticRestart()
{
  Global WarningTimes

  If (WarningTimes != "")
  {
    Global RestartCountDown
    Global WarningTimesArray
    Global WarningTimesIndex
  
    WarningTimesArray := CSVtoArray(WarningTimes)
    RestartCountDown := WarningTimesArray[1]
    WarningTimesIndex = 1
    
    SetTimer, AutomaticRestartTimer, 1000
  }
  else
  {
    AutomaticRestart()
  }
}


AutomaticRestart()
{
  SendServer("save-all")
  StopServer()
  SetTimer, WaitForRestartTimer, 1000
}


GUIUpdate()
{
  Global
  GuiControlGet, ThisTab,, ThisTab
  If (ThisTab = "Main Window")
  {
    WorldBackups := GetConfigKey("Backups", "RunWorldBackups")
    Gui, Submit, NoHide
    GuiControl,, WorldBackupsMainWindow, %WorldBackups%
  }
  if (ThisTab = "GUI Config")
  {
    MCServerPath := GetConfigKey("Folders", "ServerPath") 
    GuiControl,, MCServerPath, %MCServerPath%
    
    MCBackupPath := GetConfigKey("Folders", "BackupPath") 
    GuiControl,, MCBackupPath, %MCBackupPath%

    JavaExec := GetConfigKey("Exec", "JavaExec") 
    GuiControl,, JavaExec, %JavaExec%

    MCServerArgs := GetConfigKey("Exec", "MCServerArguments") 
    GuiControl,, MCServerArgs, %MCServerArgs%

    WindowTitle := GetConfigKey("Names", "GUIWindowTitle") 
    GuiControl,, WindowTitle, %WindowTitle%

    UpdateRate := GetConfigKey("Timing", "UpdateRate")
    GuiControl,, UpdateRate, %UpdateRate%

    WorldBackups := GetConfigKey("Backups", "RunWorldBackups")
    GuiControl,, WorldBackups, %WorldBackups%

    LogBackups := GetConfigKey("Backups", "RunLogBackups")
    GuiControl,, LogBackups, %LogBackups%
    
    WorldList := ReadWorlds()
    GuiControl,, WorldList, %WorldList%
    
    RestartTimes := GetConfigKey("Timing", "RestartTimes")
    GuiControl,, RestartTimes, %RestartTimes%
    
    WarningTimes := GetConfigKey("Timing", "WarningTimes")
    GuiControl,, WarningTimes, %WarningTimes%
    
    TimeToReconnect := GetConfigKey("Timing", "TimeToReconnect")
    GuiControl,, TimeToReconnect, %TimeToReconnect%
    
    BGColor := GetConfigKey("Colors", "BGColor")
    GuiControl,, BGColor, %BGColor%
    
    FontFace := GetConfigKey("Font", "Face")
    GuiControl,, FontFace, %FontFace%
    
    FontColor := GetConfigKey("Font", "Color")
    GuiControl,, FontColor, %FontColor%
    
    FontSize := GetConfigKey("Font", "Size")
    GuiControl,, FontSize, %FontSize%
    
    INFOColor := GetConfigKey("Colors", "INFO")
    GuiControl,, INFOColor, %INFOColor%
    
    WARNINGColor := GetConfigKey("Colors", "WARNING")
    GuiControl,, WARNINGColor, %WARNINGColor%
    
    SEVEREColor := GetConfigKey("Colors", "SEVERE")
    GuiControl,, SEVEREColor, %SEVEREColor%
  }
  if (ThisTab != "GUI Config")
  {
    GuiControlGet, MCServerPath,, MCServerPath
    SetConfigKey("Folders", "ServerPath", MCServerPath) 

    GuiControlGet, MCBackupPath,, MCBackupPath
    SetConfigKey("Folders", "BackupPath", MCBackupPath) 

    GuiControlGet, JavaExec,, JavaExec
    SetConfigKey("Exec", "JavaExec", JavaExec) 
 
    GuiControlGet, MCServerArgs,, MCServerArgs
    SetConfigKey("Exec", "MCServerArguments", MCServerArgs) 

    GuiControlGet, WindowTitle,, WindowTitle
    SetConfigKey("Names", "GUIWindowTitle", WindowTitle) 

    GuiControlGet, UpdateRate,, UpdateRate
    SetConfigKey("Timing", "UpdateRate", UpdateRate)
    SetTimer, MainTimer, Off
    SetTimer, MainTimer, %UpdateRate%
    
    GuiControlGet, WorldBackups,, WorldBackups
    SetConfigKey("Backups", "RunWorldBackups", WorldBackups)
 
    GuiControlGet, LogBackups,, LogBackups
    SetConfigKey("Backups", "RunLogBackups", LogBackups)
    
    GuiControlGet, WorldList,, WorldList
    WriteWorlds(WorldList)
    
    GuiControlGet, RestartTimes,, RestartTimes
    SetConfigKey("Timing", "RestartTimes", RestartTimes)
    
    GuiControlGet, WarningTimes,, WarningTimes
    SetConfigKey("Timing", "WarningTimes", WarningTimes)
    
    GuiControlGet, TimeToReconnect,, TimeToReconnect
    SetConfigKey("Timing", "TimeToReconnect", TimeToReconnect)
    
    GuiControlGet, BGColor,, BGColor
    SetConfigKey("Colors", "BGColor", BGColor)
    RichEdit_SetBgColor(ConsoleBox, "0x" . BGColor)
    
    GuiControlGet, FontFace,, FontFace
    SetConfigKey("Font", "Face", FontFace)
    
    GuiControlGet, FontColor,, FontColor
    SetConfigKey("Font", "Color", FontColor)
    
    GuiControlGet, FontSize,, FontSize
    SetConfigKey("Font", "Size", FontSize)
    
    GuiControlGet, INFOColor,, INFOColor
    SetConfigKey("Colors", "INFO", INFOColor)
    TagColors["INFO"] := INFOColor
    
    GuiControlGet, WARNINGColor,, WARNINGColor
    SetConfigKey("Colors", "WARNING", WARNINGColor)
    TagColors["WARNING"] := WARNINGColor
    
    GuiControlGet, SEVEREColor,, SEVEREColor
    SetConfigKey("Colors", "SEVERE", SEVEREColor)
    TagColors["SEVERE"] := SEVEREColor
  }
  
  If (ThisTab = "Server Config")
  {
    MCServerJar := GetConfigKey("ServerArguments", "ServerJarFile") 
    GuiControl,, MCServerJar, %MCServerJar%
    
    ServerXmx := GetConfigKey("ServerArguments", "Xmx") 
    GuiControl,, ServerXmx, %ServerXmx%
    
    ServerXms := GetConfigKey("ServerArguments", "Xms") 
    GuiControl,, ServerXms, %ServerXms%
    
    UseConcMarkSweepGC := GetConfigKey("ServerArguments", "UseConcMarkSweepGC")
    GuiControl,, UseConcMarkSweepGC, %UseConcMarkSweepGC%
    
    UseParNewGC := GetConfigKey("ServerArguments", "UseParNewGC")
    GuiControl,, UseParNewGC, %UseParNewGC%
    
    CMSIncrementalPacing := GetConfigKey("ServerArguments", "CMSIncrementalPacing")
    GuiControl,, CMSIncrementalPacing, %CMSIncrementalPacing%
    
    AggressiveOpts := GetConfigKey("ServerArguments", "AggressiveOpts")
    GuiControl,, AggressiveOpts, %AggressiveOpts%
    
    ParallelGCThreads := GetConfigKey("ServerArguments", "ParallelGCThreads")
    GuiControl,, ParallelGCThreads, %ParallelGCThreads%
    
    ExtraRunArguments := GetConfigKey("ServerArguments", "Extra")
    GuiControl,, ExtraRunArguments, %ExtraRunArguments%
    
    ServerProperties := ReadServerProps()
    GuiControl,, ServerProperties, %ServerProperties%
  }
  If (ThisTab != "Server Config")
  {
    GuiControlGet, MCServerJar,, MCServerJar
    SetConfigKey("ServerArguments", "ServerJarFile", MCServerJar)
    
    GuiControlGet, ServerXmx,, ServerXmx
    SetConfigKey("ServerArguments", "Xmx", ServerXmx)
    
    GuiControlGet, ServerXms,, ServerXms
    SetConfigKey("ServerArguments", "Xms", ServerXms)
    
    GuiControlGet, UseConcMarkSweepGC,, UseConcMarkSweepGC
    SetConfigKey("ServerArguments", "UseConcMarkSweepGC", UseConcMarkSweepGC)
    
    GuiControlGet, UseParNewGC,, UseParNewGC
    SetConfigKey("ServerArguments", "UseParNewGC", UseParNewGC)
    
    GuiControlGet, CMSIncrementalPacing,, CMSIncrementalPacing
    SetConfigKey("ServerArguments", "CMSIncrementalPacing", CMSIncrementalPacing)
    
    GuiControlGet, AggressiveOpts,, AggressiveOpts
    SetConfigKey("ServerArguments", "AggressiveOpts", AggressiveOpts)
    
    GuiControlGet, ParallelGCThreads,, ParallelGCThreads
    SetConfigKey("ServerArguments", "ParallelGCThreads", ParallelGCThreads)
    
    GuiControlGet, ExtraRunArguments,, ExtraRunArguments
    SetConfigKey("ServerArguments", "Extra", ExtraRunArguments)
    
    If (!ServerIsRunning())
    {
      GuiControlGet, ServerProperties,, ServerProperties
      WriteServerProps(ServerProperties)
    }
  }
}


AddText(Text, ByRef Color = "")
{
  Global ConsoleBox
  Global FontSize
  Global FontFace
  
  RichEdit_GetSel(ConsoleBox, selMin, selMax)
  EoT := RichEdit_GetTextLength(ConsoleBox)
  RichEdit_SetSel(ConsoleBox, EoT)
  
  If (Color = "")
  {
    Global FontColor
    Color := FontColor
  }
  Style := "s" . FontSize
  RichEdit_SetCharFormat(ConsoleBox, FontFace, Style,"0X" . Color)
  RichEdit_SetText(ConsoleBox, Text, , -1)
  
  RichEdit_SetSel(ConsoleBox, selMin, selMax)
  RichEdit_LineScroll(ConsoleBox,,2)
}


ReplaceText(Text = "", ByRef Color = "")
{
  Global ConsoleBox
  Global FontSize
  Global FontFace
  
  RichEdit_GetSel(ConsoleBox, selMin, selMax)
  EoT := RichEdit_GetTextLength(ConsoleBox)
  RichEdit_SetSel(ConsoleBox, EoT)
  
  If (Color = "")
  {
    Global FontColor
    Color := FontColor
  }
  Style := "s" . FontSize
  RichEdit_SetSel(ConsoleBox, 0, EOT)
  RichEdit_SetText(ConsoleBox, "")
  RichEdit_SetCharFormat(ConsoleBox, FontFace, Style,"0X" . Color)
  RichEdit_SetText(ConsoleBox, Text, , -1)
  
  RichEdit_SetSel(ConsoleBox, selMin, selMax)
  RichEdit_LineScroll(ConsoleBox,,2)
}


/*
***********
* BUTTONS *
***********
*/
Submit:
  Gui, Submit, NoHide
  GuiControlGet, ConsoleInput,, ConsoleInput
  GuiControl,, ConsoleInput, 
  SendServer(ConsoleInput)
return


StartServer:
  StartServer()
return


SaveWorlds:
  SendServer("save-all")
return


WarnRestart:
  InitiateAutomaticRestart()
return


ImmediateRestart:
  AutomaticRestart()
return


StopServer:
  StopServer()
return


JavaToggle:
  GuiControlGet, JavaToggle,, JavaToggle
  If (JavaToggle = "Show Java Console")
  {
    WinShow, ahk_id %ServerWindowID%
    GuiControl,, JavaToggle, Hide Java Console
  }
  If (JavaToggle = "Hide Java Console")
  {
    WinHide, ahk_id %ServerWindowID%
    GuiControl,, JavaToggle, Show Java Console
  }
return


MCServerPathBrowse:
  FileSelectFolder, MCServerPath, %A_ComputerName%, 3, Please locate your Minecraft Server Directory
  GuiControl,, MCServerPath, %MCServerPath%
return


MCBackupPathBrowse:
  FileSelectFolder, MCBackupPath, %A_ComputerName%, 3, Please select where you would like your backups stored
  GuiControl,, MCBackupPath, %MCBackupPath%
return


JavaExecutableBrowse:
  FileSelectFile, JavaExec,, %A_ComputerName%, Select your java executable or just close this and type java.exe in the box, *.exe
  GuiControl,, JavaExec, %JavaExec%
return

McServerJarBrowse:
  FileSelectFile, MCServerJar,, %MCServerPath%, Select the .jar file for your server. craftbukkit.jar for example, *.jar
  SplitPath, MCServerJar, MCServerJar
  GuiControl,, MCServerJar, %MCServerJar%
return


WorldBackupsMainWindow:
  Gui, Submit, NoHide
  GuiControlGet, WorldBackups,, WorldBackupsMainWindow
  SetConfigKey("Backups", "RunWorldBackups", WorldBackups)
return


GUIUpdate:
  GUIUpdate()
return


GuiClose:
  AddText("`n[GUI]Stopping server first...")
  StopServer()
  ExitApp
return