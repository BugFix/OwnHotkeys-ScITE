### OWN HOTKEYS

#### About 

This plugin is created for SciTE4AutoIt, but it's also possible to use with other SciTE versions. May be, that some settings must be customized. Feel free to ask me, if you've any problem.

I think you know this: All well-to-use keyboard bindings are occupied by SciTE. So you must use something like "Ctrl+Alt+Shift+key" or any. Not really finger friendly.

Thats why I've created this plugin. It generates 2 stage key bindings like "Ctrl+Win, Ctrl+C". First you need to define an indicator key for the first sequence of your Hotkey. Recommended is the "Win"-key, because this key is not used from SciTE by default.

How does it work?
- You press the "Ctrl"-key and additional your indicator-key. i.e. "Ctrl+Win". Now you've started the Ownhotkeys, to see at the cursor with other style and color.
- You release the indicator-key ("Win") and hold the "Ctrl"-key pressed
- The second key of your sequence must pressed now. i.e. "C". And now will run the programm/function, that you have set in the properties.

This plugin give you 65 new hotkeys. I think it's enough, to be happy.

The plugin is at first for AutoIt users. You get a couple of functions with this plugin, some to use in au3-scripts only: 

<table style='font-family:"Courier New"'>
<tr>
<td>OHK.AddFuncName</td>
<td>Adds at end of every created function in current au3-script: "  ;==> Function_Name"</td>
</tr>
<tr>
<td>OHK.AlignAtEqualSign</td>
<td>Aligns all selected rows at the first rightmost equal sign</td>
</tr>
<tr>
<td>OHK.DebugToConsole</td>
<td>Debugs variable under cursor with(out) @error, @extended to console output (table style)</td>
</tr>
<tr>
<td>OHK.ExecuteAU3</td>
<td>Runs a given au3-file with(out) parameters</td>
</tr>
<tr>
<td>OHK.FindJumpMarks</td>
<td>Search Jump Marks ( §§ ) and writes to console: "line_number   text_from_this_line"</td>
</tr>
<tr>
<td>OHK.FunctionHeader</td>
<td>Inserts a short function header for current script language (*.au3, *.py, *.lua)</td>
</tr>
<tr>
<td>OHK.GetHotkeyList</td>
<td>Writes a list of defined Hotkeys to console output</td>
</tr>
<tr>
<td>OHK.GoToLine</td>
<td><span style='color:darkblue'>[hard coded]</span> Goes to next/previous line, sets caret to end of line</td>
</tr>
<tr>
<td>OHK.JumpToMark</td>
<td>Jumps to the selected mark (where the cursor is in output line)</td>
</tr>
<tr>
<td>OHK.ReloadStartupLua</td>
<td>Reloads the Lua Startup script</td>
</tr>
<tr>
<td>OHK.Repeat</td>
<td>Repeats the character left from cursor n-times. Write the character, activate Repeat-Mode, hit numbers for "n", ENTER repeats last char n-times (count includes the first char)</td>
</tr>
<tr>
<td>OHK.RunSelectedCode</td>
<td>Runs selected au3-code in an temporary file</td>
</tr>
<tr>
<td>OHK.SelectionMoveH</td>
<td><span style='color:darkblue'>[hard coded]</span> Moves selected text in line to left or right</td>
</tr>
<tr>
<td>OHK.SelectionMoveV</td>
<td><span style='color:darkblue'>[hard coded]</span> Moves selected text between lines up or down</td>
</tr>
<tr>
<td>OHK.SelectLine</td>
<td>Selects full line from cursor</td>
</tr>
<tr>
<td>OHK.SelectTextInLine</td>
<td>Selects line from cursor without leading space characters</td>
</tr>
<tr>
<td>OHK.SelectWord</td>
<td>Selects full word with any characters at cursor position. Returns it or copy to clipboard</td>
</tr>
<tr>
<td>OHK.SetSelection</td>
<td>Selects word under cursor with(out) leading "$" / with following square braces</td>
</tr>
<tr>
<td>OHK.ShellExecute</td>
<td>Runs a given file with(out) parameters</td>
</tr>
<tr>
<td>OHK.SkipToComment</td>
<td>Sets caret to start of comment in line, if any</td>
</tr>
<tr>
<td>OHK.ToggleAdjacentChars</td>
<td>Toggles adjacent characters</td>
</tr>
</table>

You see, some functions are <span style='color:darkblue;font-family:"Courier New"'>[hard coded]</span>. But you can en/disable them in the properties.
#### Changes
In the first version I had used the <font color=darkorange>shell.dll</font>. Since the change to <font color=darkorange>Lua 5.3</font> with <font color=darkorange>SciTE 4.0.0</font>, however, it is no longer possible to load dynamic link libraries with <font color=darkorange>require</font>. Therefore, I have reworked everything and replaced the shell.dll calls used with standard system calls. The previously existing problem of the command window popping up was solved by the property: ```create.hidden.console=1``` .