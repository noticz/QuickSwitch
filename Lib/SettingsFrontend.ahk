/*
    GUI updates global variables after user actions
    and displays their values as checkboxes, options, etc.

    All values are saved to the INI only after clicking OK
*/

ShowSettings() {
	global
	
	ReadValues()
	FromSettings := true
	
	; Options that affects subsequent controls
	; Noticz mod - Fix for settings/context menu if theme is darkmode on windows 10
	GuiColorInverted := InvertedFullColor(GuiColor)
	Gui, -E0x200 -SysMenu +AlwaysOnTop -DPIScale +HwndGuiHwnd 	; hide window border and header
	if (UseLightTheme)
		Gui, Font, q5, %MainFont%
	else
		Gui, Font, s7 c%GuiColorInverted%, %MainFont%
	Gui, Color, %GuiColor%, %GuiColor%
	
	; Edit fields: fixed width, one row, max 6 symbols, no multi-line word wrap and vertical scrollbar
	local edit := "w63 r1 -Wrap -vscroll"
	
	; Split settings to the tabs
	Gui, Add, Tab3, -Wrap +Background +Theme AltSubmit vLastTabSettings Choose%LastTabSettings%, Menu|Short path|App
	
	/*
		To align "Edit" fields to the right after the "Text" fields,
		we memorize the YS position of the 1st "Text" fields using the "Section" keyword.
		Then when all the controls on the left are added one after another,
		we add "Edits" on the right starting from the memorized YS position.
		The X position is chosen automatically depending on the length of the widest "Text" field.
	*/
	
	;               type,     [ coordinates options     vVARIABLE       gGOTO       Section      ], title
    Gui,    Tab,    1       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    CheckBox,   Section                 vAutoSwitch     checked%AutoSwitch%,        &Always Auto Switch
    Gui,    Add,    CheckBox,   x+8 yp                  vDeleteDialogs,                             &del dialogs config
    Gui,    Add,    CheckBox,   xs gToggleShowAlways    vShowAlways     checked%ShowAlways%,        Always &show Menu
    Gui,    Add,    CheckBox,                           vShowNoSwitch   checked%ShowNoSwitch%,      Show Menu if Menu options &disabled
    Gui,    Add,    CheckBox,                         vShowAfterSettings checked%ShowAfterSettings%,Show Menu after &leaving settings
    Gui,    Add,    CheckBox,                           vShowAfterSelect checked%ShowAfterSelect%,  Show Menu after selecting &path
    Gui,    Add,    CheckBox,                           vSendEnter      checked%SendEnter%,         &Close old-style file dialog after selecting path
    Gui,    Add,    CheckBox,                           vPathNumbers    checked%PathNumbers%,       &Path numbers with shortcuts 0-9

    Gui,    Add,    Text,       y+20                                                  Section,      &Limit of displayed paths:
    Gui,    Add,    Text,       y+20,                                                               &Menu backgroud color (HEX)
    Gui,    Add,    Text,       y+13,                                                               &Dialogs background color (HEX)

    Gui,    Add,    Edit,       ys-4 %edit% Limit4
    Gui,    Add,    UpDown,     Range1-9999             vPathLimit,                                 %PathLimit%
    Gui,    Add,    Edit,       y+13 %edit% Limit8      vMenuColor,                                 %MenuColor%
    Gui,    Add,    Edit,       y+4  %edit% Limit8      vGuiColor,                                  %GuiColor%

    Gui,    Tab,    2       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    Checkbox,   gToggleShortPath        vShortPath checked%ShortPath%  Section,     Show short path, indicate as

    Gui,    Add,    Text,       y+13                    vPathSeparatorText,                         Path &separator
    Gui,    Add,    Text,       y+13                    vDirsCountText,                             Number of &dirs displayed
    Gui,    Add,    Text,       y+13                    vDirNameLengthText,                         &Length of dir names
    Gui,    Add,    Checkbox,   y+20                  vShowDriveLetter checked%ShowDriveLetter%,    Show &drive letter
    Gui,    Add,    Checkbox,                      vShowFirstSeparator checked%ShowFirstSeparator%, Show &first separator
    Gui,    Add,    Checkbox,                           vShortenEnd    checked%ShortenEnd%,         Shorten the &end

    Gui,    Add,    Edit,       ys-4 %edit% Limit       vShortNameIndicator,                        %ShortNameIndicator%
    Gui,    Add,    Edit,       y+4  %edit% Limit       vPathSeparator,                             %PathSeparator%

    Gui,    Add,    Edit,       y+4  %edit% Limit4
    Gui,    Add,    UpDown,     Range1-9999             vDirsCount,                                 %DirsCount%
    Gui,    Add,    Edit,       y+4  %edit% Limit4
    Gui,    Add,    UpDown,     Range1-9999             vDirNameLength,                             %DirNameLength%

    Gui,    Tab,    3       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    CheckBox,                           vAutoStartup checked%AutoStartup%,          Launch at &system startup

    Gui,    Add,    Text,       y+20                                                    Section,    Open &menu by
    Gui,    Add,    Text,       y+13,                                                               App &restart by
    Gui,    Add,    Text,       y+13,                                                               Restart only &in
    Gui,    Add,    Text,       y+13,                                                               Icon (&tray)
    Gui,    Add,    Text,       y+13,                                                               Font (&GUI)

    edit := "w160 r1 -Wrap -vscroll"
    Gui,    Add,    Hotkey,     ys-4  %edit% w100       vMainKey                        Section,    %MainKey%
    Gui,    Add,    Hotkey,     y+4   %edit% w100       vRestartKey,                                %RestartKey%
    Gui,    Add,    CheckBox,   ys+4                    vMainKeyHook    checked%MainKeyHook%,       hook
    Gui,    Add,    CheckBox,   y+12                    vRestartKeyHook checked%RestartKeyHook%,    hook

    Gui,    Add,    Edit,       xs    %edit%            vRestartWhere,                              %RestartWhere%
    Gui,    Add,    Edit,       y+4   %edit%            vMainIcon,                                  %MainIcon%
    Gui,    Add,    Edit,       y+4   %edit%            vMainFont,                                  %MainFont%

    Gui,    Tab     ; BUTTONS   ────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    Button,     w74             Default  gSaveSettings,                             &OK
    Gui,    Add,    Button,     wp x+20 yp      Cancel   gCancel,                                   &Cancel

    if NukeSettings {
        NukeSettings := false
        Gui,  Add,    Button,     wp x+20 yp  gNukeSettings,   &Nuke
    } else {
        Gui,  Add,    Button,     wp x+20 yp  gResetSettings,  &Reset
    }

    Gui,    Add,    Button,     wp xp ym-4               gShowDebug,                                &Debug


    ; SETUP AND SHOW GUI        ────────────────────────────────────────────────────────────────────────────────────────────────────────
    ; Current checkbox state
    ToggleShowAlways()
    ToggleShortPath()

    ; Get dialog position
    local _winX, _winY, _pos := ""
    WinGetPos, _winX, _winY,,, A

    if (_winX && _winY)
        _pos := " x" _winX " y" _winY + 100
	
	; Noticz mod - Fix for settings/context menu if theme is darkmode on windows 10
	if (!UseLightTheme) {
		GuiControlGet, strControlHwnd, Hwnd, OkButton
		DllCall("uxtheme\SetWindowTheme", "ptr", strControlHwnd, "str", "DarkMode_Explorer", "ptr", 0)
		GuiControlGet, strControlHwnd, Hwnd, CancelButton
		DllCall("uxtheme\SetWindowTheme", "ptr", strControlHwnd, "str", "DarkMode_Explorer", "ptr", 0)
		GuiControlGet, strControlHwnd, Hwnd, NukeButton
		DllCall("uxtheme\SetWindowTheme", "ptr", strControlHwnd, "str", "DarkMode_Explorer", "ptr", 0)	
		GuiControlGet, strControlHwnd, Hwnd, ResetButton
		DllCall("uxtheme\SetWindowTheme", "ptr", strControlHwnd, "str", "DarkMode_Explorer", "ptr", 0)
		GuiControlGet, strControlHwnd, Hwnd, DebugButton
		DllCall("uxtheme\SetWindowTheme", "ptr", strControlHwnd, "str", "DarkMode_Explorer", "ptr", 0)
	}
	
	Gui, Show, % "AutoSize" _pos, Settings
	
	ControlGet, strControlHwnd, HWND, , msctls_hotkey321, ahk_id %Hwnd%
	DllCall("uxtheme\SetWindowTheme", "ptr", strControlHwnd, "str", "DarkMode_Explorer", "ptr", 0)
	
	; Current checkbox state
	ToggleShowAlways()
	ToggleShortPath()
}

; Noticz mod - Fix for settings/context menu if theme is darkmode on windows 10
InvertedFullColor(color) {
	c1 := 0xFF & color >> 16
	c2 := 0xFF & color >> 8
	c3 := 0xFF & color
	c1 := ((c1 < 0x80) * 0xFF) << 16
	c2 := ((c2 < 0x80) * 0xFF) << 8
	c3 := (c3 < 0x80) * 0xFF
	Return Format("{:x}", c1 + c2 + c3)
}

