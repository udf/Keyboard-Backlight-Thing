#include-once
;GLOBALS
Global Const $LED_MOUSE = 0x0001 ;wird bei Set,Save und Restore benutzt, auswählen zwischen Maus oder Keyboard
Global Const $LED_KEYBOARD = 0x0002 ;mit OR verknüpfen für ALLE Geräte
Global $dllLED = 0
Global $callback = -1

;------------------------------LED steuerung, sollte selbsterklärend sein
;LogiLedInit()
;LogiLedSet($LED_KEYBOARD, r, g, b)
;LogiLedDeInit()

Func LogiLedInit($sDLLPathLED = "LogitechLed.dll")
	$dllLED = DllOpen($sDLLPathLED)
	Local $ret = DllCall($dllLED, "bool:cdecl", "LogiLedInit")
	If @error Then
		Return SetError(1, @error, 0)
	Else
		Return $ret[0]
	EndIf
EndFunc   ;==>LogiLedInit

Func LogiLedDeInit()
	If $callback <> -1 Then DllCallbackFree($callback)
	Local $ret = DllCall($dllLED, "none:cdecl", "LogiLedShutdown")
	If @error Then Return SetError(1, @error, 0)
	DllClose($dllLED)
	Return $ret[0]
EndFunc   ;==>LogiLedDeInit

;Red, Green, Blue können werte zwischen 0 und 100 einnehmen (stellt Prozent dar)
Func LogiLedSet($iKeyboadMouse = $LED_KEYBOARD, $iRed = 0, $iGreen = 0, $iBlue = 0)
	Local $ret = DllCall($dllLED, "bool:cdecl", "LogiLedSetLighting", "int", $iKeyboadMouse, "int", $iRed, "int", $iGreen, "int", $iBlue)
	If @error Then Return SetError(1, @error, 0)
	Return $ret[0]
EndFunc   ;==>LogiLedSet

;Speichert aktuelle Farbe der Beleuchtung, z.B. für temporäre Änderung (Warning etc.)
Func LogiLedSave($iKeyboadMouse = $LED_KEYBOARD)
	Local $ret = DllCall($dllLED, "bool:cdecl", "LogiLedSaveCurrentLighting", "int", $iKeyboadMouse)
	If @error Then Return SetError(1, @error, 0)
	Return $ret[0]
EndFunc   ;==>LogiLedSave

;Stellt die mit "LogiLedSave(...)" gespeicherte Beleuchtung wieder her
Func LogiLedRestore($iKeyboadMouse = $LED_KEYBOARD)
	Local $ret = DllCall($dllLED, "bool:cdecl", "LogiLedRestoreLighting", "int", $iKeyboadMouse)
	If @error Then Return SetError(1, @error, 0)
	Return $ret[0]
EndFunc   ;==>LogiLedRestore
;pulsiert im 3s Takt
Func LogiLedPulse($iKeyboadMouse = $LED_KEYBOARD, $iRed = 0, $iGreen = 0, $iBlue = 0, $iTime = 0, $iTime2 = 0)
	Local $ret = DllCall($dllLED, "bool:cdecl", "LogiLedPulseLighting", "int", $iKeyboadMouse, "int", $iRed, "int", $iGreen, "int", $iBlue, "int", $iTime, "int", $iTime2)
	If @error Then Return SetError(1, @error, 0)
	Return $ret[0]
EndFunc   ;==>LogiLedPulse

;gibt den Helligkeitswert in Prozent zurück, 0-99
Func LogiLedGet($iKeyboadMouse = $LED_KEYBOARD)
	Local $ret = DllCall($dllLED, "int:cdecl", "LogiLedGetCurrentBrightnessPercentage", "int", $iKeyboadMouse)
	If @error Then Return SetError(1, @error, 0)
	Return $ret[0]
EndFunc   ;==>LogiLedGet
;Return ist bei allen: erfolg 1, ansonsten 0
;LogiLedInit() muss vor den anderen Funktionen aufgerufen werden
