;Grab Config
IniRead, MCServerPath, guiconfig.ini, Folders, ServerPath, c:\mcserver
IniRead, MCBackupPath, guiconfig.ini, Folders, BackupPath, c:\mcserver\backup
IniRead, GUIPath, guiconfig.ini, Folders, GUIPath, c:\mcserver
IniRead, MCServerExec, guiconfig.ini, Exec, ServerExec, server_nogui.bat
IniRead, StopWait, guiconfig.ini, Timing, WaitAfterStopForClose, 10000
IniRead, UpdateRate, guiconfig.ini, Timing, UpdateRate, 250
IniRead, WindowTitle, guiconfig.ini, Names, WindowTitle, MC Server GUI
IniRead, NumWorlds, guiconfig.ini, Worlds, Amount, 1
IniRead, WorldBackups, guiconfig.ini, Backups, RunWorldBackups, true
IniRead, LogBackups, guiconfig.ini, Backups, RunLogBackups, true

SetWorkingDir, %MCServerPath%

;Initials Vars
ServerWindowPID = 0
DetectHiddenWindows, On
FileGetSize, LogSize, server.log
FileLine = 1

;Config GUI
Gui, Add, GroupBox, x10 y0 w700, Console Input
Gui, Add, Edit, xp+10 yp+20 w620 vConsoleInput
Gui, Add, Button, yp-5 xp+630 yp Default, Submit
Gui, Add, Edit, x10 W700 ReadOnly r20 vConsoleBox
Gui, Add, Button, x10, Start Server
Gui, Add, Button, yp xp+75, Warn Restart
Gui, Add, Button, yp xp+82, Immediate Restart
Gui, Add, Button, yp xp+105, Stop Server
Gui, Add, Text, yp xp+550 vServerStatus, Not Running
Gui, Show, Restore, MC Server GUI

SetTimer, MainTimer, 250
SetTimer, MainTimer, Off
return

;Reads the log file size and compares it to the last checked size... (Detects log changes and updates GUI)
MainTimer:
  MainProcess()
return

MainProcess()
{
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  If ErrorLevel
  {
    GuiControl,, ServerStatus, Running
    FileGetSize, NewLogSize, server.log
    
    ;This is necessary to "refresh" the log file
    FileGetVersion, trash, server.log
    
    if NewLogSize != %LastLogSize%        ;Changes found
    {
      GetLog()                        
      LastLogSize = %NewLogSize%             ;Updates last checked filesize
    }
    
  }
  else
  {
    GuiControl,, ServerStatus, Not Running
  }
}

InitVars()
{
  Global LogSize
  Global FileLine
  FileGetSize, LogSize, server.log
  FileLine = 1
  GuiControl,, ConsoleBox, 
}

;Runs the server and returns the PID
StartServer()
{ 
  Global ServerWindowPID
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  If ErrorLevel
  {
    MsgBox, Server is already running!
    return 0
  }
  else
  {
    InitVars()
    SetTimer, MainTimer, On
    Global MCServerPath
    Global MCServerExec
    Run, "%MCServerPath%\%MCServerExec%", %MCServerPath%, Hide, PID
    return PID
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
    sleep %StopWait%
    SendServer()
    ServerWindowPID = 0
    SetTimer, MainTimer, Off
    GuiControl,, ServerStatus, Not Running
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
  if (LogBackups = "true")
  {
    BackupLog()
  }
  Global WorldBackups
  if (WorldBackups = "true")
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
  if (WorldBackups = "true" or LogBackups = "true")
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
  FileGetTime, filetime, %MCServerPath%\%world%
  FormatTime, newfiletime, filetime, yyyyMMddHHmm
  filename = %MCBackupPath%\%world%%newfiletime%
  FileCopyDir, %MCServerPath%\%world%, %filename%
}

BackupLog()
{
  Global MCServerPath
  Global MCBackupPath
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



;Buttons

ButtonSubmit:
  Gui, Submit, NoHide
  SendServer(ConsoleInput)
  GuiControl,, ConsoleInput, 
return

ButtonStartServer:
  ServerWindowPID := StartServer()
return

ButtonWarnRestart:
  SendServer("say Automated restart/backup in 30 seconds...")
  sleep 15000
  SendServer("say Automated restart/backup in 15 seconds...")
  SendServer("Save-all")
  sleep 10000
  SendServer("say Automated restart/backup in 5 seconds.  Please reconnect in approximately 30 seconds.")
  sleep 5000
  StopServer()
  Backup()
  ServerWindowPID := StartServer()
return

ButtonImmediateRestart:
  StopServer()
  Backup()
  ServerWindowPID := StartServer()
return

ButtonStopServer:
  StopServer()
  Backup()
return

GuiClose:
  GuiControlGet, OldConsole,, ConsoleBox
  GuiControl,, ConsoleBox, [GUI]Stopping Server First`n`r%OldConsole%
  StopServer()
  ExitApp
return