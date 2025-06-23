/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddMenuTitle(_title) {
    Menu ContextMenu, Add, % _title, Dummy
    Menu ContextMenu, Disable, % _title
}

AddMenuOption(_title, _function, _isToggle := false) {
    Menu ContextMenu, Add, % _title, % _function, Radio

    if _isToggle
        Menu ContextMenu, Check, % _title

}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuPaths(ByRef array, _function) {
;─────────────────────────────────────────────────────────────────────────────
    global PathNumbers, ShortPath, PathLimit

    for _index, _path in array {
        _display := ""

        if (PathNumbers && (_index < 10))
            _display .= "&" . _index . " "
        if ShortPath
            _display .= GetShortPath(_path)
        else
            _display .= _path

        Menu, ContextMenu, Insert,, % _display, % _function        
        if (_index = PathLimit)
            return
    }
}

AddMenuPathsFavorite(ByRef array, _function) {
	global PathNumbers, ShortPath, PathsFavorite
	
	; Add all the recent files to menu
	PathsFavorite := GetFavoriteFilePaths()

	if (PathsFavorite.Length() == 0)
		return
	
	rHand := Func("FavoriteFilesHandler").Bind()
	for _index, _path in PathsFavorite {
		_display := ""
		if (_index == 1) {
			AddMenuTitle("Favorites")
		}
		if PathNumbers
			_display .= "&" . _index . " "
		if ShortPath
			_display .= GetShortPath(_path)
		else
			_display .= _path
		Menu, ContextMenu, Insert,, % _display, % rHand
	}
}

AddMenuPathsRecent(ByRef array, _function) {
	global PathNumbers, ShortPath, Paths, PathsRecent
	
	; Add all the recent files to menu
	PathsRecent := GetRecentFilePaths()
	rHand := Func("RecentFilesHandler").Bind()
	for _index, _path in PathsRecent {
		_display := ""
		if (_index == 1) {
			AddMenuTitle("Recent")
		}
		if PathNumbers
			_display .= "&" . _index . " "
		if ShortPath
			_display .= GetShortPath(_path)
		else
			_display .= _path
		Menu, ContextMenu, Insert,, % _display, % rHand
	}
}

FavoriteFilesHandler(ItemName, ItemPos, MenuName) {
	Global Paths, PathsRecent, PathsFavorite
	
	DialogId   := WinActive("A")
	WinGetClass, WinClass, A
	FileDialog := GetFileDialog(DialogId, EditId)
	WinGet, Exe, ProcessName, ahk_id %DialogId%
	WinGetTitle, WinTitle, ahk_id %DialogId%
	
	FingerPrint   := Exe "___" WinTitle
	FileDialog    := FileDialog.bind(SendEnter, EditId)
	
	; Account for the history menu name and the paths listed in menu already
	if (Paths.Length() == 0)
		matchIndex := Paths.Length() + 2
	else
		matchIndex := Paths.Length() + 1
	if (PathsRecent.Length() == 0)
		matchIndex := matchIndex + (PathsRecent.Length() + 2)	
	else
		matchIndex := matchIndex + (PathsRecent.Length() + 1)
	matchIndex := ItemPos - matchIndex
	_path := PathsFavorite[matchIndex]
	
	; If we are in explorer and you use the hotkey then just browse to folder in explorer
	if (WinClass == "CabinetWClass") {
		static objShell := ComObjCreate("Shell.Application")
		for Item in objShell.Windows
		{
			if (Item.HWND = DialogId) {
				Item.Navigate(_path)
			}
		}
	} else if (WinClass == "#32770") {
		FileDialog.call(_path)
	} else {
		Run, % _path
	}
}

