;~ MsgBox("What would you like to name this application?", "appname", "Edit")
;~ MsgBox % MsgBox("An older instance of this script is already running. Replace it with this instance?", "replace instance?")
/* MsgBox("Loading resources", "loading...", "Progress")
Loop, 10
{
	GuiControl,, stylishProgress, +10
	Sleep 100
}
*/
MsgBox("We have detected that you may have added apps while using an older version of Appifyer. Keep them?", "transfer apps?", "Choice")

MsgBox(Message="", Title="notice", Type="Message", Default="")
{
	global stylishProgress
	Gui, +Border +HWNDguiHWND +LastFound +ToolWindow
	Gui, Color, F9F9F9
	Gui, Font, s14, Segoe UI Light
	Gui, Add, Text, x0 y0 h24 w330 c909090 Right, %title%
	Gui, Font, s10, Calibri
	Gui, Add, Text, x10 y32 w310 h30 c3B3B3B,  %Message%
	If (Type = "Edit")
		Gui, Add, Edit, x10 y76 w310 h24 c333333, %Default%
	If (Type = "Progress")
		Gui, Add, Progress, x5 w330 h5 y100 cB0B0B0 Backgroundeeeeee vstylishProgress
	If (Type = "Choice")
	{
		Gui, Add, Button, x5 w100 y76 cB0B0B0, &Yes
		Gui, Add, Button, x115 y76 cB0B0B0, &No`, clean installation
		
	}
	Gui, Show, w340 h110, %A_Space%
	return guiHWND
}