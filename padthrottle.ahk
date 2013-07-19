; Pad Throttle 0.3
; By Clive "evilC" Galway - evilc@evilc.com
; An app to make a joypad (Such as an XBOX controller) behave like a throttle and rudders

; Edit the following lines for your desired setup

JoyID := 3				; Stick ID to use for input
JoyAxisX := 1			; Axis on your pad to use for rudder
JoyAxisY := 2			; Axis on your pad to use for throttle
DeadZoneX := 0.1		; DeadZone of the X axis (0 -> 1, so 10% is 0.1)
DeadZoneY := 0.1		; Deadzone of the Y axis
AmplifyAmount := 1.5	; How much to amplify each axis. Used to convert a round (gamepad) range to a square (joystick) one.
InvertY := 0			; Invert the throttle (may need depending on settings in user.cfg cl_joystick_invert_throttle setting)
RelativeThrottle := 1	; Enable relative throttle as default
ThrottleSpeed := 40		; Speed the Relative Throttle moves at. Higher is slower
StopButton := 9			; Specifies which button is bound to stop. In relative mode, sets throttle to 0. Set this to 0 to disable this feature
ModeButton := 5			; Specifies which button is bound to switch throttle mode. Switches between relative and absolute mode.

; Amount to rotate the input axis by. In degrees, 0 is none, 20 is 20deg anti-clockwise, 340 is 20deg clockwise
; Used to correct the fact that moving your thumb left on an XBOX controller is more like left and up a bit.
AxisRotate := 345		; Seems about right for XBOX left stick and Logitech G13


; Users should not edit below this line

; Convert Axis from degrees to radians
AxisRotate :=  AxisRotate * 3.141592653589793238 / 180

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Init the PPJoy / vJoy library
#include <VJoy_lib>

axis_list_ahk := Array("X","Y","Z","R","U","V")

throttle := 0
relative_mode := RelativeThrottle

LoadPackagedLibrary() {
	SplitPath, A_AhkPath,,tmp
    if (A_PtrSize < 8) {
        dllpath := tmp "\Lib\VJoyLib\x86\vJoyInterface.dll"
    } else {
        dllpath := tmp "\Lib\VJoyLib\x64\vJoyInterface.dll"
    }
    hDLL := DLLCall("LoadLibrary", "Str", dllpath)
    if (!hDLL) {
        MsgBox, [%A_ThisFunc%] Failed to find DLL at %dllpath%
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

; Bind stop button if enabled
if (StopButton){
	Hotkey, *~%JoyID%Joy%StopButton%, stop_throttle
	Hotkey, *~%JoyID%Joy%ModeButton%, throttle_mode
}

Loop {
	;GetKeyState, outx, 4JoyX
	;GetKeyState, outy, 4JoyY
	outx := axis_list_ahk[JoyAxisX]
	outy := axis_list_ahk[JoyAxisY]
	GetKeyState, outx, %JoyID%Joy%outx%
	GetKeyState, outy, %JoyID%Joy%outy%
	
	if (InvertY){
		outy := 100 - outy
	}

	; Convert from 0 -> 100 to -1 -> +1
	outx := (outx / 50) - 1
	outy := (outy / 50) - 1
	
	; Rotate the axis
	if (AxisRotate){
		rotx := outx * cos(AxisRotate) - outy * sin(AxisRotate)
		roty := outx * sin(AxisRotate) + outy * cos(AxisRotate)
		outx := rotx
		outy := roty
	}

	; Apply deadzone
	outx := deadzone_adjust(outx,DeadZoneX)
	outy := deadzone_adjust(outy,DeadZoneY)
	
	; Circle to square amplify
	outx := outx * AmplifyAmount
	outy := outy * AmplifyAmount
	
	if (relative_mode){
		; Absolute to relative throttle
		if (RelativeThrottle){
			outy := throttle + (outy / ThrottleSpeed)
		}
	}

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

stop_throttle:
	throttle := 0
	return

throttle_mode:
	relative_mode := 1 - relative_mode
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