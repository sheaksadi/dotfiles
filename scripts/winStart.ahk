#Requires AutoHotkey v2.0

!Enter:: { ; Alt + Enter
    Run("C:\Program Files\WezTerm\wezterm.exe", "", "Hide")
}

; Disable normal CapsLock functionality
SetCapsLockState "AlwaysOff"

; Configuration - Add your app-specific keybinds here
; Each entry specifies:
; 1. Type: "process" or "title"
; 2. Pattern to match (process name or window title)
; 3. Key to send
appKeybinds := [
    ["process", "TslGame.exe", "{Backspace}"],
    ["title", "PUBG", "{Backspace}"],
    ; ["process", "notepad.exe", "^s"],
    ; ["title", "google chrome", "^t"]
]

*CapsLock::
{
    ; Get the process name and window title of the active window
    activeProcess := WinGetProcessName("A")
    activeWindow := WinGetTitle("A")
    
    ; Check all configured application keybinds
    for binding in appKeybinds
    {
        checkType := binding[1]
        pattern := binding[2]
        keyToSend := binding[3]
        
        if (checkType = "process" && activeProcess = pattern)
        {
            Send keyToSend
            return
        }
        else if (checkType = "title" && InStr(activeWindow, pattern))
        {
            Send keyToSend
            return
        }
    }
    
    ; Default behavior for all other applications
    if KeyWait("CapsLock", "T0.3")
    {
        Send "{Esc}"
    }
    else
    {
        Send "{LControl Down}"
        KeyWait "CapsLock"
        Send "{LControl Up}"
    }
    return
}
