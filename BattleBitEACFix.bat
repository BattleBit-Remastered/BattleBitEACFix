:: https://github.com/livingflore/BattleBitEACFix
:: if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit ) 
@echo off & setlocal
if _%1_==_payload_  goto :payload
:getadmin
    echo %~nx0: elevating self
    set vbs=%temp%\getadmin.vbs
    echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
    echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 1 >> "%vbs%"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
goto :eof
:payload

title BattleBit EAC Fix >nul
echo [7m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@PPPP@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@^&G    G^&@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@P      P@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@?^^      ^^?@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@^^        ^^@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@^^        ^^@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@^^        ^^@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@5          5@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@J          J@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@Y          Y@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@B:        :B@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@5~~~~~~~~~~5@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@[0m
echo.
echo Hi. This batch will reinstall EAC and install VCRedist 2015-2022 x86-64.
pause
cls

echo [91m
set GamePath=
if exist "%~dp0\BattleBit.exe" SET GamePath="%~dp0"
for /F "tokens=2* skip=2" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 671860" /v "InstallLocation"') do set GamePath="%%b"
if defined GamePath (
   echo [0m[94m[...][0m Game Path: %GamePath%
) else (
   echo [91m[X][0m Unable to detect BattleBit Remastered folder. Please install the game first, then run this batch script.
   echo If BattleBit is already installed, try running this batch script from the game folder:
   echo Right click on the game in Steam ^> Manage ^> Browse local files.
   pause
   goto :eof
)
echo [94m[...][0m Closing EAC and BattleBit
2>>"%temp%\BattleBitEACFix.log" 1>nul ( 
   taskkill /f /im BattleBit.exe
   taskkill /f /im BattleBitEAC.exe
   taskkill /f /im EasyAntiCheat.exe
   taskkill /f /im EasyAntiCheat_EOS_Setup.exe
   taskkill /f /im UnityCrashHandler64.exe
)
echo [94m[...][0m Removing EAC Service[91m
%GamePath%\EasyAntiCheat\EasyAntiCheat_EOS_Setup.exe uninstall 43ed9a4620fa486994c0b368cce73b5d
%GamePath%\EasyAntiCheat\EasyAntiCheat_EOS_Setup.exe qa-factory-reset
sc delete EasyAntiCheat_EOS 2>>"%temp%\BattleBitEACFix.log" 1>nul

echo [94m[...][0m Removing EAC folders
rmdir /q /s "C:\Program Files (x86)\EasyAntiCheat_EOS" 2>>"%temp%\BattleBitEACFix.log" 1>nul
rmdir /s /q "%appdata%\EasyAntiCheat\43ed9a4620fa486994c0b368cce73b5d" 2>>"%temp%\BattleBitEACFix.log" 1>nul

Echo [94m[...][0m Removing EAC registry entry
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\EasyAntiCheat_EOS" /f 2>>"%temp%\BattleBitEACFix.log" 1>nul

echo [94m[...][0m Installing EAC[91m
%GamePath%\EasyAntiCheat\EasyAntiCheat_EOS_Setup.exe install 43ed9a4620fa486994c0b368cce73b5d

echo [94m[...][0m Switching EAC service mode to automatic
sc config EasyAntiCheat_EOS start=Auto 2>>"%temp%\BattleBitEACFix.log" 1>nul

echo [94m[...][0m Adding EAC ^& BattleBit Folder to Windows Defender exclusions
powershell -Command Add-MpPreference -ExclusionPath '%GamePath%' 2>>"%temp%\BattleBitEACFix.log" 1>nul
powershell -Command Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\EasyAntiCheat_EOS' 2>>"%temp%\BattleBitEACFix.log" 1>nul

echo [94m[...][0m Adding EAC ^& BattleBit executables to Defender Firewall exclusions
powershell -Command New-NetFirewallRule -Program '%GamePath%\BattleBit.exe' -Action Allow -Profile Domain, Private -DisplayName 'Allow BattleBit' -Direction Outbound 2>>"%temp%\BattleBitEACFix.log" 1>nul
powershell -Command New-NetFirewallRule -Program '%GamePath%\EasyAntiCheat.exe' -Action Allow -Profile Domain, Private -DisplayName 'Allow BattleBit EAC' -Direction Outbound 2>>"%temp%\BattleBitEACFix.log" 1>nul
powershell -Command New-NetFirewallRule -Program 'C:\Program Files (x86)\EasyAntiCheat_EOS\EasyAntiCheat_EOS.exe' -Action Allow -Profile Domain, Private -DisplayName 'Allow EAC_EOS' -Direction Outbound 2>>"%temp%\BattleBitEACFix.log" 1>nul

echo.
echo [32m[+][0m EAC reinstall completed.
echo.

echo [94m[...][0m Flushing DNS
ipconfig /flushdns 2>>"%temp%\BattleBitEACFix.log" 1>nul
echo [94m[...][0m Testing EAC Connection
echo download.eac-cdn.com:
curl download.eac-cdn.com --max-time 10
echo.
echo download-alt.easyanticheat.net:
curl download-alt.easyanticheat.net --max-time 10
echo.

echo.
echo [94m[...][0m Installing VCRedist 2015-2022 x86-64
echo.

echo [94m[...][0m Downloading VC_redist.x64
curl -L https://aka.ms/vs/17/release/vc_redist.x64.exe --output "%temp%\VC_redist.x64.exe" --write-out "%errorlevel%" --progress-bar 1>nul
if %errorlevel% EQU 00 goto install64

echo [33m[?][0m Unable to use curl, switching to bitsadmin instead...
for /f %%I in ('bitsadmin /rawreturn /create %random%') do set "dljob=%%~I"
set "signal=%dljob:~-13,-1%"
for %%I in (waitfor.exe) do set "waitfor=%%~$PATH:I"
>nul (
    bitsadmin /setnotifycmdline %dljob% "%waitfor%" "%waitfor% /s %computername% /si %signal%"
    bitsadmin /addfile %dljob% "https://aka.ms/vs/17/release/vc_redist.x64.exe" "%temp%\VC_redist.x64.exe"
    bitsadmin /setpriority %dljob% FOREGROUND
    start /b "" bitsadmin /resume %dljob%
    waitfor /t 100 %signal%
)
for /f %%I in ('bitsadmin /rawreturn /geterrorcount %dljob%') do cmd /c exit /b %%I && (
    bitsadmin /complete %dljob% >nul
    goto install64
) || (
    bitsadmin /geterror %dljob% >>"%temp%\BattleBitEACFix.log"
    bitsadmin /complete %dljob% >nul
)
echo [31m[!][0m VC_redist.x64 - download failed ^:^(
echo [31m[!][0m Please, download and install VC_redist.x64.exe manually - https://aka.ms/vs/17/release/vc_redist.x64.exe
goto endinstall64

:install64
echo [94m[...][0m Installing VC_redist.x64.exe ^(might take a bit^)
%temp%\VC_redist.x64.exe /install /quiet /norestart
if ERRORLEVEL 0 (
   echo [32m[+][0m VC_redist.x64.exe installed successfully!
) else (
   echo [31m[!][0m VC_redist.x64.exe install failed with code: %ERRORLEVEL%
   echo [31m[!][0m Please, download and install VC_redist.x64.exe manually - https://aka.ms/vs/17/release/vc_redist.x64.exe
)
del %temp%\VC_redist.x64.exe
:endinstall64
echo.

echo [94m[...][0m Downloading VC_redist.x86
curl -L https://aka.ms/vs/17/release/vc_redist.x86.exe --output "%temp%\VC_redist.x86.exe" --write-out "%errorlevel%" --progress-bar 1>nul
if %errorlevel% EQU 00 goto install86

echo [33m[?][0m Unable to use curl, switching to bitsadmin instead...
for /f %%I in ('bitsadmin /rawreturn /create %random%') do set "dljob=%%~I"
set "signal=%dljob:~-13,-1%"
for %%I in (waitfor.exe) do set "waitfor=%%~$PATH:I"
>nul (
    bitsadmin /setnotifycmdline %dljob% "%waitfor%" "%waitfor% /s %computername% /si %signal%"
    bitsadmin /addfile %dljob% "https://aka.ms/vs/17/release/vc_redist.x86.exe" "%temp%\VC_redist.x86.exe"
    bitsadmin /setpriority %dljob% FOREGROUND
    start /b "" bitsadmin /resume %dljob%
    waitfor /t 100 %signal%
)
for /f %%I in ('bitsadmin /rawreturn /geterrorcount %dljob%') do cmd /c exit /b %%I && (
    bitsadmin /complete %dljob% >nul
    goto install86
) || (
    bitsadmin /geterror %dljob% >>"%temp%\BattleBitEACFix.log"
    bitsadmin /complete %dljob% >nul
)
echo [31m[!][0m VC_redist.x86 - download failed ^:^(
echo [31m[!][0m Please, download and install VC_redist.x86.exe manually - https://aka.ms/vs/17/release/vc_redist.x86.exe
goto endinstall86

:install86
echo [94m[...][0m Installing VC_redist.x86.exe ^(might take a bit^)
%temp%\VC_redist.x86.exe /install /quiet /norestart
if ERRORLEVEL 0 (
   echo [32m[+][0m VC_redist.x86.exe installed successfully!
) else (
   echo [31m[!][0m VC_redist.x86.exe install failed with code: %ERRORLEVEL%
   echo [31m[!][0m Please, download and install VC_redist.x86.exe manually - https://aka.ms/vs/17/release/vc_redist.x86.exe
)
del %temp%\VC_redist.x86.exe
:endinstall86
echo.
echo [32m[+][0m Finished!
echo.
echo [93m=============================================================================
echo NOTICE: Make sure to screenshot any errors above and provide them 
echo in related Discord thread or conversation with BattleBit support.
echo You might need to run "Install & Repair Easy Anti Cheat" launch option
echo before running BattleBit itself.
echo =============================================================================[0m
echo.
CHOICE /C YN /M "Do you want to reboot your PC (recommended)"

IF %ERRORLEVEL% EQU 1 (
    setlocal enabledelayedexpansion
    for /l %%i in (10,-1,1) do (
        cls
        echo.
        echo Rebooting in %%i seconds...
        echo.
        title Rebooting in %%i seconds...
        timeout /t 1 /nobreak > nul
    )
    shutdown /r /f /t 0
) ELSE IF %ERRORLEVEL% EQU 2 (
    echo.
    echo [31m[!][0m Rebooting your PC is highly recommended, do it before opening BattleBit.
)
echo.
pause
