Option Explicit

Dim oShell, oFSO, AppData, InstFolder
Dim AHName, AH, FlashAH, Disk, cur, oDrive, Times

Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject("WScript.Shell")

AppData   = oShell.SpecialFolders("AppData")
'Папка установки
InstFolder = oFSO.BuildPath(AppData, "AntiHidden")

AHName = "_Anti_Hidden Удаление последствий вредоносного ПО на флешке.cmd"

set oDrive = oFSO.GetDrive(WScript.Arguments(0))
if not oDrive.IsReady then WScript.Quit

cur = oFSO.GetParentFolderName(WScript.ScriptFullName)
AH = oFSO.BuildPath(cur, AHName)

Disk = oFSO.BuildPath (WScript.Arguments(0), "\")
FlashAH = oFSO.BuildPath(Disk, AHName)

On Error Resume next

if not oFSO.FileExists(FlashAH) then  ' Копируем AntiHidden на флешку
	oFSO.CopyFile AH, Disk, true
end if

Do while Err.Number <> 0 and Times < 3
	if Err.Number <> 0 then
		Times = Times + 1
		Err.Clear
		WScript.Sleep(2000)
		if not oFSO.FileExists(FlashAH) then  ' Копируем AntiHidden на флешку
			oFSO.CopyFile AH, Disk, true
		end if
	end if
Loop

if Err.Number = 0 then
	oShell.Run "cmd.exe /c " & """" & FlashAH & """", 1, true  ' Запускаем и ждем завершения лечения
	if oFSO.FileExists(oFSO.BuildPath (InstFolder, "OpenExplorer.txt")) then
		oShell.Run "explorer.exe " & Disk
	end if
end if
