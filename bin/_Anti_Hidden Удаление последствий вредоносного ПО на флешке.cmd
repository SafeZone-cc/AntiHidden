@echo off
:begin
Setlocal DisableDelayedExpansion EnableExtensions
if %errorlevel% neq 0 (
  echo ���⥬��� �訡��
  echo �ணࠬ�� �㤥� ������...
  ping -n 2 127.1 >NUL
  goto :eof
)
mode con: cols=82 lines=30

set version=1.10
set upd=01.09.2016

title AntiHidden - �������� ��᫥��⢨� ����᭮� ���⥫쭮�� �� �ꥬ��� ������⥫� ver.%version%

:: � ������⥫�� 䠩��� �⭮�����:
:: game.cpl
:: system
:: *.lnk (⮫쪮 �, �� ����� ᮮ⢥������ �������� ����� � �஬� ��몮� �� ࠡ�祬 �⮫�)
:: �� *.init
:: desktop.ini
::
:: � ������⥫�� ������ �⭮�����:
:: ����� � ᨬ����� 0xA0 (�� ᮤ�ন��� ����� �㤥� ��७�ᥭ� � ��୥��� ��⠫��)
:: recycled
:: recycler
:: System Volume Information
Set "_CharA0_=�"

color 1B
echo.
echo                         ---- AntiHidden -----
echo               �������� ��᫥��⢨� ����᭮� ���⥫쭮�� 
echo                         �� �ꥬ��� ������⥫�
echo.
echo                                                (c) Created by Polshyn Stanislav
echo.
echo                                                          [ http://SafeZone.cc ]
echo.
echo                                                                      %upd%
echo                                                                         ver.%version%
echo   �⠯ 1. ������������� ᢮��� ��୥��� �����.
echo   - �� "������"
echo   - �� "���⥬��"
echo   + ���� �������楬
echo   + �।��⠢��� ����� �ࠢ�
rem echo   ��� �᪮७�� ����樨 ����� �६���� �⪫���� ��⨢���᭮� ��.

:: �஢�ઠ, �� ����饭 �� �� ࠡ�祬 �⮫�
for %%i in ("%~f0\..") do set "curFolderName=%%~nxi"
if /i "%curFolderName%"=="Desktop" set "isDesktop=true"
if /i "%curFolderName%"=="����稩 �⮫" set "isDesktop=true"
if "%isDesktop%"=="true" (
  echo.
  echo ��������. ����᪠�� �⨫��� ����� ⮫쪮, ᪮��஢�� �� �� 䫥��.
  echo.& pause& Exit /B
)
if /i "%curFolderName%" neq "" (
  echo.
  echo.
  echo  ��������! �ணࠬ�� ����饭� �� �� �᭮���� ����� ��᪠.
  echo  ���ࢠ ᪮����� �� �� 䫥�� ^(� ��७�^).
  echo  ��⥬ �������.
  echo.
  call :Dialogue "�� �筮 㢥७�, �� ��� �த������ ������ � �⮩ �����? (Y/N) (�/�) "
  if not errorlevel 1 Exit /B
)

Set Cur=%~dp0
Set Cur=%Cur:~0,-1%

chcp 1251 >nul
for /f "delims=" %%i in ('dir "%Cur%" /b /a:dh 2^>nul') do attrib -s -h "%Cur%\%%i" 1>nul 2>&1& Call :RecovFolder "%Cur%\%%i"
for /f "delims=" %%i in ('dir "%Cur%" /b /a:ds 2^>nul') do attrib -s -h "%Cur%\%%i" 1>nul 2>&1& Call :RecovFolder "%Cur%\%%i"
chcp 866 >nul

echo.
echo   �⠯ 2. �������� ��譨� ��몮�.

::�������� ⮫쪮 ��몮�, ����� ������ ᮮ⢥������ ������ �����
for /f "delims=" %%i in ('dir "%Cur%" /b /a:d') do if exist "%Cur%\%%i.lnk" (
  attrib -s -h "%Cur%\%%i.lnk" 1>nul 2>&1
  del /F /A /Q "%Cur%\%%i.lnk" 1>nul 2>&1
  call :killfile "%Cur%\%%i.lnk"
)

echo   �⠯ 4. �������� 䠩�� ��⮧���᪠.
if not exist "%Cur%\autorun.inf\" if exist "%Cur%\autorun.inf" call :killfile "%Cur%\autorun.inf"

echo   �⠯ 5. �������� ������஢����� ��⥬��� ����� � ���த��� 䠩���.
for %%a in ("recycled" "System Volume Information") do (
  if exist "%Cur%\%%~a\" Call :KillFolder "%Cur%\%%~a")
) 1>nul 2>&1
if exist "%Cur%\recycler\" (
  echo   ������� ����� Recycler. �த������ 㤠����� ��২�� Windows ��� ⮬� %~d0 ? 
  rem call :Dialogue "������ 'Y' � ������ {ENTER} "
  rem if errorlevel 1 
  Call :KillFolder "%Cur%\recycler"
)

