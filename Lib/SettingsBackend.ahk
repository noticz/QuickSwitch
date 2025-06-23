; These functions are responsible for the GUI Settings functionality and its Controls
; Also contains additional out-of-category functions needed for the app

NukeSettings() {
    ; Delete configuration
    global INI, ScriptName

    if MsgWarn("Do you want to delete the configuration?`n" INI) {
        try FileRecycle, % INI
        LogInfo("Old configuration has been placed in the Recycle Bin")
        ResetSettings()
    }
}

ResetSettings() {
    ; Show "Nuke" button once after pressing "Reset" button
    if (A_GuiControl = "&Reset")
        global NukeSettings := true

    ; Roll back values and show them in settings
    Gui, Destroy

    SetDefaultValues()
    WriteValues()
    ShowSettings()
}

SaveSettings() {
    ; Write current GUI (global) values
    Gui, Submit
    WriteValues()
    ReadValues()
    DeleteDialogs()
    InitAutoStartup()
}

RestartApp() {
    global RestartWhere

    if !RestartWhere
        Reload
    if WinActive(RestartWhere)
        Reload
}

DeleteDialogs() {
    global DeleteDialogs, INI

    if DeleteDialogs {
        try IniDelete, % INI, Dialogs
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
InitAutoStartup() {
;─────────────────────────────────────────────────────────────────────────────
    global AutoStartup, ScriptName

    try {
        _link := A_Startup "\" ScriptName ".lnk"

        if AutoStartup {
            if !FileExist(_link) {
                LogInfo("Auto Startup enabled")
            }
            FileCreateShortcut, % A_ScriptFullPath, % _link, % A_ScriptDir
        } else {
            if FileExist(_link) {
                FileDelete, % _link
                LogInfo("Auto Startup disabled")
            }
        }
    } catch _ex {
        LogException(_ex)
    }
}

;─────────────────────────────────────────────────────────────────────────────
; Noticz mod - Fix for settings/context menu if theme is darkmode on windows 10
CheckDarkThemeInit() {
	;─────────────────────────────────────────────────────────────────────────────
	Global GuiColor, MenuColor, UseLightTheme
	; check SystemUsesLightTheme for Windows system preference
	; https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661&hilit=dark#p426437
	uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
	SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
	FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
	RegRead, UseLightTheme, HKCU, SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme 
	if (UseLightTheme) {
		; Override the default colors
		GuiColor := ""
		DllCall(SetPreferredAppMode, "int", 0) ; *** 0 for NOT Dark
	} else {
		GuiColor = 202020
		MenuColor = 202020
		GuiColorInverted := InvertedFullColor(GuiColor)
		
		DllCall(SetPreferredAppMode, "int", 1) ; Dark
	}
	DllCall(FlushMenuThemes)
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShowAlways() {
;─────────────────────────────────────────────────────────────────────────────
    global

    Gui, Submit, NoHide
    GuiControl, Disable%ShowAlways%, ShowNoSwitch
    GuiControl, Disable%ShowAlways%, ShowAfterSettings
    GuiControl, Disable%ShowAlways%, ShowAfterSelect
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShortPath() {
;─────────────────────────────────────────────────────────────────────────────
    ; Hide or display additional options
    global

    Gui, Submit, NoHide
    GuiControl,, ShortPath, % "Show short path" . (ShortPath ? " indicate as" : "")

    GuiControl, Enable%ShortPath%, ShortenEnd
    GuiControl, Enable%ShortPath%, ShowDriveLetter
    GuiControl, Enable%ShortPath%, DirsCount
    GuiControl, Enable%ShortPath%, DirsCountText
    GuiControl, Enable%ShortPath%, DirNameLength
    GuiControl, Enable%ShortPath%, DirNameLengthText
    GuiControl, Enable%ShortPath%, PathSeparator
    GuiControl, Enable%ShortPath%, PathSeparatorText
    GuiControl, Enable%ShortPath%, ShowFirstSeparator
    GuiControl, Show%ShortPath%,   ShortNameIndicator
    GuiControl, Show%ShortPath%,   ShortNameIndicatorText
}