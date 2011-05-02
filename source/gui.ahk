/*
*************
* GUI SETUP *
*************
*/
Gui, Add, Tab2, w500 buttons gGUIUpdate vThisTab, Main Window||Server Config|GUI Config ;|Plugin Config
Gui, Margin, 5, 5
;Gui, +Resize +MinSize


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
Gui, Add, GroupBox, x10 y%GUIPosY% w200 h105 vServerControlBox, Server Control
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
GuiControlGet, GUIPos, Pos, ServerControlBox
GUIPosW := GUIPosW - 20
Gui, Add, Button, xs w%GUIPosW% vJavaToggle gJavaToggle, Show Java Console
JavaToggle_TT := "This will show/hide the Java Console running in the background.  This feature was added for debugging purposes and may be removed later"
GuiControl, Disable, JavaToggle ;Disable toggle at startup
;GuiControl, Disable, SaveWorlds
GuiControl, Disable, WarnRestart
GuiControl, Disable, ImmediateRestart
;GuiControl, Disable, StopServer

;Server Info
GuiControlGet, GUIPos, Pos, ServerControlBox
GUIPosX := GUIPosX + GUIPosW + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w200 h%GUIPosH% vServerInfoBox, Server Information
;Server running indicator
Gui, Add, Text, yp+15 xp+10 Section, Status: 
Gui, Add, Text, ys w80 vServerStatus cRed Bold, DOWN
;Memory counter text control
Gui, Add, Text, xs w180 vServerMemUse, Memory Usage: NA
;CPU Load indicator
Gui, Add, Text, xs w150 vServerCPUUse, CPU Load: NA
;Next Restart indicator
Gui, Add, Text, xs w180 vNextRestart, Auto-Restart in: NA

;GUI Info
GuiControlGet, GUIPos, Pos, ServerInfoBox
GUIPosX := GUIPosX + GUIPosW + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w130 h%GUIPosH% vGUIInfoBox, GUI Information
;Version Information
Gui, Add, Text, yp+15 xp+10 Section, Version %VersionNumber%
;Memory counter text control
Gui, Add, Text, xs w110 vGUIMemUse, Memory Usage: NA
;CPU Load indicator
Gui, Add, Text, xs w110 vGUICPUUse, CPU Load: NA

;Network Info
GuiControlGet, GUIPos, Pos, GUIInfoBox
GUIPosX := GUIPosX + GUIPosW + 5
Gui, Add, GroupBox, y%GUIPosY% x%GUIPosX% w155 h%GUIPosH% vNetworkInfoBox, Network Information
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
Gui, Add, CheckBox, xp+10 yp+15 Section vAutomateBackups gAutomateBackups, Automate Backups
AutomateBackups_TT := "Whether or not to perform backups on automatic restarts"
GuiControl,, AutomateBackups, %AutomateBackups%
Gui, Add, CheckBox, xs vWorldBackups gWorldBackups, Backup Worlds
WorldBackups_TT := "Whether world folders will be backed up when automatically restarted or when manual backup is pressed."
GuiControl,, WorldBackups, %WorldBackups%
Gui, Add, CheckBox, xs vLogBackups gLogBackups, Backup server.log
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
Gui, Add, Text, xs, Enter the time at which you would like to run automated`n restarts.  Separate each time by commas (Blank for none):`n Hold your mouse over the box for format details!
Gui, Add, Edit, xs w280 r1 -multi vRestartTimes, %RestartTimes%
RestartTimes_TT = 
(
You can enter these times in a wide variety of formats.
The main conditions of formatting are:
Time segments listed largest to smallest, so year, then month, then day and hours, then minutes, then seconds
Dates and times must be seperated by a space
Dates must have an associated time
24-hour format is assumed if AM/PM is not specified

Good:
  2011/05/2 10:00:00, 5:30am, 12am, 20110702 035602
Bad:
  2011/05/210:00:00, 31/5/2011 10pm
  
Additionally, you may add a single amount of time in which the server will restart after it starts.
Examples: 
  10hours30minutes
  1d14s
)
;Restart warning periods field
Gui, Add, Text, xs, Enter the times, at which automated restarts will warn the`n the server, in seconds.  List them in descending order,`n separated by commas with NO Spaces:
Gui, Add, Edit, xs w280 -multi vWarningTimes, %WarningTimes%
WarningTimes_TT := "The players will be warned at these many seconds before the server is restarted"
;Field for amount of time to add to the warning period to tell players to reconnect
Gui, Add, Text, xs Section, Amount of time (in seconds) to tell players to wait to`nreconnect. (Displayed on the last warning): 
Gui, Add, Edit, ys yp+5 w30 number -multi vTimeToReconnect, %TimeToReconnect%
TimeToReconnect_TT := "This amount of time will be added to the above Warning Times as an indication of when players should attempt to reconnect to your server"
;Field for delay before restart
Gui, Add, Text, xs yp+35 Section, Delay before auto-restarting (in seconds):
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


/*
;FOURTH TAB - PLUGIN CONFIG
Gui, Tab, Plugin Config
Gui, Add, GroupBox, x10 y30 w200 vMCSignOnDoorBox, MC Sign On Door
GuiControlGet, GUIPos, Pos, MCSignOnDoorBox
BoxW := GUIPosW
;MC Backup Path field
Gui, Add, Text, x20 yp+20 Section vMCSoDText, MCSoD Jar File: 
GuiControlGet, GUIPos, Pos, MCSoDText
Temp := BoxW - GUIPosW - 75
Gui, Add, Edit, ys yp-3 w%Temp% -wrap -multi r1 vMCSoDJar, %MCSoDJar%
Gui, Add, Button, ys yp-2 gMCSoDJarBrowse, Browse
MCSoDJar_TT := "Please select the .jar file for MC Sign On Door"
*/