@echo off
setlocal enabledelayedexpansion
CHCP 65001 >nul

REM Проверка аргумента --elevated
set elevated=false
for %%i in (%*) do (
    if "%%~i"=="--elevated" set elevated=true
)

REM Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    if not "!elevated!"=="true" (
        powershell -Command "Start-Process '%~f0' -ArgumentList '--elevated' -Verb RunAs"
        exit /b
    )
)

REM Основное меню
:MENU
cls
echo.
echo =========================================================
echo   Выберите действие:
echo =========================================================
echo.
echo   1. Создать ярлык OBS (запуск без прав администратора)
echo   2. Создать ярлык OBS (запуск с правами администратора)
echo   3. Настроить автозапуск OBS при входе (без прав администратора)
echo   4. Настроить автозапуск OBS при входе (с правами администратора)
echo   5. Удалить автозапуск OBS
echo   6. Выход
echo.
set /p "choice=Введите номер опции (1-6): "
if "%choice%"=="1" goto CREATE_SHORTCUT_USER
if "%choice%"=="2" goto CREATE_SHORTCUT_ADMIN
if "%choice%"=="3" goto SETUP_AUTOSTART_USER
if "%choice%"=="4" goto SETUP_AUTOSTART_ADMIN
if "%choice%"=="5" goto REMOVE_AUTOSTART
if "%choice%"=="6" exit
echo Неверный ввод. Пожалуйста, введите число от 1 до 6.
pause
goto MENU

:CREATE_SHORTCUT_USER
cls
echo.
echo =========================================================
echo   Создание ярлыка OBS (без прав администратора)
echo =========================================================
echo.
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "if (Test-Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers') {Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name '%~dp0bin\64bit\obs64.exe' -ErrorAction SilentlyContinue};" ^
    "$WshShell = New-Object -ComObject WScript.Shell;" ^
    "$Shortcut = $WshShell.CreateShortcut('%~dp0OBS.lnk');" ^
    "$Shortcut.TargetPath = '%~dp0bin\64bit\obs64.exe';" ^
    "$Shortcut.Arguments = '--minimize-to-tray --disable-updater --disable-shutdown-check --disable-missing-files-check';" ^
    "$Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName('%~dp0bin\64bit\obs64.exe');" ^
    "$Shortcut.IconLocation = '%~dp0bin\64bit\obs64.exe';" ^
    "$Shortcut.Save()"
echo Ярлык создан.
pause
goto MENU

:CREATE_SHORTCUT_ADMIN
cls
echo.
echo =========================================================
echo   Создание ярлыка OBS (с правами администратора)
echo =========================================================
echo.
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "New-Item -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Force | Out-Null;" ^
    "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name '%~dp0bin\64bit\obs64.exe' -Value 'RUNASADMIN';" ^
    "$WshShell = New-Object -ComObject WScript.Shell;" ^
    "$Shortcut = $WshShell.CreateShortcut('%~dp0OBS.lnk');" ^
    "$Shortcut.TargetPath = '%~dp0bin\64bit\obs64.exe';" ^
    "$Shortcut.Arguments = '--minimize-to-tray --disable-updater --disable-shutdown-check --disable-missing-files-check';" ^
    "$Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName('%~dp0bin\64bit\obs64.exe');" ^
    "$Shortcut.IconLocation = '%~dp0bin\64bit\obs64.exe';" ^
    "$Shortcut.Save()"
echo Ярлык с запуском от администратора создан.
pause
goto MENU

:SETUP_AUTOSTART_USER
cls
echo.
echo ====================================================================
echo   Настройка автозапуска OBS при входе (без прав администратора)
echo ====================================================================
echo.
schtasks /Create /TN "OBS (Max.mov) Autostart.bat" /TR "\"%~dp0\bin\64bit\OBS (Max.mov) Autostart.bat\"" /SC ONLOGON /F
echo Автозапуск настроен.
pause
goto MENU

:SETUP_AUTOSTART_ADMIN
cls
echo.
echo ====================================================================
echo   Настройка автозапуска OBS при входе (с правами администратора)
echo ====================================================================
echo.
schtasks /Create /TN "OBS (Max.mov) Autostart.bat" /TR "\"%~dp0\bin\64bit\OBS (Max.mov) Autostart.bat\"" /SC ONLOGON /RL HIGHEST /F
echo Автозапуск с правами администратора настроен.
pause
goto MENU

:REMOVE_AUTOSTART
cls
echo.
echo =========================================================
echo   Удаление автозапуска OBS
echo =========================================================
echo.
schtasks /Delete /TN "OBS (Max.mov) Autostart.bat" /F
echo Автозапуск удалён.
pause
goto MENU