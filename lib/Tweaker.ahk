#Requires AutoHotkey v2.0

CreateTweakerGui() {
    global BaseScrollAmount, Friction, LastFriction, FastSpinWindow, AccelRate, StopThreshold, Tweaker

    MyGuiTitle := "Tweaker"
    MyGuiOptions := "+LastFound +AlwaysOnTop -MaximizeBox"
    Tweaker := Gui(MyGuiOptions, MyGuiTitle)
    Tweaker.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)

    ; Define layout constants
    GuiWidth            := 200
    BtnWidth            := 80
    Tweaker.MarginX       := 12
    Tweaker.MarginY       := 12

    BaseScrollAmount:= Round(BaseScrollAmount,3)
    Friction:= Round(Friction,3)
    FastSpinWindow:= Round(FastSpinWindow,3)
    AccelRate:= Round(AccelRate,3)
    StopThreshold:= Round(StopThreshold,3)

    ; --- Column 1: Labels (Perfectly aligned to the left) ---
    Tweaker.Add("Text", "w110 h22 +0x200", "BaseScrollAmount:") ; +0x200 vertically centers text
    Tweaker.Add("Text", "xm w110 h22 +0x200", "Friction:")
    Tweaker.Add("Text", "xm w110 h22 +0x200", "FastSpinWindow:")
    Tweaker.Add("Text", "xm w110 h22 +0x200", "AccelRate:")
    Tweaker.Add("Text", "xm w110 h22 +0x200", "StopThreshold:")

    ; --- Column 2: Inputs (Perfectly aligned to the right) ---
    ; Using 'ym' on the first one kicks it to the top of the next column
    Edit_Base     := Tweaker.Add("Edit", "ym w50 h22", String(Round(BaseScrollAmount,3)))
    Edit_Friction := Tweaker.Add("Edit", "x+0 w50 h22 xp y+12", String(Round(Friction,3)))
    Edit_FastSpin := Tweaker.Add("Edit", "w50 h22 xp y+12 Number", String(Round(FastSpinWindow,3)))
    Edit_Accel    := Tweaker.Add("Edit", "w50 h22 xp y+12", String(Round(AccelRate,3)))
    Edit_Stop     := Tweaker.Add("Edit", "w50 h22 xp y+12", String(Round(StopThreshold,3)))


    Tweaker.AddButton("xm w50 h22 y+15", "ToolTip").OnEvent("Click", ShowToolTip)
    Tweaker.AddButton("yp w50 h22", "OSD").OnEvent("Click", ShowWheelGUI)
    Tweaker.AddButton("yp w50 h22", "Copy").OnEvent("Click", Copy)

    ; 4. Button
    Tweaker.SetFont("s" Settings.GuiFontSizeMedium " w300", Settings.GuiFontName)
    ; 5.1 align
;        btnX := MyGui.MarginX ; left
        btnX := (GuiWidth - BtnWidth) // 2 ; center
;        btnX := GuiWidth - MyGui.MarginX - BtnWidth ; right
;    MyGui.AddButton("x" btnX " y+25 w" BtnWidth " h30 Default", "&OK").OnEvent("Click", (*) => myGui.Destroy())
;    MyGui.Add("Button", "w50 xm y+10", "Reset").OnEvent("Click", (*) => (MyGui.Destroy(), CreateTweakerGui()))
    Tweaker.AddButton("x" btnX " y+15 w" BtnWidth " h30 Default", "&Reset").OnEvent("Click", Reset)


   ApplyThemeToGui(Tweaker)
   WatchedGUIs.Push(Tweaker)
    Tweaker.Show("w" GuiWidth " x1600 yCenter NoActivate")




    ; --- Bind Events ---
    Edit_Base.OnEvent("Change", UpdateDecimals)
    Edit_Friction.OnEvent("Change", UpdateDecimals)
    Edit_FastSpin.OnEvent("Change", UpdateDecimals)
    Edit_Accel.OnEvent("Change", UpdateDecimals)
    Edit_Stop.OnEvent("Change", UpdateDecimals)
    Tweaker.OnEvent("Close", CleanDestroy)
    Tweaker.OnEvent("Escape", CleanDestroy)


    ; --- Event Handlers ---
    
    UpdateInteger(Ctrl, *) {
        global BaseScrollAmount, Friction, LastFriction, FastSpinWindow, AccelRate, StopThreshold
        CleanText := StrReplace(Ctrl.Text, ",")
        if IsInteger(CleanText)
            IntVal := Integer(CleanText)
            switch Ctrl {
                case Edit_Base:             BaseScrollAmount := IntVal
                case Edit_Friction:         LastFriction         := IntVal
                case Edit_FastSpin:         FastSpinWindow   := IntVal
                case Edit_Accel:            AccelRate        := IntVal
                case Edit_Stop:             StopThreshold    := IntVal
            }

    }

    UpdateDecimals(Ctrl, *) {
        global BaseScrollAmount, Friction, LastFriction, FastSpinWindow, AccelRate, StopThreshold
        CleanText := StrReplace(Ctrl.Text, ",")
        
        if IsNumber(CleanText) {
            NumVal := Number(CleanText)
            switch Ctrl {
                case Edit_Base:             BaseScrollAmount := Round(NumVal,3)
                case Edit_Friction:         LastFriction         := Round(NumVal,3)
                case Edit_FastSpin:         FastSpinWindow   := Round(NumVal,3)
                case Edit_Accel:            AccelRate        := Round(NumVal,3)
                case Edit_Stop:             StopThreshold    := Round(NumVal,3)
            }
        }
    }

    ShowToolTip(*) {
        global GuiToolTip

        GuiToolTip := !GuiToolTip
        if GuiToolTip = 0
            ToolTip()
    }

    ShowWheelGUI(*) {
        global UseOSD

        UseOSD := !UseOSD

        if UseOSD {
            UseOSD := KeyDisplayOSD()
            UseOSD.ShowKey("OSD")
        }
    }

    Copy(*) {
A_Clipboard := ("                BaseScrollAmount := " BaseScrollAmount "`n"
                "                Friction         := " Friction "`n"
                "                FastSpinWindow   := " FastSpinWindow "`n"
                "                AccelRate        := " AccelRate "`n"
                "                StopThreshold    := " StopThreshold )
    }

    Reset(*) {
        RemoveGuiFromArray(Tweaker)
        Tweaker.Destroy()
        ApplyProfile(Wheel.Profile)
        CreateTweakerGui()
    }
    
    CleanDestroy(*) {
        RemoveGuiFromArray(Tweaker)
        Tweaker.Destroy()
    }
}