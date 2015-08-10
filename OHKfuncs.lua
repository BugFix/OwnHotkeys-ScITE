-- TIME_STAMP   2015-08-09 21:42:26   v 0.1


--[[-----------------------------------------------------------------------
				List of Own-Hotkey-Functions

  • AddFuncName
	  Adds at end of every created function in current au3-script: "  ;==> Function_Name"

  • AlignAtEqualSign
	  Aligns all selected rows at the first rightmost equal sign

  • DebugToConsole
      Debugs variable under cursor with(out) @error, @extended to console output (table style)

  • ExecuteAU3
      Runs a given au3-file with(out) parameters

  • FindJumpMarks
	  Search Jump Marks ( §§ ) and writes to console: "line_number   text_from_this_line"

  • FunctionHeader
	  Inserts a short function header for current script language (*.au3, *.py, *.lua)

  • GetHotkeyList
      Writes a list of used Hotkeys to console output

  • GoToLine [hard coded]
	  Goes to next/previous line, sets caret to end of line

  • JumpToMark
	  Jumps to the selected mark (where the cursor is in output line)

  • ReloadStartupLua
      Reloads the Lua Startup script

  • Repeat
      Repeats the character left from cursor n-times
      Write the character, activate Repeat-Mode, hit numbers for "n", <ENTER> repeats last char n-times (count includes the first char)

  • RunSelectedCode
      Runs selected au3-code in an temporary file

  • SelectionMoveH [hard coded]
      Moves selected text in line to left or right

  • SelectionMoveV [hard coded]
      Moves selected text between lines up or down

  • SelectLine
      Selects full line from cursor

  • SelectTextInLine
      Selects line from cursor without leading space characters

  • SelectWord
      Selects full word with any characters at cursor position. Returns it or copy to clipboard

  • SetSelection
      Selects word under cursor with(out) leading "$" / with following square braces

  • ShellExecute
      Runs a given file with(out) parameters

  • SkipToComment
      Sets caret to start of comment in line, if any

  • ToggleAdjacentChars
      Toggles adjacent characters

---------------------------------------------------------------------------

	         Hard Coded Functions (use properties to de/activate)

  •  Move Selected Line(s) up/down (native editor functions)
  •  Move Selected Text In Line up/down/left/right (SelectionMoveV / SelectionMoveH)
  •  Skip Cursor To Previous/Next Line at line end position (GoToLine)


-------------------------------------------------------------------------]]

OHK = {}
firstVLine = 0      -- in OHK.JumpToMark()

-------------------------------------------------------------------------
OHK.AddFuncName = function()
	if props['FileExt']:upper() ~= 'AU3' then return end
	local IsComment = function(_pos) local tComment = {1,2} if tComment[editor.StyleAt[_pos]] == nil then return false else return true end end
	local InSense   = function(_s) _s = _s:gsub("%a", function(_c) return string.format("[%s%s]", _c:upper(),_c:lower()) end) return _s end
	local pattFunc = '()('..InSense('func')..'%s+([%w_]+)%s-%b().-'..InSense('endfunc')..')'
	local t, s, firstVisible, a, f, fname, iLines, pos, e = {}, editor:GetText(), editor.FirstVisibleLine
	for a, f, fname in s:gmatch(pattFunc) do
		_, iLines = f:gsub('\n', '\n')
		table.insert(t, {editor:LineFromPosition(a) + iLines, fname})
	end
	if #t == 0 then return end
	editor:BeginUndoAction()
	for i = 1, #t, 1 do
		editor:GotoLine(t[i][1])
		pos = editor:PositionFromLine(t[i][1])
		if not IsComment(pos) then
			_, e = editor:GetCurLine():find(InSense('endfunc'))
			editor:SetSel(pos + e, pos + e)
			editor:DelLineRight()
			editor:InsertText(pos + e, '  ;==>'..t[i][2])
		end
	end
	editor:EndUndoAction()
	editor.FirstVisibleLine = firstVisible
	scite.MenuCommand(IDM_SAVE)
