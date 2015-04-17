; This script requires AutoIt from: www.autoitscript.com
;
; NEVERWINTER invocation script by WloBeb
;
; 1. run NeverwinterOnline
; 2. with PrtScr grab respective screens (login, select character, in game, with invocation window, with Ctrl_I white & gray
; 3. open any graphical tool (I personaly use Gimp)
; 4. find coordinates of 2 pixels belonging to fixed elements of view
; 5. insert these coordinates into $point array (2nd & 3rd column)
; 6. run Neverwinter again, run script
; 7. note color values in respective screens of game 
; 8. stop script (F6), insert these values into $pixel array (4th column)
; 9. run script again
; 10. check if script recognizes screens
; 11. set accounts names, passwords and ammounts of characters
; 11. set position of $middleScreen, $logoutButton, $invocationButton
; 12. set $testingMode = 0
;
; RELEASE NOTES
; 3.21
;   - small login changes
;   - small ETA changes
; 3.2 
;   - detection of menu window changed
;   - auto relogin if moved to login screen
;   - testing script conected to this script
; 3.1 
;   - first public release 

#RequireAdmin
Local $testingMode = 1

Local $middleScreen[] = [x coordinate, y coordinate]     ; somewhere in the middle of the screen
Local $logoutButton[] = [x coordinate, y coordinate]     ; position of logout button on character selection screen
Local $invocationButton = [x coordinate, y coordinate]   ; position of invocation button in invocation window

Local $Account[][] = [ _ ; on every row: account login, account password, amount of characters (line ended with "   _")
   ["1st acoount name", "1st account password", number_of_characters], _
   ["2nd account name", "2nd account password", number_of_characters], _
   ["3rd account name", "3rd account password", number_of_characters]]

Local $point[][] = [ _ ; in every row: name, X coordinate, Y coordinate, Expected color, 0, -1 (last 2 leave untouched)
    ["Login screen P1",          0,   0,        0, 0, -1], _ ; get points at the bottom near or at "Login" button
    ["Login screen P2",          0,   0,        0, 0, -1], _
    ["Char selection P1",        0,   0,        0, 0, -1], _ ; also at the bottom at "Enter World" button
    ["Char selection P2",        0,   0,        0, 0, -1], _
    ["In Game screen P1",        0,   0,        0, 0, -1], _ ; points somewhere near minimap
    ["In Game screen P2",        0,   0,        0, 0, -1], _ ; beware of sliding markers on the edge of minimap
    ["Game menu window P1",      0,   0,        0, 0, -1], _ ; Obsolete
    ["Game menu window P2",      0,   0,        0, 0, -1], _ ; Obsolete
    ["Invocation window P1",     0,   0,        0, 0, -1], _
    ["Invocation window P2",     0,   0,        0, 0, -1], _
    ["CTRL-I caption ON P1",     0,   0,        0, 0, -1], _ ; little Ctrl-I caption which could be white or gray
    ["CTRL-I caption ON P2",     0,   0,        0, 0, -1], _
    ["CTRL-I caption OFF P1",    0,   0,        0, 0, -1], _ ; only 4th value should differ from above
    ["CTRL-I caption OFF P2",    0,   0,        0, 0, -1]]

Local $InvokeKey = "^i", $GameMenuKey = "{ESC}"
Local $changed = 0				; for testing only
Local $lineUser = ""
Local $lineCharacter = ""
Local $lineStatistic = ""
Local $lineInvocation = "|"
Local $user
Local $pass
Local $maxLoginName = 0

Func ArePixelsCorrect ($i)
   If PixelGetColor($point[$i*2][1], $point[$i*2][2]) = $point[$i*2][3] And PixelGetColor($point[$i*2+1][1], $point[$i*2+1][2]) = $point[$i*2+1][3] Then
	  Return 1
   EndIf
   Return 0
EndFunc

Func Wait_For_Select_Character_Screen ()
   ShowInvocationInfo("Waiting for Character Selection Screen")
   While 1
	  If ArePixelsCorrect(1) Then
		 ShowInvocationInfo("")
		 Return
	  EndIf
	  ; if moved to login screen - relogin
	  If ArePixelsCorrect(0) Then login()
	  Sleep(500)
   WEnd
EndFunc

Func Wait_For_Login_Screen ()
   ShowInvocationInfo("Waiting for Login Screen")
   While 1
	  If ArePixelsCorrect(0) Then
		 ShowInvocationInfo("")
		 Return
	  EndIf
	  Sleep(500)
   WEnd
EndFunc

Func Wait_For_InGame_Screen ()
   ShowInvocationInfo("Waiting for In-Game Screen")
   While 1
	  If ArePixelsCorrect(2) Then
		 ShowInvocationInfo("")
		 Return
	  EndIf
	  Sleep(500)
   WEnd
EndFunc

Func Wait_For_Invocation_Window()
   ShowInvocationInfo("Waiting for Invocation Window")
   While 1
	  Send($InvokeKey)
	  Sleep(500)
	  If ArePixelsCorrect(4) Then
		 ShowInvocationInfo("")
		 Return
	  EndIf
	  Send($GameMenuKey)
   WEnd
EndFunc

Func Wait_For_Menu_Window()
  ; close all windows until you can see minimap
  While Not ArePixelsCorrect(2)
    Send($GameMenuKey)
    Sleep(500)
  WEnd
  ; close all window or recall menu window (which removes minimap)
  While ArePixelsCorrect(2)
    Send($GameMenuKey)
    Sleep(500)
  WEnd
EndFunc

Func Wait_For_CtrlI_Visibility()
   ShowInvocationInfo("Waiting for Ctrl-I visibility")
   While 1
	  If ArePixelsCorrect(5) Or ArePixelsCorrect(6) Then
		 ShowInvocationInfo("")
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

Func ShowInvocationInfo ($msg)
    SplashTextOn("", "To Stop: Press F4." & @CRLF & $lineUser & @CRLF &$lineCharacter & @CRLF & @CRLF & $lineStatistic & @CRLF & @CRLF & $msg & @CRLF & $lineInvocation, 300, 150, Default, 25, 1, "", 9)
EndFunc

Func login()
  For $i = 1 To $maxLoginName
    Send("{BS}")
    Sleep(20)
  Next
  ; insert username and password and "enter world"
  Send($user)
  Send("{TAB}")
  Send($pass)
  Send("{ENTER}")
EndFunc

Func StartInvocation()
  HotKeySet("{F4}", "Pause")
  AutoItSetOption("SendKeyDownDelay", 50)
  Local $currentSlot = 0, $allSlots = 0
  For $j = 1 To UBound($Account)
    $allSlots = $allSlots + $Account[$j-1][2]
    If StringLen($Account[$j-1][0]) > $maxLoginName Then $maxLoginName = StringLen($Account[$j-1][0])
  Next
  If $maxLoginName < 20 Then $maxLoginName = 20 
  MouseClick("primary", $middleScreen[0], $middleScreen[1])
  Local $StartTimer = TimerInit(), $LoopTimer
  For $j = 1 To UBound($Account)
    Wait_For_Select_Character_Screen ()
    ; activate neverwinter window
    $lineUser = "Account: " & $j &" of " & UBound($Account) & " (" & $Account[$j-1][0] & ")"
    ShowInvocationInfo("")
    MouseClick("primary", $logoutButton[0], $logoutButton[1])
    Wait_For_Login_Screen ()
    ; remove old login
    $user = $Account[$j-1][0]
    $pass = $Account[$j-1][1]
    login()
    For $i = 1 to $Account[$j -1][2]
      Wait_For_Select_Character_Screen()
      $currentSlot += 1
      $lineInvocation &= "-"
      $lineCharacter = "Invoking: " & $i & " of " & $Account[$j -1][2] & " ( " & $currentSlot & " of " & $allSlots & " total)"
      If $LoopTimer Then
        Local $LastTime = TimerDiff($LoopTimer)
        Local $AverageTime = TimerDiff($StartTimer)/($currentSlot-1)
        Local $ETA = Round(($allSlots - $currentSlot + 1) * $AverageTime / 1000)
        $lineStatistic = "Last invoke took " & Round($LastTime / 1000, 2) & " seconds to complete" & @CRLF & "ETA: " & Floor($ETA/60) & " min " & StringFormat("%02i", Mod($ETA, 60)) & " s to go"
      EndIf
      ShowInvocationInfo("")
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
   StartInvocation()
EndFunc

Func Terminate()
   Exit
EndFunc

Func GetPoints ()
   $changed = 0
   For $i = 0 To UBound($point)-1
	  $point[$i][4] = PixelGetColor ($point[$i][1], $point[$i][2])
	  If $point[$i][4] <> $point[$i][5] Then
		 $changed = 1
		 $point[$i][5] = $point[$i][4]
	  EndIf
   Next
EndFunc

Func ShowTestInfo()
Local $msg = ""
   For $i = 0 To UBound($point)-1
	  $msg &= $point[$i][0] & " color: " & $point[$i][4] & @CRLF
   Next
   If ArePixelsCorrect(1) = 1 Then $msg &= @CRLF & "THIS IS CHARACTER SELECTION SCREEN" & @CRLF
   If ArePixelsCorrect(0) = 1 Then $msg &= @CRLF & "THIS IS LOGIN SCREEN" & @CRLF
   If ArePixelsCorrect(2) = 1 Then $msg &= @CRLF & "THIS IS GAME SCREEN" & @CRLF
   If ArePixelsCorrect(4) = 1 Then $msg &= @CRLF & "INVOCATION WINDOW OPEN" & @CRLF
   If ArePixelsCorrect(5) = 1 Then $msg &= @CRLF & "INVOCATION ENABLED" & @CRLF
   If ArePixelsCorrect(6) = 1 Then $msg &= @CRLF & "INVOCATION DISABLED" & @CRLF
   $msg &= @CRLF & "  To Stop: Press F6"
   SplashTextOn("", $msg, 380, 300, 20, Default, 1, "", 9)
EndFunc

Func StartTest()
   HotKeySet("{F6}", "Terminate")
   SplashOff()
   While 0 < 1
	  GetPoints()
	  If $changed <> 0 Then ShowTestInfo()
	  Sleep(500)
   WEnd
EndFunc

If $testingMode Then
  StartTest()
Else
  Pause()
EndIf
