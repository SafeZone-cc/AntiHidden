@echo off
:begin
Setlocal DisableDelayedExpansion EnableExtensions
if %errorlevel% neq 0 (
  echo Системная ошибка
  echo Программа будет закрыта...
  ping -n 2 127.1 >NUL
  goto :eof
)
mode con: cols=82 lines=30

set version=1.10
set upd=01.09.2016

title AntiHidden - Удаление последствий вирусной деятельности на съемном накопителе ver.%version%

:: К подозрительным файлам относятся:
:: game.cpl
:: system
:: *.lnk (только те, чьи имена соответствуют названиям папок и кроме ярлыков на рабочем столе)
:: Все *.init
:: desktop.ini
::
:: К подозрительным папкам относятся:
:: Папка с символом 0xA0 (все содержимое папки будет перенесено в корневой каталог)
:: recycled
:: recycler
:: System Volume Information
Set "_CharA0_= "

color 1B
echo.
echo                         ---- AntiHidden -----
echo               Удаление последствий вирусной деятельности 
echo                         на съемном накопителе
echo.
echo                                                (c) Created by Polshyn Stanislav
echo.
echo                                                          [ http://SafeZone.cc ]
echo.
echo                                                                      %upd%
echo                                                                         ver.%version%
echo   Этап 1. Возобновление свойств корневых папок.
echo   - не "Скрытый"
echo   - не "Системный"
echo   + стать владельцем
echo   + предоставить полные права
rem echo   Для ускорения операции можно временно отключить антивирусное ПО.

:: Проверка, не запущен ли на рабочем столе
for %%i in ("%~f0\..") do set "curFolderName=%%~nxi"
if /i "%curFolderName%"=="Desktop" set "isDesktop=true"
if /i "%curFolderName%"=="Рабочий стол" set "isDesktop=true"
if "%isDesktop%"=="true" (
  echo.
  echo ВНИМАНИЕ. Запускать утилиту можно только, скопировав ее на флешку.
  echo.& pause& Exit /B
)
if /i "%curFolderName%" neq "" (
  echo.
  echo.
  echo  ВНИМАНИЕ! Программа запущена не из основной папки диска.
  echo  Сперва скопируйте ее на флешку ^(в корень^).
  echo  Затем запустите.
  echo.
  call :Dialogue "Вы точно уверены, что хотите продолжить именно в этой папке? (Y/N) (Д/Н) "
  if not errorlevel 1 Exit /B
)

Set Cur=%~dp0
Set Cur=%Cur:~0,-1%

chcp 1251 >nul
for /f "delims=" %%i in ('dir "%Cur%" /b /a:dh 2^>nul') do attrib -s -h "%Cur%\%%i" 1>nul 2>&1& Call :RecovFolder "%Cur%\%%i"
for /f "delims=" %%i in ('dir "%Cur%" /b /a:ds 2^>nul') do attrib -s -h "%Cur%\%%i" 1>nul 2>&1& Call :RecovFolder "%Cur%\%%i"
chcp 866 >nul

echo.
echo   Этап 2. Удаление лишних ярлыков.

::Удаление только ярлыков, имена которых соответствуют именам папок
for /f "delims=" %%i in ('dir "%Cur%" /b /a:d') do if exist "%Cur%\%%i.lnk" (
  attrib -s -h "%Cur%\%%i.lnk" 1>nul 2>&1
  del /F /A /Q "%Cur%\%%i.lnk" 1>nul 2>&1
  call :killfile "%Cur%\%%i.lnk"
)

echo   Этап 4. Удаление файла автозапуска.
if not exist "%Cur%\autorun.inf\" if exist "%Cur%\autorun.inf" call :killfile "%Cur%\autorun.inf"

echo   Этап 5. Удаление модифицированных системных папок и инородных файлов.
for %%a in ("recycled" "System Volume Information") do (
  if exist "%Cur%\%%~a\" Call :KillFolder "%Cur%\%%~a")
) 1>nul 2>&1
if exist "%Cur%\recycler\" (
  echo   Найдена папка Recycler. Продолжить удаление корзины Windows для тома %~d0 ? 
  rem call :Dialogue "Нажмите 'Y' и кнопку {ENTER} "
  rem if errorlevel 1 
  Call :KillFolder "%Cur%\recycler"
)

for %%b in (game.cpl system *.init desktop.ini Thumbs.db) do for /F "delims=" %%a in ('2^>nul dir "%Cur%\%%b" /b /a:-d') do (
  echo.
  echo Найден подозрительный файл - %%a. 
  rem call :Dialogue "Для удаления нажмите 'Y' и кнопку {ENTER} "
  rem if errorlevel 1 
  call :KillFile "%Cur%\%%a"
)

goto SKIP_Host
echo.
color 1b
echo   Этап 5.1. Поиск и обезвреживание процесса host.exe. Пожалуйста, подождите...
tasklist |1>nul 2>&1 FindStr /B /L /I /C:host.exe && (
  Echo   В системе запущен подозрительный процесс Host.exe
  call :Dialogue "Завершить его? - нажмите 'Y' и {ENTER}"
  if errorlevel 1 (
    taskkill /im "host.exe" /t /f
    Echo   Все файлы с именем Host.exe будут удалены с носителя %~dp0%.
    call :Dialogue "Чтобы продолжить нажмите 'Y' и {ENTER}"
    if errorlevel 1 for /f "tokens=*" %%a in ('Dir /b /s /a:-d "%Cur%\host.exe"') Do Call :KillFile "%Cur%\%%a"
  )
)
:SKIP_Host

