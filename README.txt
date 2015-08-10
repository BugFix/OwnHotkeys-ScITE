#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                   O W N  H O T K E Y S                       by BugFix            #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#    A B O U T                                                                                      #
#                                                                                                   #
#    This plugin is created for SciTE4AutoIt, but it's also possible to use with other SciTE        #
#    versions. May be, that some settings must be customized. Feel free to ask me, if you've        #
#    any problem.                                                                                   #
#                                                                                                   #
#    I think you know this: All well-to-use keyboard bindings are occupied by SciTE.                #
#    So you must use something like "Ctrl+Alt+Shift+key" or any. Not really finger friendly.        #
#    Thats why I've created this plugin. It generates 2 stage key bindings like "Ctrl+Win, Ctrl+C"  #
#    First you need to define an indicator key for the first sequence of your Hotkey. Recommended   #
#    is the "Win"-key, because this key is not used from SciTE by default.                          #
#    How does it work?                                                                              #
#    • You press the "Ctrl"-key and additional your indicator-key. i.e. "Ctrl+Win"                  #
#      Now you've started the Ownhotkeys, to see at the cursor with other style and color.          #
#    • You release the indicator-key ("Win") and hold the "Ctrl"-key pressed                        #
#    • The second key of your sequence must pressed now. i.e. "C"                                   #
#      And now will run the programm/function, that you have set in the properties.                 #
#                                                                                                   #
#   This plugin give you 65 new hotkeys. I think it's enough, to be happy.                          #
#                                                                                                   #
#   The plugin is at first for AutoIt users. You get a couple of functions with this plugin, some   #
#   to use in au3-scripts only:                                                                     #
#                                                                                                   #
#   • OHK.AddFuncName                                                                               #
#     Adds at end of every created function in current au3-script: "  ;==> Function_Name"           #
#                                                                                                   #
#   • OHK.AlignAtEqualSign                                                                          #
#     Aligns all selected rows at the first rightmost equal sign                                    #
#                                                                                                   #
#   • OHK.DebugToConsole                                                                            #
#     Debugs variable under cursor with(out) @error, @extended to console output (table style)      #
#                                                                                                   #
#   • OHK.ExecuteAU3                                                                                #
#     Runs a given au3-file with(out) parameters                                                    #
#                                                                                                   #
#   • OHK.FindJumpMarks                                                                             #
#     Search Jump Marks ( §§ ) and writes to console: "line_number   text_from_this_line"           #
#                                                                                                   #
#   • OHK.FunctionHeader                                                                            #
#     Inserts a short function header for current script language (*.au3, *.py, *.lua)              #
#                                                                                                   #
#   • OHK.GetHotkeyList                                                                             #
#     Writes a list of defined Hotkeys to console output                                            #
#                                                                                                   #
#   • OHK.GoToLine [hard coded]                                                                     #
#     Goes to next/previous line, sets caret to end of line                                         #
#                                                                                                   #
#   • OHK.JumpToMark                                                                                #
#     Jumps to the selected mark (where the cursor is in output line)                               #
#                                                                                                   #
#   • OHK.ReloadStartupLua                                                                          #
#     Reloads the Lua Startup script                                                                #
#                                                                                                   #
#   • OHK.Repeat                                                                                    #
#     Repeats the character left from cursor n-times                                                #
#     Write the character, activate Repeat-Mode, hit numbers for "n",                               #
#     <ENTER> repeats last char n-times (count includes the first char)                             #
#                                                                                                   #
#   • OHK.RunSelectedCode                                                                           #
#     Runs selected au3-code in an temporary file                                                   #
#                                                                                                   #
#   • OHK.SelectionMoveH [hard coded]                                                               #
#     Moves selected text in line to left or right                                                  #
#                                                                                                   #
#   • OHK.SelectionMoveV [hard coded]                                                               #
#     Moves selected text between lines up or down                                                  #
#                                                                                                   #
#   • OHK.SelectLine                                                                                #
#     Selects full line from cursor                                                                 #
#                                                                                                   #
#   • OHK.SelectTextInLine                                                                          #
#     Selects line from cursor without leading space characters                                     #
#                                                                                                   #
#   • OHK.SelectWord                                                                                #
#     Selects full word with any characters at cursor position. Returns it or copy to clipboard     #
#                                                                                                   #
#   • OHK.SetSelection                                                                              #
#     Selects word under cursor with(out) leading "$" / with following square braces                #
#                                                                                                   #
#   • OHK.ShellExecute                                                                              #
#     Runs a given file with(out) parameters                                                        #
#                                                                                                   #
#   • OHK.SkipToComment                                                                             #
#     Sets caret to start of comment in line, if any                                                #
#                                                                                                   #
#   • OHK.ToggleAdjacentChars                                                                       #
#     Toggles adjacent characters                                                                   #
#                                                                                                   #
#   You see, some functions are [hard coded]. But you can en/disable them in the properties.        #
#                                                                                                   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#    I N S T A L L A T I O N  &  S E T T I N G S                                                    #
#                                                                                                   #
#    Installation manually:                                                                         #
#    	                                                                                            #
#    	• copy "ownhotkeys.template.properties" as "ownhotkeys.properties" into folder:             #
#           @UserProfileDir & '\AppData\Local\AutoIt v3\SciTE\'                                     #
#                                                                                                   #
#    	• in file "SciTEUser.properties" add line:                                                  #
#           import ownhotkeys                                                                       #
#                                                                                                   #
#       • if not exists: copy "shell.dll" in the folder with your Lua scripts                       #
#           (own folder, i.e. inside USER-DIR recommended)                                          #
#           shell.dll is needed to call au3-files.                                                  #
#           Source: http://scite-ru.bitbucket.org/pack/tools/LuaLib/shell.html                      #
#                                                                                                   #
#       • be sure, that your Lua script path is added to package.cpath in SciTEStartup.lua          #
#         Recommended way:                                                                          #
#         - create own property for your Lua script path in "SciTEUser.properties"                  #
#           Lua.User.Scripts.Path=C:\YOUR\PATH\LUA\SCRIPTS                                          #
#         - use a global Lua variable LUA_USER_PATH and add it to your "SciTEStartup.lua" as below  #
#           (position: top of script)                                                               #
#                                                                                                   #
#           local sUserLua = props["Lua.User.Scripts.Path"] .. "\\"                                 #
#           LUA_USER_PATH = sUserLua .. "\\?.dll;" .. sUserLua .. "\\?\\?.dll;"                     #
#           ------------------------------------------------------------------------------------    #
#           package.cpath = LUA_USER_PATH..package.cpath                                            #
#                                                                                                   #
#           So you can store dll files as:                                                          #
#              ..\own_folder\name.dll or                                                            #
#              ..\own_folder\name\name.dll                                                          #
#           with access to this from any script.                                                    #
#                                                                                                   #
#       • copy "OHKfuncs.lua" and "Ownhotkeys.lua" in your own Lua scripts folder                   #
#                                                                                                   #
#       • copy "SciTE_Output.au3" to your user include folder                                       #
#          Its requiered to send output from called au3-files to SciTE. Replace "ConsoleWrite()"    #
#          with "_SciTE_Output()" in related au3-files and include "SciTE_Output.au3" there.        #
#                                                                                                   #
#       • insert function to load user files in SciTEStartup.lua (behind function LoadLuaFile):     #
#                                                                                                   #
#           function LoadUserLuaFile(file)                                                          #
#           	LoadLuaFile(file, props["Lua.User.Scripts.Path"] .. "\\")                           #
#           end	-- LoadUserLuaFile()                                                                #
#                                                                                                   #
#       • add at the end of SciTEStartup.lua                                                        #
#           LoadUserLuaFile("Ownhotkeys.lua")                                                       #
#                                                                                                   #
#       • now set the properties (indicator-key, caret settings, using hardcoded hotkeys,           #
#                                 Lua script path, hotkeys)                                         #
#                                                                                                   #
#       • Restart SciTE and use your hotkeys. You can open the properties file anytime about        #
#         menu: Options.                                                                            #
#                                                                                                   #
#    Using Own Hotkeys:                                                                             #
#    	• hit Ctrl + Indicator-key                                                                  #
#    	• hold pressed the Ctrl-key                                                                 #
#    	• release Indicator-key only                                                                #
#    	• hit second key from your sequence                                                         #
#                                                                                                   #
#    Write commands for hotkeys as:                                                                 #
#       Use commands without quotation marks!                                                       #
#       • "[script.lua] function_lua(param)" from this script                                       #
#       • "C:\path\script.lua function_lua(param)" from this script                                 #
#           if script.lua has no path --> encapsulate the script.lua in square braces,              #
#           the path of the own.mode.func.path property is used than.                               #
#       • lua-commands as string (it's possible to insert full scripts here)                        #
#         example (inserts a small Lua function header):                                            #
#           own.mode.cmd.xx=if props['FileExt']:upper() == 'LUA' then \                             #
#           editor:InsertText(editor.CurrentPos, ('-'):rep(100) .. \                                #
#           '\n--[[ \nin...:\t\nout..:\t\n]]\n'..('-'):rep(100)..'\n\n'..('-'):rep(100)) end        #
#       • "dofile ('C:\\full-path\\file.lua')"                                                      #
#       • to break command-lines use " \" at the end of text, line is connected during scanning.    #
#       • own.mode.descript.xx includes the key sequence. Add "|Your-Description" behind this.      #
#                                                                                                   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#