for %%b in (game.cpl system *.init desktop.ini Thumbs.db) do for /F "delims=" %%a in ('2^>nul dir "%Cur%\%%b" /b /a:-d') do (
  echo.
  echo ������ ������⥫�� 䠩� - %%a. 
  rem call :Dialogue "��� 㤠����� ������ 'Y' � ������ {ENTER} "
  rem if errorlevel 1 
  call :KillFile "%Cur%\%%a"
)

goto SKIP_Host
echo.
color 1b
echo   �⠯ 5.1. ���� � �����०������ ����� host.exe. ��������, ��������...
tasklist |1>nul 2>&1 FindStr /B /L /I /C:host.exe && (
  Echo   � ��⥬� ����饭 ������⥫�� ����� Host.exe
  call :Dialogue "�������� ���? - ������ 'Y' � {ENTER}"
  if errorlevel 1 (
    taskkill /im "host.exe" /t /f
    Echo   �� 䠩�� � ������ Host.exe ���� 㤠���� � ���⥫� %~dp0%.
    call :Dialogue "�⮡� �த������ ������ 'Y' � {ENTER}"
    if errorlevel 1 for /f "tokens=*" %%a in ('Dir /b /s /a:-d "%Cur%\host.exe"') Do Call :KillFile "%Cur%\%%a"
  )
)
:SKIP_Host

color 1a
echo   �⠯ 6. �������� ���⭮�� 䠩�� ��⮧���᪠, ����� �� 㤠����� ��⭮.
if not exist "%Cur%\autorun.inf\" mkdir "%Cur%\autorun.inf" 1>nul 2>&1
if not exist "%Cur%\autorun.inf\���饭� AntiHidden by Dragokas..\" mkdir "%Cur%\autorun.inf\���饭� AntiHidden by Dragokas..\" 1>nul 2>&1
if not exist "%Cur%\autorun.inf\com1\" mkdir "\\?\%Cur%\autorun.inf\com1" 1>nul 2>&1
if not exist "%Cur%\autorun.inf\defence" (
  mkdir "%Cur%\autorun.inf\defence" 1>nul 2>&1
  echo y|1>nul 2>&1 cacls "%Cur%\autorun.inf\defence" /d ��
  echo y|1>nul 2>&1 cacls "%Cur%\autorun.inf\defence" /d All
)

if Defined Skip_Bundpil goto Bundpil_ext

echo   �⠯ 8. ��७�� ������ � ���⮣� ��⠫���.
set "TempName=_AntiHidden - ��� 䠩��"
if exist "%Cur%\%_CharA0_%" (
  Echo �����㦥�� ��������� �����.
  attrib -R -S -H "%Cur%\%_CharA0_%"
  Echo ��२������� ������ ����� � ��� %TempName%
  if exist "%Cur%\%_CharA0_%" ren "%Cur%\%_CharA0_%" "%TempName%"
  if errorlevel 1 (
    echo �� ���� ��२��������. �������� �� ��᪥ ᮤ�ঠ��� �訡��.
    echo ������ �஢��� �஢���?
    call :Dialogue "��� �த������� ������ 'Y' � ������ {ENTER} "
    if errorlevel 1 (
      chkdsk %Cur% /F
      echo ����⪠ 2. ��२������� ������ ����� � ��� %TempName%
      if exist "%Cur%\%_CharA0_%" ren "%Cur%\%_CharA0_%" "%TempName%"
      if errorlevel 1 (
        Echo ��㤠�.
        Echo �������� ����� ����� ���� �������஢��� ��㣮� �ணࠬ���.
        Echo ������ �����஢�� � ��१������ �⨫���.
        Goto Bundpil_ext
      )
    ) else (
      Goto Bundpil_ext
    )
  )
  Echo ��稭�� ��७�� 䠩��� � ��୥��� ��⠫��.
  Echo �� ���뢠�� ����� �����.
  if exist "%Cur%\%TempName%\autorun.inf\" (
    RD /s /q "\\?\%Cur%\%TempName%\autorun.inf\com1"
    echo y|cacls %Cur%\%TempName%\autorun.inf\defence /g "%username%":f
    RD /s /q "\\?\%Cur%\%TempName%\autorun.inf"
  )
  for /f "delims=" %%F in ('dir /B /A "%Cur%\%TempName%\*"') do (
    attrib -R -S -H "%Cur%\%TempName%\%%F"
    if exist "%Cur%\%%~nxF" (
      rem �᫨ �� ����� ⥪�饣� �ਯ� - ᯮ����� 㤠�塞
      if /i "%%~nxF"=="%%~nx0" (
        del "%Cur%\%%~nxF"
      ) else (
        call :GetEmptyName "%Cur%" "%%~nxF" "NewName"
        call move "%Cur%\%TempName%\%%F" "%Cur%\%%NewName%%"
      )
    ) else (
      move "%Cur%\%TempName%\%%F" "%Cur%\"
    )
  )
  Call :IsEmptyFolder "%Cur%\%TempName%"
  if errorlevel 1 (
    echo ����� 䠩��� �/��� ����� �� �뫠 ��७�ᥭ�, �.�. ��� 㦥 �������� � ��୥ ���⥫�.
    echo ������� �� ������. ��⠢訥�� 䠩�� ��室���� � ����� %TempName%
    start "" "%Cur%\%TempName%"
    echo.
    pause
  ) else (
    rd "%Cur%\%TempName%"
  )
  EndLocal& set Skip_Bundpil=true& Goto begin
)
:Bundpil_ext

