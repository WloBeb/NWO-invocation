; This script requires AutoIt from: www.autoitscript.com

#RequireAdmin
Local $middleScreen[] = [x coordinate, y coordinate]     ; somewhere in the middle of the screen
Local $logoutButton[] = [x coordinate, y coordinate]     ; position of logout button on character selection screen
Local $invocationButton = [x coordinate, y coordinate]   ; position of invocation button in invocation window

Local $Account[][] = [ _ ; on every row: account login, account password, number of cahracters (line ended with "   _")
   ["1st acoount name", "1st account password", number_of_characters], _
   ["2nd account name", "2nd account password", number_of_characters], _
   ["3rd account name", "3rd account password", number_of_characters]]

Local $point[][] = [ _ ; in every row: name, X coordinate, Y coordinate, Expected color, 0, -1 (leave untouched)
    ["Login screen P1",          0,   0,        0, 0, -1], _ ; get points at the bottom near or at "Login" button
    ["Login screen P2",          0,   0,        0, 0, -1], _
    ["Char selection P1",        0,   0,        0, 0, -1], _ ; also at the bottom at "Enter World" button
    ["Char selection P2",        0,   0,        0, 0, -1], _
    ["In Game screen P1",        0,   0,        0, 0, -1], _ ; points somewhere near minimap
    ["In Game screen P2",        0,   0,        0, 0, -1], _ ; beware of sliding markers on the edge of minimap
    ["Game menu window P1",      0,   0,        0, 0, -1], _ ; ATTENTION!!! this window i partialy semitransparent!!
    ["Game menu window P2",      0,   0,        0, 0, -1], _ ; propably only window title and around button is safe
    ["Invocation window P1",     0,   0,        0, 0, -1], _
    ["Invocation window P2",     0,   0,        0, 0, -1], _
    ["CTRL-I caption ON P1",     0,   0,        0, 0, -1], _ ; little Ctrl-I caption which could be white or gray
    ["CTRL-I caption ON P2",     0,   0,        0, 0, -1], _
    ["CTRL-I caption OFF P1",    0,   0,        0, 0, -1], _ ; only 4th value should differ from above
    ["CTRL-I caption OFF P2",    0,   0,        0, 0, -1]]

Local $InvokeKey = "^i", $GameMenuKey = "{ESC}"
Local $lineUser = ""
Local $lineCharacter = ""
Local $lineStatistic = ""
Local $lineInvocation = "|"

Func ArePixelsCorrect ($i)
   If PixelGetColor($point[$i*2][1], $point[$i*2][2]) = $point[$i*2][3] And PixelGetColor($point[$i*2+1][1], $point[$i*2+1][2]) = $point[$i*2+1][3] Then
	  Return 1
   EndIf
   Return 0
EndFunc

Func Wait_For_Select_Character_Screen ()
   ShowInfo("Waiting for Character Selection Screen")
	  While 1
	  If ArePixelsCorrect(1) Then
		 ShowInfo("")
		 Return
	  EndIf
	  Sleep(500)
   WEnd
EndFunc

Func Wait_For_Login_Screen ()
   ShowInfo("Waiting for Login Screen")
	  While 1
	  If ArePixelsCorrect(0) Then
		 ShowInfo("")
		 Return
	  EndIf
	  Sleep(500)
   WEnd
EndFunc

Func Wait_For_InGame_Screen ()
   ShowInfo("Waiting for In-Game Screen")
   While 1
	  If ArePixelsCorrect(2) Then
		 ShowInfo("")
		 Return
	  EndIf
	  Sleep(500)
   WEnd
EndFunc

Func Wait_For_Invocation_Window()
   ShowInfo("Waiting for Invocation Window")
   While 1
	  Send($InvokeKey)
	  Sleep(500)
	  If ArePixelsCorrect(4) Then
		 ShowInfo("")
		 Return
	  EndIf
	  Send($GameMenuKey)
   WEnd
EndFunc

Func Wait_For_Menu_Window()
   Local $x, $y
   While 1
	  Send($GameMenuKey)
	  Sleep(500)
	  If ArePixelsCorrect(3) Then Return
   WEnd
EndFunc

Func Wait_For_CtrlI_Visibility()
   ShowInfo("Waiting for Ctrl-I visibility")
   While 1
	  If ArePixelsCorrect(5) Or ArePixelsCorrect(6) Then
		 ShowInfo("")
		 Return
	  EndIf
	  Send($GameMenuKey)
	  Sleep(500)
   WEnd
EndFunc

Func Is_Invocation_Enabled()
   If ArePixelsCorrect(5) Then Return 1
   Return 0
EndFunc