end  --> AddFuncName
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.AlignAtEqualSign = function()
	local iStart = editor.SelectionStart
	local iEnd = editor.SelectionEnd
	if iStart == iEnd then return end
	local iLineS, iLineE = editor:LineFromPosition(iStart), editor:LineFromPosition(iEnd)
	if iLineS == iLineE then editor:SetSelection(iStart,iStart) return end
	local iMax, tLines, sRepl, sLine, iPos = 0, {}, ''
	for i=iLineS, iLineE do
		sLine = editor:GetLine(i)
		iPos = sLine:find('=')
		table.insert(tLines, {iPos,sLine})
		if iPos and iPos > iMax then iMax = iPos end
	end
	for i=1, #tLines do
		iPos = tLines[i][1]
		sLine = tLines[i][2]
		if iPos then
			sRepl = sRepl..sLine:sub(1, iPos-1)..(' '):rep(iMax-iPos)..sLine:sub(iPos)
		else
			sRepl = sRepl..sLine
		end
	end
	editor:BeginUndoAction()
	editor:ReplaceSel(sRepl:gsub('\r\n$', ''))
	editor:EndUndoAction()
	editor:SetSelection(iStart,iStart)
end  --> AlignAtEqualSign
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--[[	DebugToConsole()        --> also recognizes array variables like: $a[$i][0]
			• debugs variable under cursor, no error output
		DebugToConsole(true)
			• debugs variable under cursor, error output
		DebugToConsole(true, true)
			• debugs variable under cursor, error & extended output
 ]]
-------------------------------------------------------------------------
OHK.DebugToConsole = function(_fErr, _fExt)
	if props['FileExt']:upper() ~= 'AU3' then return end
	local sErr = ''
	if _fErr then
		sErr = ' & "!@ " & @TAB & "#Error: " & @error'
		if _fExt then sErr = sErr..' & @TAB & "#Extended: " & @extended' end
		sErr = sErr..' & @LF'
	end
	local caret, sDebug = OHK.SetSelection(false, true)
	if sDebug ~= '' then
		local s, line = editor:GetSelText(), editor:LineFromPosition(caret) +1
		editor:LineEnd()
		local sVar = sDebug
		if sDebug:find('%[') then sVar = sDebug:gsub('%[', '%['..'" & '):gsub('%]', ' & "'..'%]') end
		editor:InsertText(editor.CurrentPos, '\nConsoleWrite("@@ Debug line" & @TAB & @ScriptLineNumber & "   var: '..sVar..' --> " & '..sDebug..' & @LF'..sErr..')')
	end
	editor:SetSel(caret, caret)
end  --> DebugToConsole
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--[[	OHK.ExecuteAU3( path_AU3_file [, param1 [, param2 [, ..] ] ] )
]]
-------------------------------------------------------------------------
OHK.ExecuteAU3 = function(_pathAU3, ...)
	local tParam = {_pathAU3, ...}
	local au3exe = props['autoit3dir']..'\\autoit3.exe'
	local sCmd = '"'..au3exe..'" /AutoIt3ExecuteScript "'.._pathAU3..'"'
	if #tParam > 1 then for i = 2, #tParam do
		sCmd = sCmd..' "'..tParam[i]..'"'
	end end
	shell.exec(sCmd)
