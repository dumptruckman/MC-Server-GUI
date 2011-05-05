AutoDetectServerJar() {
  Global MCServerPath
  
  ServerJar = 0
  SetWorkingDir, %MCServerPath%
  If (FileExist("*server*.jar")) {
    Loop, *server*.jar
    {
      ServerJar := A_LoopFileLongPath
      break
    }
  }
  If (FileExist("*bukkit*.jar")) {
    Loop, *bukkit*.jar
    {
      ServerJar := A_LoopFileLongPath
      break
    }
  }
  return ServerJar
}


Backup() {
  Global LogBackups
  Global WorldBackups
  Global IsBackingUp
  Global ZipBackups
  Global MCServerPath
  Global MCBackupPath
  
  IsBackingUp = 1
  
  
  If ((LogBackups = "1") or (WorldBackups = "1")) {
    SetWorkingDir, %MCServerPath%
    FileGetVersion, trash, server.log         ;This is necessary to "refresh"
    FileGetTime, filetime, %MCServerPath%\server.log
    FormatTime, foldername, filetime, yyyyMMddHHmmss
    filetime := substr(foldername, 1, 4) . "-" . substr(foldername, 5, 2) . "-" . substr(foldername, 7, 2) . " " . substr(foldername, 9, 2) . "." . substr(foldername, 11, 2) . "." . substr(foldername, 13, 2)
    
    If (!ZipBackups) {
      FileCreateDir, %MCBackupPath%\%filetime%
    }
    if (LogBackups = "1") {   ;Runs log backups if suppose to
      BackupLog(filetime)
    } 
    else {
      AddText("[GUI] Log backups are disabled... skipping`n")
    }
    
    if (WorldBackups = "1") {   ;Runs world backups if suppose to
      Global WorldList
      
      WorkingOn = 1           ;Loop index
      Loop, Parse, WorldList, `,
      {
        If (A_LoopField != "") {
          BackupWorld(filetime, A_LoopField)
        }
      }
    }
    else {
      AddText("[GUI] World backups are disabled... skipping`n")
    }
  }
  else {
    AddText("[GUI] Backups are disabled... skipping`n")
  }
  
  IsBackingUp = 0
}


BackupWorld(backupfolder, world = "world") {
  Global MCServerPath
  Global MCBackupPath
  Global ZipBackups

  AddText("[GUI] Backing up " . world . "...")
  sleep 10
	SetWorkingDir, %MCServerPath%
  If (ZipBackups = "1") {
    AddText("Archiving to " . backupfolder . ".zip...")
    sleep 10
    filename = %MCBackupPath%\%backupfolder%.zip
    RunLine = 7za.exe a "%MCBackupPath%\%backupfolder%.zip" "%MCServerPath%\%world%\"
    RunWait, %RunLine%, , Hide
  }
  else {
    FileGetSize, OriginalSize, %MCServerPath%\%world%
    filename = %MCBackupPath%\%backupfolder%\%world%
    FileCopyDir, %MCServerPath%\%world%, %filename%
    If (ErrorLevel) {
      AddText("Error!`n")
      WriteErrorLog("Error backing up world " . %world% . ".")
      return
    }
  }
  Loop
  {
    IfExist, %filename%
    {
      If (!ZipBackups) {
        FileGetVersion, trash, %filename%       ;This is necessary to "refresh"
        FileGetSize, BackupSize, %filename%
        If (BackupSize = OriginalSize) {
          AddText("Complete!`n")
          break
        }
      }
      else {
        FileDelete, %MCServerPath%\server.log
        FileAppend, ,%MCServerPath%\server.log
        AddText("Complete!`n")
        break
      }
    }
    else {
      If (ZipBackups) {
        AddText("Error!`n")
        break
      }
    }
  }
}


BackupLog(backupfolder) {
  Global MCServerPath
  Global MCBackupPath
  Global ConsoleBox
  Global ZipBackups
  
  AddText("[GUI] Backing up server.log...")
  sleep 10
	SetWorkingDir, %MCServerPath%
  If (ZipBackups = "1") {
    AddText("Archiving to " . backupfolder . ".zip...")
    sleep 10
    filename = %MCBackupPath%\%backupfolder%.zip
    RunLine = 7za.exe a "%MCBackupPath%\%backupfolder%.zip" "%MCServerPath%\server.log"
    RunWait, %RunLine%,,Hide
  }
  else {
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
      If (!ZipBackups) {
        FileGetVersion, trash, %filename%         ;This is necessary to "refresh"
        FileGetSize, BackupSize, %filename%
        If (BackupSize = OriginalSize) {
          FileDelete, %MCServerPath%\server.log
          FileAppend, ,%MCServerPath%\server.log
          AddText("Complete!`n")
          break
        }
      }
      else {
        FileDelete, %MCServerPath%\server.log
        FileAppend, ,%MCServerPath%\server.log
        AddText("Complete!`n")
        break
      }
    }
    else {
      If (ZipBackups) {
        AddText("Error!`n")
        break
      }
    }
  }
}


CheckForRestarts() {
  Global LongRestartTimes
  ;Debug("LongRestartTimes", LongRestartTimes)
  CurrentTime := GetCurrentTime()
  If (InStr(LongRestartTimes, CurrentTime)) {
    return 1
  }
  return 0
}


InitiateAutomaticRestart() {
  Global WarningTimes
  Global IsAutomated
  IsAutomated = 1
  If (WarningTimes != "") {
    Global RestartCountDown
    Global WarningTimesArray
    Global WarningTimesIndex
  
    WarningTimesArray := CSVtoArray(WarningTimes)
    RestartCountDown := WarningTimesArray[1] + 1
    WarningTimesIndex = 1
    
    GoSub, AutomaticRestartTimer
  }
  else {
    AutomaticRestart()
  }
}


AutomaticRestart() {  
  Global RestartDelay
  Global WarnStop
  
  SendServer("save-all")
  StopServer()
  If (!WarnStop) {
    Temp := RestartDelay * 1000
    SetTimer, WaitForRestartTimer, %Temp%
    ;Debug("WaitForRestartTimer", Temp)
  }
}