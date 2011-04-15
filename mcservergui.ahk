;Initialize Internal Global Variables
ServerWindowPID = 0
InitializeVariables()

;Initialize AHK Config
DetectHiddenWindows, On
#NoEnv

;Initialize GUI Config Globals
GUIPATH = %A_WorkingDir%
InitializeConfig()


;Grab Config
IniRead, UpdateRate, guiconfig.ini, Timing, UpdateRate, 250



;Pre GUI Phase



;Config GUI

Gui, Add, Tab2, w900 Buttons gGUIUpdate vLastTab, Main Window||GUI Config


Gui, Tab, Main Window

Gui, Add, GroupBox, x10 y30 w700, Console Input
Gui, Add, Edit, xp+10 yp+20 w620 vConsoleInput
Gui, Add, Button, xp+630 yp-5 Default, Submit

Gui, Add, Edit, xp-640 yp+40 W700 ReadOnly r20 vConsoleBox

Gui, Add, Button, x10, Start Server
;Gui, Add, Button, yp xp+75, Warn Restart
;Gui, Add, Button, yp xp+82, Immediate Restart
Gui, Add, Button, yp xp+105, Stop Server

Gui, Add, Text, yp xp+200 w300 vServerMemUse, Memory Usage: NA
Gui, Add, Text, yp xp+350 w100 vServerStatus cRed Bold, Not Running


Gui, Tab, GUI Config

Gui, Add, GroupBox, x10 y30 w300 h140, Folders/Executable
Gui, Add, Text, x20 y53, MC Server Path: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap vMCServerPath, %MCServerPath%
Gui, Add, Button, xp+150 yp-2 gMCServerPathBrowse, Browse
Gui, Add, Text, x20 yp+30, MC Backup Path: 
Gui, Add, Edit, xp+85 yp-3 w145 -wrap vMCBackupPath, %MCBackupPath%
Gui, Add, Button, xp+150 yp-2 gMCBackupPathBrowse, Browse
Gui, Add, Text, x20 yp+30, Java Executable: 
Gui, Add, Edit, xp+85 yp-3 w200 -wrap vJavaExec, %JavaExec%
Gui, Add, Text, x20 yp+30, Server Arguments: 
Gui, Add, Edit, xp+85 yp-3 w200 vMCServerArgs, %MCServerArgs%

Gui, Add, Text, x20 yp+50, GUI Window Title:
Gui, Add, Edit, xp+90 yp-3 w195 vWindowTitle, %WindowTitle%

Gui, Add, Text, x20 yp+27, Update Rate: 
Gui, Add, Edit, xp+70 yp-3 w215 vUpdateRate, %UpdateRate%
Gui, Add, Text, x20 yp+22, (How often the console window is refreshed in miliseconds)

Gui, Add, Text, x20 yp+150 cRed, Once changes are complete, simply click on Main Window to save.

Gui, Add, GroupBox, x312 y30 w300 h300, Backups
Gui, Add, CheckBox, x322 y53 vWorldBackups, Run World Backups
GuiControl,, WorldBackups, %WorldBackups%
Gui, Add, CheckBox, x322 yp+20 vLogBackups, Run Log Backups (Highly Recommended)
GuiControl,, LogBackups, %LogBackups%
Gui, Add, Text, x322 yp+30, Number of Worlds:
Gui, Add, Edit, xp+90 yp-3 w30 number -wrap vNumWorlds, %NumWorlds%
Gui, Add, Text, x322 yp+23, Please set up your worlds in guiconfig.ini`nIt will be in the same directory as this program`nEnter each world in the following format:`nWorldN=worldname`nWhere N is the number for the world and worldname is `nthe name of the folder the world is stored in.`nExample:`nWorld1=world`nWorld2=nether`nWorld3=whathaveyou`netc..

Gui, Show, Restore, %WindowTitle%



;Main Phase

SetTimer, MainTimer, %UpdateRate%
SetTimer, BackupScheduler, 1000
return



;Timers

MainTimer:
  MainProcess()
return


BackupScheduler:

return


