﻿GetPaths(ByRef array, ByRef elevatedDict, _autoSwitch := false) {
    ; Requests paths from all applications whose window class
    ; is recognized as a known file manager class (in Z-order).

    ; Get manager hwnds
    WinGet, _winIdList, list, ahk_group ManagerClasses
    Loop, % _winIdList {
        _winId := _winIdList%A_Index%
        WinGet, _winPid, pid, ahk_id %_winId%
    
        if IsAppElevated(_winPid, elevatedDict)
            continue

        ; Fix specific problems
        WinGetClass, _winClass, ahk_id %_winId%
        switch _winClass {
            case "ThunderRT6FormDC":
                ; Exclude XYplorer child windows:
                ; main window have "ThunderRT6Main" owner
                _ownerId := DllCall("GetWindow", "ptr", _winId, "uint", 4)
                WinGetClass, _ownerClass, ahk_id %_ownerId%

                if (_ownerClass != "ThunderRT6Main")
                    continue

            case "dopus.lister":
                ; Function name without dot .
                _winClass := "Dopus"
        }

        _length := array.length()
        try {
            Func(_winClass).call(_winId, array)
        } catch _ex {
            ; Assume that the file manager is elevated
            if AddElevatedName(_winPid, elevatedDict)
                continue

            LogException(_ex)
        }

        if (_length = array.length()) {
            AddElevatedName(_winPid, elevatedDict)
        }

        if (_autoSwitch && array[1]) {
            _autoSwitch := false
            SelectPath()
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetShortPath(ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Full path is shortened according to user-specified global parameters
        by shortening directory names to the specified length starting at the beginning
        and separating them with the specified delimiter.
        Additional options may change the final view.
    */
    global ShortenEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator, ShowFirstSeparator

    try {
        ; Return input path if it's really short
        if (StrLen(path) < 4)
            return path    ; Just drive and slash

        _dirs := StrSplit(path, "\")
        _size := _dirs.length()

        if (_size = 1)
            return path

        ; Variable to return
        _shortPath := ShowDriveLetter ? _dirs[1] : ""

        ; Parse the _dirs array, omit drive letter
        if ShortenEnd {
            _index := 2
            _stop  := Min(DirsCount + 1, _size)
        } else {
            _index := Max(2, _size - DirsCount + 1)
            _stop  := _size

            ; An indication that there are more paths after the drive letter
            _shortPath .= ShortNameIndicator
        }

        ; Add first separator if needed
        if (ShowFirstSeparator || ShowDriveLetter)
            _shortPath .= PathSeparator

        loop, % _size {
            _dir := _dirs[_index]
            _length  := StrLen(_dir)
            _dirName := SubStr(_dir, 1, Min(_length, DirNameLength))

            _shortPath .= _dirName
            if (_length > DirNameLength)
                _shortPath .= ShortNameIndicator

            if (_index == _stop)
                break

            _shortPath .= PathSeparator
            _index++
        }

        ; The shortened path fits into DirsCount
        ; but there are still directories remaining
        if ((_index != _size) && (_length <= DirNameLength))
            _shortPath .= ShortNameIndicator

        return _shortPath

    } catch _ex {
        LogException(_ex)
    }
    return path
}


