ControlSwitcher(ServerState) {
  Global StartStopServer_TT
  Global BackupSave_TT
  Global AlwaysShowJavaConsole
  If (ServerState = "ON") {
    GuiControl, Disable, AlwaysShowJavaConsole
    If (AlwaysShowJavaConsole) {
      GuiControl, Disable, JavaToggle
    }
    else {
      GuiControl, Enable, JavaToggle
    }
    GuiControl, Disable, ServerProperties
    GuiControl, , StartStopServer, Stop Server
    StartStopServer_TT := "Press this button to stop your server!"
    GuiControl, , BackupSave, Save Worlds
    BackupSave_TT := "Pressing run the save-all command on your server"
    GuiControl, Enable, SaveWorlds
    ;GuiControl, Enable, WarnRestart
    GuiControl, Enable, WarnStop
    GuiControl, Enable, ImmediateRestart
    GuiControl, Enable, StopServer
    GuiControl, Enable, Reloadbutton
    GuiControl, Enable, ConsoleInput
    GuiControl, Enable, Submit
    GuiControl, Disable, MCServerJar
    Global SoonestRestart
    PlayerCount := TV_GetCount()
    GuiControl, , PlayerListBox, Player List (%PlayerCount% online)
    If (SoonestRestart) {
      NextRestart := GetTimeDifference(SoonestRestart, GetCurrentTime())
      Global IsAutomated
      If ((NextRestart) and (!IsAutomated)) {
        GuiControl, , NextRestart, Auto-Restart in: %NextRestart%
      }
      else {
        GuiControl, , NextRestart, Commencing auto-restart...
      }
    }
    else {
      GuiControl, , NextRestart, No scheduled restarts
    }
    
    Gui, Font, cGreen Bold,
    GuiControl, Font, ServerStatus
    UpTime := GetTimeDifference(GetCurrentTime(), GetServerStartTime())
    GuiControl,, ServerStatus, UP for %UpTime%
    Menu, Tray, Tip, Server UP for %UpTime%`nPlayers Online: %PlayerCount%
  }
  If (ServerState = "OFF") {
    GuiControl, , PlayerListBox, Player List
    GuiControl, Enable, AlwaysShowJavaConsole
    GuiControl, Disable, JavaToggle
    GuiControl, , JavaToggle, Show Java Console
    GuiControl, Enable, ServerProperties
    GuiControl, , StartStopServer, Start Server
    StartStopServer_TT := "Press this button to start your server!"
    GuiControl, , BackupSave, Manual Backup
    BackupSave_TT := "Pressing this will backup the world folders specified in GUI Config"
    GuiControl, Disable, SaveWorlds
    ;GuiControl, Disable, WarnRestart
    GuiControl, Disable, WarnStop
    GuiControl, Disable, Reloadbutton
    GuiControl, Disable, ImmediateRestart
    GuiControl, Disable, StopServer
    GuiControl, Disable, ConsoleInput
    GuiControl, Disable, Submit
    GuiControl, Enable, MCServerJar
    GuiControl, , NextRestart, Auto-Restart in: NA
    
    GuiControl,, ServerMemUse, Memory Usage: NA
    GuiControl,, ServerCPUUse, CPU Load: NA
    Gui, Font, cRed Bold,
    GuiControl, Font, ServerStatus
    GuiControl,, ServerStatus, DOWN
    Menu, Tray, Tip, Server DOWN
    SetTimer, AutomaticRestartTimer, Off
    ;Debug("AutomaticRestartTimer", "Off")
  }
}


GUIUpdate() {
  Global
  GuiControlGet, ThisTab,, ThisTab
  If (ThisTab = "Main Window") {
    
  }
  if (ThisTab = "GUI Config") {
    BackupPath := GetConfigKey("Folders", "BackupPath") 
    GuiControl,, BackupPath, %BackupPath%

    JavaExec := GetConfigKey("Exec", "JavaExec") 
    GuiControl,, JavaExec, %JavaExec%

    MCServerArgs := GetConfigKey("Exec", "MCServerArguments") 
    GuiControl,, MCServerArgs, %MCServerArgs%

    WindowTitle := GetConfigKey("Names", "GUIWindowTitle") 
    GuiControl,, WindowTitle, %WindowTitle%

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
    
    MinimizeToTray := GetConfigKey("Other", "MinimizeToTray")
    GuiControl,, MinimizeToTray, %MinimizeToTray%
  }
  if (ThisTab != "GUI Config") {
    GuiControlGet, BackupPath,, BackupPath
    SetConfigKey("Folders", "BackupPath", BackupPath)

    GuiControlGet, JavaExec,, JavaExec
    SetConfigKey("Exec", "JavaExec", JavaExec) 
 
    GuiControlGet, MCServerArgs,, MCServerArgs
    SetConfigKey("Exec", "MCServerArguments", MCServerArgs) 

    GuiControlGet, WindowTitle,, WindowTitle
    SetConfigKey("Names", "GUIWindowTitle", WindowTitle) 
    
    GuiControlGet, WorldList,, WorldList
    WriteWorlds(WorldList)
    
    GuiControlGet, RestartTimes,, RestartTimes
    SetConfigKey("Timing", "RestartTimes", RestartTimes)
    If (!IsAutomated) {
      If (ServerIsRunning()) {
        LongRestartTimes := ParseRestartTimes(RestartTimes)
      }
      SoonestRestart := GetSoonestRestart()
    }
    
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
    
    GuiControlGet, MinimizeToTray,, MinimizeToTray
    SetConfigKey("Other", "MinimizeToTray", MinimizeToTray)
  }
  
  If (ThisTab = "Server Config") {
    MCServerJar := GetConfigKey("ServerArguments", "ServerJarFile") 
    GuiControl,, MCServerJar, %MCServerJar%
    
    ServerXmx := GetConfigKey("ServerArguments", "Xmx") 
    GuiControl,, ServerXmx, %ServerXmx%
    
    ;ServerXms := GetConfigKey("ServerArguments", "Xms") 
    ;GuiControl,, ServerXms, %ServerXms%
    
    Xincgc := GetConfigKey("ServerArguments", "Xincgc") 
    GuiControl,, Xincgc, %Xincgc%
    
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
  If (ThisTab != "Server Config") {
    GuiControlGet, MCServerJar,, MCServerJar
    SetConfigKey("ServerArguments", "ServerJarFile", MCServerJar)
    SetConfigKey("Folders", "ServerPath", MCServerPath)
    
    GuiControlGet, ServerXmx,, ServerXmx
    SetConfigKey("ServerArguments", "Xmx", ServerXmx)
    
    ;GuiControlGet, ServerXms,, ServerXms
    ;SetConfigKey("ServerArguments", "Xms", ServerXms)
    
    GuiControlGet, Xincgc,, Xincgc
    SetConfigKey("ServerArguments", "Xincgc", Xincgc)
    
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
    
    If (!ServerIsRunning()) {
      GuiControlGet, ServerProperties,, ServerProperties
      WriteServerProps(ServerProperties)
    }
  }
}


AddText(Text, ByRef Color = "") {
  Global ConsoleBox
  Global FontSize
  Global FontFace
  
  RichEdit_GetSel(ConsoleBox, selMin, selMax)
  EoT := RichEdit_GetTextLength(ConsoleBox)
  RichEdit_SetSel(ConsoleBox, EoT)
  
  If (Color = "") {
    Global FontColor
    Color := FontColor
  }
  Style := "s" . FontSize
  RichEdit_SetCharFormat(ConsoleBox, FontFace, Style,"0X" . Color)
  RichEdit_SetText(ConsoleBox, Text, , -1)
  
  RichEdit_SetSel(ConsoleBox, selMin, selMax)
  GuiThreadInfoSize = 48
  VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
  NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
  if not DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo) {
      ;MsgBox GetGUIThreadInfo() indicated a failure.
      return
  }
  FocusedHWND := NumGet(GuiThreadInfo, 12)  ; Retrieve the hwndFocus field from the struct.
  Global ConsoleBox
  If (FocusedHWND != ConsoleBox) {
    RichEdit_LineScroll(ConsoleBox,,1)
  }
}


ReplaceText(Text = "", ByRef Color = "") {
  Global ConsoleBox
  Global FontSize
  Global FontFace
  
  RichEdit_GetSel(ConsoleBox, selMin, selMax)
  EoT := RichEdit_GetTextLength(ConsoleBox)
  RichEdit_SetSel(ConsoleBox, EoT)
  
  If (Color = "") {
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


WM_MOUSEMOVE() {
  static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
  CurrControl := A_GuiControl
  If (CurrControl <> PrevControl and not InStr(CurrControl, " ")) {
    ToolTip  ; Turn off any previous tooltip.
    SetTimer, DisplayToolTip, 1000
    PrevControl := CurrControl
  }
  return

  DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 20000
  return

  RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
  return
}



/*
************
* Hot Keys *
************
*/
/*
#if (WinActive("ahk_pid" . GUIPID))
{
  Enter::
    ControlGetFocus, Focused, ahk_pid %GUIPID%
    if (ErrorLevel)
    {
      Debug("Can't get focus", 1)
    }
    Debug("Focused", Focused)
    GuiControlGet, FocusedValue,, Focused
    %Focused% = %FocusedValue%
    UpdateConfigKey(Focused, FocusedValue)
    ;GuiControlGet, BackupPath,, BackupPath
    ;SetConfigKey("Folders", "BackupPath", BackupPath)
  return
}
*/



#if (WinActive("ahk_pid" . GUIPID))
{
  ^s::
    GuiControlGet, SayOn,, SayToggle
    if (SayOn) {
      GuiControl, , SayToggle, 0
    }
    else {
      GuiControl, , SayToggle, 1
    }
  return
}


/*
************************
* GUI Component Labels *
************************
*/
Submit:
  Gui, Submit, NoHide
  GuiControlGet, ConsoleInput,, ConsoleInput
  GuiControl,, ConsoleInput, 
  GuiControlGet, SayOn,, SayToggle
  ShiftIsDown := GetKeyState("Shift")
  If ((SayOn) or (ShiftIsDown)) {
    SendServer("say " . ConsoleInput)
  } 
  else If (ConsoleInput = "stop") {
    WhatTerminated := "USER"
    StopServer()
  } 
  else {
    SendServer(ConsoleInput)
  }
return


StartStopServer:
  GuiControlGet, StartStopServer, , StartStopServer
  If (StartStopServer = "Start Server") {
    SetTimer, WaitForRestartTimer, Off
    ;Debug("WaitForRestartTimer", "Off")
    StartServer()
  } 
  else {
    WhatTerminated := "USER"
    StopServer()
  }
return


BackupSave:
  GuiControlGet, BackupSave, , BackupSave
  If (BackupSave = "Manual Backup") {
    GuiControl, Disable, BackupSave
    Backup()
    GuiControl, Enable, BackupSave
  }
  else {
    SendServer("save-all")
  }
return

/*
SaveWorlds:
  SendServer("save-all")
return
*/

/*
WarnRestart:
  WhatTerminated := "USER"
  InitiateAutomaticRestart()
return
*/


WarnStop:
  WhatTerminated := "USER"
  WarnStop = 1
  InitiateAutomaticRestart()
return


ImmediateRestart:
  WhatTerminated := "USER"
  AutomaticRestart()
return


ReloadButton:
  SendServer("reload")
Return


/*
StopServer:
  WhatTerminated := "USER"
  StopServer()
return
*/

JavaToggle:
  GuiControlGet, JavaToggle,, JavaToggle
  If (JavaToggle = "Show Java Console") {
    WinShow, ahk_id %ServerWindowID%
    GuiControl,, JavaToggle, Hide Java Console
  }
  If (JavaToggle = "Hide Java Console") {
    WinHide, ahk_id %ServerWindowID%
    GuiControl,, JavaToggle, Show Java Console
  }
return


BackupPathBrowse:
  FileSelectFolder, BackupPath, %A_ComputerName%, 3, Please select where you would like your backups stored
  GuiControl,, BackupPath, %BackupPath%
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
  If (A_GuiControl = "PlayerList") {
    If (A_EventInfo) {
      Menu, PlayerListMenu, Show, %A_GuiX%, %A_GuiY%
    }
  }
  If (A_GuiControl = "ConsoleBox") {
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


AutomateBackups:
  Gui, Submit, NoHide
  GuiControlGet, AutomateBackups,, AutomateBackups
  SetConfigKey("Backups", "AutomateBackups", AutomateBackups)
return


WorldBackups:
  Gui, Submit, NoHide
  GuiControlGet, WorldBackups,, WorldBackups
  SetConfigKey("Backups", "WorldBackups", WorldBackups)
return


LogBackups:
  Gui, Submit, NoHide
  GuiControlGet, LogBackups,, LogBackups
  SetConfigKey("Backups", "LogBackups", LogBackups)
return


ZipBackups:
  Gui, Submit, NoHide
  GuiControlGet, ZipBackups,, ZipBackups
  SetConfigKey("Backups", "ZipBackups", ZipBackups)
return


GUIUpdate:
  GUIUpdate()
return


GuiSize:
  /*
   GuiWidth:=A_GuiWidth
   GuiHeight:=A_GuiHeight
   WinGetPos, GuiX, GuiY, , , %WindowTitle%, , ,
   If (GuiWidth = 0) && If (GuiHeight = 0) && If (GuiX = -32000) && If (GuiY = -32000)
      Gui, Hide
  */
  If (MinimizeToTray) {
    If ( A_EventInfo = 1 ) ; Minimise
    {
      Menu, Tray, Icon
      Gui, 1: Show, Hide
    }
  }
Return


Restore:
  Menu, Tray, NoIcon
  Gui, Show
Return


GuiClose:
  If(ServerIsRunning()) {
    WhatTerminated := "USER"
    AddText("[GUI]Stopping server first...`n")
    StopServer()
    Loop
    {
      Process, Exist, MCServerWindowPID
      If (!ErrorLevel) {
        break
      }
    }
    sleep 1000
  }
  ExitApp
return