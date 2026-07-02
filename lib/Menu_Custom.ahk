/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.3.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom() {

    global TrayMenu := A_TrayMenu
    MoreMenu := TrayMenu.HasProp("MoreMenu") ? TrayMenu.MoreMenu : ""
    try MoreMenu.Delete("Pause")
    try MoreMenu.Delete("Suspend")
    try TrayMenu.Delete("Restart")
    
    TrayMenu.Insert("Exit", "Suspend`tScrollLock", (*) => ToggleSuspend())
    TrayMenu.Insert("More", "Settings...", (*) => ShowKineticGUI())

    global ProfileMenu := Menu()

    profilesOrder := ["Slow", "Precise", "Equilibrium", "Fast", "Dry", "Wet", "Custom"]

    for profileName in profilesOrder {
        ProfileMenu.Add(profileName, OnTrayProfileSelect)
    }

    try ProfileMenu.Check(GlobalActiveProfile)

    TrayMenu.Insert("More","Profiles", ProfileMenu)
    TrayMenu.Insert("More")

    OnTrayProfileSelect(ItemName, ItemPos, MyMenu) {
        ApplyProfile(ItemName)
        SaveSettings()
    }

}