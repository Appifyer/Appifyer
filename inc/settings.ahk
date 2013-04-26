If (GuiBuilding = 1)
	return
GuiBuilding := 1
Gui, Metro:Destroy
Gui, Settings:Default
Gui, Destroy
Gui, Font, s12, Agency MB

TabVisible := (A_ThisMenuItem = "Settings")?(2):(A_ThisMenuItem = "Help")?(3):(1)

Gui, Add, Picture, x0 y0, % img_GuiBG
Gui, Add, Tab2, x10 y5 h40 +Buttons Choose%TabVisible%, Apps||Settings|Help
Gui, Tab, Apps
	Gui, Add, Picture, x0 y0, % img_MenuApps

Gui, Font, s8, Verdana
Ynum := 0 ; Counts columns

sorted := "", sorted := [] ; Sort cApps by [App]["Name"] - see http://www.autohotkey.com/community/viewtopic.php?f=1&t=89528&p=555469 by jethrow
k := "", v := "", t := "", key := "", item := ""
for k,v in cApps
	sorted[v.name] := k
for key, item in sorted
	t .= item "`n"
Sections := SubStr(t, 1, -1) ; `n-delimited list sorted by alphabetical order (removing the last `n)
AppsCount := "" ; Reset

Loop, Parse, Sections, `n
	++Appscount ; Get # of apps in total

SysGet, CheckboxWidth, 71 ; Workaround for checkbox transparancy issue
SysGet, CheckboxHeight, 72 ; ^
If (!AppsCount)
	Gui, Add, Text, x302 y275 w340 Center BackgroundTrans, Welcome to Appifyer!`n`nLet's start by adding some apps... `n`n Click the "Add app" button and browse to and select the file/application that you want to add, or drag and drop the file/application onto this GUI.
else
Loop, Parse, Sections, `n
{
	App := A_LoopField
	File := cApps[App]["File"], Icon := cApps[App]["Icon"],
	;~ AppV := isVarSafe(App) ? App : varSafe(App)
	AppName := (cApps[App]["Name"]) ? (cApps[App]["Name"]) : ("Unknown")
	If (cApps[App]["Active"] = 0)
		continue
	File := ((cApps[App]["FilePathType"] = "Relative") ? (A_ScriptDir "\" File) : cApps[App]["File"])
	Icon := (Icon ? Icon : File)
	Mode := ( (cApps[App]["Mode"] = "AlwaysOn") ? ("AlwaysOn") : ("OnDemand") )
	ModePic := ((Mode="AlwaysOn")?(Img_GuiModeA):(Img_GuiModeO))
	%App%_Mode := Mode
	If (StrLen(AppName) > 12)
	{
		StringLeft, AppDisplay, AppName, 10
		AppDisplay := AppDisplay ".."
	}
	else
		AppDisplay := AppName
	CX := (A_Index > 11) AND (AppsCount > 11 ) ? c6 : c1
	;~ CX := (A_Index >= 10) AND (AppsCount > 10 ) ? c6 : c1
	If (A_Index = 12 AND (AppsCount > 11 ))
		Ynum := 1
	else
		++Ynum
	Ypos:=Ynum*40+25
	If (!FileExist(Icon))
		Icon := Img_StdIcon
	;~ Menu, AppMenu, Add, %App%, AppMenuRun	
	Gui, Add, Picture, w32 h32 x%CX% y%ypos% hwndsIcon%A_Index% v%App%_Icon gGuiChangeIcon 0xE
	Gdip_PaintIcon(sIcon%A_Index%, icon, 32)
	
	Gui, Add, Text, xp+35 yp+7 w100 v%App%_Text gGuiChangeName BackgroundTrans, % AppDisplay
	Gui, Add, Picture, xp+95 w32 h32 yp-10 v%App%_Mode AltSubmit BackgroundTrans gGuiChangeMode, % ModePic
	Gui, Add, Picture, xp+40 w16 h16 yp+7 v%App%_Settings gGuiAppSettings AltSubmit BackgroundTrans, % Img_GuiMoreSettings
	Gui, Add, Picture, xp+35 w16 h16 yp v%App%_Delete gGuiRemoveApp AltSubmit BackgroundTrans, % Img_GuiRemoveApp
	;~ HotkeyPic := ((App_Data(App, "Hotkey"))?(Img_GuiHasHotkey):(Img_GuiSetHotkey))
	;~ Gui, Add, Picture, x%c2% w32 h32 yp-5 v%AppV%_SetHotkey gGuiSetHotkey, %HotkeyPic%
	;~ HK := App_Data(App, "Hotkey")
	HK := cApps[App]["Hotkey"]
	StringReplace, HK, HK, #,, All ; Clears out the Win key selection for the hotkey field
	Gui, Add, Hotkey, xp+30 w80 yp-2 v%App%_Hotkey -TabStop, %HK%
	;~ WK := (InStr(App_Data(App, "Hotkey"), "#") ? 1 : 0)
	WK := (InStr(cApps[App]["Hotkey"], "#") ? 1 : 0)

	Gui, Add, Checkbox, xp+95 yp+3 w%CheckboxWidth% h%CheckboxHeight% Checked%WK% v%App%_Winkey -TabStop +AltSubmit +BackgroundTrans
}
Gui, Add, Button, x%c6% y500 w160 h30 gGuiAddApp, &Add app
Gui, Add, Button, xp+170 yp w90 h30 gGuiReset, &Reset
Gui, Add, Button, xp+100 yp w140 h30 gGuiSubmit Default, &Save 
GuiControl, Focus, % Img_GuiHeader
Gui, +Border
Gui, Color, FFffFF
; SETTINGS
Gui, Tab, Settings
	Gui, Add, Picture, x0 y0, % img_MenuSettings
	;~ Gui, Add, Pic, x20 y40, %Img_GuiHeaderSettings%
	Gui, Font, s12, Verdana
	++GB_number ; VERY ugly temp-fix due to how AddGraphicButton works (need to create a new one for each time to show GUI)
	; [ PREFERENCES ]
	Gui, Add, Groupbox, x20 y65 w280 h180 cA0A0A0, Preferences
		Gui, Add, Pic, x30 yp+22 vBtn_ChangeAutostart gChangeAutostart, % (FileExist(A_Startup . "\Appifyer.lnk") ? img_GuiBtnOn : Img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gChangeAutostart, Autostart

		;~ AutoUpdate := ini_getValue(AppifyerSettings, "General", "AutoUpdate")
		AutoUpdate := cSettings["General"]["AutoUpdate"]
		Gui, Add, Pic, x30 yp+30 vBtn_AutoUpdate gGUIChangeAutoupdate, % ((AutoUpdate = "Enabled") ? img_GuiBtnOn : img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gGUIChangeAutoupdate, Autoupdate

		;~ Gui, Add, Pic, x20 yp+30 vBtn_Notifications gGuiChangeNotifications, % ((ini_getValue(AppifyerSettings, "General", "Notifications") = "Enabled") ? img_GuiBtnOn : img_GuiBtnOff)
		Gui, Add, Pic, x30 yp+30 vBtn_Notifications gGuiChangeNotifications, % (cSettings["General"]["Notifications"] = "Enabled") ? img_GuiBtnOn : img_GuiBtnOff
		Gui, Add, Text, yp+8 xp+86 gGuiChangeNotifications, Notifications

		RegRead, OCI, HKEY_CLASSES_ROOT, Appify\shell\open\command
		Gui, Add, Pic, x30 yp+30 vBtn_OneClickInstall gGuiOneClickInstall, % (OCI ? img_GuiBtnOn : img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gGuiOneClickInstall, One-click-install
	; [ FUNCTIONS ]
	Gui, Add, Groupbox, x310 y65 w280 h180 cA0A0A0, Functions
		AddGraphicButton("AppifyerUpdate" . GB_Number, img_BlackUpdate, "xp+10 yp+22 w80 h32 gUpdate")
			Gui, Add, Text, yp+8 xp+86 gUpdate BackgroundTrans, Update
		AddGraphicButton("AppifyerStatistics" . GB_Number, img_Statistics, "xp-86 yp+30 w80 h32 gGuiListLaunchCounts")
			Gui, Add, Text, yp+8 xp+86 gGuiListLaunchCounts BackgroundTrans, Statistics
		AddGraphicButton("AppifyerFeedback" . GB_Number, img_Feedback, "xp-86 yp+30 w80 h32 gFeedback")
			Gui, Add, Text, yp+8 xp+86 gFeedback BackgroundTrans, Feedback
	
	; [ LAUNCH MODES ]
	Gui, Add, Groupbox, x20 y248 w570 h176 cA0A0A0, Launch modes ; 280 + 10 + 280 = 570
	;~ Gui, Add, Groupbox, x310 yp w280 h180 cA0A0A0, Launch hotkeys ; Just for the text
		Gui, Add, Pic, x30 yp+22 vBtn_AppsMenu gChangeAutostart, % (FileExist(A_Startup . "\Appifyer.lnk") ? img_GuiBtnOn : Img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gChangeAutostart, Appsmenu (default) ; !!! Change this !!!
		
		Gui, Add, Pic, x30 yp+30 vBtn_StartButton gGuiBtn, % (FileExist(A_Startup . "\Appifyer.lnk") ? img_GuiBtnOn : Img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gChangeAutostart, Start Button ; !!! Change this !!!
		
		Gui, Add, Pic, x30 yp+30 vBtn_QuickType gChangeAutostart, % (FileExist(A_Startup . "\Appifyer.lnk") ? img_GuiBtnOn : Img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gChangeAutostart, Quicktype ; !!! Change this !!! 
		
		Gui, Add, Pic, x30 yp+30 vBtn_MetroMenu gNYI, % (FileExist(A_Startup . "\Appifyer.lnk") ? img_GuiBtnOn : Img_GuiBtnOff)
		Gui, Add, Text, yp+8 xp+86 gNYI, Metro menu ; !!! Change this !!!		
		
		
	; [ LAUNCH HOTKEYS ]
		AddGraphicButton("AppMenuHotkey" . GB_Number, img_BlackSettings, "xp+204 yp-122 h32 w80 gGuiChangeAppifyerHotkey")
			Gui, Add, Text, yp+9 xp+86 gGuiChangeAppifyerHotkey BackgroundTrans, Set hotkey
			
		AddGraphicButton("StartButtonHotkey" . GB_Number, img_BlackSettings, "xp-86 yp+30 w80 h32 gGuiChangeAppifyerHotkey")
			Gui, Add, Text, yp+8 xp+86 gGuiChangeAppifyerHotkey BackgroundTrans, Set hotkey
		
		AddGraphicButton("QuickTypeHotkey" . GB_Number, img_BlackSettings, "xp-86 yp+30 w80 h32 gGuiChangeAppifyerHotkey")
			Gui, Add, Text, yp+8 xp+86 gGuiChangeAppifyerHotkey BackgroundTrans, Set hotkey
		
		AddGraphicButton("MetroMenuHotkey" . GB_Number, img_BlackSettings, "xp-86 yp+30 w80 h32 gNYI")
			Gui, Add, Text, yp+8 xp+86 gNYI BackgroundTrans, Set hotkey
	
	Gui, Add, Button, x20 yp+40 w180 h40 gGuiSubmit vSubmitBtn Default, &Save all settings
	Gui, Font, s8, Verdana
; HELP
Gui, Tab, Help

	Gui, Add, Picture, x0 y0, % img_MenuHelp
	;~ Gui, Add, Pic, x20 y50 BackgroundTrans, %img_GuiHeaderHelp%
	Gui, Add, Text, w590 x40 yp+80 BackgroundTrans, To run apps, first set them up under `"Apps`". You can either add apps manually, or drag them (or a folder containing an executable) onto the Appifyer apps GUI. `n`nTo launch apps, either press their associated hotkey(s), or use the appsmenu (Default hotkey: Windows key + Spacebar). You can now click the App you want to launch`, or press the first letter in its' name.`n`nYou can find more apps on www.appifyer.com`, linked here to the right. If you have any issues while using Appifyer`, don't hesitate to contact the author (link also available to the right).`n`nHave fun!
	;~ Gui, Add, Pic, x35 yp+155, %img_GuiHeaderCopyright%
	Gui, Font, cC2BAB0 italic
	Gui, Add, Text, x40 y510 w910 BackgroundTrans, Appifyer™ is under beta development by Simon Strålberg (2011-2012) and is protected by international copyright laws.
	Gui, Font, c056B9E w700 underline
	Gui, Add, Text, x740 y80 w160 Right gVisit vOnlineAppifyer hWndURL1 , www.appifyer.com
	Gui, Add, Text, xp yp+16 wp Right gVisit vOnlineAutohotkey hwndURL2, www.autohotkey.com
	;~ Gui, Add, Text, xp yp+16 gVisit vChangelog hwndURL6, Changelog
	Gui, Add, Text, xp yp+16 wp Right gVisit vOnlineLicense hwndURL3, Online License
	Gui, Add, Text, xp yp+16 wp Right gVisit vOnlineHelp hwndURL4, Online help (PDF)
	Gui, Add, Text, xp yp+16 wp Right gFeedback hwndURL5, Contact the author
	Gui, Font, cDefault norm
	

Gui, Tab, Apps ; Future controls are assigned to Apps

	GuiBuilding := 0
	Gui, +MinSize +MaxSize +Resize -MaximizeBox +E0x10 ; E0x10 is related to file droppping
	Gui, Show, w946 h540, Appifyer ;w220 original, 420 wide | 770
	OnMessage(0x200, "WM_MouseMove")
		h_cursor_hand := DllCall("LoadCursor", "uint", 0, "uint", 32649)