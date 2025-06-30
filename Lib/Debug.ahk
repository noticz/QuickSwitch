﻿/*
    Contains functions for debugging and testing code.
    Any functions to test the performance of the code
    (other than logging) should be stored here.
    Library must be imported first to be used in other libraries!
*/

Timer(R := 0) {
    /*
        Measure script performance
        Start: Timer(1).
        Save:  Timer(0)
    */

    static P := 0, F := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P", F)
    return !DllCall("QueryPerformanceCounter", "Int64P", Q) + (R ? (P := Q) / F : (Q - P) / F)
}

CancelLV() {
    LV_Delete()
    Gui, Destroy
}

LV_MaxWidths(_columns) {
    ; Calculates the maximum width of each column based on its name and ListView content.
    _maxWidths := []

    Loop, % LV_GetCount() {
        _colIndex := A_Index
        Loop, % _columns.length() {
            LV_GetText(_text, _colIndex, A_Index)
            
            if !(_maxWidths[A_Index])
                _maxWidths[A_Index] := StrLen(_columns[A_Index])

            if (StrLen(_text) > _maxWidths[A_Index])
                _maxWidths[A_Index] := StrLen(_text)
        }
    }
    
    return _maxWidths
}

LV_GetRow(_index, _columns) {
    ; Returns array of each row data
    _line := []
    
    Loop, % _columns.length() {
        LV_GetText(_text, _index, A_Index)
        _line.Push(_text)
    }
    
    return _line
}

LV_WriteLine(_file, _row, _maxWidths) {
    ; Writes a single row to the file with aligned formatting
    _line := ""
    Loop, % _row.length()
        _line .= Format("{1:-" _maxWidths[A_Index] "}", _row[A_Index]) "   "
        
    _file.writeLine(RTrim(_line))
}

;─────────────────────────────────────────────────────────────────────────────
;
ExportDebug() {
;─────────────────────────────────────────────────────────────────────────────
    global FingerPrint, FileDialog

    try {
        _fileName := A_ScriptDir "\" FingerPrint ".csv"
        _file := FileOpen(_fileName, "w")
        if !IsObject(_file) {
            return LogError(_fileName
                         , "export"
                         , "File closed for writing. Check the attributes of the target directory")
        }

        ; Align ListView contents vertically to write readable table
        _columns    :=  ["Control", "Text", "ID", "PID", "X", "Y", "Width", "Height"]
        _maxWidths  :=  LV_MaxWidths(_columns)

        LV_WriteLine(_file, _columns, _maxWidths)

        Gui, ListView
        Loop, % LV_GetCount() {
            _line := LV_GetRow(A_Index, _columns)
            LV_WriteLine(_file, _line, _maxWidths)
        }

        _file.close()
        clipboard := _fileName
        LogInfo("Export completed. Path copied to clipboard.")
    
    } catch _ex {
        LogException(_ex)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowDebug() {
;─────────────────────────────────────────────────────────────────────────────
    ; Displays information about the file dialog Controls
    global FileDialog, DialogId
    Gui, Destroy

    SetFormat, Integer, D
    Gui, Add, ListView, r30 w1024, Control||Text|ID|PID|X|Y|Width|Height

    WinGet, _controlsList, ControlList, ahk_id %DialogId%
    Loop, Parse, _controlsList, `n
    {
        ControlGet, _id, hwnd,, % A_LoopField, A
        ControlGetText _text,, ahk_id %_id%
        ControlGetPos _x, _y, _width, _height, , ahk_id %_id%

        _pid := DllCall("GetParent", "Ptr", _id)
        ; Abs for hex to dec
        LV_Add(, A_LoopField, _text, abs(_id), _pid, _x, _y, _width, _height)
    }

    ; Auto-size each column to fit its contents
    LV_ModifyCol()
    LV_ModifyCol(3, "Integer")
    LV_ModifyCol(4, "Integer")

    Gui, Add, Button, y+10 w74 gExportDebug,    &Export
    Gui, Add, Button, x+10 wp  gCancelLV,       &Cancel
    Gui, Add, Button, x+10 wp  gNukeSettings,   &Nuke
    Gui, Show,, % FileDialog.name
}