RecentFilesHandler(ItemName, ItemPos, MenuName) {
	Global PathsRecent, Paths
	
	DialogId   := WinActive("A")
	WinGetClass, WinClass, A
	FileDialog := GetFileDialog(DialogId, EditId)
	WinGet, Exe, ProcessName, ahk_id %DialogId%
	WinGetTitle, WinTitle, ahk_id %DialogId%
	
	FingerPrint   := Exe "___" WinTitle
	FileDialog    := FileDialog.bind(SendEnter, EditId)
	
	; Account for the history menu name and the paths listed in menu already
	if (Paths.Length() == 0)
		matchIndex := ItemPos - (Paths.Length() + 2)	
	else
		matchIndex := ItemPos - (Paths.Length() + 1)	
	_path := PathsRecent[matchIndex]
	
	; If we are in explorer and you use the hotkey then just browse to folder in explorer
	if (WinClass == "CabinetWClass") {
		static objShell := ComObjCreate("Shell.Application")
		for Item in objShell.Windows
		{
			if (Item.HWND = DialogId) {
				Item.Navigate(_path)
			} 
		}
	} else if (WinClass == "#32770") {
		FileDialog.call(_path)
	} else {
		; If we didn't find a matching explorer window open a new one
		Run, % _path
	}
}

GetFavoriteFilePaths() {
	PathsFavorite := Array()
	Loop, Files, %A_MyDocuments%\My Favorites\*.lnk, F
	{
		FileGetShortcut, %A_LoopFileFullPath%, OutTarget, OutDir
		; if no output directory it means that this is a link to a folder and not a file
		if (!OutDir)
			PathsFavorite.Push(OutTarget)
		else
			PathsFavorite.Push(OutDir)
	}
	return PathsFavorite
}

GetRecentFilePaths() {
	global Paths, NumberOfRecents
	FileList := Array()
	PathsRecent := Array()
	
	pathString := ""
	
	; Add the paths already in the Paths array. Might want to make this an option as well
	; For now I am taking this out because I find myself looking at the recent paths first
	for _index, path in Paths {
		if (!InStr(pathString, path)) {
			pathString .= path . ", "
		}
	}
	; By far the fastest way to grab and list the files in the recent folder by date
	shell := ComObjCreate("WScript.Shell")
	command =  dir "%A_AppData%\Microsoft\Windows\Recent\*.lnk" /B /S /O-D 
	exec := shell.Exec(ComSpec " /C " . command)
	output := exec.StdOut.ReadAll()
	Loop, parse, output, `n, `r
	{
		FileGetShortcut, %A_LoopField%, OutTarget, OutDir
		; if no output directory it means that this is a link to a folder and not a file
		if (!OutDir) {
			if (!InStr(pathString, OutTarget)) {
				pathString .= OutTarget . ", " 
				FileList.Push(OutTarget)				
			}
		} else {
			if (!InStr(pathString, OutDir)) {
				pathString .= OutDir . ", " 
				FileList.Push(OutDir)			
			}
		}
	}	
	Loop, %NumberOfRecents%
	{
		if (A_Index > FileList.Length())
			break
		PathsRecent.Push(FileList[A_Index])
	}
	return PathsRecent
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuOptions() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction

    ; Add options to select
    Menu ContextMenu, Add
    AddMenuTitle("Options")

    AddMenuOption("&Auto switch", "ToggleAutoSwitch", DialogAction = 1)
    AddMenuOption("&Black list",  "ToggleBlackList",  DialogAction = -1)

    Menu ContextMenu, Add
    Menu ContextMenu, Add, &Settings, ShowSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenu() {
	;─────────────────────────────────────────────────────────────────────────────
	global Paths, SelectMenuPath, MenuColor, DialogId, PathsRecent, PathsFavorite
	global FromSettings := false
	
	try Menu ContextMenu, Delete            ; Delete previous menu
	
	if Paths.length() {
		AddMenuPaths(Paths, SelectMenuPath)
		AddMenuPathsRecent(PathsRecent, SelectMenuPath)
		AddMenuPathsFavorite(PathsFavorite, SelectMenuPath)
		AddMenuOptions()
	} else {
		AddMenuTitle("No available paths")
		AddMenuPathsRecent(PathsRecent, SelectMenuPath)
		AddMenuPathsFavorite(PathsFavorite, SelectMenuPath)
		AddMenuOptions()
	}
	Menu ContextMenu, Color, % MenuColor
	WinActivate % "ahk_id " DialogId        ; Activate dialog in case of menu flickering
	Menu ContextMenu, Show, 0, 100          ; Show new menu and halt the thread
}
