Feedback:
Gui, Feedback:Default
Gui, Destroy
Gui, Color, FfFfFf
Gui, Font, s10, Verdana
Gui, Add, Text,, Comment(s)
SplitPath, A_ScriptName,,,, AppName
Gui, Add, Edit, r12 w460 vEmailText, Regarding %AppName%: 
Gui, Add, Text,, Your email (and/or name)
Gui, Add, Edit, w450 vEmailFrom,
Gui, Font, s8, Verdana
Gui, Add, Text, w450, Your feedback will be emailed to the developer.`nIf you provide an email adress the developer may reply.
Gui, Add, Button, yp x424 w36 h36 gFeedbackHelp, ?
Gui, Add, Button, gFeedbackSubmit x10 h40 w450, &Send feedback
Gui, +LastFound

SysGet, Mon, MonitorWorkArea ; We want to position the GUI in the tray area
MonWidth := MonRight - MonLeft, MonHeight := MonBottom - MonTop

If (A_ThisMenuItem = "Feedback") ; Triggered from the traybar
   x := Round(MonWidth - 480 - 16), y := Round(MonHeight - 380 - 32), w := 480, h := 380 ; Traybar area
else
   x := Round((MonWidth - 480 - 16)/2), y := Round((MonHeight - 380 - 32)/2), w := 480, h := 380 ; Center window

Gui, Show, hide x%x% y%y% w%w% h%h%, Feedback form
Gui, +LastFound
GUI_Feedback := WinExist()
DllCall("AnimateWindow","UInt",Gui_Feedback,"Int",800,"UInt","0x80000")
GuiControl, Focus, EmailFrom
GuiControl, Focus, EmailText
If WinActive("ahk_id" Gui_Feedback)
{
   Send {End}
   Send {Return 2}
}
return

FeedbackHelp:
MsgBox, 32, About, Please provide as much information as possible. Developers are usually very happy for feedback.`n`nThe feedback will be sent using Appifyer.com's developer system.
return

FeedbackSubmit:
Gui, Submit, Nohide
If (!RegExMatch(EmailFrom, "\w{3,}[@]{1}\w{3,}[.]{1}\w{2,}", Output)) ; Is NOT email?
{
   If (HasFailed != 1)
   {
      MsgBox, 48, ATTENTION! , You did not enter a valid email adress. This means the developer can not reply to you. If you wish to send the feedback without an email adress`, atleast supply a name or nickname.`n`nThank you!
      HasFailed = 1
      return
   }
   else
      EmailFrom = anonymous@nomail.com
}
Gui, Destroy
;~ Notify("Feedback sent", "Thank you for your feedback!", 4)
Gosub, FeedbackSendEmail
Sleep 3000
return

FeedbackSendEmail:
URL := "http://www.appifyer.com/api/feedback.php"
Query := "?app=Appifyer&message=" . EmailText . "&from=" . EmailFrom

HTTPRequest(URL . Query, Data)
if (InStr(Data, "Success"))
   Notify("Feedback sent", "Thank you for your feedback!", 4,, Img_Email ? Img_Email : "")
else
   Notify("Feedback error", "Error: Could not send", 4)
return