ServerStop:
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  If ( ! ErrorLevel )
  {
    SetTimer, ServerStop, Off
    ServerWindowPID = 0
    GuiControl,, ServerStatus, Not Running
    Backup()
  }
return



;Functions

;Resets Variables to initial values
InitializeVariables()
{
  Global LogSize
  Global FileLine
  
  FileGetSize, LogSize, server.log
  FileLine = 1
  GuiControl,, ConsoleBox, 
}


;Retrieves values from guiconfig.ini data or creates defaults if missing
InitializeConfig()
{
  global
  
  MCServerPath := GetConfigKey("Folders", "ServerPath", GUIPATH)
  MCBackupPath := GetConfigKey("Folders", "BackupPath", GUIPATH . "\backup")
  JavaExec := GetConfigKey("Exec", "JavaExec", "java.exe")
  MCServerArgs := GetConfigKey("Exec", "MCServerArguments", "Set this")
  WindowTitle := GetConfigKey("Names", "GUIWindowTitle", "MC Server GUI")
  UpdateRate := GetConfigKey("Timing", "UpdateRate", "250")
  WorldBackups := GetConfigKey("Backups", "RunWorldBackups", "1")
  LogBackups := GetConfigKey("Backups", "RunLogBackups", "1")
  NumWorlds := GetConfigKey("Worlds", "Amount", "1")
  GetConfigKey("Worlds", "World1", "world")
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


;Main Process that runs at %UpdateRate% intervals
MainProcess()
{
  Global ServerWindowPID
  
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  If ErrorLevel
  {
    Gui, Font, cGreen Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, Running
    PeakWorkingSet := GetProcessMemory_PeakWorkingSet(ServerWindowPID, "M")
    WorkingSet := GetProcessMemory_WorkingSet(ServerWindowPID, "M")
    GuiControl,, ServerMemUse, Memory Usage: %WorkingSet% M / %PeakWorkingSet% M
    
    ;Reads the log file size and compares it to the last checked size... (Detects log changes and updates GUI)
    FileGetSize, NewLogSize, server.log
    FileGetVersion, trash, server.log       ;This is necessary to "refresh" the log file
    
    if NewLogSize != %LastLogSize%        ;Changes found
    {
      GetLog()                        
      LastLogSize = %NewLogSize%             ;Updates last checked filesize
    }
    
  }
  else
  {
    GuiControl,, ServerMemUse, Memory Usage: NA
    Gui, Font, cRed Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, Not Running
  }
}


;Runs the server and returns the PID
StartServer()
{
  Global ServerWindowPID
  Global MCServerArgs
  Global JavaExec
  
  if (MCServerArgs != "Set this")
  {
    ErrorLevel = 0
    Process, Exist, %ServerWindowPID%
    If ErrorLevel
    {
      MsgBox, Server is already running!
      return ServerWindowPID
    }
    else
    {
      SetWorkingDir, %MCServerPath%
      InitializeVariables()
      Global MCServerPath
      Run, %JavaExec% %MCServerArgs%, %MCServerPath%, Hide, PID
      return PID
    }
  }
  else
  {
    GuiControl,, ConsoleBox, Please take a look at the GUI Configuration...  You must specify the path of the MC Server executable
    return 0
  }
}


StopServer()
{
  Global StopWait
  Global ServerWindowPID
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  If ErrorLevel
  {
    SendServer("Stop")
    SetTimer, ServerStop, 250
  }
  else
  {
    GuiControl,, ConsoleBox, Server is not running!
  }
}


SendServer(ByRef textline = "")
{
  Global ServerWindowPID
  ;If server is running it will give the message
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  If ErrorLevel
  {
    ControlSend,,%textline%,"ahk_pid %ServerWindowPID%"
    ControlSend,,{Enter},"ahk_pid %ServerWindowPID%"
  }
  else
  {
    GuiControl,, ConsoleBox, Server is not running!
  }
}


Backup()
{
  Global LogBackups
  if (LogBackups = "1")
  {
    BackupLog()
  }
  Global WorldBackups
  if (WorldBackups = "1")
  {
    Global NumWorlds
    Global GUIPath
    WorkingOn = 1
    loop
    {
      World := "World" . WorkingOn
      IniRead, WorldName, %GUIPath%\guiconfig.ini, Worlds, %World%, world
      BackupWorld(WorldName)
      if (NumWorlds = WorkingOn)
      {
        break
      }
      WorkingOn := WorkingOn + 1
    }
  }
  if (WorldBackups = "1" or LogBackups = "1")
  {
    GuiControl,, ConsoleBox, Server backed up successfully.
  }
  else
  {
    GuiControl,, ConsoleBox, 
  }
}


BackupWorld(world = "world")
{
  Global MCServerPath
  Global MCBackupPath
	SetWorkingDir, %MCServerPath%
  FileGetTime, filetime, %MCServerPath%\%world%
  FormatTime, newfiletime, filetime, yyyyMMddHHmm
  filename = %MCBackupPath%\%world%%newfiletime%
  FileCopyDir, %MCServerPath%\%world%, %filename%
}


BackupLog()
{
  Global MCServerPath
  Global MCBackupPath
	SetWorkingDir, %MCServerPath%
  FileGetTime, filetime, %MCServerPath%\server.log
  FormatTime, newfiletime, filetime, yyyyMMddHHmm
  filename = %MCBackupPath%\server.log%newfiletime%
  FileCopy, %MCServerPath%\server.log, %filename%
  FileDelete, %MCServerPath%\server.log
  FileAppend, ,%MCServerPath%\server.log
}


;This retrieves the server log line by line, picking up where last left off, and adds it to the GUI
GetLog()          
{
  Global FileLine
  ErrorLevel = 0          ;Not sure this is necessary...
  loop                    ;Loops through log file line by line
  {
    FileReadLine, Line, server.log, %FileLine%
    if ErrorLevel = 1           ;If %FileLine% of the log is empty, breaks out of the loop
    {
      break
    }    
    GuiControlGet, OldConsole,, ConsoleBox              ;Retrieves what's already in the console
    GuiControl,, ConsoleBox, %Line%`n`r%OldConsole%     ;Adds new data to the top of current contents
    FileLine := FileLine + 1                            ;Moves to the next line
  }
}


GetProcessMemory_PeakWorkingSet(ProcID, Units="K") {
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


GetProcessMemory_WorkingSet(ProcID, Units="K") {
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



;Buttons

ButtonSubmit:
  Gui, Submit, NoHide
  GuiControlGet, Temp,, ConsoleInput
  GuiControl,, ConsoleInput, 
  SendServer(Temp)
return


ButtonStartServer:
  ServerWindowPID := StartServer()
return

/*
ButtonWarnRestart:
  SendServer("say Automated restart/backup in 30 seconds...")
  sleep 15000
  SendServer("say Automated restart/backup in 15 seconds...")
  SendServer("Save-all")
  sleep 10000
  SendServer("say Automated restart/backup in 5 seconds.  Please reconnect in approximately 30 seconds.")
  sleep 5000
  StopServer()
  ServerWindowPID := StartServer()
return


ButtonImmediateRestart:
  StopServer()
  ServerWindowPID := StartServer()
return
*/

ButtonStopServer:
  StopServer()
return


MCServerPathBrowse:
  FileSelectFolder, MCServerPath, %A_ComputerName%, 3, Please locate your Minecraft Server Directory
  GuiControl,, MCServerPath, %MCServerPath%
return


MCBackupPathBrowse:
  FileSelectFolder, MCBackupPath, %A_ComputerName%, 3, Please select where you would like your backups stored
  GuiControl,, MCBackupPath, %MCBackupPath%
return


GUIUpdate:
  GuiControlGet, LastTab,, LastTab
  if (LastTab = "GUI Config")
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

    NumWorlds := GetConfigKey("Worlds", "Amount")
    GuiControl,, NumWorlds, %NumWorlds%
  }
  if (LastTab = "Main Window")
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
  
    GuiControlGet, NumWorlds,, NumWorlds
    SetConfigKey("Worlds", "Amount", NumWorlds)
  }
return


GuiClose:
  GuiControlGet, OldConsole,, ConsoleBox
  GuiControl,, ConsoleBox, [GUI]Stopping Server First`n`r%OldConsole%
  StopServer()
  ExitApp
return