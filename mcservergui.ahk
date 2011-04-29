/*
*****************
* MC Server GUI *
*      by       *
*  dumptruckman *
*****************
*/
VersionNumber := ".6.1-dev"

;Include Libraries
#Include RichEdit.ahk

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
netstatFile := GUIPATH . "\guinetwork.dat"
SetFormat, FloatFast, %FloatingPointPrecision%
RunWait %comspec% /c ""Netstat" "-e" >"%netstatFile%"",, Hide
FileReadLine, BytesData, % netstatFile, 5
StringReplace, BytesData, BytesData, Bytes,
BytesData = %BytesData%
;StringSplit, LastBytesData, LastBytesData, % A_Space
LastBytesDataRx := SubStr(BytesData, 1, InStr(BytesData, " "))
LastBytesDataTx := SubStr(BytesData, InStr(BytesData, " "))
LastBytesDataTx = %LastBytesDataTx%
InitializeConfig()
ServerProperties := ReadServerProps()




;Pre GUI Phase




/*
*************
* GUI SETUP *
*************
*/
Gui, Add, Tab2, buttons gGUIUpdate vThisTab, Main Window||Server Config|GUI Config
Gui, Margin, 5, 5
Gui, +Resize +MinSize


;FIRST TAB - Main Window
Gui, Tab, Main Window

;Picture control contains RichEdit control for the "Console Box"
Gui, Add, GroupBox, x10 y30 w700 h275 Section vConsoleOutput, Console Output
Gui, Add, Picture, xp+10 yp+15 w680 h250 vConsoleBox HwndREparent1
ConsoleBox := RichEdit_Add(REParent1, 0, 0, 680, 250, "READONLY VSCROLL MULTILINE")
RichEdit_SetBgColor(ConsoleBox, "0x" . BGColor)

;Player List

Gui, Add, GroupBox, ys Section w200 h275 vPlayerListBox, Player List
Gui, Add, TreeView, xp+10 yp+15 w180 h250 vPlayerList AltSubmit -Buttons -Lines

;Console input field + button
Gui, Add, GroupBox, xs x10 w700 h50 vConsoleInputBox, Console Input

Gui, Add, CheckBox, xp+10 yp+21 Section vSayToggle, Say
Gui, Add, Edit, ys yp-4 w585 vConsoleInput
ConsoleInput_TT := "Press shift+enter to 'say' to the server"
Gui, Add, Button, ys yp-1 Default gSubmit vSubmit, Submit
GuiControl, Disable, ConsoleInput
GuiControl, Disable, Submit

;Server Control buttons
GuiControlGet, GUIPos, Pos, ConsoleInputBox
GUIPosY := GUIPosY + GUIPosH + 5
Gui, Add, GroupBox, x10 y%GUIPosY% w200 h75 vServerControlBox, Server Control
Gui, Add, Button, xp+10 yp+15 w87 Section gStartStopServer vStartStopServer, Start Server
StartStopServer_TT := "Press this button to start your server!"
Gui, Add, Button, ys w87 gBackupSave vBackupSave, Manual Backup
BackupSave_TT := "Pressing this will backup the world folders specified in GUI Config"
;Gui, Add, Button, ys  gSaveWorlds vSaveWorlds, Save Worlds
;SaveWorlds_TT := "This is the same as typing save-all"
Gui, Add, Button, xs Section gWarnRestart vWarnRestart, Warn Restart
WarnRestart_TT := "This will give warnings to the players at the intervals specified in the config before restarting"
Gui, Add, Button, ys gImmediateRestart vImmediateRestart, Immediate Restart
ImmediateRestart_TT := "This will restart the server without warning the players"
;Gui, Add, Button, ys gStopServer vStopServer, Stop Server
;StopServer_TT := "This will stop the server immediately"
;Gui, Add, Button, ys xp+150 vJavaToggle gJavaToggle, Show Java Console
;JavaToggle_TT := "This will show/hide the Java Console running in the background.  This feature was added for debugging purposes and may be removed later"
;GuiControl, Disable, JavaToggle ;Disable toggle at startup
;GuiControl, Disable, SaveWorlds
GuiControl, Disable, WarnRestart
GuiControl, Disable, ImmediateRestart
;GuiControl, Disable, StopServer

;Server Info
GuiControlGet, GUIPos, Pos, ServerControlBox
GUIPosX := GUIPosX + GUIPosW + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w200 h75 vServerInfoBox, Server Information
;Server running indicator
Gui, Add, Text, yp+15 xp+10 Section, Status: 
Gui, Add, Text, ys w80 vServerStatus cRed Bold, Not Running
;Memory counter text control
Gui, Add, Text, xs w180 vServerMemUse, Memory Usage: NA
;CPU Load indicator
Gui, Add, Text, xs w150 vServerCPUUse, CPU Load: NA

;GUI Info
GuiControlGet, GUIPos, Pos, ServerInfoBox
GUIPosX := GUIPosX + GUIPosW + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w130 h75 vGUIInfoBox, GUI Information
;Version Information
Gui, Add, Text, yp+15 xp+10 Section, Version %VersionNumber%
;Memory counter text control
Gui, Add, Text, xs w110 vGUIMemUse, Memory Usage: NA
;CPU Load indicator
Gui, Add, Text, xs w110 vGUICPUUse, CPU Load: NA

;Network Info
GuiControlGet, GUIPos, Pos, GUIInfoBox
GUIPosX := GUIPosX + GUIPosW + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w155 h75 vNetworkInfoBox, Network Information
Gui, Add, Text, yp+15 xp+10 Section, Receiving: 
Gui, Add, Text, ys w90 vBytesRxPerSecond, Loading...
Gui, Add, Text, xs Section, Transmitting: 
Gui, Add, Text, ys w90 vBytesTxPerSecond, Loading...

