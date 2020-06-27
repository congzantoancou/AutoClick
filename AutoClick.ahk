#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MaxThreadsPerHotkey 2 ; https://autohotkey.com/board/topic/92188-break-a-loop-with-the-same-hotkey-its-pressed/

icon := "autoclick.ico"
If FileExist(icon)
    Menu, Tray, Icon, %icon%

; Single click tray icon suspend
; https://autohotkey.com/boards/viewtopic.php?t=38761
; https://autohotkey.com/boards/viewtopic.php?t=6110
OnMessage(0x404, "AHK_NOTIFYICON")
AHK_NOTIFYICON(wParam, lParam, uMsg, hWnd)
{
	if (lParam = 0x201) ;WM_LBUTTONDOWN := 0x201
		suspend
}

IniRead, delay, Settings.ini, Settings, delay
IniRead, times, Settings.ini, Settings, times

Gui, Add, Text,, Delay
Gui, Add, Text,, Times ; 0 means nolimited
Gui, Add, Edit, vDelay w80 y1, %delay%
Gui, Add, Edit, vTimes w80, %times%
Gui, Add, Button, Default w80, Ok

Menu, Tray, Add
Menu, Tray, Add, Settings, Settings
Menu, Tray, Add, Stop, Stop
Menu, Tray, Default, Settings

Menu, FileMenu, Add, &Open`tCtrl+O, MenuFileOpen 
Menu, FileMenu, Add, E&xit, MenuHandler

Menu, EditMenu, Add, Copy`tCtrl+C, MenuHandler
Menu, EditMenu, Add, Past`tCtrl+V, MenuHandler
Menu, EditMenu, Add ; with no more options, this is a seperator
Menu, EditMenu, Add, Delete`tDel, MenuHandler

Menu, HelpMenu, Add, &About, MenuHandler
Menu, HelpMenu, Add, &Help, MenuFileHelp

; Attach the sub-menus that were created above.
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Edit, :EditMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, Menu, MyMenuBar ; Attach MyMenuBar to the GUI
gui, show, ;w400 h200

TrayTip, AutoClick, ● F5 to start `n● F6 to pause
stopped := 1
return

MenuFileOpen:
    MsgBox, Open Menu was clicked
return

MenuHandler:
    ;MsgBox You selected %A_ThisMenuItem% from the menu %A_ThisMenu%.
    ;If (A_ThisMenuItem == "&Help")
    ;    MsgBox, ● F5 to start `n● F6 to pause
return

MenuFileHelp:
    MsgBox, ● F5 to start `n● F6 to pause
return

Stop:
    stopped := 1
    TrayTip, AutoClick, AutoClick is stopped.
return

ButtonOk:
    Gui, Submit
    IniWrite, %delay%, Settings.ini, Settings, delay
    IniWrite, %times%, Settings.ini, Settings, times
return

Settings:
    Gui, Show
return

GuiEscape:
    Gui, Cancel
return

F5::
	If stopped {
        TrayTip, AutoClick, AutoClick is working. . .
        SetTimer, Trigger, -1
    } else {
        TrayTip, AutoClick, AutoClick is stopped.
    }
    stopped:=!stopped
return

Trigger:
    While (!stopped and times) ; both condition is NOT match will stop the loop
	{
        if (times > 0)
            times--
        Send {LButton}
        Sleep, Delay
	}
/*
    Loop
	{
        if (times > 0)
            times--
		if (stopped == 1 or times == 0) ; one condition is match will stop the loop
            break
        Send {LButton}
        Sleep, Delay
	}
*/
Return
/*
F5::
    ; stopped := !stopped ; this toggle will work fine instead of if condition with no TrayTip
    
    if (!stopped) {
        stopped := 1
        TrayTip, AutoClick, AutoClick is stopped.
    } else {
        stopped := 0
        TrayTip, AutoClick, AutoClick is working. . .
    }
    If (times == 0) { ; infinity loop
        Loop
        {
            if (stopped == 1)
                break
            Send {LButton}
            Sleep, Delay
        }
    } else { ; limited loop
        Loop, times
        {
            if (stopped == 1)
                break
            Send {LButton}
            Sleep, Delay
        }
    }
return
*/
F6:: Pause