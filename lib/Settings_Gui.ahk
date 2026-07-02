/************************************************************************
 * @description Kinetic Settings GUI
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/01
 * @version 1.0.0
 ***********************************************************************/

ShowKineticGUI() {
    global KineticGui, ProfileDDL, SpeedSlider, FrictionSlider, BoostSlider
    global SpeedText, FrictionText, BoostText, ExclusionBox, WorkingExclusions
    global LiveExclusionMap
    
    WorkingExclusions := ""
    for exeName, _ in LiveExclusionMap {
        WorkingExclusions .= (WorkingExclusions == "" ? "" : ",") exeName
    }
    
    if (KineticGui != 0) {
        KineticGui.Show()
        UpdateKineticGUIElements()
        return
    }
    
    KineticGui := Gui(, "ScrollFlow Settings")
    KineticGui.SetFont("s10", "Segoe UI")
    
    KineticGui.OnEvent("Close", CancelAndRestoreValues)
    KineticGui.OnEvent("Escape", CancelAndRestoreValues)
    
    ; ---------------- LEFT COLUMN: PHYSICAL ENGINE TUNING ----------------
    KineticGui.AddGroupBox("x20 y15 w430 h80", "Preset Profile Template")
    ProfileDDL := KineticGui.AddDropDownList("x40 y42 w390 Choose1", ["Slow", "Precise", "Equilibrium", "Fast", "Dry", "Wet", "Custom"])
    ProfileDDL.OnEvent("Change", OnProfileChange)
    
    KineticGui.AddGroupBox("x20 y115 w430 h400", "Live Kinetic Engine Settings")
    
    KineticGui.SetFont("bold")
    SpeedText := KineticGui.AddText("x40 y145 w390", "Base Travel Speed: 1.00")
    KineticGui.SetFont("norm")
    SpeedSlider := KineticGui.AddSlider("x35 y170 w400 Range10-500 ToolTip", 100) 
    SpeedSlider.OnEvent("Change", OnSliderAdjustment)
    KineticGui.SetFont("s9 c666666", "Segoe UI")
    KineticGui.AddText("x40 y205 w380", "Controls distance traveled on single, isolated wheel clicks. Lower values allow exact micro-adjustments.")
    KineticGui.SetFont("s10 cDefault", "Segoe UI")
    
    KineticGui.SetFont("bold")
    FrictionText := KineticGui.AddText("x40 y255 w390", "Braking Friction: 0.10")
    KineticGui.SetFont("norm")
    FrictionSlider := KineticGui.AddSlider("x35 y280 w400 Range1-50 ToolTip", 10) 
    FrictionSlider.OnEvent("Change", OnSliderAdjustment)
    KineticGui.SetFont("s9 c666666", "Segoe UI")
    KineticGui.AddText("x40 y315 w380", "Determines how quickly scrolling slides to a stop. Higher values stop instantly; lower values provide a smooth glide.")
    KineticGui.SetFont("s10 cDefault", "Segoe UI")
    
    KineticGui.SetFont("bold")
    BoostText := KineticGui.AddText("x40 y365 w390", "Flick Acceleration (Sustained Boost): 1.04")
    KineticGui.SetFont("norm")
    BoostSlider := KineticGui.AddSlider("x35 y390 w400 Range10-500 ToolTip", 104) 
    BoostSlider.OnEvent("Change", OnSliderAdjustment)
    KineticGui.SetFont("s9 c666666", "Segoe UI")
    KineticGui.AddText("x40 y425 w380", "Sets the acceleration rate when spinning the wheel rapidly. Stays inactive during slow turns, but builds high velocity on large pages.")
    KineticGui.SetFont("s10 cDefault", "Segoe UI")
    
    ; ---------------- RIGHT COLUMN: EXCLUSION INTERFACE ----------------
    KineticGui.AddGroupBox("x475 y15 w320 h500", "Application Exclusion Filters")
    KineticGui.AddText("x495 y45 w280", "Active Bypass Rules List:")
    ExclusionBox := KineticGui.AddListBox("x495 y70 w280 h350")
    
    BtnAddCatalog := KineticGui.AddButton("x495 y435 w135 h42", "&Add Programs...")
    BtnAddCatalog.OnEvent("Click", OpenAppCatalogModal)
    
    BtnRem := KineticGui.AddButton("x640 y435 w135 h42", "&Remove Selected")
    BtnRem.OnEvent("Click", RemoveTargetFromExclusions)
    
    ; ---------------- BOTTOM ALIGNED ACTIONS ----------------
    BtnSave := KineticGui.AddButton("x475 y535 w150 h40 +Default", "&Save")
    BtnSave.OnEvent("Click", CommitChangesToIni)
    
    BtnCancel := KineticGui.AddButton("x645 y535 w150 h40", "&Cancel")
    BtnCancel.OnEvent("Click", CancelAndRestoreValues)
    
    UpdateKineticGUIElements()

    ApplyThemeToGui(KineticGui)
    WatchedGUIs.Push(KineticGui)

    KineticGui.Show("w815 h595")
}

