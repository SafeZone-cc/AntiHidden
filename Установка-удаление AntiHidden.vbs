Option Explicit

Dim AppName, oShell, oFSO, oShellApp, AppData, StartPath, InstFolder, curPath

AppName = "AntiHidden"

Set oShell     = CreateObject("WScript.Shell")
Set oFSO       = CreateObject("Scripting.FileSystemObject")
Set oShellApp  = CreateObject("Shell.Application")

AppData   = oShell.SpecialFolders("AppData")
StartPath = oShell.SpecialFolders("AllUsersPrograms") & "\" & AppName

'Папка установки
InstFolder = oFSO.BuildPath(AppData, AppName)

curPath = oFSO.GetParentFolderName(WScript.ScriptFullname)

call Elevate()

'Деинсталляция
if strcomp(curPath, StartPath, 1) = 0 or oFSO.FileExists(InstFolder & "\_service_stop.cmd") then
	if msgbox("Вы уверены, что хотите удалить " & AppName & " ?", vbYesNo, AppName) = vbYes then 
		call Uninstall()
	else
		WScript.Quit
	end if
end if

'Проверка, что запущен не из архива
if not oFSO.FolderExists(curPath & "\bin") then
	WScript.Echo "Сначала нужно распаковать все файлы из архива."
	WScript.Quit
end if

if msgbox ("Приветствую !" & vbCrLf & vbCrLf & _
	"Для установки AntiHidden Вам необходимо согласиться с условиями лицензионного соглашения к программе USBDLM от Uwe Sieber:" & vbcrlf & _
	"Программа может использоваться только для личных некоммерческих или образовательных целей." & vbcrlf & vbcrlf & _
	"ДА - Я согласен с условиями." & vbcrlf & _
	"НЕТ - перейти к чтению условий платного использования.",vbYesNo,AppName) = vbNo then
		oShell.Run "cmd.exe /c start """" """ & "http://www.uwe-sieber.de/usbdlm_e.html" & """"
		WScript.Quit
end if

'Создаю папку для установки приложения
if not oFSO.FolderExists(InstFolder) then oFSO.CreateFolder InstFolder
'Создаю папку в меню "ПУСК"
if not oFSO.FolderExists(StartPath) then oFSO.CreateFolder StartPath

'Копирую файлы приложения
on error resume next
Dim oFile
For each oFile in oFSO.GetFolder(curPath & "\bin").Files
	oFile.Copy InstFolder & "\" & oFile.Name, true
Next
oFSO.CopyFile WScript.ScriptFullname, InstFolder & "\" & oFSO.GetFileName(WScript.ScriptFullname), true
on error goto 0

'Установка службы
oShell.Run "cmd.exe /c """ & InstFolder & "\_service_register.cmd""", 1, true

with oShell.CreateShortcut(StartPath & "\Приостановить программу.lnk")
	.Description        = AppName
	.TargetPath         = InstFolder & "\_service_stop.cmd"
	.WorkingDirectory   = InstFolder
	.WindowStyle        = 1 'normal
	.Save
end with
with oShell.CreateShortcut(StartPath & "\Возобновить работу программы.lnk")
	.Description        = AppName
	.TargetPath         = InstFolder & "\_service_start.cmd"
	.WorkingDirectory   = InstFolder
	.WindowStyle        = 1 'normal
	.Save
end with
with oShell.CreateShortcut(StartPath & "\Удалить AntiHidden.lnk")
	.Description        = AppName
	.TargetPath         = InstFolder & "\" & oFSO.GetFileName(WScript.ScriptFullname)
	.WorkingDirectory   = InstFolder
	.WindowStyle        = 1 'normal
	.Save
end with
with oShell.CreateShortcut(StartPath & "\(Не) открывать проводник после лечения.lnk")
	.Description        = AppName
	.TargetPath         = InstFolder & "\" & "Не открывать проводник после лечения флешки.cmd"
	.WorkingDirectory   = InstFolder
	.WindowStyle        = 1 'normal
	.Save
end with

