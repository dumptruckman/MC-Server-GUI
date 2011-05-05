;Server Related Functions


BuildRunLine() {
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
  If (UseConcMarkSweepGC) {
    ServerArgs := ServerArgs . " -XX:+UseConcMarkSweepGC"
  }
  If (UseParNewGC) {
    ServerArgs := ServerArgs . " -XX:+UseParNewGC"
  }
  If (CMSIncrementalPacing) {
    ServerArgs := ServerArgs . " -XX:+CMSIncrementalPacing"
  }
  If (AggressiveOpts) {
    ServerArgs := ServerArgs . " -XX:+AggressiveOpts"
  }
  If (ParallelGCThreads != "") {
    ServerArgs := ServerArgs . " -XX:ParallelGCThreads=" . ParallelGCThreads
  }
  If (ExtraRunArguments != "") {
    ServerArgs := ServerArgs . " " . ExtraRunArguments
  }
  ServerArgs := ServerArgs . " -jar " . MCServerJar . " nogui"
  
  RunLine := "" . JavaExec . " " . ServerArgs
  return RunLine
}

ServerIsRunning() {
  Global ServerWindowPID
  
  ErrorLevel = 0
  Process, Exist, %ServerWindowPID%
  return ErrorLevel
}


SetServerStartTime() {
  Global ServerStartTime
  ServerStartTime := GetCurrentTime()
}


