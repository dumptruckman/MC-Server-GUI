InitializeVariables()             ;Resets Variables to initial values
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
  Global ServerUpTime
  
  FileGetSize, LogSize, server.log
  ServerStartTime = 
  LogFilePointer = 0
  PreviousLogLine =
  ServerWindowPID = 0
  ServerWindowID = 0
  IsBackingUp = 0
  ServerState := "OFF"
  WhatTerminated := "ERROR"
  ServerUpTime = 0
  
  ;Set the file pointer at the end of the log file
  LogFile := FileOpen(MCServerPath . "\server.log", "a")
  LogFilePointer := LogFile.Tell()
  LogFile.Close()
  
  ;Initialize/Clear PlayerList array
  PlayerList := Object()
}


;Retrieves values from guiconfig.ini data or creates defaults if missing
InitializeConfig()
{
  global
  
  MCServerPath := GetConfigKey("Folders", "ServerPath", GUIPATH)
  MCBackupPath := GetConfigKey("Folders", "BackupPath", GUIPATH . "\backup")
  IfNotExist %MCBackupPath%
  {
    FileCreateDir, %MCBackupPath%
    If (ErrorLevel)
    {
      AddText("[GUI] Error creating backup folder.  Please examine path under GUI Config.`n")
    }
  }
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


VerifyPaths()
{
  Global MCServerPath
  Global MCBackupPath
  Global WorldBackups
  Global LogBackups
  Global MCServerJar
  
  IfExist, %MCServerPath%\%MCServerJar%
  {
    If ((LogBackups) or (WorldBackups))
    {
      IfExist, %MCBackupPath%
      {
        return 1
      }
      else
      {
        ReplaceText("[GUI] MC Backup Path points to a non-existant folder!  Correct this under GUI Config OR turn off backups to avoid this message.")
        return 0
      }
    }
    else
    {
      return 1
    }
  }
  else
  {
    ReplaceText("[GUI] Server Jar is invalid or missing!")
    return 0
  }
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


GetSoonestRestart()
{
  Global LongRestartTimes
  Temp := 99999999999999
  Loop, Parse, LongRestartTimes, `, 
  {
    If ((A_LoopField <= Temp) and (A_LoopField != ""))
    {
      Temp := A_LoopField
    }
  }
  If (Temp != 99999999999999)
  {
    return Temp
  }
  else
  {
    return 0
  }
}


GetTimeDifference(ToTime, FromTime)
{
  If (FromTime > ToTime)
  {
    return 0
  }
  Year := SubStr(ToTime, 1, 4) - SubStr(FromTime, 1, 4)
  Month := SubStr(ToTime, 5, 2) - SubStr(FromTime, 5, 2)
  Day := SubStr(ToTime, 7, 2) - SubStr(FromTime, 7, 2)
  Hour := SubStr(ToTime, 9, 2) - SubStr(FromTime, 9, 2)
  Minute := SubStr(ToTime, 11, 2) - SubStr(FromTime, 11, 2)
  Second := SubStr(ToTime, 13, 2) - SubStr(FromTime, 13, 2)

  If (Second < 0)
  {
    Minute := Minute - 1
    Second := 60 + Second
  }
  If (Minute < 0)
  {
    Hour := Hour - 1
    Minute := 60 + Minute
  }
  If (Hour < 0)
  {
    Day := Day - 1
    Hour := 24 + Hour
  }
  If (Day < 0)
  {
    Month := Month - 1
    WasMonth := A_MM - 1
    If (WasMonth = 0)
    {
      WasMonth := 12
    }
    If (RegExMatch(WasMonth, "^(1|3|5|7|8|10|12)$"))
    {
      Day := 31 + Day
    }
    If (RegExMatch(WasMonth, "^(4|6|9|11)$"))
    {
      Day := 30 + Day
    }
    LeapYear = 0
    TempYear := A_YYYY
    If (!InStr((TempYear / 4), "."))
    {
      LeapYear = 1
      If (!InStr((TempYear / 100), "."))
      {
        LeapYear = 0
        If (!InStr((TempYear / 400), "."))
        {
          LeapYear = 1
        }
      }
    }
    If ((WasMonth = 2) and (LeapYear))
    {
      Day := 29 + Day
    }
    If ((WasMonth = 2) and (!LeapYear))
    {
      Day := 28 + Day
    }
  }
  If (Month < 0)
  {
    Year := Year - 1
    Month := 12 + Month
  }
  Temp := Second . "s"
  If (Minute)
    Temp := Minute . "m" . Temp
  If (Hour)
    Temp := Hour . "h" . Temp
  If (Day)
    Temp := Day . "D" . Temp
  If (Month)
    Temp := Month . "M" . Temp
  If (Year)
    Temp := Year . "Y" . Temp
    
  Return Temp
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


GetCurrentTime()
{
  return A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec
}