@echo off
setlocal

set "DIR=%~dp0"
set "X64=%DIR%EasyAntiCheat_x64.dll"
set "X86=%DIR%EasyAntiCheat_x86.dll"
set "X64_BAK=%DIR%EasyAntiCheat_x64.dll.bak"
set "X86_BAK=%DIR%EasyAntiCheat_x86.dll.bak"
set "X64_DUMMY=%DIR%EasyAntiCheat_x64.dll.disable"
set "X86_DUMMY=%DIR%EasyAntiCheat_x86.dll.disable"

REM -------------------------------------------------------
REM Check that the dummy files are present before doing anything
REM -------------------------------------------------------
if not exist "%X64_DUMMY%" (
    echo Error: EasyAntiCheat_x64.dll.disable not found.
    echo Make sure this script is in the EasyAntiCheat folder alongside the dummy files.
    echo.
    pause
    exit /b 1
)
if not exist "%X86_DUMMY%" (
    echo Error: EasyAntiCheat_x86.dll.disable not found.
    echo Make sure this script is in the EasyAntiCheat folder alongside the dummy files.
    echo.
    pause
    exit /b 1
)

REM -------------------------------------------------------
REM Detect state: if .bak files exist, EAC is currently disabled
REM -------------------------------------------------------
if exist "%X64_BAK%" (
    echo EAC is currently DISABLED.
    echo Re-enabling EAC...
    echo.
    copy /Y "%X64_BAK%" "%X64%" >nul || goto :ERROR
    copy /Y "%X86_BAK%" "%X86%" >nul || goto :ERROR
    del "%X64_BAK%" >nul
    del "%X86_BAK%" >nul
    echo Done! EAC is now ENABLED.
    echo You can play normally again.
) else (
    echo EAC is currently ENABLED.
    echo Disabling EAC for Linux co-op...
    echo.
    copy /Y "%X64%" "%X64_BAK%" >nul || goto :ERROR
    copy /Y "%X86%" "%X86_BAK%" >nul || goto :ERROR
    copy /Y "%X64_DUMMY%" "%X64%" >nul || goto :ERROR
    copy /Y "%X86_DUMMY%" "%X86%" >nul || goto :ERROR
    echo Done! EAC is now DISABLED.
    echo You can now play co-op with your Linux friend.
)

echo.
pause
exit /b 0

REM -------------------------------------------------------
:ERROR
echo.
echo Something went wrong! Restoring original EAC files...
if exist "%X64_BAK%" copy /Y "%X64_BAK%" "%X64%" >nul
if exist "%X86_BAK%" copy /Y "%X86_BAK%" "%X86%" >nul
echo Originals restored. Please check the EasyAntiCheat folder and try again.
echo.
pause
exit /b 1
