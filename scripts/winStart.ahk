#Requires AutoHotkey v2.0

; Disable normal CapsLock functionality
SetCapsLockState "AlwaysOff"

; Launch helper applications on script start
LaunchHelperApps()

*CapsLock:: {
    Send "{Esc}"
    return
}

LaunchHelperApps() {
    ; Check if GlazeWM is running and start if not
    if !ProcessExist("glazewm.exe") {
        try Run("glazewm.exe")
    }
    
    ; Check if LibreWolf is running and start if not
    if !ProcessExist("C:\Program Files\LibreWolf\librewolf.exe") {
        try Run("librewolf.exe")
    }
    
    ; Check if WezTerm is running and start if not
    if !ProcessExist("wezterm-gui.exe") {
        try Run("C:\Program Files\WezTerm\wezterm.exe", "", "Hide")
    }
    
    ; Always start Firefox minimized
    if !ProcessExist("firefox.exe") {
        try Run("firefox.exe",,, &pid)
        WinWait("ahk_pid " pid)
        WinMinimize("ahk_pid " pid)
    }
}

!Enter:: { ; Alt + Enter
    Run("C:\Program Files\WezTerm\wezterm.exe", "", "Hide")
}