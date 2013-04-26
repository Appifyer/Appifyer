/*
class cApp ; app class
{
	
	__new(Name) ; Initializes an app
	{
		this["name"] := name
		return
	}
	
	getValue(key) ; Returns key value
	{
		global AppifyerApps
		value := ini_getValue(AppifyerApps, this["name"], key)
		return value
	}
	
	onlineGet(Query) ; Returns query for app
	{
		URL      := "http://www.appifyer.com/apps/appinfo.php?app=" . this["name"]
		length := httpQuery(IniQuery,URL)
		varSetCapacity(IniQuery,-1)
		StringReplace, IniQuery, IniQuery, <br>, `r, All ; Turns it into ini instead of html
		return ini_getValue(IniQuery, this["name"], Query)
	}
	
	onlineIni() ; Returns an ini
	{
		URL      := "http://www.appifyer.com/apps/appinfo.php?app=" . this["name"]
		length := httpQuery(IniQuery,URL)
		varSetCapacity(IniQuery,-1)
		StringReplace, IniQuery, IniQuery, <br>, `r, All ; Turns it into ini instead of html
		return IniQuery
	}
	
	Launch() ; Launches app and adds one to launchcount
	{
		Run, % This["Path"],, PID
		This["PID"] := PID ; Assigns the PID of the running app
		This["LaunchCount"] := This["LaunchCount"] + 1
		return PID
	}
	
}
*/

app_data(AppName, key) ; Returns key value
{
	;~ global AppifyerApps
	global cApps
	;~ value := ini_getValue(AppifyerApps, AppName, key)
	value := cApps[AppName, Key]
	return value
}

app_GetData(App, Query, Mode = "App") ; "Zizorz", "Hotkey" (gets data from Appifyer.com using $_GET)
{
	URL := "http://www.appifyer.com/api/appinfo.php?" ((Mode = "aid") ? "aid" : "app") "=" App
	length := httpRequest(URL, iniQuery)
	varSetCapacity(IniQuery,-1)
	StringReplace, IniQuery, IniQuery, <br>, `r, All ; Turns it into ini instead of html
	cQuery := cIni(IniQuery)
	Value := cQuery[App][Query]
	return Value
}
app_GetData_ini(App) ; Same as above, but only returns the ini. Specify app as "all" to return all apps.
{
	URL := "http://www.appifyer.com/apps/appinfo.php?app=" App
	length := httpQuery(IniQuery,URL)
	varSetCapacity(IniQuery,-1)
	StringReplace, IniQuery, IniQuery, <br>, `r, All ; Turns it into ini instead of html
	return IniQuery
}

app_LaunchCount(App, Increment = 1) ; Input an app to increase count by 1, input App, 0 to just check the LaunchCount
{
	global Ini_Apps, Ini_Settings, AppifyerApps
	Ini := ((App = "Appifyer")?(Ini_Settings):(Ini_Apps)), Sect := ((App = "Appifyer")?("General"):(App))
	If (App = "Appifyer")
	{
		IniRead, LaunchCount, %Ini%, %Sect%, LaunchCount, 0
		LaunchCount := LaunchCount + Increment
		IniWrite, %LaunchCount%, %Ini%, %Sect%, LaunchCount
	}
	else
	{
		prevValue := ini_getValue(AppifyerApps, App, "LaunchCount")
		ini_replaceValue(AppifyerApps, App, "LaunchCount", prevValue + 1)
	}
	return LaunchCount
}

app_SaveAll()
{
	;~ global AppifyerApps, ini_Apps
	global cApps, ini_Apps
	GoSub, SaveAllHelper
	return
}

ReceiveMsg(wParam="", lParam="") ; wParam = App (ID), lParam = Action (HEX)
{
	Action := lParam = 1 ? "Add" : lParam = 2 ? "Update" : "Unknown:" lParam
	App := wParam
	MsgBox % app_GetData(App, "Name", "AID") "`nAction: " Action
	return
}

SaveAllHelper: ; Tempfix to access global variables dynamically
Null := "" ;
Sections := cApps.Sections() ; !!! Error, crashes AHK
Sort, Sections, D`n
Loop, Parse, Sections, `n 
{
	App := A_LoopField
	;~ HK := ini_getValue(AppifyerApps, App, "Hotkey")
	HK := cApps[App]["Hotkey"]
	If (HK)
		Hotkey, %HK%, HotkeyRun, Off
	;~ ini_replaceValue(AppifyerApps, App, "File", %AppV%_File)
	if (%App%_Winkey = 1)
		WK := "#"
	else
		WK := "" ; Null
	cApps[App]["Hotkey"] := WK %App%_Hotkey
	cApps[App]["Winkey"] := "" ; Resets to 0 (note: Winkey value should not be used no more/decrepated)
	cApps[App]["Icon"] := %App%_Icon
	cApps[App]["Mode"] := %App%_Mode
	If (%App%_Text)
		cApps[AppV]["Name"] := %App%_Text
		;~ ini_replaceValue(AppifyerApps, AppV, "Name", %AppV%_Text)
}
;~ ini_save(AppifyerApps, ini_Apps)
cApps.Save(ini_Apps)
return

