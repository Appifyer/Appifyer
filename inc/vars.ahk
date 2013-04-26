/* GUI Names:
Feedback
Settings
Gui Loading: 79
*/

C1 := 30 ; Columns for GUIs
C2 := 125
C3 := 220
C4 := 320
C5 := 420
C6 := 500 ; For apps column B

URL := "http://www.appifyer.com/img/application/"
Std_Icon := remoteResource("Appifyer.ico")
Std_AppIcon := remoteResource("app.ico")

Appi_SoundsOn := ((User_SoundsOn) ? (User_SoundsOn) : (1))


remoteFolder := remoteResource("get", "dir")
remoteResource("Load", URL)
Loop, %remoteFolder%\*.*, , 1
    folderSize += %A_LoopFileSize%
;~ MsgBox %folderSize% (for %remoteFolder%)
if (folderSize < 1000000) ; Less than Appify.exe
	stylishMsg := MsgBox("Please be patient while Appifyer downloads image resources (first time only)", "loading...", "Progress")
;~ if FileExist("data\AppifyerApps.ini")
	;~ MsgBox("We have detected that you may have added apps while using an older version of Appifyer. Keep them?", "transfer apps?")
ini_Apps := remoteResource("AppifyerApps.ini")
ini_Settings := remoteResource("AppifyerSettings.ini")
Sound_Click := remoteResource("click.wav")

GuiControl,, stylishProgress, +10
; Images
Img_AppifyerIcon := remoteResource("appifyer.ico")
Img_AppifyerIcon16 := remoteResource("appifyer16.ico")
Img_Appifyer := Img_AppifyerIcon
Img_AppifyerHeader := ; 
Img_StdIcon := remoteResource("app.ico")
Img_StdApp := remoteResource("app.ico")
GuiControl,, stylishProgress, +10
Img_GuiHeader := remoteResource("header.jpg") ;
Img_GuiHeaderHelp := remoteResource("header_help.jpg") ; 
;~ Img_GuiHeaderCopyright := remoteResource("header_copyright.jpg") ;
;~ Img_GuiHeaderSettings := remoteResource("header_settings.jpg") ; 
;~ Img_GuiHeaderAdvanced := remoteResource("header_settings.jpg") ; Same as above for now
Img_GuiHeaderUpdate := remoteResource("header_update.jpg") ;
GuiControl,, stylishProgress, +10
Img_GuiRemoveApp := remoteResource("remove.ico")
Img_GuiModeA := remoteResource("mode_alwayson.ico")
Img_GuiModeO := remoteResource("mode_ondemand.ico")
;~ Img_GuiLikeApp := remoteResource("like.ico")
GuiControl,, stylishProgress, +10
Img_GuiReviewApp := remoteResource("review.ico")
Img_GuiUpdateApp := remoteResource("update.ico")
Img_GuiMoreSettings := remoteResource("install.ico") ; Recently added as of 2011-11-13
Img_GuiLoading := remoteResource("appifyerFrame.png") ; ^
GuiControl,, stylishProgress, +10

Img_GuiBtnOff := remoteResource("btn_off.jpg")
Img_GuiBtnOn := remoteResource("btn_on.jpg")
GuiControl,, stylishProgress, +10

Img_GuiBG := remoteResource("gui_bg.png")
GuiControl,, stylishProgress, +10

Img_MenuApps := remoteResource("menu-apps.png")
Img_MenuSettings := remoteResource("menu-settings.png")
Img_MenuHelp := remoteResource("menu-help.png")
GuiControl,, stylishProgress, +10

Img_AddApp := 
Img_RemoveApp := 
Img_Refresh :=

Img_Close := remoteResource("close.ico")
;~ Img_Hotkey := remoteResource("hotkey.png") ; PNG
Img_Help := remoteResource("help.ico")
Img_Feedback := remoteResource("feedback.ico")
;~ Img_Email := remoteResource("email.ico")
Img_Settings := remoteResource("settings.ico")
GuiControl,, stylishProgress, +10

Img_BlackApps := remoteResource("apps.ico")
Img_BlackSettings := remoteResource("settings_black.ico")
Img_BlackUpdate := remoteResource("update.ico")
Img_BlackTime := remoteResource("time.ico")
Img_Sync := remoteResource("sync.ico")
Img_OK := remoteResource("ok.ico")
Img_OK_Large := remoteResource("ok_large.ico")
Img_Unknown := remoteResource("unknown.ico")
Img_Error := remoteResource("error.ico")
Img_Statistics := remoteResource("time.ico")
GuiControl,, stylishProgress, +10

; METRO GUI
MetroBG := RemoteResource("metro_bg.jpg", "http://wallpaperspoint.net/wp-content/walls/13_windows_wallpaper_02/windows_8_wallpaper-1.jpg")
WinClose, ahk_id %stylishMsg%

