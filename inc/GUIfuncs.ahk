SettingsGuiClose:
GuiClose:
/* Debugging got too complex for something not 100% necessary
If (cApps.Sections() != cApps_original.Sections()) ; Check if changes have been made
{
	MsgBox, 36, Save?, You have added/removed apps. Do you want to keep these changes?
	IfMsgBox, Yes
	{
		Gosub, GuiSubmit
		return
	}
}
else
{
	cApps := cApps_original.clone(), cSettings := cSettings_original.clone() ; Replenish
	Gui, Settings:Destroy ; Destroy
}
*/
Gui, Destroy
return

GuiReset:
MsgBox, 49, Reset apps?, Are you sure that you want to reset the changes you have made today? (Will use the latest safety copy`, and reload Appifyer).
IfMsgBox, No
	return
cApps_original.Save(ini_Apps)
cSettings_original.Save(ini_Settings)
Reload
return

GuiSaveNoClose:
NoClose := "True"
GuiSubmit:
If (NoClose = "True")
	Gui, Submit, nohide
else
	Gui, Submit

Sections := cApps.Sections()
Loop, Parse, Sections, `n ; Save those pesky apps
{
	App := A_LoopField
	HK := cApps[App]["Hotkey"]
	If (HK)
		Hotkey, %HK%, RunApp, Off
	WK := %App%_WinKey ? "#" : ""
	cApps[App]["Hotkey"] := WK %App%_Hotkey
	cApps[App]["Winkey"] := "" ; Resets to 0 (note: Winkey value should not be used no more/decrepated)
	cApps[App]["Icon"] := %App%_Icon
	cApps[App]["Mode"] := %App%_Mode
}


Notify("Appifyer:", "Saved settings...", 3,, img_AppifyerIcon)
Gosub, DefineHotkeys
return

GuiChangeName:
StringTrimRight, App, A_GuiControl, 5 ; _text (-)
InputBox, Name, App name:, Change app name,,300,100,,,,, % cApps[App]["Name"]
If Errorlevel
	return

cApps[App]["Name"] := Name ; Assign new value

If (StrLen(Name) > 13)
	{
		StringLeft, Name, Name, 10
		Name := Name ".."
	}
GuiControl,, %A_GuiControl%, %Name%
%App%_Text := Name
return

GuiAppSettings:
StringTrimRight, App, A_GuiControl, 9 ; _settings (-)
Gui, advAppSettings: Default
Gui, Destroy
Gui, Color, ffFFff
Gui, Add, Text,, % cApps[App]["Name"] " settings"
Gui, Add, Text,, Hook onto window
Gui, Show, w300 h220, % cApps[App]["Name"]
return

InputBox, App, App name:, Change app name,,300,100,,,,, %App%
If Errorlevel
	return
AppV := varSafe(App)
If (StrLen(App) > 13)
	{
		StringLeft, AppDisplay, App, 10
		AppDisplay := AppDisplay ".."
	}
else
	AppDisplay := App
GuiControl,, %A_GuiControl%, %AppDisplay%
%AppV%_Text := NewName

return

GuiAddApp:
FileSelectFile, AppPath, S, Apps, Please select the App you wish to add...,
If (ErrorLevel = 1)
	return
SplitPath, AppPath, Filename
StringTrimRight, FileName, FileName, 4 ; Removes .ext
InputBox, AppName, Add App, Select a name for your chosen App...,, 300, 130,,,,, %FileName%
If (ErrorLevel = 1) ; If cancel
	return
; Else

AddApp: ; Adds the app
App := "a" A_Now


cApps[App]["File"] := AppPath
cApps[App]["Name"] := AppName

If (A_ThisMenuItem != "App settings") ; Metro GUI
{
	Loop, % MetroPos["maxCount"]
	{
		if !MetroPos[A_Index, "App"]
		{
			MetroPos[A_Index, "App"] := App
			cApps[App]["MetroPos"] := A_Index
			break
		}	
	}
	Gui, Metro: Destroy
	Gosub, GUIMetroInterface
}
else
{
	Gosub, GuiSubmit
	Gosub, AppSettings ; Would refresh the apps listing
}
return

GuiBTN: ; Generic label
If (Appi_SoundsON AND FileExist(Sound_Click))
	SoundPlay, %Sound_Click%

If (A_GuiControl = "Btn_StartButton")
{
	If (cSettings["Launching"]["StartButton"] = "Enabled")
	{
		cSettings["Launching"]["StartButton"] := "Disabled"
		GuiControl,, %A_GuiControl%, % img_GuiBtnOff
	}
	else
	{
		cSettings["Launching"]["StartButton"] := "Enabled"
		GuiControl,, %A_GuiControl%, % img_GuiBtnOn
	}
}
return

GuiChangeIcon:
StringTrimRight, App, A_GuiControl, 5 ; _icon (-)
File := cApps[App]["File"]
AppName := cApps[App]["Name"]
SplitPath, File,, Dir
FileSelectFile, NewIcon, 1, %Dir%, Select a new icon for %AppName%, Icon or exe (*ico; *.exe)
If Errorlevel
	return
%App%_Icon := NewIcon
GuiControl,, %App%_Icon, %NewIcon%
return

GuiChangeMode:
StringTrimRight, App, A_GuiControl, 5 ; _mode (-)
;~ App := varUnsafe(AppV)
Mode := %App%_Mode ; Before
Mode := ((Mode = "AlwaysOn")?("OnDemand"):("AlwaysOn")) ; Toggle
%App%_Mode := Mode, cApps[App]["Mode"] := Mode ; After
NewIcon := ((Mode = "AlwaysOn")?(Img_GuiModeA):(Img_GuiModeO))
Descriptive := ((Mode = "AlwaysOn")?("Always on"):("On demand")) ; Adds spaces
Notify("Appifyer:", "Toggled " cApps[App]["Name"] " to """ Descriptive """ mode", 2,, NewIcon)
;~ Traytip, Appifyer:, Toggled %App% to `"%Descriptive%`" mode, 4, 1
GuiControl,, %A_GuiControl%, % NewIcon
If (cSettings["General"]["Sound"] != "Disabled")
	Soundplay, % Sound_Click
return

GuiRemoveApp:
If (A_GuiControl)
	StringTrimRight, App, A_GuiControl, 7 ; _delete (-)
else if (A_ThisMenuItem)
	App := Metro_ContextMenuApp
MsgBox, 52, Remove app?, % "Remove " cApps[App]["Name"] "?`nNote: You will only remove the app from Appifyer."
IfMsgBox, No
	return

If (A_GuiControl)
{
	Gui, Settings:Default
	GuiControl, Hide, %App%_Icon
	GuiControl, Hide, %App%_Mode
	GuiControl, Disable, %App%_Text
	GuiControl, Hide, %App%_Mode
	GuiControl, Hide, %App%_Delete
	GuiControl, Disable, %App%_Hotkey
	GuiControl, Disable, %App%_Winkey
}
else if (A_ThisMenuItem)
{
	Gui, Metro:Default
	GuiControl, Hide, App_%App%
	GuiControl, Hide, Name%App%
	GuiControl, Hide, Ico_%App%
	GuiControl, Hide, Hotk%App%
}

If (cApps[App]["MetroPos"])
	MetroPos[cApps[App]["MetroPos"], "App"].Delete()

SoundPlay, data\sounds\paper_rip2.wav
cApps.Delete(App) ; Clears all associated data to the app

Gosub, Definehotkeys

return

GuiContextMenu:
MsgBox More opts
return

SettingsGuiDropFiles:  ; Support drag & drop. Most of below code is from GuiAddApp
Loop, parse, A_GuiEvent, `n
{
	AppPath := A_LoopField  ; Get the first file
	SplitPath, AppPath, FileName,, Ext, NameNoExt
	If (!Ext) ; Is a folder
	{
		MsgBox, 36, Look in folder?, You dropped a folder (%FileName%) onto the Apps interface. Do you want to look in the folder for executables to add?
		IfMsgBox, No
			break
		; else
		Loop, %AppPath%\*.exe, 0, 1
		{
			SplitPath, A_LoopFileName, FileName, OutDir, Ext, NameNoExt
			InputBox, AppName, Add App, Select a name for %FileName%,, 300, 130,,,,, %NameNoExt%
			If (ErrorLevel = 1)
				continue
			AppPath := AppPath "\" FileName ;  & AppName (from above)
			Gosub, AddApp
		}
	}
	else ; Else, is a file
	{
		InputBox, AppName, Add App, Select a name for %FileName%,, 300, 130,,,,, %NameNoExt%
		If (ErrorLevel = 1)
			return
		; else
		GoSub, AddApp
	}
}

;~ cApps.Save(ini_Apps) ; Note: Should not save unless asked for
Gosub, AppSettings ; Has to reload, unfortunately
return

GuiHelp:
Help:
MsgBox, 32, Appifyer help, Appifyer v. %ScriptVersion% (Beta)`nAuthor: Simon Strålberg`n`nTo run Apps, first set them up using the Settings menu. You can either add Apps manually, or drag them onto the Appifyer apps GUI. Save your changes when finished.`n`nTo launch apps, either press their associated hotkey(s), or use the Appsmenu (Default hotkey: Windows key + Spacebar). You can now click the App you want to launch`, or press the first letter in its' name.
return
NYI:
MsgBox, 64, Not yet implemented, Sorry! The function you tried to access has not yet been fully implemented.
return

GuiChangeNotifications:
If (Appi_SoundsON AND FileExist(Sound_Click))
	SoundPlay, %Sound_Click%
;~ If (ini_getValue(AppifyerSettings, "General", "Notifications") = "Enabled")
If (cSettings["General"]["Notifications"] = "Enabled")
{
	;~ ini_replaceValue(AppifyerSettings, "General", "Notifications", "Disabled")
	cSettings["General"]["Notifications"] := "Disabled"
	GuiControl,, Btn_Notifications, % img_GuiBtnOff
	;~ AddGraphicButton("AppifyerNotifications" . GB_Number, "data\img\ico\disabled.ico")
}
else
{
	;~ ini_replaceValue(AppifyerSettings, "General", "Notifications", "Enabled")
	cSettings["General"]["Notifications"] := "Enabled"
	GuiControl,, Btn_Notifications, % img_GuiBtnOn
	;~ AddGraphicButton("AppifyerNotifications" . GB_Number, "data\img\ico\enabled.ico")	
}
return

GuiChangeAppifyerHotkey:
IniRead, PrevHotkey, %ini_Settings%, General, AppsMenuHotkey, ; Iniread from FILE, to get the actual (saved) value
InputBox, AppsMenuHotkey, Appifyer appmenu hotkey, Type an AHK compatible hotkey,, 300, 140,,,,, %AppsMenuHotkey%
;~ ini_replaceValue(AppifyerSettings, "General", "AppsMenuHotkey", AppsMenuHotkey)
cSettings["General"]["AppsMenuHotkey"] := AppsMenuHotkey
return

GuiOneClickInstall:
If (Appi_SoundsON AND FileExist(Sound_Click))
	SoundPlay, %Sound_Click%
RegRead, OCI, HKEY_CLASSES_ROOT, Appify\shell\open\command
OCI_status := ((OCI != "")?"Active":"Inactive")
RegDelete, HKEY_CLASSES_ROOT, Appify ; Clear
If (OCI_status = "Active")
{
	Notify("Appifyer", "Removed custom URI from the registry", 4,, Img_AppifyerIcon)	
	GuiControl,, Btn_OneClickInstall, % img_GuiBtnOff
	;~ AddGraphicButton("AppifyerOCI" . GB_Number, "data\img\ico\install.ico")
	return
}
RegWrite, REG_SZ, HKEY_CLASSES_ROOT, Appify, URL Protocol, ""
RegWrite, REG_SZ, HKEY_CLASSES_ROOT, Appify\DefaultIcon,, `"%A_ScriptDir%\Appifyer.exe,1`"
RegWrite, REG_SZ, HKEY_CLASSES_ROOT, Appify\shell\open\command,, `"%A_ScriptDir%\Engines\Appify.exe`" `"`%1`"
; Verify the registry has been read
RegRead, OCI, HKEY_CLASSES_ROOT, Appify\shell\open\command
OCI_status := ((OCI != "")?"Active":"Inactive")
If (OCI_status = "Active") ; If registry was written to
{
	Notify("Appifyer", "Added custom URI (Appify:app) to the registry", 4,, img_AppifyerIcon)
	GuiControl,, Btn_OneClickInstall, % img_GuiBtnOn
	;~ AddGraphicButton("AppifyerOCI" . GB_Number, "data\img\ico\install_a.ico")
}
else
	Notify("Appifyer", "Could not add custom URI`nTry running Appifyer as administrator, and try again", 4,, Img_AppifyerIcon)
return

ChangeAutostart:
If (Appi_SoundsON AND FileExist(Sound_Click))
	SoundPlay, %Sound_Click%
IfNotExist %A_Startup%\Appifyer.lnk ; Adds Appifyer to Autostart
{	
	GuiControl,, Btn_ChangeAutostart, %Img_GuiBtnOn%
	FileCreateShortcut , %A_ScriptDir%\%A_ScriptName%, %A_Startup%\Appifyer.lnk, %A_ScriptDir%
	Notify("(+) Autostart", "Added " . A_ScriptName . " to autostart", 3)
	;~ AddGraphicButton("AppifyerAutostart" . GB_Number, "\ico\enabled.ico")
	;~ Menu, Tray, Icon, Autostart, %Img_Autostart_On%,, 32
	; Menu, SettingsMenu, Check, Autostart
}
Else
{
	GuiControl,, Btn_ChangeAutostart, %Img_GuiBtnOff%
	FileDelete, %A_Startup%\Appifyer.lnk
	Notify("(-) Autostart", "Removed " . A_ScriptName . " from autostart", 3)
;~ AddGraphicButton("AppifyerAutostart" . GB_Number, "data\img\ico\disabled.ico")
;~ Menu, Tray, Icon, Autostart, %Img_Autostart_Off%,, 32
; Menu, SettingsMenu, UnCheck, Autostart
}
return

GuiListLaunchCounts:
Gui, Statistics:Default
Gui, Destroy
Gui, Color, ffFFff
Gui, Font, s18, Verdana ; Header
Gui, Add, Text, x10, App            Launches
Gui, Font, s10, Verdana

Sorted := "", Sorted := [] ; Sort cApps by [App]["Name"] - see http://www.autohotkey.com/community/viewtopic.php?f=1&t=89528&p=555469 by jethrow
k := "", v := "", t := "", key := "", item := ""
for k,v in cApps
	sorted[v.name] := k
for key, item in sorted
	t .= item "`n"
Sections := SubStr(t, 1, -1) ; `n-delimited list sorted by alphabetical order (removing the last `n)
AppsCount := "" ; Reset
Loop, Parse, Sections, `n
{
	App := A_LoopField
	Gui, Add, Text, x10, % cApps[App]["Name"]
	;~ Gui, Add, Text, x200 yp, % app_LaunchCount(App, "0")
	Gui, Add, Text, x200 yp, % (cApps[App]["LaunchCount"] ? cApps[App]["LaunchCount"] : "0") ; A literal zero
}
Gui, Show
Return

Notification:
If (!cSettings["Notifications"]["Update0.99"] > 0)
{
	Notify("Patch 0.99 installed", "Change notes:`n- Patch notifications && patch log`n- Live notification support`n- More...",6,, Img_Ok_Large)
	iniWrite, 1, data\AppifyerSettings.ini, Notifications, Update0.99
	return
}
If (ConnectedToInternet())
{
	IniRead, NotifiedIDs, data\AppifyerSettings.ini, Notifications, DailyNews, 0
	Loop
	{
		If (!InStr(NotifiedIDs, "`," . A_Index))
		{
			ID := A_Index
			break
		}
		else If (InStr(NotifiedIDs, A_Index)) ; Temp
			return ; Temp
	}
	NotifiedID := appi_DailyNotification()
	NotifiedIDs := NotifiedIDs . "`," . NotifiedID
	IniWrite, %NotifiedIDs%, data\AppifyerSettings.ini, Notifications, DailyNews
}
return

GUIChangeAutoUpdate:
AutoUpdate := cSettings["General"]["AutoUpdate"]
If (Appi_SoundsON AND FileExist(Sound_Click))
	SoundPlay, %Sound_Click%
If (AutoUpdate = "Enabled")
{
	cSettings["General"]["AutoUpdate"] := "Disabled"
	GuiControl,, Btn_AutoUpdate, % img_GuiBtnOff
}
else
{
	cSettings["General"]["AutoUpdate"] := "Enabled"
	GuiControl,, Btn_AutoUpdate, % img_GuiBtnOn
}
return

UpdateGUI: ; Triggered by the Notify(), makes sure the GUI gets shown
Update: 
; Check version 
OutOfDateApps := "" ; Clear
If (!ConnectedToInternet())
{
	Notify("No connection", "You do not seem to have a working internet connection`,`nso Appifyer will not even try to update.", 3)
	return
}
Gui, Update:Default
Gui, Destroy
Gui, Color, ffFFff
Gui, Font, s10, Verdana
Gui, Add, Pic,, % img_GuiHeaderUpdate
cAllAppsIni := cIni(app_getData_ini("all")) ; From online

;~ Sections := ini_getAllSectionNames(AppifyerApps) ; From locally
Sections := cApps.Sections() ; From locally
Sort, Sections, D`n
;~ Sections := "Appifyer`n" Sections
Loop, Parse, Sections, `n
{
	App := A_LoopField
	Gui, Add, Text, x20, % cApps[App]["Name"]
	;~ Version := app_VersionCheck_ini(cApps[App]["Name"], AllAppsIni)
	Version := (cAllAppsIni[cApps[App]["Name"]]["Version"] > cApps[App]["Version"]) ? (cAllAppsIni[cApps[App]["Name"]]["Version"]) : (0) ; Retrieve newest version - 0 means "up-to-date"
	;~ MsgBox % "Online version: " cAllAppsIni[cApps[App]["Name"]]["Version"] "`nLocal version: " cApps[App]["Version"]
	If (Version != 0)
	{
		Version_%App% := Version, prevVersion_%App% := cApps[App]["Version"]
		Gui, Add, Pic, yp x143 yp-1 gUpdateApp vUpdate%App%, % Img_Sync
		++OutOfDateApps ; For later use
	}
	;~ else if (!InStr(AllAppsIni, cApps[App]["Name"])) ; Information unknown, usually because of non-Appifyer app
	else if (!InStr(cAllAppsIni.Sections(), cApps[App]["Name"])) ; Information unknown, usually because of non-Appifyer app
		Gui, Add, Pic, yp x143 yp-1, % Img_Unknown
	else
		Gui, Add, Pic, yp x143 yp-1, % Img_OK
	Color := (Version != 0) ? "93220b" : "266b12" ; Red/green text
	Gui, Font, c%Color% w700
	Gui, Add, Text, x234 yp-1, % cApps[App]["Version"] ? Round(cApps[App]["Version"], 2) : ""
	;~ Gui, Add, Text, x234 yp-1, % (App = "Appifyer") ? (ScriptVersion) : ((cApps[App]["Version"]) ? Round(cApps[App]["Version"], 2) : "")
	Gui, Font, cDefault Norm
	App := "" ; Clear the "App" var
}


Gui, Add, Button, x10 w160 yp+40 gGuiClose, Done
Gui, Add, Button, x180 w100 yp gGuiUpdateHelp, Help

If (A_ThisLabel = "UpdateGUI" OR (A_GuiControl))
{
	Gui, Show
}
else if (cSettings["General"]["Notifications"] != "Disabled") OR (A_GuiControl)
{
	If (OutOfDateApps)
		Notify("Update...", OutOfDateApps . " app" . (OutOfDateApps>1 ? "s are" : " is") . " out of date. Click here to read more.", 5, "AC=UpdateGUI", Img_Sync)
	;~ else
		;~ Notify("Up to date!", "All your apps are up to date!", 3, "AC=UpdateGUI", Img_OK_Large)
}
return

GuiUpdateHelp:
MsgBox, 32, About Appifyer Update, Appifyer update syncs any known information about your apps' version towards the Appifyer database`, to detect if you need to update something. `n`nTo update`, click the "sync" button next to the app that needs to be updated.`n`nNon-Appifyer app versions can not be detected`, so they have a questionmark next to them.
return

GuiSetMetroBG:
InputBox, URL, Background URL, Set background image URL,, 500, 100,,,,, % cSettings["Metro"]["BackgroundURL"]
If Errorlevel
	return
Tooltip Loading...
remoteResource_Clear("", "custom_bg.jpg")
cSettings["Metro"]["BackgroundURL"] := URL ; Assign new value
newBG := remoteResource("custom_bg.jpg", URL)
GuiControl,, MetroBG, % newBG
Tooltip
return

GuiSetMetroColor:
if (A_ThisMenuItem)
	App := Metro_ContextMenuApp
else
	return
cApps[App, "MetroColor"] := A_ThisMenuItem
If (MetroGUI)
{
	val := cApps[App]["MetroColor"]
	tmp := Colors%val%
	LinearGradient(Frame%App%, tmp, Positions) ; Background FRAME
	Gui, Metro:Default
	GuiControl, MoveDraw, Name%App%	
	GuiControl, MoveDraw, Ico_%App%	
	GuiControl, MoveDraw, HotK%App%	
}
return

UpdateApp:
StringTrimLeft, App, A_GuiControl, 6 ; (-) Update
prevVersion := prevVersion_%App%, version := Version_%App%
GuiControl,, %A_GuiControl%, %Img_BlackUpdate%
;~ uApp := VarUnsafe(App)
;~ MsgBox, 68, Update %uApp%?, Current version: %prevVersion%`nAvailable version: %Version%
;~ If (ErrorLevel)
	;~ return
;~ Location := app_Data(uApp, "File")
Location := cApps[App]["File"], Name := cApps[App]["Name"]
StringLower, lowApp, Name
If (App = "Appifyer")
{
	RegRead, OCI, HKEY_CLASSES_ROOT, Appify\shell\open\command
	OCI_status := ((OCI != "")?"Active":"Inactive")
	If (OCI_status = "Active")
		Run, Appify:Appifyer
	else
		Notify("Error while updating " App, "To update Appifyer, One-click-install must be properly enabled", 3,, Img_Error)
	return
} ; Else...
UrlDownloadToFile, % "http://www.appifyer.com/apps/app/" lowApp "/" cApps[App]["Name"] ".exe", % Location ; IMPORTANT! "Name" cannot be trusted, this must be fixed ffs
If (!FileExist(Location))
{
	Notify("Error while updating " App, App . " could not be updated.`nTry again or update manually", 3,, Img_Error)
	GuiControl,, %A_GuiControl%, %Img_Error%
	return
}
cApps[App]["Version"] := Version
;~ cApps.Save(ini_Apps)
GuiControl,, %A_GuiControl%, %Img_OK_Large%
Notify("Updated " cApps[App]["Name"], cApps[App]["Name"] " was succesfully updated to version " Round(Version, 2), 3,, Img_OK_Large)
return

Visit: ; All GUIControls with a very simple action (such as visiting a site)
If (A_GuiControl = "OnlineAppifyer")
	Run, http://www.appifyer.com
Else If (A_GuiControl = "OnlineAutohotkey")
	Run, http://www.autohotkey.com
Else If (A_GuiControl = "Changelog")
	Run, data\Changelog.txt
Else If (A_GuiControl = "OnlineHelp" OR A_ThisMenuItem = "Help")
{
	If (FileExist("Appifyer Help.pdf") AND A_ThisMenuItem = "Help")
		Run, "Appifyer Help.pdf"
	else
		Run, http://www.appifyer.com/apps/app/appifyer/Appifyer`%20help.pdf
}
Else If (A_GuiControl = "OnlineLicense")
	Run, http://www.autohotkey.net/~sumon/strictlicense.html
Else if (A_ThisMenuItem = "&Get more apps")
	Run, http://www.appifyer.com/apps
else
	Run, http://www.appifyer.com
return