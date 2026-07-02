;@region Setup
;@region Description
/************************************************************************
 * @description Scroll Flow is a lightweight utility that enhances mouse scrolling with smoother movement, improved responsiveness, and refined acceleration behavior for a more natural navigation experience.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/02
 * @releasedate 2025/05/06
 * @version 3.1.0.0
 ***********************************************************************/

AppName := "Scroll Flow"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "3.1.0.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := '"Scroll Flow is a lightweight utility that enhances mouse scrolling with smoother movement, improved responsiveness, and refined acceleration behavior for a more natural navigation experience."'
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
A_MenuMaskKey := "vkFF"
; --- Optimization Settings ---
;ProcessSetPriority("High")
ListLines(False)
KeyHistory(0)
A_MaxHotkeysPerInterval := 5000
A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Config&Vars>
#Include *i <_MsgBoxCustom>
#Include *i <_SaveSettings>
#Include *i <_Theme>
#Include *i <_OSDCustom>
;#Include *i <_Color_Picker_Dialog_>
#Include *i <_SplashScreen>
#Include *i <_About>
;#Include *i <_Help>
#Include *i <_Menu>

#Include <Vars_Custom>
#Include <Menu_Custom>
#Include <Help>
#Include <Settings_Gui>
;@endregion

;@region Startup
; SPLASHSCREEN
if IsSet(SplashScreen){
    SplashScreen()
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()
;@endregion

; Execute the bridge mapping
SyncEngineFromSettings()

if IsSet(FirstRun){
    ShowKineticGUI()
}
;@endregion


;@region Helper Funcs
; OSD
SFOSD := OSDCustom("Another OSD with default settings")
Show_OSD(label) {
    SFOSD.ClearCells()
    SFOSD.SetCellImage( 1, 1, App.Icon, "Left", 16, 1, 1)
    msg := SFOSD.SetCellText( 2, 1, label, "Center", {FontSize: 9, FontWeight: 300})
    SFOSD.SetCellText( 3, 1, "   ", "Right", {FontSize: 8, FontWeight: 500})
    if SFOSD.IsVisible{
        SFOSD.UpdateTextObject( msg, label, 3300)
        return
    } else {
        SFOSD.Show("x0.90 y0.95", 3000)
    }
}

SoundPlayWin(sound := "Windows Notify", timer := 3000) {
  try SoundPlay(A_WinDir "\Media\" sound ".wav")
  SetTimer(ReleaseFile,-timer)
  ReleaseFile(){
    try SoundPlay("NON-EXISTENT.wav")
  }
}

SyncEngineFromSettings() {
    global GlobalActiveProfile, LiveExclusionMap
    
    ; 1. Pull the raw config values loaded into 'Settings' object
    GlobalActiveProfile := Settings.ActiveProfile
    
    ; 2. Parse the CSV exclusions string into a fast look-up Map
    LiveExclusionMap.Clear()
    loop parse, Settings.Exclusions, "," {
        clean := StrLower(Trim(A_LoopField))
        if (clean != "")
            LiveExclusionMap[clean] := true
    }
    
    ; 3. Safely update Custom profile configurations
        if Settings.HasOwnProp("Custom_BaseSpeed")
            Profiles["Custom"].BaseSpeed := (Settings.Custom_BaseSpeed)
        if Settings.HasOwnProp("Custom_BrakingFriction")
            Profiles["Custom"].BrakingFriction := (Settings.Custom_BrakingFriction)
        if Settings.HasOwnProp("Custom_SpeedBoost")
            Profiles["Custom"].SpeedBoost := (Settings.Custom_SpeedBoost)
    
    ApplyProfile(GlobalActiveProfile)
}

ApplyProfile(profileName) {
    global GlobalActiveProfile, ProfileMenu
    if !Profiles.Has(profileName)
        profileName := "Equilibrium"
        
    ; 1. Remove checkmark from the previously active profile
    if IsSet(ProfileMenu) {
        try ProfileMenu.Uncheck(GlobalActiveProfile)
    }
        
    GlobalActiveProfile := profileName
    prof := Profiles[profileName]
    
    Physics.BaseSpeed := prof.BaseSpeed
    Physics.BrakingFriction := prof.BrakingFriction
    Physics.SpeedBoost := prof.SpeedBoost
    
    ; 2. Add checkmark to the newly active profile
    if IsSet(ProfileMenu) {
        try ProfileMenu.Check(GlobalActiveProfile)
    }
    
    ; 3. If the main studio GUI is visible, update its sliders/dropdown too
    ;if (ShowKineticGUI != 0) {
    if (KineticGUI != 0) {
        try UpdateKineticGUIElements()
    }
}

LoadSettings() {
    LoadINI()
    SyncEngineFromSettings()
}

SaveSettings() {
    global GlobalActiveProfile, LiveExclusionMap
    
    ; 1. Push internal physics state configuration variables back out to 'Settings' model
    Settings.ActiveProfile := GlobalActiveProfile
    
    outStr := ""
    for exeName, _ in LiveExclusionMap {
        outStr .= (outStr == "" ? "" : ",") exeName
    }
    Settings.Exclusions := (outStr == "") ? 0 : outStr
    
    Settings.Custom_BaseSpeed := Round(Profiles["Custom"].BaseSpeed, 2)
    Settings.Custom_BrakingFriction := Round(Profiles["Custom"].BrakingFriction, 2)
    Settings.Custom_SpeedBoost := Round(Profiles["Custom"].SpeedBoost, 2)
    
    ; 2. Commit the structural 'Settings' data downstream to the INI
    SaveINI()
}
;@endregion

;@region Interception
#HotIf ShouldNormalizeScroll()
$WheelUp::   HandleScroll(1)
$WheelDown:: HandleScroll(-1)
#HotIf

~ScrollLock::ToggleSuspend()
ToggleSuspend() {
    Global Settings
    Settings.IsScriptPaused := !Settings.IsScriptPaused
    Physics.Velocity := 0.0
    Physics.MomentumReservoir := 0.0

    if (Settings.IsScriptPaused) {
        Show_OSD( App.Name " Suspended")
        SoundPlayWin("Speech Sleep")
        try TrayMenu.Check("Suspend`tScrollLock")
    } else {
        Show_OSD( App.Name " Active")
        SoundPlayWin("Speech On")
        try TrayMenu.Uncheck("Suspend`tScrollLock")
    }
        if (A_IsCompiled && (Settings.IsScriptPaused || A_IsSuspended))
            TraySetIcon(App.IconPaused, -207, true)
        else if (Settings.IsScriptPaused || A_IsSuspended)
            TraySetIcon(App.IconPaused, -207, true)
        else
        TraySetIcon(App.Icon,, true)
}
;@endregion

;@region Main
ShouldNormalizeScroll() {
    global LiveExclusionMap, KineticGui, AddAppsGui
    
    ; Layer 1: Global Pause Safeguard
    if (Settings.IsScriptPaused)
        return false

    CoordMode "Mouse", "Screen"
    try {
        MouseGetPos ,, &topHwnd
        if (!topHwnd)
            return true
            
        ; Updated to use your new 'KineticGui' variable name
        if (KineticGui != 0 && topHwnd == KineticGui.Hwnd)
            return false
        if (AddAppsGui != 0 && topHwnd == AddAppsGui.Hwnd)
            return false
            
        rootHwnd := DllCall("GetAncestor", "Ptr", topHwnd, "UInt", 2, "Ptr")
        targetHwnd := rootHwnd ? rootHwnd : topHwnd

        topClass := WinGetClass(targetHwnd)
        procName := StrLower(WinGetProcessName(targetHwnd))
        
        ; Layer 2: Core Windows Interface & Desktop Protections
        if (topClass == "Shell_SecondaryTrayWnd" || topClass == "Shell_TrayWnd" || topClass == "NewStartServer" || topClass == "Progman" || topClass == "WorkerW")
            return false
            
        ; Layer 3: Explicit User Exclusion List
        if LiveExclusionMap.Has(procName) || LiveExclusionMap.Has(StrLower(topClass)) {
            Physics.Velocity := 0.0
            Physics.MomentumReservoir := 0.0
            return false
        }
        
        ; Layer 4: AUTOMATIC FULLSCREEN GAME DETECTION (With Browser Whitelist Exception)
        WinGetPos(&wX, &wY, &wW, &wH, targetHwnd)
        style := WinGetStyle(targetHwnd)
        
        ; 0x00C00000 is WS_CAPTION (Title bar removed when a game or full-screen app runs)
        if ((style & 0x00C00000) == 0) {
            if (wW >= A_ScreenWidth && wH >= A_ScreenHeight) {
                
                ; Check if this borderless window is actually a web browser or document viewer
                isScrollableApp := (procName = "chrome.exe" || procName = "firefox.exe" 
                                 || procName = "msedge.exe" || procName = "brave.exe" 
                                 || procName = "opera.exe"  || procName = "vivaldi.exe"
                                 || procName = "acrord32.exe" || procName = "foxitreader.exe"
                                 || InStr(topClass, "Chrome_") || InStr(topClass, "Mozilla"))
                
                ; If it is NOT a known web browser/reader, treat it as a game and bypass!
                if (!isScrollableApp) {
                    Physics.Velocity := 0.0
                    Physics.MomentumReservoir := 0.0
                    return false 
                }
            }
        }
        
        ; Layer 5: Universal Windows Platform (UWP) App Framework Blocks
        if (topClass == "ApplicationFrameWindow" || topClass == "Windows.UI.Core.CoreWindow" || InStr(topClass, "Windows.UI.XAML")) {
            return false
        }
    } catch {
        return true 
    }
    return true
}

HandleScroll(Direction) {
    global TargetTopHWnd, TargetCtrlHWnd, PackedLParam, ScrollMethod, AccV
    
    if (Direction > 0 && Physics.Velocity < 0) || (Direction < 0 && Physics.Velocity > 0) {
        Physics.Velocity := 0.0
        Physics.MomentumReservoir := 0.0
        AccV := 0.0
    }
    
    Physics.MomentumReservoir += 1.1
    if (Physics.MomentumReservoir > 18.0) 
        Physics.MomentumReservoir := 18.0
    
    boostFactor := 1.0
    if (Physics.MomentumReservoir > 2.2) {
        boostFactor += (Physics.MomentumReservoir - 2.2) * Physics.SpeedBoost * 0.65
    }
    
    CoordMode "Mouse", "Screen"
    MouseGetPos &X, &Y, &TopHWnd, &CtrlHWnd, 2 
    
    TargetTopHWnd := TopHWnd
    TargetCtrlHWnd := CtrlHWnd ? CtrlHWnd : TopHWnd
    PackedLParam := (Y << 16) | (X & 0xFFFF)
    
    ScrollMethod := DetectMethod(TargetCtrlHWnd, TargetTopHWnd)
    Physics.Velocity += Direction * Physics.BaseSpeed * boostFactor
    
    SetTimer PhysicsTick, 8 
}

DetectMethod(ctrlHwnd, topHwnd) {
    try {
        topClass := WinGetClass(topHwnd)
        procName := WinGetProcessName(topHwnd)
        
        if (InStr(topClass, "Chrome_") || InStr(topClass, "Mozilla") || procName = "firefox.exe") {
            return "BrowserHighPrecision"
        }
        
        ctrlClass := WinGetClass(ctrlHwnd)
        if (ctrlClass = "SysListView32")
            return "PixelLV"
        if (ctrlClass = "SysTreeView32" || ctrlClass = "Edit" || ctrlClass = "ListBox" || InStr(ctrlClass, "RichEdit"))
            return "LineScroll"
    }
    return "Win32HighPrecision" 
}

PhysicsTick() {
    global TargetTopHWnd, TargetCtrlHWnd, PackedLParam, ScrollMethod, AccV
    
    if (!WinExist("ahk_id " TargetTopHWnd)) {
        Physics.Velocity := 0.0
        Physics.MomentumReservoir := 0.0
        AccV := 0.0
        SetTimer , 0
        return
    }
    
    Physics.Velocity *= (1.0 - Physics.BrakingFriction)
    Physics.MomentumReservoir *= 0.95 
    
    if (Abs(Physics.Velocity) < 0.03) {
        Physics.Velocity := 0.0
        Physics.MomentumReservoir := 0.0
        AccV := 0.0
        SetTimer , 0
        return
    }
    
    AccV += Physics.Velocity
    
    if (Abs(AccV) > 0.01) {
        if (ScrollMethod = "PixelLV") {
            px := Integer(AccV * 4)
            if (px != 0) {
                AccV -= (px / 4)
                SendMessage(0x1014, 0, -px,, "ahk_id " TargetCtrlHWnd)
            }
        }
        else if (ScrollMethod = "LineScroll") {
            lines := Integer(AccV / 1.2) 
            if (lines != 0) {
                AccV -= lines * 1.2
                cmd := (lines > 0) ? 0 : 1 
                Loop Abs(lines) {
                    SendMessage(0x0115, cmd, 0,, "ahk_id " TargetCtrlHWnd)
                }
                SendMessage(0x0115, 8, 0,, "ahk_id " TargetCtrlHWnd) 
            }
        }
        else { 
            step := Integer(AccV * 25)
            if (step != 0) {
                AccV -= (step / 25)
                wParam := (step << 16) & 0xFFFFFFFF 
                PostMessage(0x020A, wParam, PackedLParam,, "ahk_id " (ScrollMethod = "BrowserHighPrecision" ? TargetTopHWnd : TargetCtrlHWnd))
            }
        }
    }
}
;@endregion