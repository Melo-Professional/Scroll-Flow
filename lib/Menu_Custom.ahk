/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.3.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom() {

    TrayMenu := A_TrayMenu
    MoreMenu := TrayMenu.HasProp("MoreMenu") ? TrayMenu.MoreMenu : ""

    global ProfileList

    ProfileMenu := Menu()
    ProfileMenu.Add("Tweaks...", (*) => CreateTweakerGui())
    ProfileMenu.Add()
    for name in ProfileList {
        ProfileMenu.Add(name, ProfileHandler)
    }

    ProfileMenu.Check(Wheel.Profile)

    TrayMenu.Insert("More","Profile", ProfileMenu)
    TrayMenu.Insert("More")

    ProfileHandler(ItemName, ItemPos, MyMenu) {
        global Wheel, ProfileList
        Wheel.Profile := ItemName
        ApplyProfile(ItemName)
        SaveINI()
        for item in ProfileList {
            isCurrent := (item == ItemName)
            MyMenu.% isCurrent ? "Check" : "Uncheck" %(item)
            MyMenu.% isCurrent ? "Disable" : "Enable" %(item)
        }
    }






    ; Custom items
/*
    ; INSERT AT POSITION
    TrayMenu.Insert("3&", "Sound Control Panel", (*) => Run("control mmsys.cpl sounds"))
    TrayMenu.Insert("4&", "Volume Mixer", (*) => Run("sndvol.exe"))
    TrayMenu.Insert("5&")
 */

    ; INSERT OVER 'More'
;    TrayMenu.Insert("More", "Sound Control Panel", (*) => Run("control mmsys.cpl sounds"))
;    TrayMenu.Insert("More", "Volume Mixer", (*) => Run("sndvol.exe"))
;    TrayMenu.Insert("More")

    ; Clean up Suspend and Pause
;    if (MoreMenu != "") {
;    try MoreMenu.Delete("4&")
;    try MoreMenu.Delete("Suspend")
;    try MoreMenu.Delete("Pause")
;    }

    IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }
}

;A_TrayMenu.Delete()

