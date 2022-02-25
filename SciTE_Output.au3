;-- TIME_STAMP   2022-02-18 11:47:12

Global $sSciTECmd
GUIRegisterMsg(74, "MY_WM_COPYDATA") ; $WM_COPYDATA = 74

; == TEST ==
;~ _SciTE_Output("!== Console Output by using SciTE Director Interface ==!\n")

;===============================================================================
; Function Name....: _SciTE_Output
; Description......: Writes output in the current open SciTE output pane
; Parameter(s).....: $_sOutput    Text to write, same use as in "ConsoleWrite"
;===============================================================================
Func _SciTE_Output($_sOutput)
	$_sOutput = StringRegExpReplace($_sOutput, '\r\n|\n|\r', '\\n')
	$_sOutput = StringReplace($_sOutput, @TAB, '\t')
	SendSciTE_Command("output:" & $_sOutput)
EndFunc


; by BugFix
Func _GetHwndDirectorExtension()
    Local $hActive = WinGetHandle('[ACTIVE]')
    Local $PIDActive = WinGetProcess($hActive)
    Local $aExtension = WinList("DirectorExtension")
    Local $PIDExt
    For $i = 1 To $aExtension[0][0]
        $PIDExt = WinGetProcess($aExtension[$i][1])
        If $PIDExt = $PIDActive Then Return $aExtension[$i][1]
    Next
EndFunc

; by Jos
Func SendSciTE_Command($_sCmd)     ;, $Wait_For_Return_Info = 0)
    Local $WM_COPYDATA = 74
    Local $WM_GETTEXT = 0x000D
    Local $WM_GETTEXTLENGTH = 0x000E224
    Local Const $SCI_GETLINE = 2153
;~     Local $Scite_hwnd = WinGetHandle("DirectorExtension") ; Get SciTE DIrector Handle
    Local $Scite_hwnd = _GetHwndDirectorExtension() ; Get SciTE DIrector Handle
    Local $My_Hwnd = GUICreate("AutoIt3-SciTE interface") ; Create GUI to receive SciTE info
    Local $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2)) ; Convert my Gui Handle to decimal
    $_sCmd = ":" & $My_Dec_Hwnd & ":" & $_sCmd              ; Add dec my gui handle to commandline to tell SciTE where to send the return info
    Local $CmdStruct = DllStructCreate('Char[' & StringLen($_sCmd) + 1 & ']')
    DllStructSetData($CmdStruct, 1, $_sCmd)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
    DllStructSetData($COPYDATA, 1, 1)
    DllStructSetData($COPYDATA, 2, StringLen($_sCmd) + 1)
    DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
    DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $Scite_hwnd, _
            'Int', $WM_COPYDATA, 'HWnd', $My_Hwnd, _
            'Ptr', DllStructGetPtr($COPYDATA))
    GUIDelete($My_Hwnd)
EndFunc   ;==>SendSciTE_Command

Func MY_WM_COPYDATA($hWnd, $msg, $wParam, $lParam)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
	Local $SciTECmdLen = DllStructGetData($COPYDATA, 2)
	Local $CmdStruct = DllStructCreate('Char[255]', DllStructGetData($COPYDATA, 3))
	$sSciTECmd = StringLeft(DllStructGetData($CmdStruct, 1), $SciTECmdLen)
EndFunc   ;==>MY_WM_COPYDATA