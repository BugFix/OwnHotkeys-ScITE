-- TIME_STAMP   2015-08-09 21:42:20   v 0.1

-- Ownhotkeys.lua by BugFix


OwnHotKey = EventClass:new(Common)

shell = require "shell"
LoadUserLuaFile('OHKfuncs.lua')


------------------------------------ HELPER FUNCTIONS ----------------------------------------------
----------------------------------------------------------------------------------------------------
-- returns current time string hh:mm:ss
----------------------------------------------------------------------------------------------------
TimeOS = function() local datetable = os.date("*t", os.time())
	return string.format('%02d:%02d:%02d', datetable.hour, datetable.min, datetable.sec)
end  --> TimeOS
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Trim _i chars from string _s
-- Positive integer trim from left, negative from right side
-- if _fspace == true --> delete, after trimming still existing, space characters on trim side
----------------------------------------------------------------------------------------------------
Trim = function(_s, _i, _fspace)
	local iLen, tPatt, iPatt = _s:len(), {'^%s*', '%s*$'}, 1   -- {leftPatt,rightPatt}
	local sTrim
	if _i == nil then _i = 1 end
	if _i >= iLen then return '' end
	if _i == 0 then return _s
	elseif _i < 0 then sTrim = _s:sub(1, iLen + _i) iPatt = 2  -- trim from right
	else sTrim = _s:sub(_i + 1, -1) end                        -- trim from left
	if _fspace then sTrim = sTrim:gsub(tPatt[iPatt], '') end
	return sTrim
end  --> Trim
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
TableInsert = function(_t, _v)
	local f, v = 0
	if not _t then _t = {} end
	if #_t == 0 then
		table.insert(_t, _v) return true
	else
		for _, v in pairs(_t) do
			if v:lower() == _v:lower() then f = 1 break end
		end
		if f == 0 then table.insert(_t, _v) return true end
	end return false
end  --> TableInsert
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
local ReadHotkeySettings = function(_tLL)
	local getAllUsedKeys = function()
		local file = io.open(os.getenv('USERPROFILE')..'\\AppData\\Local\\AutoIt v3\\SciTE\\ownhotkeys.properties')
		if file == nil then return nil end
		local sRead = file:read("*all") file:close()
		local tKeys = {}
		for k, v in sRead:gmatch('[\r\n]own%.mode%.cmd%.(%d+)=([^%\n]+)') do
			if v ~= '' then table.insert(tKeys, k) end
		end
		if #tKeys == 0 then return nil else return tKeys end
	end
	local tUsedKeys = getAllUsedKeys()
	if tUsedKeys == nil then return {} end
	local tKeyCmd, tDesc, nCmd, v, sKey, sDesc = {}, {}, #tUsedKeys
	for v, sKey in pairs(tUsedKeys) do
		sCmd = props['own.mode.cmd.'..sKey]
		sDesc = props['own.mode.descript.'..sKey]
		if sDesc ~= '' then
			local iSplit, _, sL, sR = sDesc:find('|')
			if iSplit then
				sL = sDesc:sub(1, iSplit-1) sR = sDesc:sub(iSplit +1)
			else
				sL = sDesc sR = 'NO DESCRIPTION'
			end
			table.insert(tDesc, {sL,sR})
		end
		sCmd = sCmd:gsub('^(%[([^%]]+)%])', props['own.mode.func.path']..'\\%2')
		if sCmd:find('^[a-zA-Z]:') then
			local n, sFile, sFunc = 0
			for sFile, sFunc in sCmd:gmatch('([a-zA-Z]:.+%.[Ll][Uu][Aa])([^%\n]+)') do
				n = n +1  TableInsert(_tLL, sFile)
				sCmd = Trim(sCmd, sFile:len(), true)
				if n == 1 then break end
			end
		end
		tKeyCmd[sKey] = sCmd
	end
	if #tDesc > 0 then
		local tRet, iMax, r, s = {}, 0, '.', ''
		for _, v in pairs(tDesc) do if v[1]:len() > iMax then iMax = v[1]:len() end end iMax = iMax +6
		for _, v in pairs(tDesc) do s = s..v[1]..' '..r:rep(iMax-v[1]:len()-2)..' '..v[2] table.insert(tRet, s) s = '' end
		tDesc = tRet
	end
	return tKeyCmd, tDesc, _tLL, nCmd
end  --> ReadHotkeySettings
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
local GetCaretOwn = function()
	tCaretOwn.fore   = tonumber(props['own.mode.caret.indicator.fore']) or 0x0000FF
	tCaretOwn.width  = tonumber(props['own.mode.caret.width'])          or 3
	tCaretOwn.period = tonumber(props['own.mode.caret.period'])         or 300
	tCaretOwn.style  = tonumber(props['own.mode.caret.style'])          or 2
end  --> GetCaretOwn
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
SetCaret = function(_tCProps)
	if _tCProps == nil then _tCProps = {['fore']=tonumber(props['own.mode.caret.repeat.fore']) or 0xBDB936,
	                                                           ['width']=3,['period']=300,['style']=2} end -- repeat-mode
	scite.SendEditor(SCI_SETCARETFORE,   _tCProps.fore  )
	scite.SendEditor(SCI_SETCARETWIDTH,  _tCProps.width )
	scite.SendEditor(SCI_SETCARETPERIOD, _tCProps.period)
	scite.SendEditor(SCI_SETCARETSTYLE,  _tCProps.style )
