Usage:
1) Install AutoHotkey - http://autohotkey.com
2) Install VJoy 2.x - http://vjoystick.sourceforge.net
If running windows 64-bit, you will need to enter "Test Mode" to install the Vjoy driver. VJoy handles this for you. It requires a reboot.
Once you have rebooted, you can use the vjoy app to configure the virtual stick. The default setting works with this app though.
3) Take the Lib Folder from the zip and drop it into your AutoHotkey folder. This should be C:\Program Files\AutoHotkey or C:\Program Files (x86)\AutoHotkey
If there is already a lib folder in there, do not worry.
You should end up with a bunch of stuff in C:\Program Files\AutoHotkey\Lib - VJoy_lib.ahk and some other files in a VJoyLib folder.
4) Extract the padthrottle.ahk somewhere and edit it - the first few lines define which joystick to use etc.
For an XBOX controller with recommended settings, you should only need to change the joystick ID line.
5) Run padthrottle.ahk. If it does not throw any errors, you should be good. Just go into Game controllers and preview the virtual stick.
Check that it works and that you can reach the corners (esp if not in relative mode)

Game binding:
To bind the virtual stick in your game, to avoid the game recognising the physical stick, bind like this:
Double click the bind option in the game for the x axis, and hit CTRL+ALT+X. This will waggle the virtual x axis a bit.
Repeat for the Y Axis, use CTRL+ALT+Y

MWO users:
For this to work, the setting cl_joystick_throttle_range must be 1.
1 is the default value, so either make sure there is no cl_joystick_throttle_range setting in your user cfg or make sure it is set to 1.
cl_joystick_throttle_range = 0 in your user.cfg will break this script!
