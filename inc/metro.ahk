GUIMetroInterface:
Gui, Metro:Default
If WinExist("ahk_id " MetroGUI)
{
	If (cSettings["Metro"]["Transition"] != "None")
		AnimateWindow(MetroGUI, 200, "HB")
	Gui, Destroy ; On the second "launch", remove the GUI
	return
}
Gui, Destroy
Gui, -Caption
Gui, Color, 000000
x := 0, y := 0, w := A_ScreenWidth, h := A_ScreenHeight
MetroBG := (cSettings["Metro"]["BackgroundURL"] ? remoteResource("custom_bg.jpg", cSettings["Metro"]["BackgroundURL"]) : MetroBG)
Gui, Add, Picture, x%x% y%y% w%w% h%h% vMetroBG, % MetroBG
Gui, Font, s36 cFFFFFF, Segoe UI Light
Gui, Add, Text, x46 y12 +BackgroundTrans, Applications
Gui, Font, s18 cEEEEEE, Segoe UI Light

/* xM := 50, yM := 80 ; Margin: x & y [total]
xS := 15, yS := 15 ; Appspacing: x & y [between apps]
pW := 340, pH := 160 ; Picture: width & height
*/

xM := 46, yM := 100 ; Margin: x & y [outer]
xS := 8, yS := 8 ; Appspacing: x & y [between apps]
pW := 250, pH := 120 ; Picture: width & height
iWH := 64 ; Icon width/height

/* 
Small
xM := 24, yM := 64 ; Margin: x & y [total]
xS := 8, yS := 8 ; Appspacing: x & y [between apps]
pW := 180, pH := 120 ; Picture: width & height 
*/

row := 1, col := 0

/* sorted := "", sorted := [] ; Sort cApps by [App]["Name"] - see http://www.autohotkey.com/community/viewtopic.php?f=1&t=89528&p=555469 by jethrow
k := "", v := "", t := "", key := "", item := ""
for k,v in cApps
	sorted[v.name] := k
for key, item in sorted
	t .= item "`n"
Sections := SubStr(t, 1, -1) ; `n-delimited list sorted by alphabetical order (removing the last `n)
*/

AppsCount := "" ; Reset
Sections := cApps.Sections()
Loop, Parse, Sections, `n
	++Appscount ; Get # of apps in total
MetroPos := []

Loop ; Create the possible positions
{
	++col ; Column
	posCount := A_Index
	MetroPos[A_Index, "w"] := pW, MetroPos[A_Index, "h"] := pH
	
	if ((xM + pW*(col) + xS*(col)) > A_ScreenWidth) ; If width would be exceeded
		++row, col := 1, MetroPos[A_Index, "x"] := xM, MetroPos[A_Index, "y"] := yM+(yS+pH)*(row-1)
	else
		MetroPos[A_Index, "x"] := xM + (col-1)*(xS+pW), MetroPos[A_Index, "y"] := yM+(yS+pH)*(row-1)
	if ((MetroPos[A_Index, "y"] + pH) > A_ScreenHeight)
		break
	
	pos := "x" MetroPos[A_Index]["x"] " y" MetroPos[A_Index]["y"] " w" pW " h" pH
	;~ Gui, Add, Text, %pos% BACKGROUNDTRANS vBox_%A_Index%, %A_Index% ; Position-box
	MetroPos["maxCount"] := A_Index
}

Loop, Parse, Sections, `n
{
	App := A_LoopField, n := A_Index
	If !App
		continue
	Icon := cApps[App]["Icon"] ? cApps[App]["Icon"] : Std_AppIcon
	if (m := cApps[App]["MetroPos"])
		pos := "x" MetroPos[m]["x"] " y" MetroPos[m]["y"] " w" pW " h" pH, MetroPos[m, "App"] := App
	else
		continue ; This app does not have a Metro pos
	Gui, Add, Picture, gMetroLaunch BackgroundTrans vApp_%App% %pos% hwndFrame%App%, ; %frame%
	if (cApps[App]["MetroColor"])
	{
		val := cApps[App]["MetroColor"]
		tmp := Colors%val%
		LinearGradient(Frame%App%, tmp, Positions) ; Background FRAME 
	}
	else
		LinearGradient(Frame%App%, Colors, Positions) ; Background FRAME
	
	Gui, Font, s11 cFFFFFF, Calibri
	pos := "x" MetroPos[m]["x"] + xS*2 " y" MetroPos[m]["y"] + MetroPos[m]["h"] - 22 " w" MetroPos[m]["w"] - xS*4 ; Title
	Gui, Add, Text, %pos% BackgroundTrans vName%App%, % cApps[App]["Name"] ? cApps[App]["Name"] : ""
	pos := "x" MetroPos[m]["x"] + (MetroPos[m]["w"] - iWH)//2 " y" MetroPos[m]["y"] + (MetroPos[m]["h"] - iWH)//2 " w" iWH " h" iWH ; Icon
	Gui, Add, Pic, %pos% 0xE BackgroundTrans hwndIcon%A_Index% vIco_%App%, ; 
	sFile := cApps[App]["Icon"] ? cApps[App]["Icon"] : cApps[App]["File"] ? cApps[App]["File"] : Std_AppIcon
	Gdip_PaintIcon(Icon%A_Index%, sFile, iWH)
	
	Gui, Font, s11 cFFFFFF, Calibri
	x := pW - 55, y := pH - 90
	Input := cApps[App]["Hotkey"]
	StringUpper, displayHotkey, Input
	StringReplace, displayHotkey, displayHotkey, #, ❖ ; Fancier Winkey
	pos := "x" MetroPos[m]["x"] + xS*2 " y" MetroPos[m]["y"] + MetroPos[m]["h"] - 22 " w" MetroPos[m]["w"] - xS*4 ; Hotkey
	Gui, Add, Text, %pos% BackgroundTrans Right vHotK%App%, % cApps[App]["Hotkey"] ? displayHotkey : ""
}