end  --> ExecuteAU3
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.FindJumpMarks = function()
	local sOut = ''
	for pos in editor:GetText():gmatch('()§§') do
		line = editor:LineFromPosition(pos)
		sOut = sOut .. '+> '..tostring(line+1)..(' '):rep(8-#tostring(line))..editor:GetLine(line)
	end
	output:ClearAll()
	if sOut ~= '' then
		output:AppendText('-> Sprungmarken in Zeilen:\n' .. sOut)
	else
		output:AppendText('!> Keine Sprungmarken vorhanden.\n')
	end
end
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.FunctionHeader = function()
	local ext = props['FileExt']:upper()
	if ext == 'LUA' then
		editor:InsertText(editor.CurrentPos,
		('-'):rep(100)..'\n--[[ \nin...:\t\nout..:\t\n]]\n'..
		('-'):rep(100)..'\n\n'..
		('-'):rep(100))
	elseif ext == 'PY' then
		editor:InsertText(editor.CurrentPos,
		'#'..('='):rep(98)..'#\n'..
		'# Function .....: \n# Description ..: \n# Parameter(s) .: \n# Return .......: \n'..
		'#'..('='):rep(98)..'#')
	elseif ext == 'AU3' then
		editor:InsertText(editor.CurrentPos,
		';'..('='):rep(99)..'\n'..
		'; Function Name....: \n'..
		'; Description......: \n'..
		'; Parameter(s).....: \n'..
		'; Return Value(s)..: \n'..
		';'..('='):rep(99))
	end
end --> FunctionHeader
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.GetHotkeyList = function()
	local i, tSign = 0, {'>>', '++'}
	output:ClearAll()
	print('!'..('-'):rep(90)..'HotKeyList!')
	for _, v in pairs(tDesc) do
		i = i+1
		print(tSign[math.fmod(i, 2)+1]..'> \t'..string.format('%03d', i)..'\t'..v)
	end
	print('!'..('-'):rep(92)..TimeOS()..'!')
end
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.GoToLine = function(_n)
	local caret = editor.CurrentPos
	local line = editor:LineFromPosition(caret)
	local lineNext = line +(_n)
	local lineLast = editor.LineCount -1
	if lineNext < 0 or lineNext > lineLast then return end
	editor.CurrentPos = editor:PositionFromLine(lineNext)
	editor:LineEnd()
end  -->GoToLine
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.JumpToMark = function()
	if firstVLine == 0 then firstVLine = editor.FirstVisibleLine end
	local sOutLine, iLen = output:GetCurLine()
	if iLen == 0 then
		editor.FirstVisibleLine = firstVLine
		firstVLine = 0
	else
		local _, _, iLine = sOutLine:find('^%+>%s(%d+)')
		if iLine == nil then
			editor.FirstVisibleLine = firstVLine
			firstVLine = 0
			return
		end
		editor:GotoLine(iLine-1)
		editor.CurrentPos = editor:PositionFromLine(iLine-1)
		editor:LineEndExtend()
		editor.FirstVisibleLine = iLine-1
	end
end
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.ReloadStartupLua = function()
	output:ClearAll()
	dofile( props["SciteDefaultHome"] .. "\\Lua\\SciTEStartup.lua" )
	print('++> '..TimeOS()..' SciTE StartUp script reloaded.')
end  --> ReloadStartupLua
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.Repeat = function(_keycode) -- first call from Hotkey needs no parameter
	if not fRepStarted then
		fRepStarted = true
		local caret = editor.CurrentPos
		editor:SetSel(caret-1, caret)
		sRepeat = editor:GetSelText()
		editor:SetSel(caret, caret)
		caretRepeat = caret
		fRepeat = true
		return
	else
		SetCaret()
		local num = tNum[tostring(_keycode)]
		if num then
			iRepeat = iRepeat .. num return false
		else
			SetCaret(tCaretDef)
			fRepeat = false
			fRepStarted = false
			if _keycode == 13 then
				iRepeat = tonumber(iRepeat) -1
				if iRepeat > 0 then
					editor:SetSel(editor.CurrentPos, caretRepeat)
					editor:ReplaceSel(sRepeat:rep(iRepeat))
				end
				sRepeat = '' iRepeat = '' return true
			else
				sRepeat = '' iRepeat = '' return false
			end
		end
	end
end  --> Repeat
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.RunSelectedCode = function()
	local writeTmpFile = function(_path, _s)
		local file = io.open(_path, 'w+')
		file:write(_s) file:close()
	end
	output:ClearAll()
	local sErr = "!>> "..TimeOS().." [Error RunSelectedCode] >> "
	if props['FileExt']:upper() ~= 'AU3' then print(sErr..'Attempting to run code from a non-au3 file!') return end
	local fileDir = props["FileDir"]
	local sSel = editor:GetSelText()
	if sSel == '' then print(sErr..'No code selected!') return end
	sSel = sSel:gsub('\r\n', '\n')
	local text = editor:GetText()
	local sWrite, incl = ''
	for incl in text:gmatch("[\n]?(#[iI][nN][cC][lL][uU][dD][eE]%s-<[%w%s_.]+>)") do sWrite = sWrite..incl..'\n' end            -- #include <abc.au3>
	for incl in text:gmatch("[\n]?(#[iI][nN][cC][lL][uU][dD][eE]%s-([\"'])[%w%s_.:\\]+%2)") do sWrite = sWrite..incl..'\n' end  -- #include 'abc.au3' or #include "abc.au3"
	local newPath = fileDir..'\\__TMP__RunSelected.au3'
	writeTmpFile(newPath, sWrite..'\n'..sSel)
	scite.Open(newPath)
	scite.MenuCommand(IDM_GO)
end  --> RunSelectedCode
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.SelectionMoveH = function(_fLeft)
	local moveText = function(_s, _a, _e, _val)
		editor:SetSelection(_a, _e) editor:Clear()
		if _val == -1 then editor:CharLeft() else editor:CharRight() end
		editor:InsertText(editor.CurrentPos, _s)
		editor:SetSelection(_a +(_val), _e +(_val))
	end
	output:ClearAll()
	local sErr = "!>> "..TimeOS().." [Error SelectionMoveH] >> "
	local caret = editor.CurrentPos
	local line = editor:LineFromPosition(caret)
	local selText, selLen = editor:GetSelText()
	local selStart, selEnd = editor:GetLineSelStartPosition(line), editor:GetLineSelEndPosition(line)
	editor:SetSelection(selStart, selEnd)
	if selLen == 0 then print(sErr..'Nothing selected!') return end
	local lineStart = editor:PositionFromLine(line)
	editor:LineEnd()
	local lineEnd = editor.CurrentPos
	if _fLeft then
		if caret > lineStart then moveText(selText, selStart, selEnd, -1) else
			print(sErr..'First position was already reached!') editor:SetSelection(selStart, selEnd) end
	else
		if selStart +selLen -1 < lineEnd then moveText(selText, selStart, selEnd, 1) else
			print(sErr..'Last position was already reached!') editor:SetSelection(selStart, selEnd) end
	end
end  --> SelectionMoveH
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.SelectionMoveV = function(_fUp)
	local moveText = function(_i, _txt, _len, _line)
		editor:Clear()
		local lineNext = _line +(_i)
		local column = editor.Column[editor.CurrentPos]
		local insertPos = editor:FindColumn(lineNext, column)
		editor:InsertText(insertPos, _txt)
		editor:SetSelection(insertPos, insertPos +_len-1)
		editor:EnsureVisible(lineNext)
	end
	output:ClearAll()
	local sErr = "!>> "..TimeOS().." [Error SelectionMoveV] >> "
	local line = editor:LineFromPosition(editor.CurrentPos)
	local lineLast = editor.LineCount -1
	local selStart, selEnd = editor:GetLineSelStartPosition(line), editor:GetLineSelEndPosition(line)
	local selText, selLen = editor:GetSelText()
	editor:SetSelection(selStart, selEnd) -- now the cursor is on left side of selection
	if selLen == 0 then print(sErr..'Nothing selected!') return end
	if _fUp then
		if line == 0 then print(sErr..'No line before this!') return else moveText(-1, selText, selLen, line) end
	else
		if line == lineLast then print(sErr..'No line after this!') return else moveText(1, selText, selLen, line) end
	end
end  --> SelectionMoveV
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.SelectLine = function()
	editor:Home()
	editor:LineEndExtend()
end  --> SelectLine
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.SelectTextInLine = function()
	editor:Home()
	local caret = editor.CurrentPos
--~ 	while string.char(editor.CharAt[caret]):find('%s') do
	while ('9 13'):find(editor.CharAt[caret]) do
		caret = caret +1
	end
	editor:SetSel(caret, caret)
	editor:LineEndExtend()
end  --> SelectTextInLine
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--[[	SelectWord()
			• selects full word with any characters at cursor position
			• returns the string or
			• copies the string to clipboard
]]
-------------------------------------------------------------------------
OHK.SelectWord = function(_return)
	local caret = editor.CurrentPos
    local iStart, iEnd, sSelect = caret, caret, ''
	local iLine = editor:LineFromPosition(iStart)
	local iZero = editor:PositionFromLine(iLine)
	local iCol = iStart - iZero
	local sLine = editor:GetLine(iLine)
	iStart = iCol
	while not sLine:sub(iStart,iStart):find('[\r\n\%s]') do iStart = iStart -1 end
	iEnd = iStart +1
	iStart = iStart +1
	while not sLine:sub(iEnd,iEnd):find('[\r\n%s]') do sSelect = sSelect..sLine:sub(iEnd,iEnd) iEnd = iEnd +1 end
	if _return then return sSelect end
	editor:CopyText(sSelect)
end --> SelectWord
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--[[	SetSelection()
			• selects variable under cursor: $variable
		SetSelection(false, true)
			• selects variable under cursor with following square braces: $variable[$i][$j]
			• builds an debug string from this variable
		SetSelection(true)
			• selects variable under cursor without leading "$": variable
 ]]
-------------------------------------------------------------------------
OHK.SetSelection = function(_part, _brace)
	if props['FileExt']:upper() ~= 'AU3' then return end
    local caret = editor.CurrentPos
	if editor.StyleAt[caret] ~= 9 then if editor.StyleAt[caret-1] ~= 9 then return caret, '' end end
    local iStart, iEnd, iPos, iEnd2, fBrace, sDebugAU3 = caret, caret, nil, nil, false, ''
	local iLine = editor:LineFromPosition(iStart)
	local iZero = editor:PositionFromLine(iLine)
	local iCol = iStart - iZero
	local sLine = editor:GetLine(iLine)
	local sRight = Trim(sLine, iCol)
	iStart = iCol
	while sLine:sub(iStart,iStart):find('[$a-zA-Z0-9_]') do iStart = iStart -1 end
	iEnd = iStart +1
	iStart = iStart +1
	while sLine:sub(iEnd,iEnd):find('[$a-zA-Z0-9_]') do sDebugAU3 = sDebugAU3..sLine:sub(iEnd,iEnd) iEnd = iEnd +1 end
	local sBrace, sTmp = ''
	local iStartBrace, iEndBrace, iPos, iBrace = nil, nil, iEnd
	if _brace then
		while iPos < sLine:len() do
			if sLine:sub(iPos,iPos):find('%[') then
				if not iStartBrace then iStartBrace = iPos end
				iBrace = iPos
				sTmp = sLine:sub(iBrace)
				local s, e, inBrace = sTmp:find('(%b[])')
				iPos = iBrace +e
				iEndBrace = iPos
			elseif sLine:sub(iPos,iPos):find('%s') then
				iPos = iPos +1
			else
				break
			end
		end
		if iStartBrace then sBrace = sLine:sub(iStartBrace, iEndBrace -1):gsub('%s', '') end
	end
	if _part and sDebugAU3:sub(1,1) == '$' then sDebugAU3 = sDebugAU3:sub(2) iStart = iStart+1 end
	if iEndBrace then iEnd = iEndBrace end
	editor:SetSelection(iZero-1+iStart, iZero-1+iEnd)
	if _brace then sDebugAU3 = sDebugAU3..sBrace end
	return caret, sDebugAU3
end  --> SetSelection
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--[[	OHK.ShellExecute( path_file [, param1 [, param2 [, ..] ] ] )
]]
-------------------------------------------------------------------------
OHK.ShellExecute = function(_path, ...)
	local tParam = {_path, ...}
	local sCmd = '"'.._path..'"'
	if #tParam > 1 then for i = 2, #tParam do
		sCmd = sCmd..' "'..tParam[i]..'"'
	end end
	shell.exec(sCmd)
end  --> ShellExecute
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.SkipToComment = function()
	if props['FileExt']:upper() ~= 'AU3' then return end
	local IsComment = function(_pos)
		local tComment = {1,2} if tComment[editor.StyleAt[_pos]] == nil then return false
		else return true end
	end
	output:ClearAll()
	local caret = editor.CurrentPos
	local iStart = caret
	local iLine = editor:LineFromPosition(iStart)
	local iLineStart = editor:PositionFromLine(iLine)
	if IsComment(iStart) then
		while (iStart-1 >= iLineStart) and IsComment(iStart-1) do
			iStart = iStart-1
		end
	else
		while (iStart+1 < iLineStart +editor:LineLength(iLine)) and not IsComment(iStart+1) do
			iStart = iStart+1
		end
		iStart = iStart+1
	end
	if not IsComment(iStart) then editor.CurrentPos = caret
		print("!>> "..TimeOS().." [Error SkipToComment] >> No comment in this line!") return end
	editor:SetSelection(iStart, iStart)
end  --> SkipToComment
-------------------------------------------------------------------------

-------------------------------------------------------------------------
OHK.ToggleAdjacentChars = function()
	local caret = editor.CurrentPos
	editor:SetSel(caret-1, caret)
	local charLeft = editor:GetSelText()
	editor:SetSel(caret, caret+1)
	local charRight = editor:GetSelText()
	editor:ReplaceSel(charLeft)
	editor:SetSel(caret-1, caret)
	editor:ReplaceSel(charRight)
	editor.CurrentPos = caret
end  --> ToggleAdjacentChars
-------------------------------------------------------------------------
