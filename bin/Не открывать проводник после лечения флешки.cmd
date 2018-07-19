@echo off
SetLocal

set "Marker=%AppData%\AntiHidden\OpenExplorer.txt"

echo.
echo Опции AntiHidden.
echo.

if exist "%Marker%" (
  del /F /A "%Marker%"
  echo AntiHidden теперь настроен, чтобы не открывать окно проводника после лечения.
) else (
  set /p "="<NUL>"%Marker%"
  echo AntiHidden теперь настроен, чтобы открывать окно проводника сразу после лечения.
)
echo.
pause