color 1a
echo   Этап 6. Создание защитного файла автозапуска, который не удаляется штатно.
if not exist "%Cur%\autorun.inf\" mkdir "%Cur%\autorun.inf" 1>nul 2>&1
if not exist "%Cur%\autorun.inf\Защищено AntiHidden by Dragokas..\" mkdir "%Cur%\autorun.inf\Защищено AntiHidden by Dragokas..\" 1>nul 2>&1
if not exist "%Cur%\autorun.inf\com1\" mkdir "\\?\%Cur%\autorun.inf\com1" 1>nul 2>&1
if not exist "%Cur%\autorun.inf\defence" (
  mkdir "%Cur%\autorun.inf\defence" 1>nul 2>&1
  echo y|1>nul 2>&1 cacls "%Cur%\autorun.inf\defence" /d Все
  echo y|1>nul 2>&1 cacls "%Cur%\autorun.inf\defence" /d All
)

if Defined Skip_Bundpil goto Bundpil_ext

echo   Этап 8. Перенос данных со скрытого каталога.
set "TempName=_AntiHidden - Ваши файлы"
if exist "%Cur%\%_CharA0_%" (
  Echo Обнаружена нивидимая папка.
  attrib -R -S -H "%Cur%\%_CharA0_%"
  Echo Переименовую скрытую папку в имя %TempName%
  if exist "%Cur%\%_CharA0_%" ren "%Cur%\%_CharA0_%" "%TempName%"
  if errorlevel 1 (
    echo Не могу переименовать. Возможно на диске содержатся ошибки.
    echo Желаете провести проверку?
    call :Dialogue "Для продолжения нажмите 'Y' и кнопку {ENTER} "
    if errorlevel 1 (
      chkdsk %Cur% /F
      echo Попытка 2. Переименовую скрытую папку в имя %TempName%
      if exist "%Cur%\%_CharA0_%" ren "%Cur%\%_CharA0_%" "%TempName%"
      if errorlevel 1 (
        Echo Неудача.
        Echo Возможно папка открыта либо заблокирована другой программой.
        Echo Снимите блокировку и перезапустите утилиту.
        Goto Bundpil_ext
      )
    ) else (
      Goto Bundpil_ext
    )
  )
  Echo Начинаю перенос файлов в корневой каталог.
  Echo Не прерывайте данный процесс.
  if exist "%Cur%\%TempName%\autorun.inf\" (
    RD /s /q "\\?\%Cur%\%TempName%\autorun.inf\com1"
    echo y|cacls %Cur%\%TempName%\autorun.inf\defence /g "%username%":f
    RD /s /q "\\?\%Cur%\%TempName%\autorun.inf"
  )
  for /f "delims=" %%F in ('dir /B /A "%Cur%\%TempName%\*"') do (
    attrib -R -S -H "%Cur%\%TempName%\%%F"
    if exist "%Cur%\%%~nxF" (
      rem Если это копия текущего скрипта - спокойно удаляем
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
    echo Часть файлов и/или папок не была перенесена, т.к. они уже существуют в корне носителя.
    echo Сделайте это вручную. Оставшиеся файлы находятся в папке %TempName%
    start "" "%Cur%\%TempName%"
    echo.
    pause
  ) else (
    rd "%Cur%\%TempName%"
  )
  EndLocal& set Skip_Bundpil=true& Goto begin
)
:Bundpil_ext

echo   Этап 9. Переименование *.LNK в *.LNK_ (Anti Stuxnet)
ren "%Cur%\*.LNK" *.LNK_ 2>NUL

color 1A
echo.
echo   Лечение завершено.
ping -n 3 localhost 1>nul 2>&1
color
goto :eof

:Dialogue
  set "ch="
  set /p "ch=%~1"
  if /i "%ch%"=="Y" Exit /B 1
  if /i "%ch%"=="Д" Exit /B 1
  if /i "%ch%"=="N" Exit /B 0
  if /i "%ch%"=="Н" Exit /B 0
  echo Ошибка ввода!
  echo Введите букву Д или Y, затем нажмите ENTER (чтобы ответить ДА).
  echo Введите букву Н или N, затем нажмите ENTER (чтобы ответить НЕТ).
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
  :: Функция, которая проверяет, пуста ли папка
  :: %1-вх.параметр - проверяемая папка
  :: errorlevel 0 - пустая, 1 - есть файлы, 2 - есть каталоги, 3 - есть каталоги и файлы
  set EF_Flag=0
  set EF_Cur_Flag=0
  for /f "delims=" %%A in ('dir /B /A:D "%~1\*"') do set EF_Cur_Flag=2
  set /A EF_Flag=%EF_Flag% "|" %EF_Cur_Flag%
  for /f "delims=" %%A in ('dir /B /A:-D "%~1\*"') do set EF_Cur_Flag=1
  set /A EF_Flag=%EF_Flag% "|" %EF_Cur_Flag%
Exit /B %EF_Flag%

:GetEmptyName %1-Folder %2-FileName %3-Var.Return %4-Optional.System.Num
  :: Функция получение свободного имени файла в виде дописки цифры в скобках
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