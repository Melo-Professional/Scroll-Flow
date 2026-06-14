#Requires AutoHotkey v2.0


class KeyDisplayOSD {
    ; --- Configuration ---
    FontSize  := 14
    TextColor := "FFFFFF"  
    BgColor   := "373f86"  
    
    ; --- Internal State ---
    LastKey := ""
    Count   := 0
    GuiObj  := ""
    TextObj := ""
    TimerRef := ""
    
    ; Fixed coordinates calculated once at startup
    GuiX := 0
    GuiY := 0
    GuiW := 0
    GuiH := 0

    __New() {
        ; 1. Calculate static proportions based on FontSize
        this.GuiW := this.FontSize * 10.5   ; Adjust multiplier to change width
        this.GuiH := this.FontSize * 2.2   ; Adjust multiplier to change height
        
        ; 2. Calculate top-center position based on the fixed width
        MonitorGetWorkArea(, &Left, &Top, &Right, &Bottom)
        this.GuiX := (Right - Left - this.GuiW) / 2
        this.GuiY := Top + 20 

        ; 3. Build the static GUI
        this.CreateGui()
        this.TimerRef := this.ResetDisplay.Bind(this)
    }

    CreateGui() {
        this.GuiObj := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        this.GuiObj.BackColor := this.BgColor
        
        ; Remove all internal padding so our control matches the window size perfectly
        this.GuiObj.MarginX := 0
        this.GuiObj.MarginY := 0
        this.GuiObj.SetFont("S" . this.FontSize . " Bold", "Segoe UI")
        
        ; FIX: Force text control to match the exact dimensions of the GUI window.
        ; Passing "w" and "h" fixes the Left-alignment issue permanently.
;        this.TextObj := this.GuiObj.Add("Text", "w" . this.GuiW . " h" . this.GuiH . " c" . this.TextColor . " Center -Wrap +0x0200", "")
        this.TextObj := this.GuiObj.Add("Text", "w" . this.GuiW . " h" . this.GuiH . " c" . this.TextColor . " Center +0x0200", "")
        
        ; Prepare the window position without displaying it yet
        this.GuiObj.Show("X" . this.GuiX . " Y" . this.GuiY . " W" . this.GuiW . " H" . this.GuiH . " Hide")
    }

    ShowKey(keyName) {
        SetTimer(this.TimerRef, 0) ; Kill old timer

        if (keyName == this.LastKey) {
            this.Count++
        } else {
            this.LastKey := keyName
            this.Count := 1
        }

        ; Update text string
        this.TextObj.Value := this.LastKey . " " . this.Count
        
        ; Show instantly. Zero layout math, zero movement, ultra-lightweight.
        this.GuiObj.Show("NoActivate")

        ;SetTimer(this.TimerRef, -LastTimeTimeout)
        SetTimer(this.TimerRef, -LastTimeTimeout)
    }

    ResetDisplay() {
        this.LastKey := ""
        this.Count := 0
        this.GuiObj.Hide()
;        SetTimer(this.GuiObj.Hide.Bind(this.GuiObj), -LastTimeTimeout)
    }
}