/*
Gui, Add, Pic, % "x" A_ScreenWidth - 84 " y" A_ScreenHeight - 118 " w64 h64 gAppSettings", % img_BlackSettings
Gui, Add, Pic, xp-74 yp w64 h64 gHelp gVisit vMetroVisitAppifyer, % img_BlackUpdate
*/
Gui, Color, ECECEC
Gui, +LastFound +Owner
MetroGUI := WinExist()
If (cSettings["Metro"]["Transition"] != "None")
{
	Gui, Show, Hide
	AnimateWindow(MetroGUI, 200, "B")
}
else
	Gui, Show, Maximize
WinActivate, ahk_id %MetroGui%
return

MetroGuiContextMenu:
If (A_GuiControl = "MetroBG")
{
	Menu, MetroBGMenu, Add, Add application, GuiAddApp
	;~ Menu, MetroBGMenu, Add, Change background image, GuiSetMetroBG
	Menu, MetroBGMenu, Add, Close, GUIMetroInterface
	Menu, MetroBGMenu, Show
}
else if (cApps[SubStr(A_GuiControl, 5)]["File"]) ; Something exists
{	
	Metro_ContextMenuApp := SubStr(A_GuiControl, 5) ; For use in GUIfuncs subroutines
	;~ Menu, ContextMenu, Add, Run, RunApp
	;~ Menu, ContextMenu, Add, &Modify hotkey, NYI
		Menu, ContextMenuColor, Add, Azure, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Blue, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Green, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Orange, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Pink, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Purple, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Red, GuiSetMetroColor
		Menu, ContextMenuColor, Add, Yellow, GuiSetMetroColor
	Menu, ContextMenu, Add, Tile color, :ContextMenuColor
	Menu, ContextMenu, Add, Remove app, GuiRemoveApp
	Menu, ContextMenu, Show
}
else if (A_GuiControl = "MetroVisitAppifyer")
	MsgBox Visit Appifyer online
return

#if MouseIsOver("ahk_id " MetroGUI)
MButton::
Gui, Metro:Destroy ; Toggles the Win8 mode off
return
#if

MetroLaunch:
GuiControl := A_GuiControl
StringTrimLeft, App, GuiControl, 4 ; (-) App_/Ico_/Name removed
	
