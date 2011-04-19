/* 
*****************************************************************************************
cGui.ahk

Version 0.09 beta
April 19, 2008
by corrupt <apps4apps(a)gmail.com> http://apps4apps.filetap.com
*****************************************************************************************
As you may have guessed, this function isn't designed only for use with a RICHEDIT 
control. This is the reason for the additional params and If statements that are not all 
necessary for creating a RICHEDIT control (although only tested and used with RICHEDIT so
far). The following params can be used for creating a RICHEDIT control:

_Action		= Add			(to add to Gui2 use 2:Add)
							- to add to a different control or window use 1:Add:HWND (where 
							HWND is the HWND of the control or window to use as the parent) 
_ctrlID 	= ControlHWND  	(Returns the HWND of the control in the variable specified)
_x							(x position to place the control)
_y							(y position to place the control)
_w							(width of the control)
_h							(height of the control)
_ClassName	= RICHEDIT		(specify RICHEDIT to create a RICHEDIT 1.0 control)	
_dll		=				(leave blank for RICHEDIT)
_style		= 0				(specify 0 or leave blank for default style 0x54B371C4)
_exstyle	= 0				(specify 0 or leave blank for default style 0x200)	

Examples: 
to create a Richedit 1.0 control: cGUI("Add", REdit1, 10, 40, 480, 450, "RICHEDIT")
to create a Richedit 2.0 control: cGUI("Add", REdit1, 10, 40, 480, 450, "RichEdit20A")
or  RichEdit 2.0 unicode support: cGUI("Add", REdit1, 10, 40, 480, 450, "RichEdit20W")
*****************************************************************************************
*/

cGui(_Action, ByRef _ctrlID, _x=0, _y=0, _w=10, _h=10, _ClassName="", _dll="", _style=0, _exstyle=0)
{
  Global 
  local hInstance, ctrlHWND, _Action0, _Action1, _Action2, _Action3, _GuiNum, _Gui_hwnd, freehwnd0, freehwnd1, freehwnd2

; **** Determine the hWnd of the GUI
;   DetectHiddenWindows, On
;   SetTitleMatchMode, 1
;   WinWait %A_ScriptFullPath%,,1
  StringSplit, _Action, _Action, :
  If (_Action0="2") {
    _Action = %_Action2%
    _GuiNum = %_Action1%
  }
  If (_Action0="3") {
    _Action = %_Action2%
    _GuiNum = %_Action1%
    _Gui_hwnd = %_Action3%
  }
  Else
    _GuiNum = 1
  If !(_Gui_hwnd)
    _Gui_hwnd := cGUIxGuiGetHWND("", _GuiNum)

; **** _Action = Add  ****
If _Action = Add
{
  ; **** add default _dll values for common controls if not specified 
  If (_dll = "") {
    If (_ClassName = "RICHEDIT")
      _dll = riched32.dll
    Else If (InStr(_ClassName, "RichEdit20")) 
      _dll = riched20.dll
  }

    ; **** specify default style, exstyle
  If (InStr(_ClassName, "RichEdit")) {
    If !(_style)
      _style = 0x54B371C4
    If !(_exstyle)
      _exstyle = 0x200
  }

  ; **** Load library if necessary and keep track
  If (_dll != "") {
    If !InStr(__cGuiDll, _dll . "*") {
      hInstance := DllCall("LoadLibrary", "Str", _dll)
      If (ErrorLevel)
        Return "ERROR: Error loading " . _dll
      Else
        __cGuiDll .= _dll . "*" . hInstance . ":"
    }
  }
  Else
    hInstance = 0

  _ctrlID := DllCall("CreateWindowEx" 
  , "Uint", _exstyle                    ; ExStyle
  , "str",  _ClassName                  ; ClassName 
  , "str",  _ClassName				 	; WindowName 
  , "Uint", _style					  	; Style
  , "int",  _x                          ; Left 
  , "int",  _y                          ; Top 
  , "int",  _w                          ; Width 
  , "int",  _h                          ; Height 
  , "Uint", _Gui_hwnd                   ; hWndParent 
  , "Uint", 0                           ; hMenu 
  , "Uint", hInstance                   ; hInstance 
  , "Uint", 0)						  	; lpParam

  If (ErrorLevel != 0 OR _ctrlID = 0)
    Return "ERROR: Error creating control" . ErrorLevel . "/" . A_LastError

  ; **** initialize control ****
  If (InStr(_ClassName, "RichEdit")) {
    DllCall("SendMessage", "UInt", _ctrlID, "UInt", 0x435, "UInt", "0", "UInt", "2147483647") ; EM_EXLIMITTEXT
    DllCall("SendMessage", "UInt", _ctrlID, "UInt", 0x461, "Str", "", "Str", "") ; EM_SETTEXTEX
  Return _ctrlID
  }
} ; <Add>
Else If _Action = FreeDlls
{ 
  Loop, Parse, __cGuiDll, :
  {
    If (A_LoopField != "") {
      StringSplit, freehwnd, A_LoopField, *
      If (freehwnd2)
        DllCall("FreeLibrary", "UInt", freehwnd2)
    }
  }
  Return
} ; <FreeDlls>
Else
  Return
}

/* 
*****************************************************************************************
aka GuiGetHWND
*****************************************************************************************
*/
cGUIxGuiGetHWND(xxClassNN="", xxGUI=0) 
{
  If (xxGUI) 
    Gui, %xxGUI%:+LastFound 
  xxGui_hwnd := WinExist() 
  If xxClassNN= 
    Return, xxGui_hwnd 
  ControlGet, xxOutputVar, Hwnd,, %xxClassNN%, ahk_id %xxGui_hwnd% 
Return, xxOutputVar 
}
