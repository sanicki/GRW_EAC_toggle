@echo off
REM ## GRW EAC Toggle Script

REM --- Configuration Variables ---
set "TOGGLE_DIR=GRW_EAC_toggle"
set "BACKUP_DIR=%TOGGLE_DIR%\backups"
set "UID_FILE=%TOGGLE_DIR%\UIDs.txt"
set "DLL_X86=EasyAntiCheat_x86.dll"
set "DLL_X64=EasyAntiCheat_x64.dll"
set "HASH_ALGO=SHA256"

REM Enable delayed expansion for runtime variable changes inside loops/blocks
setlocal EnableDelayedExpansion

REM --- Error Handling Subroutine ---
:ERROR_RESET
echo.
echo An error occurred. EAC has been reset to ENABLED. Exiting.
REM Copy original files from backup to current directory
copy /Y "%BACKUP_DIR%\%DLL_X86%" "%~dp0" >nul
copy /Y "%BACKUP_DIR%\%DLL_X64%" "%~dp0" >nul
endlocal
goto :EOF

REM --- Check for First Run Setup ---
if not exist "%UID_FILE%" goto :FIRST_RUN
goto :DAILY_RUN

REM #######################################
REM ## FIRST RUN: Setup and UID Recording ##
REM #######################################
:FIRST_RUN
echo --- First Run Setup Initiated ---

REM 1. Create subfolder and backup directory
mkdir "%BACKUP_DIR%" 2>nul || (echo Failed to create directories. Exiting. & endlocal & exit /b 1)
echo Created directory: %TOGGLE_DIR%

REM Check if DLLs exist before proceeding
if not exist "%DLL_X86%" (echo Error: Missing %DLL_X86%. Exiting. & endlocal & exit /b 1)
if not exist "%DLL_X64%" (echo Error: Missing %DLL_X64%. Exiting. & endlocal & exit /b 1)

REM 2. Generate and record unique identifiers (UIDs)
echo Generating UIDs...
(
    REM Record x86 UID
    for /f "tokens=2 skip=1" %%i in ('certutil -hashfile "%DLL_X86%" %HASH_ALGO%') do (
        echo x86=%%i
    )
    REM Record x64 UID
    for /f "tokens=2 skip=1" %%i in ('certutil -hashfile "%DLL_X64%" %HASH_ALGO%') do (
        echo x64=%%i
    )
) > "%UID_FILE%"

if errorlevel 1 goto :ERROR_RESET
echo UIDs recorded in %UID_FILE%

REM 3. Copy files to backups directory
copy /Y "%DLL_X86%" "%BACKUP_DIR%" >nul || goto :ERROR_RESET
copy /Y "%DLL_X64%" "%BACKUP_DIR%" >nul || goto :ERROR_RESET
echo Original files backed up.

echo --- Setup Complete. Now running the daily check. ---
goto :DAILY_RUN

REM #######################################
REM ## DAILY RUN: Check, Prompt, and Toggle ##
REM #######################################
:DAILY_RUN
REM Ensure DLLs exist
if not exist "%DLL_X86%" goto :ERROR_RESET
if not exist "%DLL_X64%" goto :ERROR_RESET

REM Load UIDs from file
for /f "delims=" %%i in (%UID_FILE%) do (
    set %%i
)

REM 1. Check current DLL status by generating current hashes
for /f "tokens=2 skip=1" %%i in ('certutil -hashfile "%DLL_X86%" %HASH_ALGO%') do set "CURRENT_X86_HASH=%%i"
for /f "tokens=2 skip=1" %%i in ('certutil -hashfile "%DLL_X64%" %HASH_ALGO%') do set "CURRENT_X64_HASH=%%i"

REM Check if files match recorded UIDs (x86 and x64 must both match or both not match)
if "!CURRENT_X86_HASH!"=="!x86!" (set "X86_MATCH=1") else (set "X86_MATCH=0")
if "!CURRENT_X64_HASH!"=="!x64!" (set "X64_MATCH=1") else (set "X64_MATCH=0")

REM 2. Check for mixed state
if "!X86_MATCH!" neq "!X64_MATCH!" (
    echo.
    echo There is a problem with your DLLs. Please restore the original files from the backups folder to continue.
    endlocal
    exit /b 1
)

if "!X86_MATCH!" equ "1" (
    set "CURRENT_STATE=ENABLED"
    set "NEXT_STATE=DISABLED"
    set "CURRENT_EXT="
    set "NEXT_EXT=.disable"
    set "TOGGLE_OP=DISABLE"
) else (
    set "CURRENT_STATE=DISABLED"
    set "NEXT_STATE=ENABLED"
    set "CURRENT_EXT=.disable"
    set "NEXT_EXT=.enable"
    set "TOGGLE_OP=ENABLE"
)

REM 3. Prompt the user
echo.
set /p "CHOICE=EAC is currently !CURRENT_STATE!. Do you want to toggle it to !NEXT_STATE!? (Y/n): "

REM 4. Check user input
if /i not "!CHOICE!"=="y" if defined CHOICE (
    echo EAC remains !CURRENT_STATE!. Exiting.
    endlocal
    exit /b 0
)

REM 5. User wants to proceed

REM 6. Rename current DLLs to prepare for toggle
REM Renames must succeed or we go to error state
ren "%DLL_X86%" "%DLL_X86%!CURRENT_EXT!" || goto :ERROR_RESET
ren "%DLL_X64%" "%DLL_X64%!CURRENT_EXT!" || goto :ERROR_RESET
if not exist "%DLL_X86%!CURRENT_EXT!" goto :ERROR_RESET
if not exist "%DLL_X64%!CURRENT_EXT!" goto :ERROR_RESET

REM 7. Copy the disabled/enabled files from backup to toggle state
REM Copy files from backup and rename them to the required new extension (.enable/.disable)
copy /Y "%BACKUP_DIR%\%DLL_X86%" "%DLL_X86%!NEXT_EXT!" >nul || goto :ERROR_RESET
copy /Y "%BACKUP_DIR%\%DLL_X64%" "%DLL_X64%!NEXT_EXT!" >nul || goto :ERROR_RESET

REM Apply the toggle by copying the newly prepared files back to the current DLL names
copy /Y "%DLL_X86%!NEXT_EXT!" "%DLL_X86%" >nul || goto :ERROR_RESET
copy /Y "%DLL_X64%!NEXT_EXT!" "%DLL_X64%" >nul || goto :ERROR_RESET

REM Cleanup the files that are not the current state's source (the opposite toggle files)
del "%DLL_X86%!CURRENT_EXT!" 2>nul
del "%DLL_X64%!CURRENT_EXT!" 2>nul
del "%DLL_X86%!NEXT_EXT!" 2>nul
del "%DLL_X64%!NEXT_EXT!" 2>nul


REM 9. Success message
echo.
echo EAC has been successfully been toggled to !NEXT_STATE!. Exiting.
endlocal
exit /b 0
