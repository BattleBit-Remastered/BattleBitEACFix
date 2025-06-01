@echo off & setlocal EnableDelayedExpansion
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
title BattleBit Logs Collector >nul
:: i hate onedrive
set Logs=C:\Users\Public\Desktop\BattleBit Logs
if not exist "%Logs%" ( if not exist "%Logs%.zip" goto :start )
echo [91m[X][0m BattleBit Logs folder or BattleBit Logs.zip already exists on your desktop. 
echo Please send it to BattleBit representative in order to get support.
echo.
pause
goto :eof
:start
echo [94m[...][0m Creating BattleBit Logs folder on your desktop
mkdir "%Logs%" >nul
mkdir "%Logs%\Dumps" >nul
mkdir "%Logs%\EAC" >nul
echo [94m[...][0m Copying game logs
xcopy /i "C:\Users\%username%\AppData\LocalLow\BattleBitDevTeam\BattleBit\" "%Logs%\" >nul
echo [94m[...][0m Copying EAC logs
copy /y "%appdata%\EasyAntiCheat\anticheatlauncher.log" "%Logs%\EAC" >nul
copy /y "%appdata%\EasyAntiCheat\service.log" "%Logs%\EAC" >nul
copy /y "%appdata%\EasyAntiCheat\43ed9a4620fa486994c0b368cce73b5d\315826d981f4480aa6155e32d71b0d3b\loader.log" "%Logs%\EAC" >nul
copy /y "%temp%\BattleBitEACFix.log" "%Logs%\EAC" >nul
echo [94m[...][0m Creating msinfo32 dump
msinfo32 /report "%Logs%\msinfo32.txt" >nul
echo [94m[...][0m Creating dxdiag dump
dxdiag /dontskip /t "%Logs%\dxdiag.txt" >nul
echo [94m[...][0m Copying crash dumps

set BigDumpCollected=0
:: Max size considering compressing (0.7)
set MaxDumpSize=46215620 
set MaxTotalSize=209715200
set TotalDumpSize=0
set SkippedDumps=""

for /R "C:\Users\%username%\AppData\Local\CrashDumps" %%F in (*BattleBit*.dmp *EasyAntiCheat*.dmp) do (
  set FileSize="%%~zF"
  set /a "NewTotalSize=!TotalDumpSize!+!FileSize!"
  
  if !NewTotalSize! GTR !MaxTotalSize! (
    set /a "SkippedDumps+=%%~nxF "
  ) else (
    if %BigDumpCollected%==0 (
      if !FileSize! GTR !MaxDumpSize! (
        copy /y "%%F" "%Logs%\Dumps" >nul
        set BigDumpCollected=1
        set /a "TotalDumpSize+=!FileSize!"
      ) else (
        copy /y "%%F" "%Logs%\Dumps" >nul
        set /a "TotalDumpSize+=!FileSize!"
      )
    ) else (
      if !FileSize! LEQ !MaxDumpSize! (
        copy /y "%%F" "%Logs%\Dumps" >nul
        set /a "TotalDumpSize+=!FileSize!"
      )
    )
  )
)
if not %SkippedDumps%=="" ( echo %SkippedDumps% > "%Logs%\Dumps\SkippedDumps.txt" )

echo [94m[...][0m Creating BattleBit Logs.zip
powershell Compress-Archive '%Logs%' '%Logs%.zip' >nul
echo.
echo [32m[+][0m Finished!
echo.
echo [93mPlease copy BattleBit Logs.zip file from your desktop 
echo and send it to BattleBit representative in order to get support.
echo If you don't see the archive on your desktop, hit F5.[0m
echo.
pause
