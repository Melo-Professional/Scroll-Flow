;@region Setup
;@region Description
/************************************************************************
 * @description Scroll Flow is a lightweight utility that enhances mouse scrolling with smoother movement, improved responsiveness, and refined acceleration behavior for a more natural navigation experience.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/09
 * @releasedate 2025/05/06
 * @version 2.3.1.0
 ***********************************************************************/

AppName := "Scroll Flow"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.3.1.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := '"Scroll Flow is a lightweight utility that enhances mouse scrolling with smoother movement, improved responsiveness, and refined acceleration behavior for a more natural navigation experience."'
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
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
;#Include *i <_OSDCustom_>
;#Include *i <_Color_Picker_Dialog_>
#Include *i <_SplashScreen>
#Include *i <_About>
;#Include *i <_Help>
#Include *i <_Menu>

#Include <Menu_Custom>
#Include <Help>
#Include <Vars_Custom>
#Include <OSD>
#Include <Tweaker>
;@endregion

;@region Startup
; SPLASHSCREEN
if IsSet(SplashScreen){
    SplashScreen("Icon")
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()

;@endregion
;@endregion


;@region Main
ApplyProfile(Wheel.Profile)
LastFriction := Friction
$~WheelUp:: {
    Global Friction
    Friction := LastFriction
    MainChoose(1)
}

$~WheelDown:: {
    Global Friction
    Friction := LastFriction
    MainChoose(-1)
}

#HotIf (Abs(CurrentVelocity) > StopThreshold)
MButton:: {
    Global Friction
    Static State := true

    if State
        Friction := 1
    else
        Friction := LastFriction

    State := !State
}
#HotIf

; ==============================================================================
; CHECK FOR TASKBAR AND BROWSERS
; ==============================================================================
MainChoose(Direction){
    global MainLastScrollTime

    MainCurrentTime := A_TickCount
    MainTimeDelta := MainCurrentTime - MainLastScrollTime
    MainLastScrollTime := MainCurrentTime

    if MainTimeDelta > LastTimeTimeout {

        MouseGetPos(&mouseXPos, &mouseYPos, &winId)

        ; Check TaskBar
        if MouseIsOverTaskbar(winId){
            MainLastScrollTime := A_TickCount - LastTimeTimeout -1 ; Keep checking mouse
            Debug ? (ToolTip(" TaskBar `n Delta: " MainTimeDelta), SetTimer(() => ToolTip(), -LastTimeTimeout)) : ""
            return
        }

        ; Check Apps
        if CheckCTW(Direction, mouseXPos, mouseYPos, winId){
            MainLastScrollTime := A_TickCount - LastTimeTimeout -1 ; Keep checking mouse
            Debug ? (ToolTip(" CTW `n Delta: " MainTimeDelta), SetTimer(() => ToolTip(), -LastTimeTimeout)) : ""
            return
        }
    }
    HandleScroll(Direction)
}

; ==============================================================================
; SMOOTH PHYSICS ENGINE LOGIC
; ==============================================================================
HandleScroll(Direction) {
    global CurrentVelocity, LastScrollTime, ScrollTimerActive
    global BaseScrollAmount, FastSpinWindow, AccelRate
    
    CurrentTime := A_TickCount
    TimeDelta := CurrentTime - LastScrollTime
    LastScrollTime := CurrentTime
    
    SameDirection := ((Direction = 1 && CurrentVelocity > 0) || (Direction < 0 && CurrentVelocity < 0))
    
    if (SameDirection && TimeDelta < FastSpinWindow) {  ; ACCELERATE
        BoostPercent := (FastSpinWindow - TimeDelta) / FastSpinWindow
;        BoostPercent := ((FastSpinWindow - TimeDelta) / FastSpinWindow) ** 2
        CurrentVelocity += Direction * BaseScrollAmount * (1 + (BoostPercent * AccelRate))
    } else {    ; FIRST WHEEL
        if (!SameDirection) {
            CurrentVelocity := 0
        }
        UseOSD ? UseOSD.Count:=1 : ""
        CurrentVelocity += Direction * BaseScrollAmount
        ;return
    }
    ; ToolTip(CurrentVelocity)
    MaxVelocity := 2080.0
    if (Abs(CurrentVelocity) > MaxVelocity) {
        CurrentVelocity := (CurrentVelocity > 0 ? MaxVelocity : -MaxVelocity)
    }
    
    if (!ScrollTimerActive) {
        ScrollTimerActive := true
        SetTimer(TickScroll, RenderInterval)
    }
}

TickScroll() {
    global CurrentVelocity, ResidualScroll, ScrollTimerActive
    global Friction, RenderInterval, StopThreshold
    
    CurrentVelocity /= Friction
    
    if (Abs(CurrentVelocity) < StopThreshold) {
        CurrentVelocity := 0.0
        ResidualScroll := 0.0
        SetTimer(TickScroll, 0)
        ScrollTimerActive := false
        return
    }
    
    ResidualScroll += CurrentVelocity
    IntScroll := Integer(ResidualScroll)
    
    if (IntScroll != 0) {
        ResidualScroll -= IntScroll
        
        Loop Abs(IntScroll) {
            if (IntScroll > 0) {
;                if (A_Index == 1)       ; BYPASS FIRST WHEEL BECAUSE OF HOTKEY WITH '~'
;                    continue
                ;SendInput("{WheelUp}")
                Click("WheelUp")
                UseOSD ? UseOSD.ShowKey("WheelUp") : ""
            } else {
                ;SendInput("{WheelDown}")
                Click("WheelDown")
                UseOSD ? UseOSD.ShowKey("WheelDown") : ""
            }
        }
        if GuiToolTip {
            ToolTip(    "`n  CurrentVelocity:    " round(Abs(CurrentVelocity * 10),2)
                    . " `n                                           "
            ,35,265)
        }
    }
}

CheckCTW(Direction, mouseXPos, mouseYPos, winId){
;    global MainLastScrollTime

    CoordMode("Mouse", "Screen")
    ;MouseGetPos(&mouseXPos, &mouseYPos, &winId)
    Debug ? (ToolTip(" > 1000"), SetTimer(() => ToolTip(), -1000)) : ""
    
    try {
        winClass := WinGetClass("ahk_id " winId)
        WinGetPos(&winXPos, &winYPos, , , "ahk_id " winId)
        Debug ? (ToolTip(" Get pos"), SetTimer(() => ToolTip(), -1000)) : ""
        
        ; Verify application type and the horizontal boundary area
        if (EnabledTabApps.Has(winClass) && mouseYPos >= winYPos && mouseYPos <= (winYPos + TabAreaHeight)) {
            Debug ? (ToolTip(" APP SPOT"), SetTimer(() => ToolTip(), -1000)) : ""
            if !WinActive("ahk_id " winId) {
                WinActivate("ahk_id " winId)
            }
            ; Execute tab jump commands
            ;MainLastScrollTime := A_TickCount - LastTimeTimeout
            Send(Direction > 0 ? "{Blind}^{PgUp}" : "{Blind}^{PgDn}")
            return true
        }
    } catch {
        ; Fail-safe: continue to fallback if window elements are inaccessible
    }
    return false
}

MouseIsOverTaskbar(winId) {
    OldMatchMode := SetTitleMatchMode("RegEx")
    IsOver := WinExist("ahk_class ^Shell_(Secondary)?TrayWnd$ ahk_id " winId)
    SetTitleMatchMode(OldMatchMode)
    return IsOver
}

;^p::Reload()