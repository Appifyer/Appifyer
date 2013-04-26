ScriptVersion := "1.2"
	/*
	< Appifyer > (beta)
	Author: Simon Strålberg [sumon @ Autohotkey forums, simon . stralberg @ gmail . com]
	Autohotkey version: AHK_L (Unicode, x32)
	Dependencies:
		- AHK_L
		- Notify.ahk by gwarble & more [http://www.autohotkey.com/forum/viewtopic.php?t=48668]
		- AddGraphicButton () by Corrupt [http://www.autohotkey.com/forum/topic4047.html]
		
	CHANGELOG:
	v.
		- 1.2.1 Menu size changed to 16px.
		- 1.2. Beta version. Added a 16px icon. Removed "All apps up to date" even while notifications are enabled. Adding appspecific settings. Changed Tray menu to make Appsmenu default. Added a semitransparent Splashscreen.
			Changed "GUI, n: Default" to "GUI, Settings:Default" etc. Improved drag-n-drop and added support for dropping folders. Moved "App settings" to bottom (instead of top) of Appsmenu. Cleaned up source code.
		- 0.99 Update notification added. Live notification(s) added. Hotkeys now change directly, instead of sometimes requiring relaunch.
		- 0.98 Added update for all apps & Appifyer. Trying to launch a running app only activates it. Added fast access to Settings, and MClick on Windows Start button brings up App menu.
		- 0.97b Trimmed winkey into the "hotkey" value
		- 0.97 Added basic Settings/Help tabs, fixed an issue where non-existing icon crashed the script, Slightly improved Appify:, fixed a crash caused by a removed app.
		- 0.96 Rewritten for nicer code, proper ini system, GUI saves flawlessly. Hotkey behaviour is fine. Added "Modes".
		- 0.91 a proper INI system, Settings, update, etc.

	TODO:
		- Fix adding of apps (also GuiDrop)
		- Remove comments and prepare for publishing
		- Add appspecific settings
		- Add LaunchField
		- Fix the import/export of profiles
		
	WISHLIST:
		- Add Appifyer settings [Check]
		- Add scriptlet support & holder
		- [] Add hotstrings/gestures/launchfield?
		
	BUGS:
		- There can be variants of section like App_Name, App Name, which causes conflict.
		- AppifyerSettings doesn't get appropiately saved

	LICENSE: 
	For Appifyer, [http://www.autohotkey.net/~sumon/strictlicense.html]
	Icons are in many cases selfmade, in other cases downloaded from http://www.iconfinder.com from Iconpacks with WTF public license. Huge thanks to the authors of Brightset icon pack.
	
	Script created using Autohotkey [http://www.autohotkey.com], AHK_L by Lexikos
*/
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

; RunAsAdmin() ; Enabling this fixes a few issues with UAC, but elevates all launched scripts, which may be a security risk

/*****************
** Autoexecute  **
******************
*/
OnExit, Exit
If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have GDI+ on your system
   ExitApp
}

;~ FileCreateDir, Engines
;~ FileCreateDir, data
SplitPath, A_ScriptName,,,, ScriptName ; Removes extension
      Directory := A_AppData "\" ScriptName "\Engines" ; Store Appify.exe in AppData
FileCreateDir, %Directory%
FileInstall, engines\appify.exe, %Directory%\appify.exe
;~ FileInstall, data\changelog.txt, data\changelog.txt


OnMessage(0x8020, "ReceiveMsg") ; Receives a message with wParam lParam as App ID (from Appifyer.com) and Action - performs the action

/* SENDER SCRIPT as of below:
	TargetScriptTitle := "Appifyer Beta.ahk ahk_class AutoHotkey" ; This needs to detect any version of Appifyer, please
	DetectHiddenWindows On
	SetTitleMatchMode 2
	SendMessage, 0x8020, 3, 0x1,, %targetScriptTitle%
*/

Gui, Native: +LastFound
hWnd := WinExist() 
DllCall("RegisterShellHookWindow", Uptr, hWnd) ; Uint
MsgNum := DllCall("RegisterWindowMessage", Str, "SHELLHOOK")
OnMessage(MsgNum, "ShellMessage_Win") ; See function ShellMessage_Win()

;~ OnMessage(617070, "app_Appify") ; Not working atm

#Include inc\vars.ahk ; Defines global variables, such as img_GuiHeader
#include inc\traymenu.ahk ; Adds a Traymenu

cApps := cIni(ini_Apps) ; Initialize ini class/array from file
cSettings := cIni(ini_Settings) 
cApps_original := cIni(ini_Apps), cSettings_original := cIni(ini_Settings)
;~ cApps_original := cApps.Clone(), cSettings_original := cSettings.Clone() ; For "reset" option [WARNING: Shallow copy!?]

cSettings["General"]["Launchcount"]++

Gosub, DefineHotkeys