If (GetKeyState("LButton", "P"))
{
	CoordMode, Mouse, Screen
	;~ GuiControl, Move, %GuiControl%, % "w" pW-9 "h" pH - 9
	;~ MouseGetPos, X, Y
	GuiControlGet, pos, Pos, %GuiControl%
	box := { x: posX, y: posY, w: pW, h: pH }, boxOrigin := ""
	for k, v in MetroPos
	{
		if in_Box(box, MetroPos[k])
		{
			MetroPos[k].Remove("App"), boxOrigin := k ; Blank the app spot
			break
		}
	}
	KeyWait, LButton, T0.4
	If (!ErrorLevel) ; Was released
	{
		;~ GuiControl, Move, %GuiControl%, % "w" pW "h" pH
		ApptoRun := cApps[App]["File"]
		Run %ApptoRun%
		Gui, Metro:Destroy
		return
	}
	; Else hold
		
	GuiControl, Hide, %GuiControl%
	GuiControl, Hide, Name%App%
	GuiControl, Hide, Ico_%App%
	GuiControl, Hide, HotK%App%
	
	Gui, MetroBox: Default
	Gui, +AlwaysOnTop -Caption +Border +ToolWindow +LastFound
	WinSet, Transparent, 120
	Gui, Color, ECECEC ; Shows a light gray box to move around
	
	While (GetKeyState("LButton", "P"))
	{
		MouseGetPos, X, Y
		Sleep 20
		Gui, Show, % "x" x+5 " y" y+5 " w" pW-10 " h" pH-10 ; Offset to a smaller box while dragging
	}
	
	box := { x: x, y: y, w: pW, h: pH }
	boxNumber := ""
	
	for k, v in MetroPos
	{
		if in_Box(box, MetroPos[k])
		{
			boxNumber := k
			break
		}
	}
	if (boxNumber AND !MetroPos[boxNumber]["App"]) ; If moved to new box
	{
		cApps[App]["MetroPos"] := boxNumber, k := boxNumber, MetroPos[k]["App"] := App
		pos := "x" MetroPos[k]["x"] " y" MetroPos[k]["y"] " w" MetroPos[k]["w"] " h" MetroPos[k]["h"]
		posName := "x" MetroPos[k]["x"] + xS*2 " y" MetroPos[k]["y"] + MetroPos[k]["h"] - 22 " w" MetroPos[k]["w"] - xS*4 ; Title
		posHotK := "x" MetroPos[k]["x"] + xS*2 " y" MetroPos[k]["y"] + MetroPos[k]["h"] - 22 " w" MetroPos[k]["w"] - xS*4 ; Hotkey
		posIcon := "x" MetroPos[k]["x"] + (MetroPos[k]["w"] - iWH)//2 " y" MetroPos[k]["y"] + (MetroPos[k]["h"] - iWH)//2 ; Icon
	
	}
	else ; If failed to move
	{
		;~ ToolTip, % "Can't move to " boxNumber ", it is taken!`n(By " MetroPos[boxNumber]["App"] ")", 0, 0
		n := cApps[App]["MetroPos"], MetroPos[boxOrigin]["App"] := App
		pos := "x" MetroPos[n]["x"] " y" MetroPos[n]["y"]
		posName := "x" MetroPos[n]["x"] + xS*2 " y" MetroPos[n]["y"] + MetroPos[n]["h"] - 22 " w" MetroPos[n]["w"] - xS*4 ; Title
		posHotK := "x" MetroPos[n]["x"] + xS*2 " y" MetroPos[n]["y"] + MetroPos[n]["h"] - 22 " w" MetroPos[n]["w"] - xS*4 ; Hotkey
		posIcon := "x" MetroPos[n]["x"] + (MetroPos[n]["w"] - iWH)//2 " y" MetroPos[n]["y"] + (MetroPos[n]["h"] - iWH)//2 ; Icon
	}
	Gui, MetroBox: Destroy
	
	Gui, Metro:Default
	GuiControl, Move, %GuiControl%, %pos%
	GuiControl, Move, Name%App%, %posName%
	GuiControl, Move, Ico_%App%, %posIcon%
	GuiControl, Move, HotK%App%, %posHotK%
	
	GuiControl, Show, %GuiControl%
	GuiControl, Show, Name%App%	
	GuiControl, Show, Ico_%App%	
	GuiControl, Show, HotK%App%	
}
/*
else ; Launched by Hotkey
{
	GuiControl, Move, %GuiControl%, % "w" pW-9 "h" pH - 9
	KeyWait, %A_ThisHotkey%, T1
	If (!ErrorLevel) ; Was released
	{
		GuiControl, Move, %GuiControl%, % "w" pW "h" pH
		ApptoRun := cApps[App]["File"]
		Run %ApptoRun%
		Gui, Destroy
		return
	}
}
*/
return

~Esc::
Gui, Metro:Destroy
Gui, MetroSettings:Destroy
return

in_Box(box, bigBox) 
{
	return ( (box["x"]+box["w"]//2) > bigBox["x"] ) AND ( (box["x"]+box["w"]//2) < (bigBox["x"]+bigBox["w"]) ) AND ( (box["y"]+box["h"]//2) > bigBox["y"] ) AND ( (box["y"]+box["h"]//2) < (bigBox["y"]+bigBox["h"]) ) ? 1 : 0
}