@echo off
SetLocal

set "Marker=%AppData%\AntiHidden\OpenExplorer.txt"

echo.
echo ��樨 AntiHidden.
echo.

if exist "%Marker%" (
  del /F /A "%Marker%"
  echo AntiHidden ⥯��� ����஥�, �⮡� �� ���뢠�� ���� �஢������ ��᫥ ��祭��.
) else (
  set /p "="<NUL>"%Marker%"
  echo AntiHidden ⥯��� ����஥�, �⮡� ���뢠�� ���� �஢������ �ࠧ� ��᫥ ��祭��.
)
echo.
pause