UpdateKineticGUIElements() {
    global ProfileDDL, SpeedSlider, FrictionSlider, BoostSlider, ExclusionBox, WorkingExclusions, GlobalActiveProfile
    global SpeedText, FrictionText, BoostText
    
    ProfileDDL.Text := GlobalActiveProfile
    
    SpeedSlider.Value := Integer(Physics.BaseSpeed * 100)
    SpeedText.Text := "Base Travel Speed: " String(Format("{:.2f}", Physics.BaseSpeed))
    
    FrictionSlider.Value := Integer(Physics.BrakingFriction * 100)
    FrictionText.Text := "Braking Friction: " String(Format("{:.2f}", Physics.BrakingFriction))
    
    BoostSlider.Value := Integer(Physics.SpeedBoost * 100)
    BoostText.Text := "Flick Acceleration (Sustained Boost): " String(Format("{:.2f}", Physics.SpeedBoost))
    
    ExclusionBox.Delete()
    loop parse, WorkingExclusions, "," {
        cleanItem := Trim(A_LoopField)
        if (cleanItem != "") && (cleanItem != 0)
            ExclusionBox.Add([cleanItem])
    }
}


OnProfileChange(CtrlObj, *) {
    ApplyProfile(CtrlObj.Text)
    UpdateKineticGUIElements()
}

OnSliderAdjustment(*) {
    global ProfileDDL, GlobalActiveProfile
    if (ProfileDDL.Text != "Custom") {
        ProfileDDL.Choose("Custom")
        GlobalActiveProfile := "Custom"
    }
    
    vSpeed := Round((SpeedSlider.Value / 100), 2)
    vFric  := Round((FrictionSlider.Value / 100), 2)
    vBoost := Round((BoostSlider.Value / 100), 2)
    
    Profiles["Custom"].BaseSpeed := vSpeed
    Profiles["Custom"].BrakingFriction := vFric
    Profiles["Custom"].SpeedBoost := vBoost
    
    Physics.BaseSpeed := vSpeed
    Physics.BrakingFriction := vFric
    Physics.SpeedBoost := vBoost

    SpeedText.Text := "Base Travel Speed: " String(Format("{:.2f}", vSpeed))
    FrictionText.Text := "Braking Friction: " String(Format("{:.2f}", vFric))
    BoostText.Text := "Flick Acceleration (Sustained Boost): " String(Format("{:.2f}", vBoost))
}

RemoveTargetFromExclusions(*) {
    global WorkingExclusions
    selectedIdx := ExclusionBox.Value
    if (selectedIdx == 0)
        return
        
    items := StrSplit(WorkingExclusions, ",")
    items.RemoveAt(selectedIdx)
    
    rebuiltStr := ""
    for item in items {
        cleanItem := Trim(item)
        if (cleanItem != "")
            rebuiltStr .= (rebuiltStr == "" ? "" : ",") cleanItem
    }
    WorkingExclusions := rebuiltStr
    
    UpdateKineticGUIElements()
}

CommitChangesToIni(*) {
    global KineticGui, WorkingExclusions, LiveExclusionMap
    
    LiveExclusionMap.Clear()
    loop parse, WorkingExclusions, "," {
        clean := StrLower(Trim(A_LoopField))
        if (clean != "")
            LiveExclusionMap[clean] := true
    }
    
    SaveSettings()
    
    Physics.Velocity := 0.0
    Physics.MomentumReservoir := 0.0
    
    ;KineticGui.Hide()
    KineticGui.Destroy()
    KineticGui := 0
}