/* Colors := [0x56AFD4, 0x4B93D0, 0x3963CA]
ColorsAzure := Colors
ColorsBlue := [0x04428B, 0x05488F, 0x044C9E]
ColorsGreen := [0x495700, 0x617401, 0x91AF01]
ColorsOrange := [0xFE5400, 0xFF7406, 0xFE9E0B]
ColorsPink := [0x800055, 0xA0006A, 0xA8006F]
ColorsPurple := [0x5D3EB3, 0x6F50C0, 0x6E4AC2]
ColorsRed := [0x6E0000, 0x860000, 0x900000]
ColorsYellow := [0xD89B26, 0xE1B844, 0xFCC938]
*/

Colors := [0x00D0FF, 0x00B2FD, 0x019BFD]
ColorsAzure := Colors
ColorsBlue := [0x0166FE, 0x004BD8, 0x0132B2]
ColorsOrange := [0xFE7E00, 0xFF6B01, 0xFF5811]
ColorsPink := [0xE943A5, 0xE1359B, 0xD2238A]
ColorsPurple := [0xAA26F3, 0x6F50C0, 0x9100F1]
ColorsRed := [0xF62400, 0xE52500, 0xD02200]
ColorsYellow := [0xffb400, 0xf0a900, 0xe09e00]
ColorsGreen := [0x00BB42, 0x00A038, 0x008B32]


Positions := [0.0, 0.5, 1.0]

/* OLD METHOD OF ACCESSING data 
Std_Icon := "data\img\ico\Appifyer.ico"
Std_AppIcon := "data\img\ico\app.ico"

Appi_SoundsOn := ((User_SoundsOn) ? (User_SoundsOn) : (1))
;~ Appi_TrayTipsOn := ((User_TrayTipsOn) ? (User_TrayTipsOn) : (1))
;~ Appi_Autoupdate := ((User_AutoUpdate) ? (User_AutoUpdate) : (1))

ini_Apps := "data\AppifyerApps.ini"
ini_Settings := "data\AppifyerSettings.ini"

Sound_Click := "data\sounds\click.wav"
; Images
Img_AppifyerIcon := "data\img\ico\appifyer.ico"
Img_AppifyerIcon16 := "data\img\ico\appifyer16.ico"
Img_Appifyer := Img_AppifyerIcon
Img_AppifyerHeader :=
Img_StdIcon := "data\img\ico\app.ico"
Img_StdApp := "data\img\ico\app.ico"
Img_GuiHeader := "data\img\gui\header.jpg"
Img_GuiBG := "data\img\gui\guibg.png"
Img_GuiHeaderHelp := "data\img\gui\header_help.jpg"
Img_GuiHeaderCopyright := "data\img\gui\header_copyright.jpg"
Img_GuiHeaderSettings := "data\img\gui\header_settings.jpg"
Img_GuiHeaderAdvanced := "data\img\gui\header_settings.jpg" ; Same as above for now
Img_GuiHeaderUpdate := "data\img\gui\header_update.jpg"
Img_GuiDragNDrop := "data\img\gui\draganddrop.jpg"
Img_GuiSetHotkey := "data\img\gui\ico\hotkey_off.ico"
Img_GuiHasHotkey := "data\img\gui\ico\hotkey_on.ico"
Img_GuiRemoveApp := "data\img\gui\ico\remove.ico"
Img_GuiModeA := "data\img\gui\ico\mode_alwayson.ico"
Img_GuiModeO := "data\img\gui\ico\mode_ondemand.ico"
Img_GuiLikeApp := "data\img\gui\ico\like.ico"
Img_GuiReviewApp := "data\img\gui\ico\review.ico"
Img_GuiReviewApp := "data\img\gui\ico\update.ico"
Img_GuiMoreSettings := "data\img\ico\install.ico" ; Recently added as of 2011-11-13
Img_GuiLoading := "data\img\gui\appifyerFrame.png" ; ^

Img_GuiBtnOff := "data\img\gui\btn_off.jpg"
Img_GuiBtnOn := "data\img\gui\btn_on.jpg"

Img_AddApp := 
Img_RemoveApp := 
Img_Refresh :=

Img_Close := "data\img\menu\close.ico"
Img_Hotkey := "data\img\menu\hotkey.ico"
Img_Help := "data\img\menu\help.ico"
Img_Feedback := "data\img\menu\feedback.ico"
Img_Settings := "data\img\menu\settings.ico"
Img_Autostart_On := "data\img\menu\autostart_on.ico"
Img_Autostart_Off := "data\img\menu\autostart_off.ico"

Img_BlackSettings := "data\img\gui\ico\settings.ico"
Img_BlackUpdate := "data\img\gui\ico\update.ico"
Img_BlackTime := "data\img\gui\ico\time.ico"
Img_Sync := "data\img\gui\ico\sync.ico"
Img_OK := "data\img\gui\ico\OK.ico"
Img_OK_Large := "data\img\gui\ico\OK_large.ico"
Img_Unknown := "data\img\gui\ico\unknown.ico"
Img_Error := "data\img\gui\ico\error.ico"
Img_Statistics := "data\img\ico\time.ico"
*/ 