Opt("GUIOnEventMode", 1)

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <GuiEdit.au3>
#include <LED.au3>
#include <Misc.au3>
#NoTrayIcon

Global Const $MAX_BYTES = 104857600
Global Const $sLogFile = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".log"
_Log("Started with PID "  & @AutoItPID)

If $CmdLine[0] > 0 Then
	ProcessWaitClose($CmdLine[1], 5)

	; Screw the system, kill the parent
	_Log("Killing parent " & $CmdLine[1])
	ProcessClose($CmdLine[1])
	ProcessWaitClose($CmdLine[1], 5)
	_Log("Parent terminated")
EndIf

Global $sDLLPathLED = @ScriptDir & "\LogitechLed.dll"
LogiLedInit($sDLLPathLED)

Global $hGUI = GUICreate("KeyboardBacklightThing", 100, 20)
Global $hInput = GUICtrlCreateInput("", 0, 0, 100, 20)

GUICtrlSetState($hInput, $GUI_DISABLE)

Global $hTimer = TimerInit()
OnAutoItExitRegister("_Exit")

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUISetOnEvent($GUI_EVENT_CLOSE, "_GuiClose")
AdlibRegister("_RestartCheck", 10000)

While Sleep(20)
WEnd

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam

	Local $iB

	Switch _WinAPI_LoWord($wParam)
		Case $hInput
			Switch _WinAPI_HiWord($wParam)
				Case $EN_CHANGE
					$iB = Int($lParam)
					LogiLedSet($LED_KEYBOARD, $iB, $iB, $iB)
			EndSwitch
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func _GuiClose()
	Exit 0
EndFunc

Func _Exit()
	LogiLedDeInit()
EndFunc   ;==>_Exit

Func _RestartCheck()
	; Due to a memory leak in older versions of logitechled.dll, we need to restart the process when the memory usage exceeds a specified limit
	; Newer versions of the dll do not have this problem, but the brightness has only 10 levels, compared to the older 100 levels

	$aMemory = ProcessGetStats()
	_Log("Using " & $aMemory[0] & " bytes of memory, " & ($MAX_BYTES - $aMemory[0]) & " bytes to termination")

	If $aMemory[0] >= $MAX_BYTES Then
		_Log("Commiting suicide...")
		$iChildPID = Run(StringFormat('"%s" "%s" "%s"', @AutoItExe, @ScriptFullPath, @AutoItPID), @ScriptDir)
		_Log("Spawned child with PID " & $iChildPID)
		Exit
	EndIf
EndFunc

Func _Log($sText)
;~ 	FileWriteLine($sLogFile, _TimeStamp() & @TAB & $sText)
	ConsoleWrite($sText & @CRLF)
EndFunc

Func _TimeStamp()
	Return @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc