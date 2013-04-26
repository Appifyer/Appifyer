DefineHotkeys: ; *** *** LIST APPS & hotkey'em *** *** ALSO DOES EXTRA STUFF

AppsMenuHotkey := ( cSettings["General"]["AppsMenuHotkey"] != "") ? cSettings["General"]["AppsMenuHotkey"] : "#space"
If (PrevHotkey != "")
	Hotkey, %PrevHotkey%, AppMenu, Off ; Value from GuiSubmit
Hotkey, %AppsMenuHotkey%, AppMenu, On

; App hotkeys

Sections := cApps.Sections() ; Appsnumber = N apps
Loop, Parse, Sections, `n
{
	App := A_LoopField
	If (cApps[App]["Active"] = "0") ; If app is not set as active
		continue
	HK := cApps[App]["Hotkey"]
	If (HK) ; TO-DO: Add check for "isValidHotkey(HK)"
	{
		Hotkey, %HK%, RunApp, On
/*		StringReplace, AppToRun, HK, #, Win
		StringReplace, AppToRun, ApptoRun, ^, Ctrl
		StringReplace, AppToRun, AppToRun, !, Alt
		StringReplace, AppToRun, AppToRun, +, Shift
		%ApptoRun% := cApps[App]["File"] ; Definies f.ex. "WinCtrlB = BitlyButler[path]"
		ApptoRunName%ApptoRun% := App
*/
	}
	
	; Every time hotkeys get defined, run AlwaysOn apps
	If ((cApps[App]["Mode"] == "AlwaysOn") AND (!InStr(RunningApps, App)))
	{
		File := cApps[App]["File"]
		Process, Exist, % File
		PID := ErrorLevel
		If (!ErrorLevel)
		{
			Run % File
			RunningApps := App "`n" RunningApps
			If (cSettings["General"]["Notifications"] != "Disabled")
			{
				Icon := ((cApps[App]["Icon"]) ? (cApps[App]["Icon"]) : ((InStr(cApps[App]["File"], ".exe")) ? cApps[App]["File"] : Img_StdApp)) ; Display ICO > EXE > Default
				DisplayHK := (cApps[App]["Hotkey"] AND A_ThisMenuItem)?(" (" . cApps[App]["Hotkey"] . ")"):("") ; Display hotkey if launched from menu
				Notify("Appifyer", "Autostarting " cApps[App]["Name"] . DisplayHK, 3,, Icon) ; Bug(?) sometimes the icon may not appear correctly
			}
		}
	}
}
return