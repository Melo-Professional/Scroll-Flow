/************************************************************************
 * @description Vars_Custom
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.0.0
 ***********************************************************************/

;@region VARS
; CUSTOM VARIABLES

global GuiToolTip := false
global UseOSD := false
global RenderInterval   := 10

; ==============================================================================
; INTERNAL STATE VARIABLES
; ==============================================================================
global CurrentVelocity   := 0.0
global ResidualScroll    := 0.0
global MainLastScrollTime    := 0
global LastScrollTime    := 0
global ScrollTimerActive := false
global LastTimeTimeout := 1000

; ==============================================================================
; --- MOUSETABS RULES ---
; ==============================================================================
global TabAreaHeight    := 50    ; Height in pixels from the top of the window
global EnabledTabApps   := Map(
    "Chrome_WidgetWin_1", true,  ; Chrome, Edge, Brave, Opera, VS Code
    "MozillaWindowClass", true,  ; Firefox
    "Notepad++", true,           ; Notepad++
    "CabinetWClass", true        ; Windows 11 File Explorer
)
; ==============================================================================
; --- PROFILES ---
; ==============================================================================
;global ProfileList := ["slow", "precise", "equilibrium", "long", "fast", "custom_1", "custom_2"]
global ProfileList := ["slow", "precise", "equilibrium", "long", "fast", "mobile_flow", "mobile_flow2"]
Global Wheel := {
        Profile: "equilibrium"
}

;ApplyProfile(Wheel.Profile)

ApplyProfile(Profile){
    global

    switch Profile {
        case "slow":
                BaseScrollAmount := 0.170
                Friction         := 1.0869
                FastSpinWindow   := 40.000
                AccelRate        := 3.000
                StopThreshold    := 0.080
        case "precise":
                BaseScrollAmount := 0.170
                Friction         := 1.0869
                FastSpinWindow   := 40.000
                AccelRate        := 8.000
                StopThreshold    := 0.080
        case "equilibrium":
                BaseScrollAmount := 0.170
                Friction         := 1.066
                FastSpinWindow   := 50.000
                AccelRate        := 16.000
                StopThreshold    := 0.101
        case "long":
                BaseScrollAmount := 0.170
                Friction         := 1.0416
                FastSpinWindow   := 50.000
                AccelRate        := 16.000
                StopThreshold    := 0.050
        case "fast":
                BaseScrollAmount := 0.170
                Friction         := 1.066
                FastSpinWindow   := 80.000
                AccelRate        := 25.000
                StopThreshold    := 0.101
        case "custom_1":
                BaseScrollAmount := 0.170
                Friction         := 1.0582
                FastSpinWindow   := 20.000
                AccelRate        := 16.000
                StopThreshold    := 0.100
        case "custom_2":
                BaseScrollAmount := 0.25
                Friction         := 1.0526
                FastSpinWindow   := 60
                AccelRate        := 4
                StopThreshold    := 0.07
        case "mobile_flow":
                BaseScrollAmount := 0.250
                Friction         := 1.050
                FastSpinWindow   := 18.000
                AccelRate        := 38.000
                StopThreshold    := 0.210
        case "mobile_flow2":
                BaseScrollAmount := 0.250
                Friction         := 1.0489999999999999
                FastSpinWindow   := 20.000
                AccelRate        := 18.000
                StopThreshold    := 0.110
        }
}
;@endregion


ResetSettings       := Settings.Clone()
;ResetSettings       := Settings.Clone()
;ResetGeneral        := General.Clone()
;ResetOSDSettings    := OSDSettings.Clone()

;App.NameCutted := "Template`nBigName"
;Settings.SplashScreen := "Icon"
;Debug := true
;@endregion


;@region INI
SaveToINI.Push("Wheel.Profile")     ; add more to INI file
RegisterArrayItems(SaveToINI)
LoadINI()
;@endregion