If (cSettings["General"]["Notifications"] != "Disabled")
{
	pToken_Loading := GdipSplash(Img_GuiLoading)
	Sleep 2000
	Gdip_Shutdown(pToken_Loading)
	Gui, GdipSplashGUI:Destroy
}
;~ Notify("Appifyer:", "Appifyer (v " ScriptVersion ") has been launched`n[" getComputerName() "]", 2,, Img_AppifyerIcon)
If (cSettings["General"]["AutoUpdate"] != "Disabled")
	Settimer, Update, -6000 ; AutoUpdate 6 seconds after startup - because autostarts are annoying

;~ SetTimer, Notification, % "-" (cSettings["General"]["UpdateDelay"])?(cSettings["General"]["UpdateDelay"]):(8000) ; Welcome-message, from server-side
return

#If MouseIsOver("ahk_class Button") ; For Start Button MClick
MButton:: ; Has to be explicitly declared (not using Hotkey command?)
Gosub, AppMenu ; Calls AppMenu, which in its' turn responds to being called by MButton and displays another "Start Menu"
return 

/* Metro interface: Inactive, beta
#if MouseIsOver("ahk_class Progman") or MouseIsOver("ahk_class WorkerW") or MouseIsOver("ahk_class Shell_TrayWnd") or (MouseisOver("ahk_id " MetroGUI) AND MetroGui) ; Desktop or taskbar or Metro GUI
MButton::
Gosub, GuiMetroInterface
return

LWin & Space::
Gosub, GuiMetroInterface
return
*/

#if 

return

; INCLUDES containing subroutines/functions

#Include inc\Appmenu.ahk ; Subs: AppMenu: & AppMenuRun:
#Include inc\GUIfuncs.ahk ; Every GUI related function and label "functions"
#Include inc\metro.ahk ; Optional launcher: Metro style
;~ #Include inc\intellilaunch.ahk ; Optional launcher: Launchy style
#include inc\definehotkeys.ahk ; Is called when hotkeys need to be updated
#include inc\feedback.ahk ; Feedback function

return

/****************
** Main routine
** (thus: This belongs in "main file")
*****************
*/

RunApp: ; From Hotkey or Appmenu
Sections := cApps.Sections()
Loop, Parse, Sections, `n
{
	If (A_ThisHotkey && (A_ThisHotkey = cApps[A_LoopField]["Hotkey"])) ; Triggered by hotkey: Find app to launch
		App := A_LoopField
	else if (A_ThisMenuItem = cApps[A_LoopField]["Name"]) ; Triggered by Menu
		App := A_LoopField
}

cApps[App, "LaunchCount"] := cApps[App]["LaunchCount"] ? cApps[App]["LaunchCount"] + 1 : 1 ; Initiate/increment launchcount
If (A_ThisHotkey AND WinExist("ahk_id" MetroGui))
	Gui, Metro: Destroy
Path := cApps[App]["File"]

StringLeft, FileTest, Path, 1 ; If relative position
if (Filetest = "\")
	File := A_ScriptDir . File

SplitPath, Path,,,, AppNoExt
Process, Exist, %AppNoExt%.exe
ProcessError := Errorlevel
If (!ProcessError)
	Run, % cApps[App]["File"],,, App_PID
else
{	
	SoundPlay, %A_WinDir%\Media\ding.wav
	WinActivate, ahk_pid %ProcessError%
	return
}

If (cSettings["General"]["Notifications"] != "Disabled")
{
	Icon := ((cApps[App]["Icon"]) ? (cApps[App]["Icon"]) : ((InStr(cApps[App]["File"], ".exe")) ? cApps[App]["File"] : Img_StdApp)) ; Display ICO > EXE > Default
	DisplayHK := (cApps[App]["Hotkey"] AND A_ThisMenuItem)?(" (" . cApps[App]["Hotkey"] . ")"):("") ; Display hotkey if launched from menu
	Notify("Appifyer", "Launching " cApps[App]["Name"] . DisplayHK, 3,, Icon) ; Bug(?) sometimes the icon may not appear correctly
}
return

Exit: ; If OnExit is declared, here is the exit
Gdip_Shutdown(pToken)
;~ app_SaveAll()
;~ ToolTip, Saving...
Sections := cApps.Sections()
Sort, Sections, D`n
Loop, Parse, Sections, `n 
{
	App := A_LoopField
	WK := %App%_WinKey ? "#" : ""
	cApps[App]["Hotkey"] := %App%_Hotkey ? WK %App%_Hotkey : cApps[App]["Hotkey"] ; This and below: Fetch fields from GUI
	cApps[App]["Icon"] := %App%_Icon ? %App%_Icon : cApps[App]["Icon"]
	cApps[App]["Mode"] := %App%_Mode ? %App%_Mode : cApps[App]["Mode"]
	cApps[App]["Winkey"].Delete() ; Resets to 0 (note: Winkey value should not be used no more/decrepated)
	;~ Tooltip %A_Index%
}
cApps.Save(ini_Apps)
cSettings.Save(ini_Settings)
ExitApp
return

; #f5:: ; Uncomment for testing
; reload

/***************
**    GUI     **
****************
*/

AppSettings:
#include inc\settings.ahk
return

/***************
** Functions  **
****************
*/
#Include inc\functions.ahk
return