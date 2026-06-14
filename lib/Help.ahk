/************************************************************************
 * @description Help GUI
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/29
 * @version 1.4.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

ShowHelpGUI() {
    MyGuiTitle := "Help"
    MyGuiOptions := "+LastFound -SysMenu"
    MyGui := Gui(MyGuiOptions, MyGuiTitle)
    MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)

    ; Define layout constants
    GuiWidth            := 540
    BtnWidth            := 80
    MyGui.MarginX       := 50
    MyGui.MarginY       := 30

    ; 1. Icon
    try {
        MyGui.Add("Picture", "w32 h32", App.Icon)
    } catch {
        MyGui.SetFont("s15 w500")
        MyGui.Add("Text", "w32 h32", "[ i ]")
    }

    ; 2. Title and Version
    MyGui.SetFont("s" Settings.GuiFontSizeBig " w700")
    MyGui.Add("Text", "x+15 y28 vStrong_Title", App.Name)

    MyGui.SetFont("s" Settings.GuiFontSizeSmall " w400 ")
    MyGui.Add("Text", "y+2 vSmooth_Version", "Version " App.Version)

    ; 3. Content
    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "xm y+30 w" . (GuiWidth - (MyGui.MarginX * 2)), App.Description)


    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "xm y+20 w" . (GuiWidth - (MyGui.MarginX * 2)), "From tray icon menu / Profile, select your desired profile.")

    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "xm y+15 w" . (GuiWidth - (MyGui.MarginX * 2)), "While scrolling, press middle mouse button to infinite scroll. Press again to stop.")

    ; 4. Button
    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300", Settings.GuiFontName)
    ; 5.1 align
;        btnX := MyGui.MarginX ; left
;        btnX := (GuiWidth - BtnWidth) // 2 ; center
        btnX := GuiWidth - MyGui.MarginX - BtnWidth ; right
;    MyGui.AddButton("x" btnX " y+25 w" BtnWidth " h30 Default", "&OK").OnEvent("Click", (*) => myGui.Destroy())
    MyGui.AddButton("x" btnX " y+25 w" BtnWidth " h30 Default", "&OK").OnEvent("Click", CleanDestroy)


    MyGui.OnEvent("Close", CleanDestroy)
    MyGui.OnEvent("Escape", CleanDestroy)

    if IsFunctionDefined("ApplyThemeToGui") {
        %"ApplyThemeToGui"%(MyGui)
        %"WatchedGUIs"%.Push(MyGui)
    }

    MyGui.Show("w" GuiWidth)

    CleanDestroy(*) {
        if IsFunctionDefined("RemoveGuiFromArray")
            %"RemoveGuiFromArray"%(MyGui)
        if (IsSet(CurrentActualTheme) && CurrentActualTheme == "Dark") {
            %"RemoveGuiFromArray"%(MyGui)
        }
        MyGui.Destroy()
    }

    IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }
}