CancelAndRestoreValues(*) {
    global KineticGui
    
; 1. Remove checkmark from the previously active profile
    if IsSet(ProfileMenu) {
        try ProfileMenu.Uncheck(GlobalActiveProfile)
    }
    LoadSettings()
    
    Physics.Velocity := 0.0
    Physics.MomentumReservoir := 0.0
    
; 2. Add checkmark to the newly active profile
    if IsSet(ProfileMenu) {
        try ProfileMenu.Check(GlobalActiveProfile)
    }

    if (KineticGui != 0) {
        ;KineticGui.Hide()
    KineticGui.Destroy()
    KineticGui := 0
    }
}

; ==============================================================================
; --- LIVE WINDOW ENUMERATION MODAL ---
; ==============================================================================
OpenAppCatalogModal(*) {
    global KineticGui, AddAppsGui, CatalogListBox
    
    AddAppsGui := Gui("+Owner" KineticGui.Hwnd, "Add Programs to Exclusion List")
    AddAppsGui.SetFont("s10", "Segoe UI")
    
    AddAppsGui.OnEvent("Close", (*) => (AddAppsGui.Destroy(), AddAppsGui := 0))
    AddAppsGui.OnEvent("Escape", (*) => (AddAppsGui.Destroy(), AddAppsGui := 0))
    
    AddAppsGui.AddText("x20 y15 w410", "Hold Ctrl or Shift to select multiple currently running applications:")
    
    CatalogListBox := AddAppsGui.AddListView("x20 y40 w410 h320", ["Process Name", "Window Title"])
    CatalogListBox.ModifyCol(1, 140) 
    CatalogListBox.ModifyCol(2, 260) 
    
    idList := WinGetList()
    addedProcesses := Map()
    
    for hwnd in idList {
        try {
            title := WinGetTitle(hwnd)
            style := WinGetStyle(hwnd)
            pName := WinGetProcessName(hwnd)
            
            if (title != "" && (style & 0x10000000) && pName != "explorer.exe" && !InStr(pName, "AutoHotkey")) {
                if !addedProcesses.Has(StrLower(pName)) {
                    addedProcesses[StrLower(pName)] := true
                    CatalogListBox.Add(, pName, title)
                }
            }
        }
    }
    
    if (CatalogListBox.GetCount() == 0)
        CatalogListBox.Add(, "No active windows", "")
        
    BtnBrowse := AddAppsGui.AddButton("x20 y375 w120 h38", "Select From File...")
    BtnBrowse.OnEvent("Click", BrowseForExecutableFile)
    
    BtnAddSelected := AddAppsGui.AddButton("x155 y375 w140 h38 +Default", "Add Selected")
    BtnAddSelected.OnEvent("Click", ProcessCatalogSelections)
    
    BtnClose := AddAppsGui.AddButton("x310 y375 w120 h38", "Close")
    BtnClose.OnEvent("Click", (*) => (AddAppsGui.Destroy(), AddAppsGui := 0))

    ApplyThemeToGui(AddAppsGui)
    WatchedGUIs.Push(AddAppsGui)

    AddAppsGui.Show("w450 h430")
}

ProcessCatalogSelections(*) {
    global CatalogListBox, WorkingExclusions, AddAppsGui
    
    RowNumber := 0
    Loop {
        RowNumber := CatalogListBox.GetNext(RowNumber)
        if (!RowNumber)
            break
            
        pName := StrLower(Trim(CatalogListBox.GetText(RowNumber, 1)))
        
        if (pName == "no active windows")
            continue
            
        isDuplicate := false
        loop parse, WorkingExclusions, "," {
            if (StrLower(Trim(A_LoopField)) == pName) {
                isDuplicate := true
                break
            }
        }
        
        if (!isDuplicate) {
            WorkingExclusions .= (WorkingExclusions == "" ? "" : ",") pName
        }
    }
    
    UpdateKineticGUIElements()
    AddAppsGui.Destroy()
    AddAppsGui := 0
}

BrowseForExecutableFile(*) {
    global WorkingExclusions, AddAppsGui
    
    SelectedFile := FileSelect(3, , "Select Target Executable to Bypass", "Applications (*.exe; *.dll)")
    if (SelectedFile == "")
        return
        
    SplitPath(SelectedFile, &pName)
    pName := StrLower(Trim(pName))
    
    isDuplicate := false
    loop parse, WorkingExclusions, "," {
        if (StrLower(Trim(A_LoopField)) == pName) {
            isDuplicate := true
            break
        }
    }
    
    if (!isDuplicate) {
        WorkingExclusions .= (WorkingExclusions == "" ? "" : ",") pName
        UpdateKineticGUIElements()
    }
    
    AddAppsGui.Destroy()
    AddAppsGui := 0
}