;Main Window Backup Control
GuiControlGet, GUIPos, Pos, PlayerListBox
BoxW := GUIPosW
GuiControlGet, GUIPos, Pos, ServerControlBox
BoxH := GUIPosH + 5
GuiControlGet, GUIPos, Pos, ConsoleInputBox
GUIPosX := GUIPosX + GUIPosW + 5
BoxH := BoxH + GUIPosH
Gui, Add, GroupBox, x%GUIPosX% y%GUIPosY% w%BoxW% h%BoxH%, Backup Control
;Checkboxes for whether or not to backup worlds/log
Gui, Add, CheckBox, xp+10 yp+15 Section vWorldBackups gWorldBackups, Run World Backups
WorldBackups_TT := "Whether world folders will be backed up when automatically restarted or when manual backup is pressed."
GuiControl,, WorldBackups, %WorldBackups%
Gui, Add, CheckBox, xs vLogBackups gLogBackups, Run Log Backups
LogBackups_TT := "Whether server.log will be backed up when automatically restarted or when manual backup is pressed."
GuiControl,, LogBackups, %LogBackups%
;Checkbox for Zipping backups
Gui, Add, CheckBox, xs vZipBackups gZipBackups, Zip Backups
ZipBackups_TT := "Whether or not to archive the backup files"
GuiControl,, ZipBackups, %ZipBackups%
;Info
Gui, Add, Text, xs, Configure the settings for your backups`non the GUI Config tab


;SECOND TAB - SERVER CONFIG
Gui, Tab, Server Config

;Java Arguments box
Gui, Add, GroupBox, x10 y30 w300 h230, Server Arguments
;Server Jar File Location field
Gui, Add, Text, x20 y53 Section, Server Jar File: 
Gui, Add, Edit, ys yp-3 w145 -wrap -multi r1 vMCServerJar, %MCServerJar%
Gui, Add, Button, ys yp-2 gMCServerJarBrowse, Browse
MCServerJar_TT := "Put the name of your server Jar file here.  Example: craftbukkit.jar"
;Xms memory field
Gui, Add, Text, xs Section, Xms Memory: 
Gui, Add, Edit, ys yp-3 w60 -wrap -multi vServerXms, %ServerXms%
;Xmx memory field
Gui, Add, Text, ys, Xmx Memory: 
Gui, Add, Edit, ys yp-3 w60 -wrap -multi vServerXmx, %ServerXmx%
;Checkboxes for various arguments
Gui, Add, CheckBox, xs vUseConcMarkSweepGC, -XX:+UseConcMarkSweepGC
GuiControl,, UseConcMarkSweepGC, %UseConcMarkSweepGC%
Gui, Add, CheckBox, xs vUseParNewGC, -XX:+UseParNewGC
GuiControl,, UseParNewGC, %UseParNewGC%
Gui, Add, CheckBox, xs vCMSIncrementalPacing, -XX:+CMSIncrementalPacing
GuiControl,, CMSIncrementalPacing, %CMSIncrementalPacing%
Gui, Add, CheckBox, xs vAggressiveOpts, -XX:+AggressiveOpts
GuiControl,, AggressiveOpts, %AggressiveOpts%
;ParallelGCThreads field
Gui, Add, Text, xs Section, ParallelGCThreads:
Gui, Add, Edit, ys yp-3 w30 number -wrap -multi vParallelGCThreads, %ParallelGCThreads%
;Field for extra arguments
Gui, Add, Text, xs Section, Extra Arguments:
Gui, Add, Edit, ys yp-3 w190 -wrap -multi r1 vExtraRunArguments, %ExtraRunArguments%
ExtraRunArguments_TT := "Put any extra server arguments here seperated by spaces.  Example -Xincgc"

;Info
Gui, Add, Text, xm y430 cRed, Once changes are complete, simply click on another tab to save..

;Server.properties edit box
Gui, Add, Text, x322 y30, Edit server.properties here: (Server must not be running) 
Gui, Add, Edit, x322 yp+20 w300 r20 -wrap vServerProperties, %ServerProperties%


;THIRD TAB - GUI CONFIG
Gui, Tab, GUI Config

;Box for file/folder information controls
Gui, Add, GroupBox, x10 y30 w300 h70 vFoldersExecutableBox, Folders/Executable
GuiControlGet, GUIPos, Pos, FoldersExecutableBox
BoxW := GUIPosW
;MC Backup Path field
Gui, Add, Text, x20 yp+20 Section vMCBackupPathText, MC Backup Path: 
GuiControlGet, GUIPos, Pos, MCBackupPathText
Temp := BoxW - GUIPosW - 75
Gui, Add, Edit, ys yp-3 w%Temp% -wrap -multi r1 vMCBackupPath, %MCBackupPath%
Gui, Add, Button, ys yp-2 gMCBackupPathBrowse, Browse
MCBackupPath_TT := "Enter the path of the folder you'd like to store backups in"
;Java Executable field
Gui, Add, Text, xs Section vJavaExecutableText, Java Executable: 
GuiControlGet, GUIPos, Pos, JavaExecutableText
Temp := BoxW - GUIPosW - 75
Gui, Add, Edit, ys yp-3 w%Temp% -wrap -multi r1 vJavaExec, %JavaExec%
Gui, Add, Button, ys yp-2 gJavaExecutableBrowse, Browse
JavaExec_TT := "Enter the path of your Java executable here.  You can probably leave this set to java.exe"

;Miscellaneous
GuiControlGet, GUIPos, Pos, FoldersExecutableBox
GUIPosY := GUIPosY + GUIPosH + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w%GUIPosW% h125 vMiscellaneousBox, Miscellaneous
GuiControlGet, GUIPos, Pos, MisecellaneousBox
BoxW := GUIPosW
;Title of GUI's window
Gui, Add, Text, xp+10 yp+20 Section vWindowTitleText, GUI Window Title:
GuiControlGet, GUIPos, Pos, WindowTitleText
Temp := BoxW - GUIPosW - 23
Gui, Add, Edit, ys yp-3 w%Temp% vWindowTitle, %WindowTitle%
WindowTitle_TT := "Enter the title of this very window!"
;Box for rate at which GUI updates the console readout of the server
Gui, Add, Text, xs Section vUpdateRateText, Update Rate: 
GuiControlGet, GUIPos, Pos, UpdateRateText
Temp := BoxW - GUIPosW - 23
Gui, Add, Edit, ys yp-3 w%Temp% number vUpdateRate, %UpdateRate%
Gui, Add, Text, xs, (How often the console window is refreshed in miliseconds)
;Option to start server on gui startup
Gui, Add, CheckBox, xs vServerStartOnStartup, Start Server on GUI Start
GuiControl,, ServerStartOnStartup, %ServerStartOnStartup%
;Option to always show java console
Gui, Add, CheckBox, xs vAlwaysShowJavaConsole, Always show Java console (Starts minimized)
GuiControl,, AlwaysShowJavaConsole, %AlwaysShowJavaConsole%

/* Not yet ready
;NickNames
GuiControlGet, GUIPos, Pos, MiscellaneousBox
GUIPosY := GUIPosY + GUIPosH + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w%GUIPosW% h70 vNickNamesBox, Nick Names
GuiControlGet, GUIPos, Pos, NickNamesBox
BoxW := GUIPosW
Gui, Add, Text, xp+10 yp+15 Section, If anyone ever shows up in your /list with a name other than`nthe name they log in with, please specify it here.  The format`nis as follows: LoginName=NickName`nSeperate multiple entries with commas (and no spaces)
Temp := BoxW - 20
Gui, Add, Edit, xs w%Temp% vNickNames
*/

;Info
Gui, Add, Text, xm y430 cRed, Once changes are complete, simply click on another tab to save..

