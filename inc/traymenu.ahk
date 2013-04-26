Menu, Tray, Nostandard
If (FileExist(Img_AppifyerIcon16))
	Menu, Tray, Icon, %Img_AppifyerIcon16%
Menu, Tray, Tip, Left-click for apps menu`nRight-click for more options

Menu, Tray, Add, Appsmenu, AppMenu
Menu, Tray, Default, Appsmenu
Menu, Tray, Add ; --
Menu, Tray, Add, App settings, AppSettings
Menu, Tray, Add, Settings, AppSettings
Menu, Tray, Add, Help, AppSettings
Menu, Tray, Add ; --
Menu, Tray, Add, Feedback
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 1

; Setup Menu icons
Menu, Tray, Icon, Appsmenu, %Img_AppifyerIcon%,, 32
Menu, Tray, Icon, App settings, %Img_BlackApps%,, 32
Menu, Tray, Icon, Settings, %Img_BlackSettings%,, 32
;~ Menu, Tray, Icon, Autostart, %Img_Autostart_Off%,, 32
;~ IfExist %A_Startup%\Appifyer.lnk
	;~ Menu, Tray, Icon, Autostart, %Img_Autostart_On%,, 32
Menu, Tray, Icon, Help, %Img_Help%,, 32
Menu, Tray, Icon, Feedback, %Img_Feedback%,, 32
Menu, Tray, Icon, Exit, %Img_Close%,, 32