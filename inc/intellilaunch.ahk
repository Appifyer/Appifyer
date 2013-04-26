;~ #i::
; IMPORTANT: THIS FILE IS INACTIVE (not in use). To-do: Reverse app lookup (by name) and improving the intellilaunch interface.
return
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
StringReplace, List, Sections, `n, `,, All ; Now we have an alphabetical list

Gui, Font, s16, Lucida Console
Gui, Add, Picture, x10 w32 h32 viPicture,
Gui, Add, Edit, gIntelliEdit hwndIntelliControl vControl yp x52 w176, ; Note the gRoutine, hwndID and vVar: All are used later
Gui, Color, ffFFff
Gui, -Caption +Border
Gui, Show, w240 h60, GuiWin

return

#If (WinActive("GuiWin")) ; Optional/configurable part: Hotkey to "verify" the suggestion
Tab::
If IntelliHotkey
    Send {Right}{Space}
return

NumPadEnter::
Enter::
Gui, Submit
If (Control AND InStr(List, Control))
{
	Run % cApps[Control]["File"]

}
return

Esc::
Gui, Destroy
return
#If

IntelliEdit:
Control := A_GuiControl ; Added in v0.3
If (GetKeyState("Backspace","P") OR GetKeyState("Delete", "P")) ; Added by zzzooo10 (+sumon v0.3)
    Return
Gui, Submit, Nohide
Suggestion := IntelliEdit(Control, List) ; See the function
If (Suggestion)
{
	StringSplit, Words, Control, %A_Space% ; Checks to see if there is more then one word
	Words := Words%Words0%
	Suggestion := Words0 > 1 ? SubStr(Control, 1, StrLen(Control) - StrLen(Words))  . Suggestion : Suggestion ; If there is append the Suggestion to Control, else replace the whole edit box.
	GuiControl,, Control, %Suggestion%
	PostMessage, 0xB1, % StrLen(Control), % StrLen(Suggestion),, ahk_id %IntelliControl% ; EM_SETSEL
	IntelliHotkey := "True"
}
else
	IntelliHotkey := "False"


If (cApps[Suggestion]["File"]) ; Add picture to picture box
	GuiControl,, iPicture, % cApps[Suggestion]["File"]
return

IntelliEdit(Control, List="", Length=1) ; Input the content to check for, and the matches (edit-control & list)
{
   If (StrLen(Control) < 1) ; If input string is empty
      return 0
   StringSplit, Word, Control, %A_Space% ; Gets the current word.
   Word := Word%Word0%
   Loop, Parse, List, `, ; Look for consecutive alphabetical match
   {
      If ((( Word < A_LoopField) AND ( Word > Previous) AND InStr(A_LoopField, Word )) AND StrLen(Word) >= Length)
         Return A_LoopField ; Return the closest alphabetical match
      else
         Previous := A_Loopfield
   }
   return
}