;Backup information controls
Gui, Add, GroupBox, x312 y30 w300 h285, Backup Settings
;Names of world field
Gui, Add, Text, x322 yp+15 Section, Enter names of worlds below:`n  (separate each one with a comma and NO spaces)
Gui, Add, Edit, xs w280 r1 -multi vWorldList, %WorldList%
WorldList_TT := "Example: world,nether"
;Restart times field
Gui, Add, Text, xs, Enter the time at which you would like to run automated`n restarts in HH:MM:SS (24-hour) format.  Separate each `n time by commas with NO spaces: (Leave blank for none)
Gui, Add, Edit, xs w280 r1 -multi vRestartTimes, %RestartTimes%
RestartTimes_TT := "The times at which the server will restart automatically, with the below warning(s), and run backups, if enabled."
;Restart warning periods field
Gui, Add, Text, xs, Enter the times, at which automated restarts will warn the`n the server, in Seconds.  List them in descending order,`n separated by commas with NO Spaces:
Gui, Add, Edit, xs w280 -multi vWarningTimes, %WarningTimes%
WarningTimes_TT := "The players will be warned at these many seconds before the server is restarted"
;Field for amount of time to add to the warning period to tell players to reconnect
Gui, Add, Text, xs Section, Amount of time to tell players to wait to reconnect:`n (This will be added to the current warning's time)`n (In seconds)
Gui, Add, Edit, ys w30 number -multi vTimeToReconnect, %TimeToReconnect%
TimeToReconnect_TT := "This amount of time will be added to the above Warning Times as an indication of when players should attempt to reconnect to your server"
;Field for delay before restart
Gui, Add, Text, xs Section, Delay before auto-restarting (in seconds):
Gui, Add, Edit, ys yp-3 w40 number -multi r1 vRestartDelay, %RestartDelay%
RestartDelay_TT := "Keep in mind, the server will wait to restart until backups are finished, if applicable."


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
;Gui, +Resize +MinSize
Gui, Show, Restore, %WindowTitle%



/*
********************
* Player List Menu *
********************
*/
Menu, ItemCategories, add, Test
Menu, PlayerListMenu, add, Kick, PL_Kick
Menu, PlayerListMenu, add, Ban, PL_Ban
;Menu, PlayerListMenu, add, Ban-IP, PL_BanIP
;Menu, PlayerListMenu, add, Give, :ItemCategories



/*
*******************
* ConsoleBox Menu *
*******************
*/
Menu, ConsoleBoxMenu, add, Copy, ConsoleCopy



/*
**************
* MAIN PHASE *
**************
*/
OnMessage(0x200, "WM_MOUSEMOVE")
SetTimer, MainTimer, 250
SetTimer, RestartAtScheduler, 1000
SetTimer, NetworkMonitor, 1000
SetTimer, GetCharKeyPress, 100

If ((MCServerJar = "Set this") or (MCServerJar = ""))
{
  ServerJar := AutoDetectServerJar()
  If (ServerJar)
  {
    MCServerJar := ServerJar
    SplitPath, MCServerJar, MCServerJar, MCServerPath
    SetConfigKey("Folders", "ServerPath", MCServerPath)
    SetConfigKey("ServerArguments", "ServerJarFile", MCServerJar)
    AddText("[GUI] Autodetected " . MCServerJar . " as your Minecraft server jar file.  Please make corrections in Server Config if this is wrong.")
  }
  else
  {
    AddText("[GUI] Could not locate a server jar file.  Please set this manually under Server Config.")
  }
}

If (ServerStartOnStartup)
{
  StartServer()
}
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


RestartAtScheduler:
  If (CheckForRestarts())
  {
    WhatTerminated := "AUTO"
    InitiateAutomaticRestart()
  }
return


ServerUpTimer:
  ;ServerUpTime := ServerUpTime + 1
  If (CheckForRestarts())
  {
    WhatTerminated := "AUTO"
    InitiateAutomaticRestart()
  }
return


GetCharKeyPress:
  IfWinActive, ahk_pid %GUIPID%
  {
    GuiControlGet, InputEnabled, Enabled, ConsoleInput
    If (InputEnabled)
    {
      GuiControlGet, FocusedControl, Focus
      GuiControlGet, ThisTab,, ThisTab
      If (FocusedControl != "Edit1" and ThisTab = "Main Window")
      {
        Input, KeyPressed, I L1 T.1
        If (KeyPressed)
        {
          ControlSend, Edit1, %KeyPressed%, A
          GuiControl, focus, ConsoleInput
        }
      }
    }
  }
return


ServerStopTimer:
  If (!ServerIsRunning())
  {
    PlayerList.Remove(PlayerList.MinIndex(), PlayerList.MaxIndex())
    TV_Delete()
    SetTimer, ServerStopTimer, Off
    SetTimer, ServerRunningTimer, Off
    SetTimer, ServerUpTimer, Off
    ServerWindowPID = 0
    ServerWindowID = 0
    ControlSwitcher("OFF")
    GuiControl,, ServerStatus, Not Running
    AddText("[GUI] Server Stopped`n")
    If (WhatTerminated = "AUTO")
    {
      Backup()
    }
    AddText("[GUI] Finished`n")
  }
  StopTimeout := StopTimeout + 1
  If (StopTimeout = 60)
  {
    Process, Close, ServerWindowPID
  }
return


WaitForRestartTimer:
  SetTimer, WaitForRestartTimer, 1000
  If (!ServerIsRunning())
  {
    If (IsBackingUp = 0)
    {
      SetTimer, WaitForRestartTimer, Off
      Loop
      {
        If (StartServer())
        {
          break
        }
      }
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
      WarningMessage := "say Automatic restart in " . RestartTime := ConvertSecondstoMinSec(RestartCountDown) . ".  Please reconnect in approximately " . ConvertSecondstoMinSec(RestartCountDown + TimeToReconnect) . "."

      SendServer(WarningMessage)
    }
  }
  RestartCountDown := RestartCountDown - 1
return


NetworkMonitor:
  RunWait %comspec% /c ""Netstat" "-e" >"%netstatFile%"",, Hide
  FileReadLine, BytesData, % netstatFile, 5
  StringReplace, BytesData, BytesData, Bytes,
  BytesData = %BytesData%
  ;StringSplit, LastBytesData, LastBytesData, % A_Space
  BytesDataRx := SubStr(BytesData, 1, InStr(BytesData, " "))
  BytesDataTx := SubStr(BytesData, InStr(BytesData, " "))
  BytesDataTx = %BytesDataTx%
  DisplayBytesRx := BytesDataRx - LastBytesDataRx
  DisplayBytesTx := BytesDataTx - LastBytesDataTx
  If (DisplayBytesRx < 1024)
  {
    DisplayBytesRx := DisplayBytesRx . " B/s"
  }
  else If ((DisplayBytesRx >= 1024) and (DisplayBytesRx < 1048576))
  {
    DisplayBytesRx := (DisplayBytesRx / 1024) . " KB/s"
  }
  else If (DisplayBytesRx >= 1048576)
  {
    DisplayBytesRx := (DisplayBytesRx / 1048576) . " MB/s"
  }
  If (DisplayBytesTx < 1024)
  {
    DisplayBytesTx := DisplayBytesTx . " B/s"
  }
  else If ((DisplayBytesTx >= 1024) and (DisplayBytesTx < 1048576))
  {
    DisplayBytesTx := (DisplayBytesTx / 1024) . " KB/s"
  }
  else If (DisplayBytesTx >= 1048576)
  {
    DisplayBytesTx := (DisplayBytesTx / 1048576) . " MB/s"
  }
  GuiControl, , BytesRxPerSecond, %DisplayBytesRx%
  GuiControl, , BytesTxPerSecond, %DisplayBytesTx%
  LastBytesDataRx := BytesDataRx
  LastBytesDataTx := BytesDataTx
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
  Global GUIPID
  
  If (ServerIsRunning())
  {
    ControlSwitcher("ON")
    
    ;PeakWorkingSet := GetProcessMemory_PeakWorkingSet(ServerWindowPID, "M")
    CommitSize := GetProcessMemory_CommitSize(ServerWindowPID, "M")
    WorkingSet := GetProcessMemory_WorkingSet(ServerWindowPID, "M")
    GuiControl,, ServerMemUse, Memory Usage: %WorkingSet% M / %CommitSize% M
    CPULoad := GetServerProcessTimes(ServerWindowPID)
    GuiControl,, ServerCPUUse, CPU Load: %CPULoad%`%
    /*
    If (VerifyPaths() = 0)
    {
      MsgBox, Something just happened to the paths you specified!  Please check your configuration.
    }
    */
  }
  else
  {
    Global ServerState
    
    If (ServerState == "ON")
    {
      StopServer()
    }
    ControlSwitcher("OFF")
    SetTimer, ServerRunningTimer, Off
    SetTimer, ServerUpTimer, Off
  }
  WorkingSet := GetProcessMemory_WorkingSet(GUIPID, "M")
  GuiControl,, GUIMemUse, Memory Usage: %WorkingSet% M
  GUICPULoad := GetGUIProcessTimes(GUIPID)
  GuiControl,, GUICPUUse, CPU Load: %GUICPULoad%`%
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
  Global LogFilePointer
  Global PlayerList
  Global PreviousLogLine
  Global ServerWindowPID
  Global ServerWindowID
  Global ServerState
  Global ServerStartTime
  Global WhatTerminated
  Global IsBackingUp
  Global MCServerPath
  
  FileGetSize, LogSize, server.log
  ServerStartTime = 
  LogFilePointer = 0
  PreviousLogLine =
  ServerWindowPID = 0
  ServerWindowID = 0
  IsBackingUp = 0
  ServerState := "OFF"
  WhatTerminated := "ERROR"
  
  LogFile := FileOpen(MCServerPath . "\server.log", "a")
  LogFilePointer := LogFile.Tell()
  LogFile.Close()

  PlayerList := Object()
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
  RestartDelay := GetConfigKey("Timing", "RestartDelay", "0")
  TimeToReconnect := GetConfigKey("Timing", "TimeToReconnect", "30")
  WorldBackups := GetConfigKey("Backups", "RunWorldBackups", "1")
  LogBackups := GetConfigKey("Backups", "RunLogBackups", "1")
  ZipBackups := GetConfigKey("Backups", "ZipBackups", "1")
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
  FontSize := GetConfigKey("Font", "Size", "8")
  FontFace := GetConfigKey("Font", "Face", "Roman")
  WWidth := GetConfigKey("Window", "Width", 700)
  WHeight := GetConfigKey("Window", "Height", 275)
  SetConfigKey("Window", "Width", 700)
  SetConfigKey("Window", "Height", 275)
  ServerStartOnStartup := GetConfigKey("Other", "ServerStartOnStartup", "0")
  AlwaysShowJavaConsole := GetConfigKey("Other", "AlwaysShowJavaConsole", "0")
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


DeleteWorlds()
{
  Global GUIPATH
  IniDelete, %GUIPATH%\guiconfig.ini, Worlds
}


WriteWorlds(Worlds)
{
  Global GUIPATH
  
  DeleteWorlds()
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


AutoDetectServerJar()
{
  Global MCServerPath
  
  ServerJar = 0
  SetWorkingDir, %MCServerPath%
  If (FileExist("*server*.jar"))
  {
    Loop, *server*.jar
    {
      ServerJar := A_LoopFileLongPath
      break
    }
  }
  If (FileExist("*bukkit*.jar"))
  {
    Loop, *bukkit*.jar
    {
      ServerJar := A_LoopFileLongPath
      break
    }
  }
  return ServerJar
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


ConvertSecondstoMinSec(Seconds)
{
  MinSec := ""
  Minutes := 0
  Loop
  {
    If (Seconds < 60)
    {
      If (Minutes != 0)
      {
        MinSec := Minutes . " minute"
        If (Minutes > 1)
        {
          MinSec := MinSec . "s"
        }
        If (Seconds > 0)
        {
          MinSec := MinSec . " and "
        }
      }
      If (Seconds > 0)
      {
        MinSec := MinSec . Seconds . " second"
        If (Seconds > 1)
        {
          MinSec := MinSec . "s"
        }
      }
      break
    }
    Seconds := Seconds - 60
    Minutes := Minutes + 1
  }
  return MinSec
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
      ;ReplaceText("MC Backup Path points to a non-existant folder!")
      return 0
    }
  }
  else
  {
    ;ReplaceText("MC Server Path points to a non-existant folder!")
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


WriteErrorLog(ErrorMessage)
{
  TempDir := A_WorkingDir
  SetWorkingDir, %GUIPATH%
  ErrorLogFile := FileOpen("guierror.log", "a")
  ErrorLogFile.WriteLine(A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . "  " . ErrorMessage)
  ErrorLogFile.Close()
  SetWorkingDir, %TempDir%
}


;Runs the server and sets ServerWindowPID
StartServer()
{
  Global MCServerJar
  Global MCServerPath
  
  If (MCServerJar = "Set this")             ;If not config'd
  {
    ReplaceText("[GUI] Please take a look at the Server Configuration...  You must specify the MC Server Jar file.")
    return 0
  }
  
  If (!FileExist(MCServerPath . "\" . MCServerJar))
  {
    ReplaceText("[GUI] Server Jar file does not exist! please correct this in Server Config.")
    return 0
  }
  
  If (VerifyPaths() = 0)                    ;If paths are invalid
  {
    ReplaceText("[GUI] Your paths are not set up properly, please make corrections in GUI Config before continuing.")
    return 0
  }
  
  If (ServerIsRunning())                    ;If server is running
  {
    MsgBox, Server is already running!
    return 1      ;Special case return 1 since this should only happen if user starts server before it is automatically started.
  }
  
  Global IsBackingUp                        
  If (IsBackingUp)                          ;If backup is in progress
  {
    MsgBox, 0, Error, Cannot start server while backup is in progress., 5
    return 0
  }
  
  ;Grab some globals
  Global ServerWindowPID
  Global ServerWindowID
  Global UpdateRate
  Global AlwaysShowJavaConsole

  SetWorkingDir, %MCServerPath%
  
  ;If the log is really large, give the user a chance to clean it up.
  FileGetSize, LogFileSize, server.log, K
  If (LogFileSize > 1024)
  {
    MsgBox, 4, Large Log File, Your log file is %LogFileSize% KB.  This is quite large.  Would you like to back it up and start a new one?  This window will time out in 10 seconds, 10
  }
  IfMsgBox Yes
  {
    IsBackingUp = 1
    FileGetVersion, trash, server.log         ;This is necessary to "refresh"
    FileGetTime, filetime, server.log
    FormatTime, foldername, filetime, yyyyMMddHHmmss
    foldername := substr(foldername, 1, 4) . "-" . substr(foldername, 5, 2) . "-" . substr(foldername, 7, 2) . " " . substr(foldername, 9, 2) . "." . substr(foldername, 11, 2) . "." . substr(foldername, 13, 2)
    FileCreateDir, %MCBackupPath%\%foldername%
    BackupLog(foldername)
    IsBackingUp = 0
  }
  
  InitializeVariables()                     ;Get variables ready for start
  
  RunLine := BuildRunLine()
  
  ;Attempt to start Java for the server
  ReplaceText("[GUI] Starting Java...")
  If (AlwaysShowJavaConsole)
  {
    Run, %RunLine%, %MCServerPath%, Min UseErrorlevel, ServerWindowPID
  }
  else
  {
    Run, %RunLine%, %MCServerPath%, Hide UseErrorlevel, ServerWindowPID
  }
  If (ErrorLevel)                           ;If there was a problem launching it initially, error out
  {
    WriteErrorLog("Error starting server.  Windows system error code: " . A_LastError)
    MsgBox, 5, Server Start Error, Error starting the server.  Windows system error code: %A_LastError%.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry                         ;Give user option to retry
    {
      StartServer()
    }
    return 0
  }
  Process, Wait, %ServerWindowPID%, 5         ;Waits on the process to be ready
  If (ErrorLevel = 0)                         ;If it times out waiting or the process doesn't exist, error out
  {
    AddText("Error.")
    WriteErrorLog("Error starting server.  Problem starting Java.")
    MsgBox, 5, Server Start Error, Error starting the server.  Java did not run or there was a problem starting it.  Check your configuration.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry                         ;Give user option to retry
    {
      StartServer()
    }
    return 0
  }
  
  GuiControl, Disable, ServerProperties       ;Server has started, so disable editing of server.properties
  ;Waits for the console window to exist
  ReplaceText("[GUI] Waiting to hook console window...")
  WinWait, ahk_pid %ServerWindowPID% ahk_class ConsoleWindowClass, , 5
  If (ErrorLevel)                             ;Waits 5 seconds for the window to exist and, if it doesn't or there was some other error, errors out
  {
    Loop                                      ;This loops ensures that it closes the Java process semi-gracefully
    {
      Process, Exist, %ServerWindowPID%
      If (ErrorLevel)
      {
        WinClose, ahk_pid %ServerWindowPID%
      }
      else
      {
        break
      }
    }
    GuiControl, Enable, ServerProperties      ;Re-enables the server.properties edit since it didn't start properly
    AddText("Error.")
    WriteErrorLog("Error starting server.  Could not hook Java console window.")
    MsgBox, 5, Server Start Error, Error starting the server.  Could not hook Java console window.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry
    {
      StartServer()
    }
    return 0
  }
  
  ;Since the windows supposedly exists, attempts to hook onto it
  WinGet, ServerWindowID, ID, ahk_pid %ServerWindowPID% ahk_class ConsoleWindowClass
  If (ServerWindowID = 0)                   ;If, for some reason, it doesn't hook the window, errors out
  {
    Loop                                    ;This loops ensures that it closes the Java process semi-gracefully
    {
      Process, Exist, %ServerWindowPID%
      If (ErrorLevel)
      {
        WinClose, ahk_pid %ServerWindowPID%
      }
      else
      {
        break
      }
    }
    GuiControl, Enable, ServerProperties      ;Re-enables the server.properties edit since it didn't start properly
    AddText("Error.")
    WriteErrorLog("Error starting server.  Could not hook Java console window.")
    MsgBox, 5, Server Start Error, Error starting the server.  Could not hook Java console window.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry
    {
      StartServer()
    }
    return 0
  }
  
  Global LongRestartTimes
  Global RestartTimes
  LongRestartTimes := ParseRestartTimes(RestartTimes)
  Global ServerUpTime
  ServerUpTime = 0
  SetTimer, ServerUpTimer, 1000
  SetServerStartTime()
  
  Global ServerState
  
  ReplaceText()                           ;Blanks the console output box
  ServerState := "ON"                     ;Stores the state of the server as ON
  
  ControlSwitcher("ON")                   ;Switches all the buttons
  
  SetTimer, ServerRunningTimer, %UpdateRate%      ;Start log update timer
  
  return 1
}


StopServer()
{
  Global StopTimeout
  Global ServerState
  Global WhatTerminated
  
  SendServer("stop")
  ServerState = "OFF"
  If (WhatTerminated = "ERROR")
  {
    WriteErrorLog("Server error.  Java terminated unexpectedly.")
    MsgBox, 0, Server Error, Java terminated unexpectedly.  Check your configuration.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
  }
  StopTimeout = 0
  SetTimer, ServerStopTimer, 1000
}


SendServer(textline = "")
{
  Global ServerWindowID

  ControlSendRaw,,%textline%, ahk_id %ServerWindowID%
  ControlSend,,{Enter}, ahk_id %ServerWindowID%
}


ControlSwitcher(ServerState)
{
  Global StartStopServer_TT
  Global BackupSave_TT
  Global AlwaysShowJavaConsole
  If (ServerState = "ON")
  {
    GuiControl, Disable, AlwaysShowJavaConsole
    If (AlwaysShowJavaConsole)
    {
      GuiControl, Disable, JavaToggle
    }
    else
    {
      GuiControl, Enable, JavaToggle
    }
    GuiControl, Disable, ServerProperties
    GuiControl, , StartStopServer, Stop Server
    StartStopServer_TT := "Press this button to stop your server!"
    GuiControl, , BackupSave, Save Worlds
    BackupSave_TT := "Pressing run the save-all command on your server"
    GuiControl, Enable, SaveWorlds
    GuiControl, Enable, WarnRestart
    GuiControl, Enable, ImmediateRestart
    GuiControl, Enable, StopServer
    GuiControl, Enable, ConsoleInput
    GuiControl, Enable, Submit
    GuiControl, Disable, MCServerJar
    
    Gui, Font, cGreen Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, Running
  }
  If (ServerState = "OFF")
  {
    GuiControl, Enable, AlwaysShowJavaConsole
    GuiControl, Disable, JavaToggle
    GuiControl, , JavaToggle, Show Java Console
    GuiControl, Enable, ServerProperties
    GuiControl, , StartStopServer, Start Server
    StartStopServer_TT := "Press this button to start your server!"
    GuiControl, , BackupSave, Manual Backup
    BackupSave_TT := "Pressing this will backup the world folders specified in GUI Config"
    GuiControl, Disable, SaveWorlds
    GuiControl, Disable, WarnRestart
    GuiControl, Disable, ImmediateRestart
    GuiControl, Disable, StopServer
    GuiControl, Disable, ConsoleInput
    GuiControl, Disable, Submit
    GuiControl, Enable, MCServerJar
    
    GuiControl,, ServerMemUse, Memory Usage: NA
    GuiControl,, ServerCPUUse, CPU Load: NA
    Gui, Font, cRed Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, Not Running
  }
}


Backup()
{
  Global LogBackups
  Global WorldBackups
  Global IsBackingUp
  Global ZipBackups
  Global MCServerPath
  Global MCBackupPath
  
  IsBackingUp = 1
  
  
  If ((LogBackups = "1") or (WorldBackups = "1"))
  {
    SetWorkingDir, %MCServerPath%
    FileGetVersion, trash, server.log         ;This is necessary to "refresh"
    FileGetTime, filetime, %MCServerPath%\server.log
    FormatTime, foldername, filetime, yyyyMMddHHmmss
    filetime := substr(foldername, 1, 4) . "-" . substr(foldername, 5, 2) . "-" . substr(foldername, 7, 2) . " " . substr(foldername, 9, 2) . "." . substr(foldername, 11, 2) . "." . substr(foldername, 13, 2)
    
    If (!ZipBackups)
    {
      FileCreateDir, %MCBackupPath%\%filetime%
    }
    if (LogBackups = "1")     ;Runs log backups if suppose to
    {
      BackupLog(filetime)
    } 
    else
    {
      AddText("[GUI] Log backups are disabled... skipping`n")
    }
    
    if (WorldBackups = "1")   ;Runs world backups if suppose to
    {
      Global WorldList
      
      WorkingOn = 1           ;Loop index
      Loop, Parse, WorldList, `,
      {
        If (A_LoopField != "")
        {
          BackupWorld(filetime, A_LoopField)
        }
      }
    }
    else
    {
      AddText("[GUI] World backups are disabled... skipping`n")
    }
  }
  else
  {
    AddText("[GUI] Backups are disabled... skipping`n")
  }
  
  IsBackingUp = 0
}


BackupWorld(backupfolder, world = "world")
{
  Global MCServerPath
  Global MCBackupPath
  Global ZipBackups
  
  AddText("[GUI] Backing up " . world . "...")
  sleep 10
	SetWorkingDir, %MCServerPath%
  If (ZipBackups = "1")
  {
    AddText("Archiving to " . backupfolder . ".zip...")
    sleep 10
    filename = %MCBackupPath%\%backupfolder%.zip
    RunLine = 7za.exe a "%MCBackupPath%\%backupfolder%.zip" "%MCServerPath%\%world%\"
    RunWait, %RunLine%, , Hide
  }
  else
  {
    FileGetSize, OriginalSize, %MCServerPath%\%world%
    filename = %MCBackupPath%\%backupfolder%\%world%
    FileCopyDir, %MCServerPath%\%world%, %filename%
    If (ErrorLevel)
    {
      AddText("Error!`n")
      WriteErrorLog("Error backing up world " . %world% . ".")
      return
    }
  }
  Loop
  {
    IfExist, %filename%
    {
      If (!ZipBackups)
      {
        FileGetVersion, trash, %filename%       ;This is necessary to "refresh"
        FileGetSize, BackupSize, %filename%
        If (BackupSize = OriginalSize)
        {
          AddText("Complete!`n")
          break
        }
      }
      else
      {
        FileDelete, %MCServerPath%\server.log
        FileAppend, ,%MCServerPath%\server.log
        AddText("Complete!`n")
        break
      }
    }
    else
    {
      If (ZipBackups)
      {
        AddText("Error!`n")
        break
      }
    }
  }
}


BackupLog(backupfolder)
{
  Global MCServerPath
  Global MCBackupPath
  Global ConsoleBox
  Global ZipBackups
  
  AddText("[GUI] Backing up server.log...")
  sleep 10
	SetWorkingDir, %MCServerPath%
  If (ZipBackups = "1")
  {
    AddText("Archiving to " . backupfolder . ".zip...")
    sleep 10
    filename = %MCBackupPath%\%backupfolder%.zip
    RunLine = 7za.exe a "%MCBackupPath%\%backupfolder%.zip" "%MCServerPath%\server.log"
    RunWait, %RunLine%,,Hide
  }
  else
  {
    FileGetVersion, trash, server.log         ;This is necessary to "refresh"
    FileGetSize, OriginalSize, server.log
    filename = %MCBackupPath%\%backupfolder%\server.log
    FileCopy, %MCServerPath%\server.log, %filename%
    If (ErrorLevel)
    {
      AddText("Error!`n")
      WriteErrorLog("Error backing up server.log.")
      return
    }
  }
  Loop
  {
    IfExist, %filename%
    {
      If (!ZipBackups)
      {
        FileGetVersion, trash, %filename%         ;This is necessary to "refresh"
        FileGetSize, BackupSize, %filename%
        If (BackupSize = OriginalSize)
        {
          FileDelete, %MCServerPath%\server.log
          FileAppend, ,%MCServerPath%\server.log
          AddText("Complete!`n")
          break
        }
      }
      else
      {
        FileDelete, %MCServerPath%\server.log
        FileAppend, ,%MCServerPath%\server.log
        AddText("Complete!`n")
        break
      }
    }
    else
    {
      If (ZipBackups)
      {
        AddText("Error!`n")
        break
      }
    }
  }

}


;This retrieves the server log line by line, picking up where last left off, and adds it to the GUI
GetLog()          
{
  Global MCServerPath
  Global LogFilePointer
  Global PreviousLogLine
  
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
    PreviousLogLine := Line
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
  Global PreviousLogLine

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
  If (InStr(Line, "] logged in with entity id"))
  {
    AfterInfoTagPos := InStr(Line, "[INFO]") + 7
    NameLength := (InStr(Line, "[/") - 1) - AfterInfoTagPos
    PlayerName := SubStr(Line, AfterInfoTagPos, NameLength)
    
    AddToPlayerList(PlayerName)
  }
  PlayerQuit := InStr(Line, "lost connection")
  If (PlayerQuit)
  {
    AfterInfoTagPos := InStr(Line, "[INFO]") + 7
    NameLength := PlayerQuit - 1 - AfterInfoTagPos
    PlayerName := SubStr(Line, AfterInfoTagPos, NameLength)
    
    If (!InStr(PlayerName, "/"))
    {
      RemoveFromPlayerList(PlayerName)
    }
  }
  If (InStr(Line, "Connection reset"))
  {
    If (!InStr(PreviousLogLine, "lost connection"))
    {
      SendServer("list")
    }
  }
  ContainsPlayerList := InStr(Line, "Connected players: ")
  If (ContainsPlayerList)
  {
    ConnectedPlayers := SubStr(Line, (ContainsPlayerList + 19))
    StringReplace, ConnectedPlayers, ConnectedPlayers, `n
    StringReplace, ConnectedPlayers, ConnectedPlayers, `r
    VerifyPlayerList(ConnectedPlayers)
  }
  
  If (!BeenParsed)
  {
    AddText(Line)
  }
  
  return
}


;This is to remove extra players that don't get removed properly, Names contains the player list obtained from SendServer("list")
VerifyPlayerList(ByRef Names)
{
  Global PlayerList
  
  Loop
  {
    If (A_Index > PlayerList.MaxIndex())
    {
      break
    }
    PlayerListIndex := A_Index
    PlayerConnected = 0
    Loop, Parse, Names, `,%A_Space%
    {
      If (PlayerList[PlayerListIndex] = A_LoopField)
      {
        PlayerConnected = 1
        break
      }
    }
    If (!PlayerConnected)
    {
      RemoveFromPlayerList(PlayerList[PlayerListIndex])
    }
  }
}


RemoveFromPlayerList(PlayerName)
{
  Global PlayerList
  
  loop
  {
    If (A_Index > PlayerList.MaxIndex())
    {
      break
    }
    If (PlayerList[A_Index] = PlayerName)
    {
      PlayerList.Remove(A_Index)
      TV_Delete(PlayerList[PlayerName])
      PlayerList.Remove(PlayerName)
      break
    }
  }
}


AddToPlayerList(PlayerName)
{
  Global PlayerList
  
  If (!PlayerList[PlayerName])
  {
    ErrorCheck := PlayerList.Insert(PlayerName)
    If (!ErrorCheck)
    {
      MsgBox, Not enough memory to add player
    }
    PlayerListTreeNum := TV_Add(PlayerName, "", "Sort")
    PlayerList.Insert(PlayerName, PlayerListTreeNum)
  }
}


GetProcessMemory_CommitSize(ProcID, Units="K") 
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

  PrivateBytes := NumGet(memCounters, 40, "UInt")
  if (Units == "B")
      return PrivateBytes
  if (Units == "K")
      Return PrivateBytes / 1024
  if (Units == "M")
      Return PrivateBytes / 1024 / 1024
}


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


GetServerProcessTimes(pid)    ; Individual CPU Load of the process with pid
{
   Static soldKrnlTime, soldUserTime
   Static snewKrnlTime, snewUserTime

   soldKrnlTime := snewKrnlTime
   soldUserTime := snewUserTime

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", snewKrnlTime, "int64P", snewUserTime)
   DllCall("CloseHandle", "Uint", hProc)
   Return (snewKrnlTime-soldKrnlTime + snewUserTime-soldUserTime)/10000000 * 100   ; 1sec: 10**7
}


GetGUIProcessTimes(pid)    ; Individual CPU Load of the process with pid
{
   Static goldKrnlTime, goldUserTime
   Static gnewKrnlTime, gnewUserTime

   goldKrnlTime := gnewKrnlTime
   goldUserTime := gnewUserTime

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", gnewKrnlTime, "int64P", gnewUserTime)
   DllCall("CloseHandle", "Uint", hProc)
   Return (gnewKrnlTime-goldKrnlTime + gnewUserTime-goldUserTime)/10000000 * 100   ; 1sec: 10**7
}


SetServerStartTime()
{
  Global ServerStartTime
  ServerStartTime := A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec
}


CheckForRestarts()
{
  Global LongRestartTimes

  CurrentTime := A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec
  If (InStr(LongRestartTimes, CurrentTime))
  {
    return 1
  }
  return 0
}


ParseRestartTimes(Times)
{
  Global ServerStartTime
  LongTimes = 
  Loop, Parse, Times, `,,%A_Space%
  {
    FoundMatch = 0
    DelimiterPattern := "-!@#%&=_:;',/``~\Q$^*()+{}[]\|?<>.\E"
    If ((RegExMatch(A_LoopField, "ix)^((\d{4})[" . DelimiterPattern . "]?(0[1-9])|(\d{4})[" . DelimiterPattern . "]?(1[012])|(\d{2}|\d{4})[" . DelimiterPattern . "](1[012])|(\d{2}|\d{4})[" . DelimiterPattern . "]([1-9])|(\d{2}|\d{4})[" . DelimiterPattern . "](0[1-9]))([" . DelimiterPattern . "]([1-9])|[" . DelimiterPattern . "]?(0[1-9])|[" . DelimiterPattern . "]?([12]\d)|[" . DelimiterPattern . "]?(3[01]))\s([012]?\d)[" . DelimiterPattern . "]?([0-5]\d)?[" . DelimiterPattern . "]?([0-5]\d)?([ap]m)?$", Test)) and (!FoundMatch))
    {
      MsgBox, %Test%
      FoundMatch = 1
    }
    if ((RegExMatch(A_LoopField, "ix)^([012]?\d)[" . DelimiterPattern . "]?([0-5]\d)?[" . DelimiterPattern . "]?([0-5]\d)?(?P<APM>[ap]m)?$", Test)) and (!FoundMatch))
    {
      MsgBox, %Test%
      FoundMatch = 1
    }
    if ((RegExMatch(A_LoopField, "^((?P<Day>\d{1,2})(d|day|days))?\s?((?P<Hour>\d{1,2})(h|hr|hrs|hour|hours))?\s?((?P<Minute>\d{1,2})(m|min|mins|minutes))?\s?((?P<Second>\d{1,2})(s|sec|secs|seconds))?$", Test)) and (!FoundMatch))
    {
      MsgBox, Days: %TestDay%`nHours: %TestHour%`nMinutes: %TestMinute%`nSeconds: %TestSecond%
      FoundMatch = 1
    }
  }
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
  Global RestartDelay
  
  SendServer("save-all")
  StopServer()
  Temp := RestartDelay * 1000
  SetTimer, WaitForRestartTimer, %Temp%
}


GUIUpdate()
{
  Global
  GuiControlGet, ThisTab,, ThisTab
  If (ThisTab = "Main Window")
  {
    ;WorldBackups := GetConfigKey("Backups", "RunWorldBackups")
    ;Gui, Submit, NoHide
    ;GuiControl,, WorldBackupsMainWindow, %WorldBackups%
  }
  if (ThisTab = "GUI Config")
  {
    ;MCServerPath := GetConfigKey("Folders", "ServerPath") 
    ;GuiControl,, MCServerPath, %MCServerPath%
    
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
    
    /*
    WorldBackups := GetConfigKey("Backups", "RunWorldBackups")
    GuiControl,, WorldBackups, %WorldBackups%

    LogBackups := GetConfigKey("Backups", "RunLogBackups")
    GuiControl,, LogBackups, %LogBackups%
    
    ZipBackups := GetConfigKey("Backups", "ZipBackups")
    GuiControl,, ZipBackups, %ZipBackups%
    */
    
    WorldList := ReadWorlds()
    GuiControl,, WorldList, %WorldList%
    
    RestartTimes := GetConfigKey("Timing", "RestartTimes")
    GuiControl,, RestartTimes, %RestartTimes%
    
    RestartDelay := GetConfigKey("Timing", "RestartDelay")
    GuiControl,, RestartDelay, %RestartDelay%
    
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
    
    ServerStartOnStartup := GetConfigKey("Other", "ServerStartOnStartup")
    GuiControl,, ServerStartOnStartup, %ServerStartOnStartup%
    
    AlwaysShowJavaConsole := GetConfigKey("Other", "AlwaysShowJavaConsole")
    GuiControl,, AlwaysShowJavaConsole, %AlwaysShowJavaConsole%
  }
  if (ThisTab != "GUI Config")
  {
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
    
    /*
    GuiControlGet, WorldBackups,, WorldBackups
    SetConfigKey("Backups", "RunWorldBackups", WorldBackups)
 
    GuiControlGet, LogBackups,, LogBackups
    SetConfigKey("Backups", "RunLogBackups", LogBackups)
    
    GuiControlGet, ZipBackups,, ZipBackups
    SetConfigKey("Backups", "ZipBackups", ZipBackups)
    */
    
    GuiControlGet, WorldList,, WorldList
    WriteWorlds(WorldList)
    
    GuiControlGet, RestartTimes,, RestartTimes
    SetConfigKey("Timing", "RestartTimes", RestartTimes)
    LongRestartTimes := ParseRestartTimes(RestartTimes)
    
    GuiControlGet, WarningTimes,, WarningTimes
    SetConfigKey("Timing", "WarningTimes", WarningTimes)
    
    GuiControlGet, TimeToReconnect,, TimeToReconnect
    SetConfigKey("Timing", "TimeToReconnect", TimeToReconnect)
    
    GuiControlGet, RestartDelay,, RestartDelay
    SetConfigKey("Timing", "RestartDelay", RestartDelay)
    
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
    
    GuiControlGet, ServerStartOnStartup,, ServerStartOnStartup
    SetConfigKey("Other", "ServerStartOnStartup", ServerStartOnStartup)
    
    GuiControlGet, AlwaysShowJavaConsole,, AlwaysShowJavaConsole
    SetConfigKey("Other", "AlwaysShowJavaConsole", AlwaysShowJavaConsole)
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
    SetConfigKey("Folders", "ServerPath", MCServerPath)
    
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


WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1000
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
      SetTimer, DisplayToolTip, Off
      ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
      SetTimer, RemoveToolTip, 5000
    return

    RemoveToolTip:
      SetTimer, RemoveToolTip, Off
      ToolTip
    return
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
  GuiControlGet, SayOn,, SayToggle
  ShiftIsDown := GetKeyState("Shift")
  If ((SayOn) or (ShiftIsDown))
  {
    SendServer("say " . ConsoleInput)
  }
  else If (ConsoleInput = "stop")
  {
    WhatTerminated := "USER"
    StopServer()
  }
  else
  {
    SendServer(ConsoleInput)
  }
return


StartStopServer:
  GuiControlGet, StartStopServer, , StartStopServer
  If (StartStopServer = "Start Server")
  {
    StartServer()
  }
  else
  {
    WhatTerminated := "USER"
    StopServer()
  }
return


BackupSave:
  GuiControlGet, BackupSave, , BackupSave
  If (BackupSave = "Manual Backup")
  {
    GuiControl, Disable, BackupSave
    Backup()
    GuiControl, Enable, BackupSave
  }
  else
  {
    SendServer("save-all")
  }
return

/*
SaveWorlds:
  SendServer("save-all")
return
*/

WarnRestart:
  WhatTerminated := "USER"
  InitiateAutomaticRestart()
return


ImmediateRestart:
  WhatTerminated := "USER"
  AutomaticRestart()
return

/*
StopServer:
  WhatTerminated := "USER"
  StopServer()
return
*/
/*
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
*/

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
  SplitPath, MCServerJar, MCServerJar, MCServerPath
  GuiControl,, MCServerJar, %MCServerJar%
return


GuiContextMenu:
  If (A_GuiControl = "PlayerList")
  {
    If (A_EventInfo)
    {
      Menu, PlayerListMenu, Show, %A_GuiX%, %A_GuiY%
    }
  }
  If (A_GuiControl = "ConsoleBox")
  {
    Menu, ConsoleBoxMenu, Show, %A_GuiX%, %A_GuiY%
  }
return

PL_Kick:
  PlayerListSelection := TV_GetSelection()
  TV_GetText(PlayerName, PlayerListSelection)
  SendServer("kick " . PlayerName)
  RemoveFromPlayerList(PlayerName)
return


PL_Ban:
  PlayerListSelection := TV_GetSelection()
  TV_GetText(PlayerName, PlayerListSelection)
  SendServer("ban " . PlayerName)
  RemoveFromPlayerList(PlayerName)
return

/*
PL_BanIP:
  PlayerListSelection := TV_GetSelection()
  TV_GetText(PlayerName, PlayerListSelection)
  SendServer("ban-ip " . PlayerName)
  RemoveFromPlayerList(PlayerName)
return
*/

PL_Give:
  
return

Test:

return


ConsoleCopy:
  RichEdit_Copy(ConsoleBox)
return


WorldBackups:
  Gui, Submit, NoHide
  GuiControlGet, WorldBackups,, WorldBackups
  SetConfigKey("Backups", "RunWorldBackups", WorldBackups)
return


LogBackups:
  Gui, Submit, NoHide
  GuiControlGet, LogBackups,, LogBackups
  SetConfigKey("Backups", "RunLogBackups", LogBackups)
return


ZipBackups:
  Gui, Submit, NoHide
  GuiControlGet, ZipBackups,, ZipBackups
  SetConfigKey("Backups", "ZipBackups", ZipBackups)
return


GUIUpdate:
  GUIUpdate()
return


GuiClose:
  If(ServerIsRunning())
  {
    WhatTerminated := "USER"
    AddText("`n[GUI]Stopping server first...")
    StopServer()
  }
  ExitApp
return