StartServer() {
  Global MCServerJar
  Global MCServerPath
  
  Debug("Server Start Process", "ServerStart()")
  
  If ((MCServerJar = "Set this") or (MCServerJar = "")) {            ;If not config'd
    ReplaceText("[GUI] Please take a look at the Server Configuration...  You must specify the MC Server Jar file.")
    return 0
  }
  
  If (!FileExist(MCServerPath . "\" . MCServerJar)) {
    ReplaceText("[GUI] Server Jar file does not exist! please correct this in Server Config.")
    return 0
  }
  
  If (VerifyPaths() = 0) {                   ;If paths are invalid
    ;ReplaceText("[GUI] Your paths are not set up properly, please make corrections in GUI Config before continuing.")
    return 0
  }
  
  If (ServerIsRunning()) {                   ;If server is running
    MsgBox, Server is already running!
    return 1      ;Special case return 1 since this should only happen if user starts server before it is automatically started.
  }
  
  Global IsBackingUp                        
  If (IsBackingUp) {                         ;If backup is in progress
    MsgBox, 0, Error, Cannot start server while backup is in progress., 5
    return 0
  }
  
  ;Grab some globals
  Global ServerWindowPID
  Global ServerWindowID
  Global AlwaysShowJavaConsole

  SetWorkingDir, %MCServerPath%
  
  Debug("Server Start Process", "Checking log size")
  
  ;If the log is really large, give the user a chance to clean it up.
  FileGetSize, LogFileSize, server.log, K
  If (LogFileSize > 1024) {
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
  
  Debug("Server Start Process", "Initializing Vars")
  
  InitializeVariables()                     ;Get variables ready for start
  Global ServerStarted
  
  Debug("Server Start Process", "Building Run Line")
  RunLine := BuildRunLine()
  
  Debug("Server Start Process", "Starting java")
  ReplaceText()                           ;Blanks the console output box
  ;Attempt to start Java for the server
  ;ReplaceText("[GUI] Starting Java...")
  GuiControl, , ServerStartProcess, Starting java
  If (AlwaysShowJavaConsole) {
    Run, %RunLine%, %MCServerPath%, Min UseErrorlevel, ServerWindowPID
  }
  else {
    Run, %RunLine%, %MCServerPath%, Hide UseErrorlevel, ServerWindowPID
  }
  If (ErrorLevel) {                          ;If there was a problem launching it initially, error out
    ServerStarted = 1
    GuiControl, , ServerStartProcess, Error!
    WriteErrorLog("Error starting server.  Windows system error code: " . A_LastError)
    MsgBox, 5, Server Start Error, Error starting the server.  Windows system error code: %A_LastError%.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry                         ;Give user option to retry
    {
      StartServer()
    }
    return 0
  }
  Debug("Server Start Process", "Java launched, waiting for PID")
  Process, Wait, %ServerWindowPID%, 5         ;Waits on the process to be ready
  If (ErrorLevel = 0) {                        ;If it times out waiting or the process doesn't exist, error out
    ServerStarted = 1
    GuiControl, , ServerStartProcess, Error!
    ;AddText("Error.")
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
  Debug("Server Start Process", "PID foud, waiting for console window")
  ;ReplaceText("[GUI] Waiting to hook console window...")
  GuiControl, , ServerStartProcess, Hooking console
  WinWait, ahk_pid %ServerWindowPID% ahk_class ConsoleWindowClass, , 5
  If (ErrorLevel) {                            ;Waits 5 seconds for the window to exist and, if it doesn't or there was some other error, errors out
    ServerStarted = 1
    GuiControl, , ServerStartProcess, Error!
    Loop                                      ;This loops ensures that it closes the Java process semi-gracefully
    {
      Process, Exist, %ServerWindowPID%
      If (ErrorLevel) {
        WinClose, ahk_pid %ServerWindowPID%
      }
      else {
        break
      }
    }
    GuiControl, Enable, ServerProperties      ;Re-enables the server.properties edit since it didn't start properly
    ;AddText("Error.")
    WriteErrorLog("Error starting server.  Could not hook Java console window.")
    MsgBox, 5, Server Start Error, Error starting the server.  Could not hook Java console window.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry
    {
      StartServer()
    }
    return 0
  }
  Debug("Server Start Process", "Hooking console window")
  ;Since the windows supposedly exists, attempts to hook onto it
  WinGet, ServerWindowID, ID, ahk_pid %ServerWindowPID% ahk_class ConsoleWindowClass
  If (ServerWindowID = 0) {                 ;If, for some reason, it doesn't hook the window, errors out
    ServerStarted = 1
    GuiControl, , ServerStartProcess, Error!
    Loop                                    ;This loops ensures that it closes the Java process semi-gracefully
    {
      Process, Exist, %ServerWindowPID%
      If (ErrorLevel) {
        WinClose, ahk_pid %ServerWindowPID%
      }
      else {
        break
      }
    }
    GuiControl, Enable, ServerProperties      ;Re-enables the server.properties edit since it didn't start properly
    ;AddText("Error.")
    WriteErrorLog("Error starting server.  Could not hook Java console window.")
    MsgBox, 5, Server Start Error, Error starting the server.  Could not hook Java console window.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
    IfMsgBox, Retry
    {
      StartServer()
    }
    return 0
  }
  Debug("Server Start Process", "Parsing restart times")
  ;If it made it this far, it should be good!
  
  Global LongRestartTimes
  Global RestartTimes
  Global SoonestRestart
  SetServerStartTime()
  LongRestartTimes := ParseRestartTimes(RestartTimes)
  SoonestRestart := GetSoonestRestart()
  GuiControl, , ServerStartProcess, Server started!

  Global ServerState
  ServerState := "ON"                     ;Stores the state of the server as ON
  
  Debug("Server Start Process", "Switching controls")
  ControlSwitcher("ON")                   ;Switches all the buttons
  
  ServerStarted = 1
  ;SetTimer, ServerRunningTimer, 250
  Debug("Server Start Process", "Complete!")
  return 1
}


StopServer() {
  Global StopTimeout
  Global ServerState
  Global WhatTerminated
  
  SendServer("stop")
  GuiControl, , ServerStartProcess, Stopping server
  ServerState = "OFF"
  If (WhatTerminated = "ERROR") {
    WriteErrorLog("Server error.  Java terminated unexpectedly.")
    MsgBox, 0, Server Error, Java terminated unexpectedly.  Check your configuration.  This has been logged in guierror.log`n`r`n`rThis window will close in 5 seconds, 5
  }
  StopTimeout = 0
  SetTimer, ServerStopTimer, 1000
  If (DebugMode()) {
    Debug("ServerStopTimer", "1000")
  }
}


SendServer(textline = "") {
  Global ServerWindowID

  ControlSendRaw,,%textline%, ahk_id %ServerWindowID%
  ControlSend,,{Enter}, ahk_id %ServerWindowID%
}


GetServerStartTime() {
  Global ServerStartTime
  return ServerStartTime
}