end  --> SetCaret
----------------------------------------------------------------------------------------------------



--------------------------------------- VARIABLES --------------------------------------------------
----------------------------------------------------------------------------------------------------

local iIndicator = tonumber(props['own.mode.indicator'])
local fOwnMode = false

fRepeat, fRepStarted, iRepeat, sRepeat, caretRepeat = false, false, '', ''

tLL = {}                                         -- list to load
tHK, tDesc, tLL, nCmd = ReadHotkeySettings(tLL)  -- tables with: Hotkeys, Description; fill list to load, counter commands

if #tLL > 0 then for _, v in pairs(tLL) do dofile(v) end end

tNum, j = {}, 0
for i = 48,  57 do tNum[tostring(i)] = j j = j+1 end j = 0   -- numbers on keyboard
for i = 96, 105 do tNum[tostring(i)] = j j = j+1 end         -- numbers on numpad

tCaretDef, tCaretOwn = {}, {}
tCaretDef.fore   = tonumber(props['caret.fore'])   or 1
tCaretDef.width  = tonumber(props['caret.width'])  or 1
tCaretDef.period = tonumber(props['caret.period']) or 500
tCaretDef.style  = tonumber(props['caret.style'])  or 1

GetCaretOwn()     -- fill table 'tCaretOwn'
----------------------------------------------------------------------------------------------------


-------------------------------------- MAIN FUNCTION -----------------------------------------------
----------------------------------------------------------------------------------------------------
function OwnHotKey:OnKey(_keycode, _shift, _ctrl, _alt)
--~ print('_keycode: '..tostring(_keycode)..', _shift: '..tostring(_shift)..', _ctrl: '..tostring(_ctrl)..', _alt: '..tostring(_alt))  -- DebugToConsole

	------------------------------  HOT-KEYS HARDCODED ---------------------------------------------

    if tonumber(props['own.mode.move.lines']) == 1 then                      -- ##== MOVE LINES ==##
		if _ctrl and _shift and not _alt then
			-- Ctrl+Shift+ArrowUp                        ##== Move line/selected-lines Up ==##
			if _keycode == 38 then
				editor:MoveSelectedLinesUp()
			-- Ctrl+Shift+ArrowDown                      ##== Move line/selected-lines Down ==##
			elseif _keycode == 40 then
				editor:MoveSelectedLinesDown()
			end
		end
    end

    ------------------------------------------------------------------------------------------------

	if tonumber(props['own.mode.move.selections']) == 1 then    -- ##== MOVE SELECTIONS IN LINE ==##
		if _ctrl and not _shift and _alt then
			-- Ctrl+Alt+ArrowUp                          ##== Move selection in line Up ==##
			if _keycode == 38 then
				OHK.SelectionMoveV(true)
			-- Ctrl+Alt+ArrowDown                        ##== Move selection in line Down ==##
			elseif _keycode == 40 then
				OHK.SelectionMoveV(false)
			-- Ctrl+Alt+ArrowLeft                        ##== Move selection in line to Left ==##
			elseif _keycode == 37 then
				OHK.SelectionMoveH(true)
			-- Ctrl+Alt+ArrowRight                       ##== Move selection in line to Right ==##
			elseif _keycode == 39 then
				OHK.SelectionMoveH(false)
			end
		end
	end

    ------------------------------------------------------------------------------------------------

	if tonumber(props['own.mode.cursor.line.end']) == 1 then -- ##== CURSOR TO PREVIOUS/ NEXT LINE AT LINE END POSITION ==##
		if not _shift and not _ctrl and _alt then
			-- Alt+ArrowUp                               ##== Cursor skips line up, position at end of line ==##
			if _keycode == 38 then
				OHK.GoToLine(-1) return true
			-- Alt+ArrowDown                             ##== Cursor skips line down, position at end of line ==##
			elseif _keycode == 40 then
				OHK.GoToLine(1) return true
			end
		end
	end
    ------------------------------------------------------------------------------------------------

	if tonumber(props['own.mode.repeat']) == 1 then
		if fRepeat then
			return OHK.Repeat(_keycode)
		end
	end

    ---------------------------------- OWN HOT-KEY MODE --------------------------------------------

	if not fOwnMode and _ctrl and not _shift and not _alt and _keycode == iIndicator then   --- activates OwnMode
		if nCmd > 0 then
			fOwnMode = true SetCaret(tCaretOwn)
			return true -- avoids default processing
		end
	end

	if fOwnMode and not _shift and not _alt then
		local sCmd = tHK[tostring(_keycode)]
		if sCmd == nil then
			fOwnMode = false SetCaret(tCaretDef)
			return nil  -- default processing
		end
		dostring (sCmd)
		fOwnMode = false
		if fRepeat then SetCaret() else SetCaret(tCaretDef) end
		return true -- avoids default processing
	end
	if fOwnMode then SetCaret(tCaretDef) fOwnMode = false end                               --- deactivates OwnMode

    ------------------------------------------------------------------------------------------------

	return nil -- default processing
end  --> OwnHotKey
----------------------------------------------------------------------------------------------------