app_AddApp(App, File, FilePathType="", Version="", Active="1", Mode="OnDemand", LaunchCount="0", Icon="", Hotkey="") ; !!! Does not work
{
	;~ global AppifyerApps
	global cApps
	AppName := App
	App := varSafe(App)
	If Instr(File, A_ScriptDir) ; Is app in a subdir of Appifyer?
	{
		StringReplace, File, File, %A_ScriptDir%,, 1 ; Relativize
		StringTrimLeft, File, File, 1 ; Remove \
		FilePathType := "Relative"
	}
	;~ ini_insertSection(AppifyerApps, App, "Name=" . AppName . "`nFile=" . File . "`nFilePathType=" . FilePathType . "`nVersion=" . Version . "`nActive=" . Active . "`nMode=" . Mode . "`nLaunchCount=" . LaunchCount . "`nIcon=" . Icon . "`nHotkey=" . Hotkey)
	cApps.App := "Name=" . AppName . "`nFile=" . File . "`nFilePathType=" . FilePathType . "`nVersion=" . Version . "`nActive=" . Active . "`nMode=" . Mode . "`nLaunchCount=" . LaunchCount . "`nIcon=" . Icon . "`nHotkey=" . Hotkey
	return
}

/*
app_Appify() ; Input comes from %tmp% [NOTE! Not in use!]
{
	ini_load(Ini, A_Temp . "\appifyer_newapp.ini")
	do_hotkey := wParam
	msgbox %ini%
	return
}
*/

app_VersionCheck(App) ; Checks the app version against online version
{
	global ScriptVersion
	OnlineVersion := App_getData(App, "Version")
	AppVersion := (app_data(App, "Version")?app_data(App, "Version"):"Unknown")
	Version := ((App = "Appifyer")? ScriptVersion : AppVersion)
	ReturnValue := ((OnlineVersion > Version) ? OnlineVersion : 0)
	return ReturnValue
}

/*
app_VersionCheck_ini(App, Ini) ; Checks the app version against local version - Faster, since it only downloads the ini once
{
	
	global ScriptVersion
	OnlineVersion := ini_getValue(Ini, App, "Version")
	AppVersion := (app_data(App, "Version")?app_data(App, "Version"):0)
	Version := ((App = "Appifyer")? ScriptVersion : AppVersion)
	ReturnValue := ((OnlineVersion > Version) ? OnlineVersion : 0)
	return ReturnValue ; Outputs 0 if up-to-date, else new version number
}
*/