oShell.Run "cmd.exe /c ""<NUL set /p=>""" & WScript.ScriptFullname & """:Zone.Identifier:$DATA""", 0, false
oShell.Run "cmd.exe /c ""<NUL set /p=>""" & InstFolder & "\_service_stop.cmd" & """:Zone.Identifier:$DATA""", 0, false
oShell.Run "cmd.exe /c ""<NUL set /p=>""" & InstFolder & "\_service_start.cmd" & """:Zone.Identifier:$DATA""", 0, false
oShell.Run "cmd.exe /c ""<NUL set /p=>""" & InstFolder & "\" & oFSO.GetFileName(WScript.ScriptFullname) & """:Zone.Identifier:$DATA""", 0, false
oShell.Run "cmd.exe /c ""<NUL set /p=>""" & InstFolder & "\" & "Не открывать проводник после лечения флешки.cmd" & """:Zone.Identifier:$DATA""", 0, false

if Msgbox ("Хотите отключить автозапуск на всех съемных накопителях, кроме CD-ROM ?", vbYesNo, AppName) = vbYes then
	DisableAutoRun
end if

MsgBox "Установка AntiHidden завершена." & vbCrLf & vbCrLf & "Лечение будет автоматически запускаться каждый раз при подключении USB-накопителя.", , AppName

Sub DisableAutoRun()
	oShell.RegWrite "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer\NoDriveTypeAutoRun",221,"REG_DWORD"
End Sub

Sub Uninstall()
	oShell.CurrentDirectory = oFSO.GetDriveName(WScript.ScriptFullname)
	on error resume next
	'Удаление службы
	oShell.Run "cmd.exe /c """ & InstFolder & "\_service_deregister.cmd""", 1, true
	
	if oFSO.FolderExists(StartPath) then oFSO.DeleteFolder StartPath, true
	if oFSO.FolderExists(InstFolder) then oFSO.DeleteFolder InstFolder, true
	if err.Number <> 0 then
		msgbox "Удалите самостоятельно папку: " & InstFolder
		oShell.Run "explorer.exe " & """" & InstFolder & """"
	else
		msgbox "Удаление завершено.",,AppName
	end if
	WScript.Quit
End Sub

Function GetWindowsVersion() '"NT" или "Vista" core
	dim ver
	ver = oShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CurrentVersion")
	if left(ver, 2) = "5." then GetWindowsVersion = "NT" else GetWindowsVersion = "Vista"
End Function