echo   �⠯ 9. ��२��������� *.LNK � *.LNK_ (Anti Stuxnet)
ren "%Cur%\*.LNK" *.LNK_ 2>NUL

color 1A
echo.
echo   ��祭�� �����襭�.
ping -n 3 localhost 1>nul 2>&1
color
goto :eof

:Dialogue
  set "ch="
  set /p "ch=%~1"
  if /i "%ch%"=="Y" Exit /B 1
  if /i "%ch%"=="�" Exit /B 1
  if /i "%ch%"=="N" Exit /B 0
  if /i "%ch%"=="�" Exit /B 0
  echo �訡�� �����!
  echo ������ �㪢� � ��� Y, ��⥬ ������ ENTER (�⮡� �⢥��� ��).
  echo ������ �㪢� � ��� N, ��⥬ ������ ENTER (�⮡� �⢥��� ���).
  echo.
  goto Dialogue
Exit /B 0

:RecovFolder
  set "folder=%~1"
  set "folder=%folder:^^=^%"
  attrib "%folder%"|>nul FindStr /BIR "....H.."
  if not errorlevel 1 (
    Call :GrantAccess "%folder%"
    attrib -s -h "%folder%" 1>nul 2>&1
  ) else (
    attrib "%folder%"|>nul FindStr /BIR "...S..." && (
      Call :GrantAccess "%folder%"
      attrib -s -h "%folder%" 1>nul 2>&1
    )
  )
exit /b

:GrantAccess
  set "folder=%~1"
  set "folder=%folder:^^=^%"
  takeown /f "%~1" /r /d y 1>nul 2>&1
  echo y|cacls "%~1" /g "%username%":f 1>nul 2>&1
exit /b

:KillFile
  set "file=%~1"
  set "file=%file:^^=^%"
  attrib -s -h "%file%" 1>nul 2>&1
  del /F /A /Q "%file%" 1>nul 2>&1
  if exist "%file%" (
    takeown /f "%file%"
    echo y|cacls "%file%" /g "%username%":f
    del /F /A /Q "%file%"
  ) 1>nul 2>&1
  if exist "%file%" (
    del /F /A /Q "\\?\%file%"
  ) 1>nul 2>&1
exit /b

:KillFolder
  set "folder=%~1"
  set "folder=%folder:^^=^%"
  attrib -s -h "%folder%" 1>nul 2>&1
  rd /S /Q "%folder%" 1>nul 2>&1
  if exist "%folder%" (
    takeown /f "%folder%" /r /d y
    echo y|cacls "%folder%" /g "%username%":f
    rd /S /Q "%folder%"
  ) 1>nul 2>&1
  if exist "%folder%" (
    rd /S /Q "\\?\%folder%"
  ) 1>nul 2>&1
exit /b

:IsEmptyFolder
  :: �㭪��, ����� �஢����, ���� �� �����
  :: %1-��.��ࠬ��� - �஢��塞�� �����
  :: errorlevel 0 - �����, 1 - ���� 䠩��, 2 - ���� ��⠫���, 3 - ���� ��⠫��� � 䠩��
  set EF_Flag=0
  set EF_Cur_Flag=0
  for /f "delims=" %%A in ('dir /B /A:D "%~1\*"') do set EF_Cur_Flag=2
  set /A EF_Flag=%EF_Flag% "|" %EF_Cur_Flag%
  for /f "delims=" %%A in ('dir /B /A:-D "%~1\*"') do set EF_Cur_Flag=1
  set /A EF_Flag=%EF_Flag% "|" %EF_Cur_Flag%
Exit /B %EF_Flag%

:GetEmptyName %1-Folder %2-FileName %3-Var.Return %4-Optional.System.Num
  :: �㭪�� ����祭�� ᢮������� ����� 䠩�� � ���� ����᪨ ���� � ᪮����
  Set "Num=%~4"
  if "%~4"=="" (
      Set "NewFileName=%~2"
      Set Num=1
    ) else (
      Set "NewFileName=%~n2 (%~4)%~x2"
  )
  if exist "%~1\%NewFileName%" (
      Set /A Num+=1
      Call Call :GetEmptyName "%~1" "%~2" "%~3" "%%Num%%"
    ) else (
      Set "%~3=%NewFileName%"
      (if "%~4"=="" (echo 0) else (echo %~4))>>"%Q2%"
      Exit /B
  )
Exit /B