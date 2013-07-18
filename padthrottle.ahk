#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Init the PPJoy / vJoy library
#include <VJoy_lib>

throttle := 0

LoadPackagedLibrary() {
	SplitPath, A_AhkPath,,tmp
    if (A_PtrSize < 8) {
        dllpath := tmp "\Lib\VJoyLib\x86\vJoyInterface.dll"
    } else {
        dllpath := tmp "\Lib\VJoyLib\x64\vJoyInterface.dll"
    }
    hDLL := DLLCall("LoadLibrary", "Str", dllpath)
    if (!hDLL) {
        MsgBox, [%A_ThisFunc%] LoadLibrary %dllpath% fail
    }
    return hDLL
} 

; Detects the sign (+ or -) of a number and returns a multiplier for that sign
sign(input){
	if (input < 0){
		return -1
	} else {
		return 1
	}
}

sign_adjust(input, sign){
	return input * sign(sign)
}

; Applies a deadzone to an axis.
; A 50% deadzone passes back 0% at < 50%, but from 50% -> 100% returns 1-100%
; axis: value of axis (-1 -> +1 format)
; dz: Deadzone amount (0 -> 1 format)
deadzone_adjust(axis, dz){
	if (dz != 0){
		tmp := sign(dz)

		if (abs(axis) > dz){
			axis := (abs(axis) - dz) * (1/(1 - dz)) * sign(axis)
		} else {
			axis := 0
		}
	}
	return axis
}

; Load DLL
LoadPackagedLibrary()

; ID of the virtual stick (1st virtual stick is 1)
vjoy_id := 1

; Init Vjoy library
VJoy_Init(vjoy_id)

Loop {
	;GetKeyState, tmpx, 4JoyX
	;GetKeyState, tmpy, 4JoyY
	GetKeyState, tmpx, 3JoyX
	GetKeyState, tmpy, 3JoyY

	; Convert from 0 -> 100 to -1 -> +1
	tmpx := (tmpx / 50) - 1
	tmpy := (tmpy / 50) - 1
	
	; Apply deadzone
	;outx := deadzone_adjust(tmpx,0.1)
	outx := tmpx
	outy := deadzone_adjust(tmpy,0.1)
	
	; Circle to square amplify
	outx := outx * 1.3
	outy := outy * 1.3
	
	; Absolute to relative throttle
	outy := throttle + (outy / 40)

	; Limit to -1 -> +1
	if (abs(outx) > 1){
		outx := sign(outx)
	}
	if (abs(outy) > 1){
		outy := sign(outy)
	}
	; Save throttle value
	throttle := outy
	
	;tooltip, % "X: " tmpx " | " outx "`nY: " tmpy " | " outy "`n" tmp
	
	; Rescale to 0 -> 100
	outx := (outx * 50) + 50
	outy := (outy * 50) + 50
	
	; Rescale to 0 -> 32767
	outx := outx * 327.67
	outy := outy * 327.67
	
	; Send data to virtual stick
	VJoy_SetAxis(outx, vjoy_id, HID_USAGE_X)
	VJoy_SetAxis(outy, vjoy_id, HID_USAGE_Y)
	sleep, 10
}

; XBOX controller stop on click of stick
3Joy9::
	throttle := 0
	return

; Waggle x axis for game binding
*~^!x::
	soundbeep
	VJoy_SetAxis(1500, vjoy_id, HID_USAGE_X)
	sleep, 50
	return
	
; Waggle y axis for game binding
*~^!y::
	soundbeep
	VJoy_SetAxis(1500, vjoy_id, HID_USAGE_Y)
	sleep, 50
	return

return