Sub Elevate()
	if GetWindowsVersion() = "NT" then exit sub
    Const DQ = """"
	if WScript.Arguments.Count = 0 then
	    oShellApp.ShellExecute WScript.FullName, DQ & WScript.ScriptFullName & DQ & " " & DQ & "Admin" & DQ, "", "runas", 1
		WScript.Quit
	end if
End Sub

'' SIG '' Begin signature block
'' SIG '' MIIQIgYJKoZIhvcNAQcCoIIQEzCCEA8CAQExCzAJBgUr
'' SIG '' DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
'' SIG '' gjcCAR4wJAIBAQQQTvApFpkntU2P5azhDxfrqwIBAAIB
'' SIG '' AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFJwNIrkV0FDH
'' SIG '' M4s+4h09846XsqZWoIICDDCCAggwggF1oAMCAQICEPTb
'' SIG '' 3W6cNZGsSlw56VqCU28wCQYFKw4DAh0FADAYMRYwFAYD
'' SIG '' VQQDEw1BbGV4IERyYWdva2FzMB4XDTE0MDYzMDIwNTk0
'' SIG '' MloXDTM5MTIzMTIzNTk1OVowGDEWMBQGA1UEAxMNQWxl
'' SIG '' eCBEcmFnb2thczCBnzANBgkqhkiG9w0BAQEFAAOBjQAw
'' SIG '' gYkCgYEA0ZF2vv2gn+17UGx/QNKdOdEKeCjk/cz0zjFv
'' SIG '' qb59WEg9CP975lku7nklgPOKw3w/O4vfSjurwYW9Yh9c
'' SIG '' Ldef6UVN0NBooVRtZ3H8LAk5s/6h3/bOGhbHQxV4EakA
'' SIG '' h84zkK4eBr3wR1lOT9RC2+zruwGlG1KJPHkZE5ex+yyU
'' SIG '' KAcCAwEAAaNbMFkwDAYDVR0TAQH/BAIwADBJBgNVHQEE
'' SIG '' QjBAgBAg3Mm7xHMuIoLCqkkoBotCoRowGDEWMBQGA1UE
'' SIG '' AxMNQWxleCBEcmFnb2thc4IQ9Nvdbpw1kaxKXDnpWoJT
'' SIG '' bzAJBgUrDgMCHQUAA4GBAF7S7++1pq0cQKeHkD2wCbbR
'' SIG '' nfrOA6F26AT6Ol0UHXbvHl92M+UzuNrkT+57LH0kG9eu
'' SIG '' UlDbrP4kytNQ7FtL8o/IS5tvORwuTsrs4AGrzfpKm2KH
'' SIG '' y0EIMGJbIW3OoHHpiVqZK2eEW5HuSqaE+xTs05vfgBho
'' SIG '' TugVef8DA2tnrOgpMYINgjCCDX4CAQEwLDAYMRYwFAYD
'' SIG '' VQQDEw1BbGV4IERyYWdva2FzAhD0291unDWRrEpcOela
'' SIG '' glNvMAkGBSsOAwIaBQCgUjAQBgorBgEEAYI3AgEMMQIw
'' SIG '' ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAjBgkq
'' SIG '' hkiG9w0BCQQxFgQUoZQ2Zp0jyQ97O66Q9PqjoBnbQA0w
'' SIG '' DQYJKoZIhvcNAQEBBQAEgYC+uJ3daofPkce4ZaHauJZ9
'' SIG '' a06uWUrMA2zOe+C6SYlb3pSz1vw2Wdi8adi2q6xIrR9R
'' SIG '' WScANEYtqhAPSpA/LTfmZ/NdYp5j9gwPt6r+vqhv7yIc
'' SIG '' 6PoPawl70UmFJ33xU70fGef66KlQfCFVb82DuqGGVze5
'' SIG '' yVkEtgfMvBuDXtj0oqGCDFgwggxUBgorBgEEAYI3AwMB
'' SIG '' MYIMRDCCDEAGCSqGSIb3DQEHAqCCDDEwggwtAgEDMQsw
'' SIG '' CQYFKw4DAhoFADCBzQYLKoZIhvcNAQkQAQSggb0Egbow
'' SIG '' gbcCAQEGCSsGAQQBoDICAjAhMAkGBSsOAwIaBQAEFB7t
'' SIG '' 7Tf82asEFLm/YP0I6ByCgQkvAhReiZO+XcdP9LImu4XN
'' SIG '' UZ2yMWbZTBgPMjAxNjA4MzEyMTMwMTlaoF2kWzBZMQsw
'' SIG '' CQYDVQQGEwJTRzEfMB0GA1UEChMWR01PIEdsb2JhbFNp
'' SIG '' Z24gUHRlIEx0ZDEpMCcGA1UEAxMgR2xvYmFsU2lnbiBU
'' SIG '' U0EgZm9yIFN0YW5kYXJkIC0gRzKgggi0MIIEmDCCA4Cg
'' SIG '' AwIBAgISESG0VTUeuxqyT5fvB/4qswuKMA0GCSqGSIb3
'' SIG '' DQEBBQUAMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
'' SIG '' bG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxT
'' SIG '' aWduIFRpbWVzdGFtcGluZyBDQSAtIEcyMB4XDTE2MDUy
'' SIG '' NDAwMDAwMFoXDTI3MDYyNDAwMDAwMFowWTELMAkGA1UE
'' SIG '' BhMCU0cxHzAdBgNVBAoTFkdNTyBHbG9iYWxTaWduIFB0
'' SIG '' ZSBMdGQxKTAnBgNVBAMTIEdsb2JhbFNpZ24gVFNBIGZv
'' SIG '' ciBTdGFuZGFyZCAtIEcyMIIBIjANBgkqhkiG9w0BAQEF
'' SIG '' AAOCAQ8AMIIBCgKCAQEApLbCTEUO4rBsJZ6Cd3QPTcR5
'' SIG '' oedNN1N4NG+GyrukMrQtwSqqY/v1a/+4KVmJET/bejo4
'' SIG '' wo4pgSPUMw0gpeQUMWSM/qhs5RI/2JyYlp6Fvd7vhsAa
'' SIG '' vsvTjbVS5yXaLQJxciT3rN5jxGs55jT0Qske6yz1FEyZ
'' SIG '' eH3bz/SKo4haoeQ4ebo/iT4R2Y5S7s4nmeDsWKgeshT4
'' SIG '' aLpvLQDUkglAGtkC5pwlWtC403LfDmyp/fWd3aCDG3qB
'' SIG '' mEBQ8WC2MGslldu63IHe+o+Mw1iyDy71sJg3Ac4KHffx
'' SIG '' vKubQK10j3CUJZ8LyrT/zjWXAHvZWoFpwtrJoXW6Hs7E
'' SIG '' FzUbscvLTQIDAQABo4IBXzCCAVswDgYDVR0PAQH/BAQD
'' SIG '' AgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYI
'' SIG '' KwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24u
'' SIG '' Y29tL3JlcG9zaXRvcnkvMAkGA1UdEwQCMAAwFgYDVR0l
'' SIG '' AQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
'' SIG '' M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9n
'' SIG '' c3RpbWVzdGFtcGluZ2cyLmNybDBUBggrBgEFBQcBAQRI
'' SIG '' MEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUuZ2xv
'' SIG '' YmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5n
'' SIG '' ZzIuY3J0MB0GA1UdDgQWBBRPNUG1+UqSzkgpUEsDLLN3
'' SIG '' +ipAtDAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm9IWbsN1q
'' SIG '' 1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEALqbwOoR3hYhm
'' SIG '' JxL69i1Nf79Tp0qr2Sl5GZ22+R3ibc8s1rhqkHGqqwYe
'' SIG '' 4Kzveo+azeznOaJM6UTVCNTbXvd8j4sB/AZ/YXTII9Xx
'' SIG '' 6NDsnYKUDIfGntpbdwlYQMo/FxIZWLmbaiMY+rIsa4Ga
'' SIG '' uV8ppZkLvHboq4Fs/O+31I5hJGhRnEIv3puiLMFd3ioi
'' SIG '' e5F+WOjVI0NzPBIOBRcUW28qIoJzUX9tr9GLOZQnbKCS
'' SIG '' lJkSS8nEcRuMh3f3EZdZy4AFs8swOD5mQ9VZANkFDbxZ
'' SIG '' fVD9piH0mQwhFwE7/0acLPYt1Gv8VXo4aHSIJWpZ/eSt
'' SIG '' FQ4vmt0GeXRl9g8Q8mEWYTCCBBQwggL8oAMCAQICCwQA
'' SIG '' AAAAAS9O4VLXMA0GCSqGSIb3DQEBBQUAMFcxCzAJBgNV
'' SIG '' BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNh
'' SIG '' MRAwDgYDVQQLEwdSb290IENBMRswGQYDVQQDExJHbG9i
'' SIG '' YWxTaWduIFJvb3QgQ0EwHhcNMTEwNDEzMTAwMDAwWhcN
'' SIG '' MjgwMTI4MTIwMDAwWjBSMQswCQYDVQQGEwJCRTEZMBcG
'' SIG '' A1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UEAxMf
'' SIG '' R2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjCC
'' SIG '' ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJTv
'' SIG '' Zfi1V5+gUw00BusJH7dHGGrL8Fvk/yelNNH3iRq/nrHN
'' SIG '' EkFuZtSBoIWLZFpGL5mgjXex4rxc3SLXamfQu+jKdN6L
'' SIG '' Tw2wUuWQW+tHDvHnn5wLkGU+F5YwRXJtOaEXNsq5oIwb
'' SIG '' TwgZ9oExrWEWpGLmtECew/z7lfb7tS6VgZjg78Xr2AJZ
'' SIG '' eHf3quNSa1CRKcX8982TZdJgYSLyBvsy3RZR+g79ijDw
'' SIG '' Fwmnu/MErquQ52zfeqn078RiJ19vmW04dKoRi9rfxxRM
'' SIG '' 6YWy7MJ9SiaP51a6puDPklOAdPQD7GiyYLyEIACDG6Hu
'' SIG '' tHQFwSmOYtBHsfrwU8wY+S47+XB+tCUCAwEAAaOB5TCB
'' SIG '' 4jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB
'' SIG '' /wIBADAdBgNVHQ4EFgQURtg+/9zjvv+D5vSFm7DdatYU
'' SIG '' qcEwRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUH
'' SIG '' AgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
'' SIG '' cG9zaXRvcnkvMDMGA1UdHwQsMCowKKAmoCSGImh0dHA6
'' SIG '' Ly9jcmwuZ2xvYmFsc2lnbi5uZXQvcm9vdC5jcmwwHwYD
'' SIG '' VR0jBBgwFoAUYHtmGkUNl8qJUC99BM00qP/8/UswDQYJ
'' SIG '' KoZIhvcNAQEFBQADggEBAE5eVpAeRrTZSTHzuxc5KBvC
'' SIG '' Ft39QdwJBQSbb7KimtaZLkCZAFW16j+lIHbThjTUF8xV
'' SIG '' OseC7u+ourzYBp8VUN/NFntSOgLXGRr9r/B4XOBLxRjf
'' SIG '' OiQe2qy4qVgEAgcw27ASXv4xvvAESPTwcPg6XlaDzz37
'' SIG '' Dbz0xe2XnbnU26UnhOM4m4unNYZEIKQ7baRqC6GD/Sjr
'' SIG '' 2u8o9syIXfsKOwCr4CHr4i81bA+ONEWX66L3mTM1fsua
'' SIG '' irtFTec/n8LZivplsm7HfmX/6JLhLDGi97AnNkiPJm87
'' SIG '' 7k12H3nD5X+WNbwtDswBsI5//1GAgKeS1LNERmSMh08W
'' SIG '' YwcxS2Ow3/MxggKRMIICjQIBATBoMFIxCzAJBgNVBAYT
'' SIG '' AkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSgw
'' SIG '' JgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFtcGluZyBD
'' SIG '' QSAtIEcyAhIRIbRVNR67GrJPl+8H/iqzC4owCQYFKw4D
'' SIG '' AhoFAKCB/zAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQ
'' SIG '' AQQwHAYJKoZIhvcNAQkFMQ8XDTE2MDgzMTIxMzAxOVow
'' SIG '' IwYJKoZIhvcNAQkEMRYEFJDs/MxPY6ThqgUA6jDVxcYz
'' SIG '' on6DMIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQU
'' SIG '' g/3hunb+9VKRtQ1oYZBtqkW1jLUwbDBWpFQwUjELMAkG
'' SIG '' A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
'' SIG '' c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1w
'' SIG '' aW5nIENBIC0gRzICEhEhtFU1Hrsask+X7wf+KrMLijAN
'' SIG '' BgkqhkiG9w0BAQEFAASCAQAisg/uSEWHoeO/j6AgTRml
'' SIG '' u0QWdxuSgQC4ig55dFZYZ99BHkEBDLH/YcZWQxYO1cnc
'' SIG '' 7/s0YNYVvjTZP9C7IPWS85RoVLxYTXFOVstSPQqy+lzb
'' SIG '' JeMjTCuBGmE+KgZx1QzR1NUYS98tdnYuPOnLUCflwlh1
'' SIG '' /8kNVoMbwEgzv4Xx/VCJI8dqrkZ0XUwQYTpnOeQ60ufo
'' SIG '' 8G9wZ0J1ruVDgYaewJPU8TNPZ/GvQcAy+8PuutcqbRQT
'' SIG '' f24qcpLVAwG0c91q3GuqSvXrpfNj6Mu+Ex3MagMFkq3A
'' SIG '' 65ORKjAtF5sZ/2L3ZMBfWZL/098yDJ+SJT8lUi7I1uqW
'' SIG '' wWUYV4zsLhwA
'' SIG '' End signature block
