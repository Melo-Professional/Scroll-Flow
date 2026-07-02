/************************************************************************
 * @description Vars_Custom
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.0.0
 ***********************************************************************/

;@region VARS
; CUSTOM VARIABLES
; ==============================================================================
; --- PROFILES ---
; ==============================================================================

Settings.ActiveProfile := "Equilibrium"
Settings.Exclusions := "mspaint.exe,steamwebhelper.exe,voicemeeter8x64.exe,whatsapp.root.exe"
Settings.Custom_BaseSpeed :=        1.03
Settings.Custom_BrakingFriction :=  0.10
Settings.Custom_SpeedBoost :=       1.16

global GlobalActiveProfile := "Equilibrium"
global LiveExclusionMap := Map() ; The internal engine ONLY reads application blocks from this map

global Profiles := Map(
    "Slow",        {BaseSpeed: 0.84, BrakingFriction: 0.14, SpeedBoost: 0.60},
    "Precise",     {BaseSpeed: 1.00, BrakingFriction: 0.16, SpeedBoost: 1.06},
    "Equilibrium", {BaseSpeed: 1.08, BrakingFriction: 0.10, SpeedBoost: 1.14},
    "Fast",        {BaseSpeed: 1.60, BrakingFriction: 0.10, SpeedBoost: 1.95},
    "Dry",         {BaseSpeed: 1.40, BrakingFriction: 0.20, SpeedBoost: 1.80},
    "Wet",         {BaseSpeed: 1.40, BrakingFriction: 0.06, SpeedBoost: 1.80},
    "Custom",      {BaseSpeed: 1.03, BrakingFriction: 0.10, SpeedBoost: 1.16}
)
;@endregion

;ResetSettings       := Settings.Clone()
;ResetSettings       := Settings.Clone()
;ResetGeneral        := General.Clone()
;ResetOSDSettings    := OSDSettings.Clone()

App.Github := "https://github.com/Melo-Professional/Scroll-Flow"
;App.NameCutted := "Template`nBigName"
;Settings.SplashScreen := "Icon"
;Debug := true
;@endregion


;@region INI
SaveToINI.Push("Settings.ActiveProfile",
    "Settings.Exclusions",
    "Settings.Custom_BaseSpeed",
    "Settings.Custom_BrakingFriction",
    "Settings.Custom_SpeedBoost")     ; add more to INI file
RegisterArrayItems(SaveToINI)
LoadINI()
GlobalActiveProfile := Settings.ActiveProfile
;KineticGui := 0

class Physics {
    static BaseSpeed := 1.00
    static BrakingFriction := 0.10
    static SpeedBoost := 1.04
    
    static Velocity := 0.0
    static MomentumReservoir := 0.0
}

; ==============================================================================
; --- INTERCEPTION ENGINE RUNTIME STATE BUFFER ---
; ==============================================================================
global TargetTopHWnd := 0
global TargetCtrlHWnd := 0
global PackedLParam := 0
global ScrollMethod := "Win32HighPrecision"
global AccV := 0.0

global KineticGui := 0
global AddAppsGui := 0
global CatalogListBox := 0 
global WorkingExclusions := "" 

;@endregion