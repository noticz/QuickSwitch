﻿/*
    Contains getters whose names correspond to classes of known file managers.
    All functions add values to the array by reference.
    "winId" param must be existing window uniq ID (window handle / HWND)
*/

GroupAdd, ManagerClasses, ahk_class TTOTAL_CMD
GroupAdd, ManagerClasses, ahk_class CabinetWClass
GroupAdd, ManagerClasses, ahk_class ThunderRT6FormDC
GroupAdd, ManagerClasses, ahk_class dopus.lister


TTOTAL_CMD(ByRef winId, ByRef array) {
    return GetTotalPaths(winId, array)
}

CabinetWClass(ByRef winId, ByRef array) {
    ; Analyzes open Explorer windows (tabs) and looks for non-virtual paths

    try {
        for _win in ComObjCreate("Shell.Application").windows {
            if (winId = _win.hwnd) {
                _path := _win.document.folder.self.path
                if !InStr(_path, "::{") {
                    array.push(_path)
                }
            }
        }
        _win := ""
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ThunderRT6FormDC(ByRef winId, ByRef array) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends script to XYplorer and parses the clipboard.
    ; Save clipboard to restore later
    _clipSaved := ClipboardAll
    Clipboard  := ""

    static script := "
    ( LTrim Join Comments
        ::$paths = <get tabs_sf | a>, 'r'`;         ; Get tabs from the active panel, resolve native variables
        if (get('#800')) {                          ; Second panel is enabled
            $paths .= '|' . <get tabs_sf | i>`;     ; Get tabs from second panels
        }
        $reals = ''`;
        foreach($path, $paths, '|') {               ; Path separator is |
            $reals .= '|' . pathreal($path)`;       ; Get the real path (XY has special and virtual paths)
        }
        $reals = trim($reals, '|', 'L')`;           ; Remove the extra  | from the beginning of $reals
        copytext $reals`;                           ; Place $reals to the clipboard, faster then copydata
    )"

    SendXyplorerScript(winId, script)

    ; Try to fetch clipboard data
    ClipWait 1
    _clip     := Clipboard
    Clipboard := _clipSaved

    ; Retry if empty
    static attempts := 0
    if !(_clip || (attempts = 3)) {
        attempts++
        return ThunderRT6FormDC(winId, array)
    }

    attempts := 0
    Loop, parse, _clip, `|
        array.push(A_LoopField)

}

;─────────────────────────────────────────────────────────────────────────────
;
Dopus(ByRef winId, ByRef array) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes the text of address bars of each tab using MS C++ functions.
    ; Searches for active tab using DOpus window title

    WinGetTitle, _title, ahk_id %winId%

    ; Each tab has its own address bar, so we can use it to determine the path of each tab
    static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer"
    ; Defined in AutoHotkey source
    static WINDOW_TEXT_SIZE := 32767
    VarSetCapacity(_text, WINDOW_TEXT_SIZE * 2)

    ; Find the first address bar HWND
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
    _previousHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
    _startHwnd    := _previousHwnd
    _paths        := []
    _active       := 1

    loop, 100 {
        ; Pass every HWND to GetWindowText() and get the content
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw
        if DllCall("GetWindowTextW", "ptr", _previousHwnd, "str", _text, "int", WINDOW_TEXT_SIZE) {
            _paths.push(_text)

            if InStr(_text, _title)
                _active := A_Index
        }
        _nextHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", _previousHwnd, "str", ADDRESS_BAR_CLASS, "ptr", 0)

        ; The loop iterates through all the tabs over and over again,
        ; so we must stop when it repeats
        if (_nextHwnd = _startHwnd)
            break

        _previousHwnd := _nextHwnd
    }

    ; Push the active tab to the global array first
    ; Remove duplicate and add the remaining tabs
    array.push(_paths.removeAt(_active))
    array.push(_paths*)
}