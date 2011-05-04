MainTimer:
  MainProcess()
return

ServerRunningTimer:
  ProcessLog()
return


DebugModeTimer:
  If (DebugMode()) {
    Debug("Server PID", ServerWindowPID)
    Debug("Server Window ID", ServerWindowID)
  }
return


/*
RestartAtScheduler:
  If (CheckForRestarts())
  {
    WhatTerminated := "AUTO"
    InitiateAutomaticRestart()
  }
return
*/


;ServerUpTimer:
  ;ServerUpTime := ServerUpTime + 1
;return


GetCharKeyPress:
  IfWinActive, ahk_pid %GUIPID%
  {
    GuiControlGet, InputEnabled, Enabled, ConsoleInput
    If (InputEnabled) {
      GuiControlGet, FocusedControl, Focus
      GuiControlGet, ThisTab,, ThisTab
      If (FocusedControl != "Edit1" and ThisTab = "Main Window") {
        Input, KeyPressed, I L1 T.1
        If (KeyPressed) {
          ControlSend, Edit1, %KeyPressed%, A
          GuiControl, focus, ConsoleInput
        }
      }
    }
  }
return


ServerStopTimer:
  If (!ServerIsRunning()) {
    ServerStarted = 0
    PlayerList.Remove(PlayerList.MinIndex(), PlayerList.MaxIndex())
    TV_Delete()
    SetTimer, ServerStopTimer, Off
    ;SetTimer, ServerRunningTimer, Off
    ;SetTimer, ServerUpTimer, Off
    If (DebugMode()) {
      Debug("ServerStopTimer", "Off")
      ;Debug("ServerRunningTimer", "Off")
      ;Debug("ServerUpTimer", "Off")
    }
    ;SetTimer, RestartAtScheduler, Off
    ServerWindowPID = 0
    ServerWindowID = 0
    ControlSwitcher("OFF")
    GuiControl,, ServerStatus, DOWN
    AddText("[GUI] Server Stopped`n")
    If (WhatTerminated = "AUTO") {
      If (AutomatemateBackups) {
        Backup()
      }
      else {
        AddText("[GUI] Automatic backups are disabled...skipping.`n")
      }
    }
    else {
      AddText("[GUI] Backups skipped when manually stopping the server.`n")
    }
    AddText("[GUI] Finished`n")
  }
  StopTimeout := StopTimeout + 1
  If (StopTimeout = 60) {
    Process, Close, ServerWindowPID
  }
return


WaitForRestartTimer:
  SetTimer, WaitForRestartTimer, 1000
  If (DebugMode()) {
    Debug("WaitForRestartTimer", "1000")
  }
  If (!ServerIsRunning()) {
    If (IsBackingUp = 0) {
      SetTimer, WaitForRestartTimer, Off
      If (DebugMode()) {
        Debug("WaitForRestartTimer", "Off")
      }
      Loop
      {
        If (StartServer()) {
          break
        }
        If (ServerState = "ON") {
          break
        }
      }
    }
  }
return


AutomaticRestartTimer:
  If ((WarningTimesIndex > WarningTimesArray.MaxIndex()) or (WarningTimesArray[WarningTimesIndex] = "")) {
    If (RestartCountDown = 0) {
      AutomaticRestart()
      SetTimer, AutomaticRestartTimer, Off
      If (DebugMode()) {
        Debug("AutomaticRestartTimer", "Off")
      }
      return
    }
    RestartCountDown := RestartCountDown - 1
    return
  }

  If (WarningTimesArray[WarningTimesIndex] = RestartCountDown) {
    WarningMessage := "say Automatic restart in " . RestartTime := ConvertSecondstoMinSec(RestartCountDown) . "."
    SendServer(WarningMessage)
    If (WarningTimesIndex = WarningTimesArray.MaxIndex()) {
      WarningMessage := "say Please reconnect in approximately " . ConvertSecondstoMinSec(RestartCountDown + TimeToReconnect) . "."      
      SendServer(WarningMessage)
    }
    WarningTimesIndex := WarningTimesIndex + 1
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
  If (DisplayBytesRx < 1024) {
    DisplayBytesRx := DisplayBytesRx . " B/s"
  }
  else If ((DisplayBytesRx >= 1024) and (DisplayBytesRx < 1048576)) {
    DisplayBytesRx := (DisplayBytesRx / 1024) . " KB/s"
  }
  else If (DisplayBytesRx >= 1048576) {
    DisplayBytesRx := (DisplayBytesRx / 1048576) . " MB/s"
  }
  If (DisplayBytesTx < 1024) {
    DisplayBytesTx := DisplayBytesTx . " B/s"
  }
  else If ((DisplayBytesTx >= 1024) and (DisplayBytesTx < 1048576)) {
    DisplayBytesTx := (DisplayBytesTx / 1024) . " KB/s"
  }
  else If (DisplayBytesTx >= 1048576) {
    DisplayBytesTx := (DisplayBytesTx / 1048576) . " MB/s"
  }
  GuiControl, , BytesRxPerSecond, %DisplayBytesRx%
  GuiControl, , BytesTxPerSecond, %DisplayBytesTx%
  LastBytesDataRx := BytesDataRx
  LastBytesDataTx := BytesDataTx
return