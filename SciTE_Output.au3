;-- TIME_STAMP   2013-07-19 18:57:32

Global $sSciTECmd
GUIRegisterMsg(74, "MY_WM_COPYDATA") ; $WM_COPYDATA = 74

; == TEST ==
;~ _SciTE_Output("!== Console Output by using SciTE Director Interface ==!" & @LF)

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

; by Jos
Func SendSciTE_Command($sCmd, $Wait_For_Return_Info = 0)
    Local $WM_COPYDATA = 74
    Local $Scite_hwnd = WinGetHandle("DirectorExtension") ; Get SciTE Director Handle
    Local $My_Hwnd = GUICreate("AutoIt3-SciTE interface") ; Create GUI to receive SciTE info
    Local $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2)) ; Convert my Gui Handle to decimal
    $sCmd = ":" & $My_Dec_Hwnd & ":" & $sCmd              ; Add dec my Gui handle to commandline to tell SciTE where to send the return info
    Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
    DllStructSetData($CmdStruct, 1, $sCmd)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
    DllStructSetData($COPYDATA, 1, 1)
    DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
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