Func Is_Invocation_Disabled()
   If ArePixelsCorrect(6) Then Return 1
   Return 0
EndFunc

Func ShowInfo ($msg)
    SplashTextOn("", "To Stop: Press F4." & @CRLF & $lineUser & @CRLF &$lineCharacter & @CRLF & @CRLF & $lineStatistic & @CRLF & @CRLF & $msg & @CRLF & $lineInvocation, 300, 150, Default, 25, 1, "", 9)
EndFunc

Func Start()
   Local $currentSlot = 0, $allSlots = 0
   For $j = 1 To UBound($Account)
	  $allSlots = $allSlots + $Account[$j-1][2]
   Next
   HotKeySet("{F4}", "Pause")
   AutoItSetOption("SendKeyDownDelay", 50)
   MouseClick("primary", $middleScreen[0], $middleScreen[1])
   Local $StartTimer = TimerInit(), $LoopTimer
   For $j = 1 To UBound($Account)
	  Wait_For_Select_Character_Screen ()
	 ; activate neverwinter window
	  $lineUser = "Account: " & $j &" of " & UBound($Account) & " (" & $Account[$j-1][0] & ")"
	  ShowInfo("")
      MouseClick("primary", $logoutButton[0], $logoutButton[1])
	  Wait_For_Login_Screen ()
	  ; remove old login
	  For $i = 1 To 20
		 Send("{BS}{BS}{BS}{BS}")
		 Sleep(20)
	  Next
	  ; insert username and password and "enter world"
	  Send($Account[$j-1][0])
	  Send("{TAB}")
	  Send($Account[$j-1][1])
	  Send("{ENTER}")
	  For $i = 1 to $Account[$j -1][2]
		 Wait_For_Select_Character_Screen()
		 $currentSlot += 1
		 $lineInvocation &= "-"
		 $lineCharacter = "Invoking: " & $i & " of " & $Account[$j -1][2] & " ( " & $currentSlot & " of " & $allSlots & " total)"
         	 If $LoopTimer Then
			Local $LastTime = TimerDiff($LoopTimer)
			$lineStatistic = "Last invoke took " & Round($LastTime / 1000, 2) & " seconds to complete" & @CRLF & "ETA: " & Round(($allSlots - $currentSlot) * $LastTime / 60000) & " minutes to go"
		 EndIf
		 ShowInfo("")
		 $LoopTimer = TimerInit()
		 ; select next character
		 For $k = 2 to $Account[$j -1][2]
			Send("{UP}")
			Sleep(50)
		 Next
		 For $k = 2 to $i
			Send("{DOWN}")
			Sleep(50)
		 Next
		 Sleep(1000)
		 Send("{ENTER}")
		 Wait_For_InGame_Screen()
		 Sleep(2000)
		 ; try to invoke if it's possible
		 Local $InvokeEnd = 0
		 While $InvokeEnd = 0
			Wait_For_CtrlI_Visibility()
			If Is_Invocation_Enabled() = 1 Then
			   Wait_For_Invocation_Window()
			   Sleep(200)
			   MouseClick("primary", $invocationButton[0], $invocationButton[1])
			   $lineInvocation = StringTrimRight($lineInvocation, 1) & "+"
			   Sleep(1000)
			EndIf
			If Is_Invocation_Disabled() = 1 Then $InvokeEnd = 1
		 WEnd
		 ; go to character selection screen
		 Wait_For_Menu_Window()
		 Sleep(200)
		 For $k = 1 to 3
			Send("{DOWN}")
			Sleep(100)
		 Next
		 Sleep(500)
		 For $k = 1 to 3
			Send("{ENTER}")
			Sleep(500)
		 Next
	  Next
	  $lineInvocation &= "|"
   Next
   HotKeySet("{F4}")
   SplashOff()
   MsgBox(0, "Neverwinter Invoke Bot", "Completed invoking: " & $currentSlot & @CRLF & @CRLF & "Invoking took " & Round(TimerDiff($StartTimer) / 60000) & " minutes to complete." & @CRLF & @CRLF & $lineInvocation, "", WinGetHandle(AutoItWinGetTitle()) * WinSetOnTop(AutoItWinGetTitle(), "", 1))
   Exit
EndFunc

Func Pause()
   HotKeySet("{F4}")
   SplashOff()
   if (MsgBox(1+64+4096, "Neverwinter Invoke Bot", "To start invoking, click the OK button while at the character selection screen.", "", WinGetHandle(AutoItWinGetTitle()) * WinSetOnTop(AutoItWinGetTitle(), "", 1)) = 2 ) Then
	  Exit
   EndIf
  Start()
EndFunc

Pause()