appi_DailyNotification(ID = "") ; Specify ID to retrieve specific news
{
	global ; To retrieve icons etc.
	URL      := "http://www.appifyer.com/news/dailynews.php"
	length := httpQuery(IniQuery,URL)
	varSetCapacity(IniQuery,-1)
	StringReplace, IniQuery, IniQuery, <br>, `r, All ; Turns it into ini instead of html
	
	LatestID := ini_getAllSectionNames(IniQuery)
	If (ID and (!InStr(LatestID, ID . "`,")))
		return "ERROR_NoSuchID"
	Else If (!ID) ; If no ID, retrieve latest (highest)
	{
		Sort, LatestID, D`,
		RegExMatch(LatestID, "(\d*),*", Output)
		ID := Output1
	}
	; Now, we have an ID (or have returned)
	ReturnID := ID
	Title := ini_getValue(IniQuery, ID, "Title")
	Body := ini_getValue(IniQuery, ID, "Body"), Body := RegExReplace(Body, "<lb>", "`n")
	Action := (ini_getValue(IniQuery, ID, "Action"))?(ini_getValue(IniQuery, ID, "Action")):("")
	;~ Icon := (ini_getValue(IniQuery, ID, "Icon"))?(ini_getValue(IniQuery, ID, "Icon")):(Img_AppifyerIcon)
	;~ Icon := %Icon%
	Notify(Title, Body, 14, "AC=" . Action, Img_AppifyerIcon)
	return ReturnID
}

varSafe(String)
{
	
	StringReplace, String, String, %A_Space%, _, All
	Chars = .,<>:;'"/|(){}=-+!`%^&*~
	Loop, Parse, Chars
      Stringreplace, String, String ,%A_loopfield%,, All
	return String
}

isVarSafe(String)
{
	Chars = .,<>:;'"/|(){}=-+!`%^&*~
	Loop, Parse, Chars
	{
		If (InStr(String, A_LoopField))
		return 0
	}
	If (InStr(String, A_Space))
		return 0
	else return 1
}

varUnSafe(String)
{
	StringReplace, String, String, _, %A_Space%, All
	return String
}

; AHK non-appifyer functions


ArraySort(object, key, order = "Down") ; Sorts an array by one of the members keys, by Fragman
{
    static obj, k, o
    ;Called by user
    if(order = "Up" || order = "Down")
    {
        obj := object
        k := key
        o := order
        SortString := ""
        Loop % obj.MaxIndex()
            SortString .= (A_Index = 1 ? "" : "`n") A_Index
        Sort, SortString, % "F ArraySort"
        obj := ""
        k := ""
        o := ""
        sorted := Array()
        Loop, Parse, SortString, `n
            sorted.Insert(object[A_LoopField])
        return sorted
    }
    else ;Called by Sort command
    {
        if(obj[object][k] != obj[key][k])
            return (o = "Down" && obj[object][k] < obj[key][k]) || (o = "Up" && obj[object][k] > obj[key][k]) ? 1 : -1
        else
            return 0
    }
}

getComputerName(in=""){
	EnvGet, ComputerName, COMPUTERNAME
	return ComputerName
}

getIP(){
	TmpFile := A_Temp "\ip.txt"
	UrlDownloadToFile, http://ip.ahk4.me/, % TmpFile
	FileReadLine, ExternalIP, % TmpFile, 1
	RegRead, ComputerName, HKEY_LOCAL_MACHINE, System\CurrentControlSet\Control\ComputerName, ComputerName
	FileDelete % TmpFile
	return ExternalIP
}

ConnectedToInternet(flag=0x40) { 
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}

MouseIsOver(WinTitle) { ; Used for the MButton @ Start menu
    MouseGetPos,,, Win
    return WinExist(WinTitle . " ahk_id " . Win)
}

WM_MouseMove(){ ; Thank you Nimda
 Global h_cursor_hand, h_old_cursor
 Static ListHandControls := "1,2,3,4,5,6"
 MouseGetPos,,,,Control,2 ; HWND
 If (Control <> "")
  Loop Parse, ListHandControls,`,
   If (Control = URL%A_LoopField%){
    h_old_cursor := DllCall("SetCursor", "uint", h_cursor_hand)
    return
   }
 Else If h_old_cursor
  DllCall("SetCursor", "uint", h_old_cursor)
 return
}

urlEncode(url){ ; [by RaptorX]
    f = %A_FormatInteger%
    SetFormat, Integer, Hex
    While (RegexMatch(url,"\W", var))
        StringReplace, url, url, %var%, % asc(var), All
    StringReplace, url, url, 0x, `%, All
    SetFormat, Integer, %f%
    return url
}

GdipSplash(Image, Img_Scale=1) ; By Tic (adapted by Sumon) Remember to shutdown the pToken when done
{
	;~ Img_Scale := 1

	If !pToken := Gdip_Startup()
	   return 0 ; Error

	; Prepare the GUI
	Gui, GdipSplashGUI:Default
	Gui, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
	Gui, Show, NA
	hwnd1 := WinExist() ; The handle to our window

	; Get a bitmap from the image
	pBitmap := Gdip_CreateBitmapFromFile(Image)
	If !pBitmap
		return 0 ; Error
	; Prepare the image & GDI
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	hbm := CreateDIBSection(Width//Img_Scale, Height//Img_Scale)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetInterpolationMode(G, 7)

	; Draw the image onto the GUI
	Gdip_DrawImage(G, pBitmap, 0, 0, Width//Img_Scale, Height//Img_Scale, 0, 0, Width, Height)
	x := (A_ScreenWidth-Width)//2, Y := (A_ScreenHeight-Height)//2 ; Centered
	UpdateLayeredWindow(hwnd1, hdc, x, y, Width//Img_Scale, Height//Img_Scale)

	; Select the object back into the hdc, delete it and the associated graphics
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)

	; Assign Actions to the window
	Return pToken
}

ShellMessage_Win(wParam, lParam) {
	global cApps ; Retrieve info
	If (wParam = 1) ;  HSHELL_WINDOWCREATED := 1
	{
		WinGetClass, Class, ahk_id %lParam%
		Sections := cApps.Sections()
		Loop, Parse, Sections, `n
		{
			App := A_LoopField
			if (Class = cApps[App]["WinHook"])
			{
				ToRun := cApps[App]["File"]
				Run, %ToRun%
			}
		}
	}
}

Gdip_PaintIcon(hwnd1, file, toSize=64) ; By sumon
{
   Gdip_GetDimensions(pBitmap := Gdip_CreateBitmapFromFile(file,, toSize), Width, Height)
   hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
   SetImage(hwnd1, hBitmap)
   Gdip_DisposeImage(pBitmap)
   return
}

RunAsAdmin() { ; by Shajul @ http://www.autohotkey.com/forum/viewtopic.php?t=50448
  Loop, %0%  ; For each parameter:
    {
      param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
      params .= A_Space . param
    }
  ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
      
  if not A_IsAdmin
  {
      If A_IsCompiled
         DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
      Else
         DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
      ExitApp
  }
}