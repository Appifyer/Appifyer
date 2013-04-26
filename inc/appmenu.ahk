;; APPMENU

AppMenu: ; VERSION 0.9a: Uses new ini load functions

Key := RegExReplace(A_ThisHotkey, "[#^!+]")
KeyWait, % Key, T2
If (A_TimeSinceThisHotkey > 1000 AND A_TimeSinceThisHotkey < 2000) ; Was held for > 1 seconds
{
	Gosub, AppSettings
	return 
} 
Menu, AppMenu, Add ; (To enable "Delete")
Menu, AppMenu, Delete ; Clears the menu

sorted := [] ; Sort cApps by [App]["Name"] - see http://www.autohotkey.com/community/viewtopic.php?f=1&t=89528&p=555469 by jethrow
for k,v in cApps
	sorted[v.name] := k
for each,item in sorted
	t .= item "`n"
Sections := SubStr(t, 1, -1) ; `n-delimited list sorted by alphabetical order (removing the last `n)
Loop, Parse, Sections, `n
{
	App := A_LoopField, File := cApps[App]["File"], Icon := cApps[App]["Icon"]
	AppName := cApps[App]["Name"] ? cApps[App]["Name"] : App
	If (cApps[App]["Active"] = 0)
		continue
	Menu, AppMenu, Add, %AppName%, RunApp
		File := ((cApps[App]["FilePathType"] = "Relative") ? (A_ScriptDir "\" File) : (cApps[App]["File"]))
		SplitPath, File,,, FileExt
		Icon := Icon ? Icon : FileExt = "exe" ? File : Std_AppIcon
		If (!FileExist(Icon))
			Icon := Std_AppIcon
		Menu, AppMenu, Icon, %AppName%, %Icon%,, 16
}

Menu, AppMenu, Add ; --- ; Below: App settings at the bottom of apps menu
Menu, AppMenu, Add, App settings, AppSettings
	Menu, AppMenu, Icon, App Settings, %img_settings%,, 16


If (A_ThisHotkey = "MButton" AND A_TimeSinceThisHotkey < 1000) ; If triggered from the start menu
{
	x := 2
	y := A_ScreenHeight-42
	CoordMode, Menu, Screen
	Menu, AppMenu, Show, %x%, %y%
	CoordMode, Menu, Relative
	return
}
else
	Menu, AppMenu, Show
return