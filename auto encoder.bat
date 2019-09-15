@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set queue=unconfigured
set target=unconfigured
set host=unconfigured

if %queue%==unconfigured (
echo The encoding queue folder has not been configured. 
echo Please edit this script and set queue to the path you desire in quotes.
echo Example "D:\cytube\encoding queue"
pause
exit
)

if %target%==unconfigured (
echo The location for your steam ready files has not been configured. 
echo Please edit this script and set target to the path you desire in quotes.
echo Example "C:\cytube ready videos"
pause
exit
)

if %host%==unconfigured (
echo The file server address has not been configured. 
echo Please edit this script and set host to the url of your server. Trailing / included. No quotes
echo Example https://cytubevideos.no-ip.com/
pause
exit
)

if not exist ffmpeg.exe (
echo please download and add ffmpeg.exe to the folder
pause
exit
)
if not exist ffprobe.exe (
echo please download and add ffprobe.exe to the folder
pause
exit
)

set root=%~dp0
set job=%queue%\~

md %job% >nul 2>&1
:start
cd %job%
for /f "tokens=*" %%i in ('dir /b /s') do (
Call :encode "%%i" %target%
echo encoding %%i
goto wait
)

:scan
cd %queue%
for /f "tokens=*" %%i in ('dir /b /a:-d /s') do (
set "test=%%i"
if !test!==!test:\.=\! (
md ~
set "name=%%~nxi"
set "name=!name: =_!"
move "%%i" "%%~dpi~\!name!"
goto start
)
) >nul 2>&1
echo Nothing to encode. Waiting 60 seconds..
ping localhost -n 60 >nul
goto scan

:wait
ping localhost -n 10 >nul
cd %target%
(
for /f "tokens=*" %%i in ('dir ~~* /b /s') do (
set "test=%%i"
if !test!==!test:\.=\! (
goto wait
)
)
) >nul 2>&1
echo finished
del /s /f /q %job%

goto start

:encode
Set filename="%~1"
For /F "delims=" %%a in ('dir /b /s %filename%') do (
    SET Name=%%~na
)
md "%~2\%Name%\"

set durationfile="%~2\%~n1\duration.txt"
"%root%ffprobe" -i %1 -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 > %durationfile%
set /p duration=< %durationfile%
del %durationfile% /f /q

set heightfile="%~2\%~n1\height.txt"
"%root%ffprobe" -i %1 -v error -select_streams v -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 > %heightfile%
set /p height=< %heightfile%
del %heightfile% /f /q

set widthfile="%~2\%~n1\width.txt"
"%root%ffprobe" -i %1 -v error -select_streams v -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 > %widthfile%
set /p width=< %widthfile%
del %widthfile% /f /q

if not defined height (exit 0)
SET "var="&for /f "delims=0123456789" %%i in ("%height%") do set var=%%i
if defined var (exit 0)

set /a "aspect=width*100/height"
if %aspect% GTR 167 (
set encodescript="%root%encode-task-ultrawide.bat"
::calculate what the height would be if this ultrawide was leterboxed
set /a "height=width/16*9"
) else (
set encodescript="%root%encode-task-standard.bat"
)

start /min cmd /c Call %encodescript% %1 "%~2\%Name%" "%Name%" 240 low
if %height% GTR 240 start /min cmd /c Call %encodescript% %1 "%~2\%Name%" "%Name%" 360 low
if %height% GTR 360 start /min cmd /c Call %encodescript% %1 "%~2\%Name%" "%Name%" 480 low
if %height% GTR 480 start /min cmd /c Call %encodescript% %1 "%~2\%Name%" "%Name%" 540 low
if %height% GTR 540 start /min cmd /c Call %encodescript% %1 "%~2\%Name%" "%Name%" 720 belownormal
if %height% GTR 720 start /min cmd /c Call %encodescript% %1 "%~2\%Name%" "%Name%" 1080 belownormal

echo.> "%~2\%Name%\play.json"
echo { >> "%~2\%Name%\play.json"
echo   "title": "%Name:_= %", >> "%~2\%Name%\play.json"
echo   "duration": %duration%, >> "%~2\%Name%\play.json"
echo   "live": false, >> "%~2\%Name%\play.json"
echo   "sources": [ >> "%~2\%Name%\play.json"
echo     { >> "%~2\%Name%\play.json"
echo       "url": "%host%%Name%/%Name%-240p.mp4", >> "%~2\%Name%\play.json"
echo       "contentType": "video/mp4", >> "%~2\%Name%\play.json"
echo       "quality": 240 >> "%~2\%Name%\play.json"
if %height% GTR 240 (
echo     }, >> "%~2\%Name%\play.json"
echo     { >> "%~2\%Name%\play.json"
echo       "url": "%host%%Name%/%Name%-360p.mp4", >> "%~2\%Name%\play.json"
echo       "contentType": "video/mp4", >> "%~2\%Name%\play.json"
echo       "quality": 360 >> "%~2\%Name%\play.json"
)
if %height% GTR 360 (
echo     }, >> "%~2\%Name%\play.json"
echo     { >> "%~2\%Name%\play.json"
echo       "url": "%host%%Name%/%Name%-480p.mp4", >> "%~2\%Name%\play.json"
echo       "contentType": "video/mp4", >> "%~2\%Name%\play.json"
echo       "quality": 480 >> "%~2\%Name%\play.json"
)
if %height% GTR 480 (
echo     }, >> "%~2\%Name%\play.json"
echo     { >> "%~2\%Name%\play.json"
echo       "url": "%host%%Name%/%Name%-540p.mp4", >> "%~2\%Name%\play.json"
echo       "contentType": "video/mp4", >> "%~2\%Name%\play.json"
echo       "quality": 540 >> "%~2\%Name%\play.json"
)
if %height% GTR 540 (
echo     }, >> "%~2\%Name%\play.json"
echo     { >> "%~2\%Name%\play.json"
echo       "url": "%host%%Name%/%Name%-720p.mp4", >> "%~2\%Name%\play.json"
echo       "contentType": "video/mp4", >> "%~2\%Name%\play.json"
echo       "quality": 720 >> "%~2\%Name%\play.json"
)
if %height% GTR 720 (
echo     }, >> "%~2\%Name%\play.json"
echo     { >> "%~2\%Name%\play.json"
echo       "url": "%host%%Name%/%Name%-1080p.mp4", >> "%~2\%Name%\play.json"
echo       "contentType": "video/mp4", >> "%~2\%Name%\play.json"
echo       "quality": 1080 >> "%~2\%Name%\play.json"
)
echo     } >> "%~2\%Name%\play.json"
echo   ] >> "%~2\%Name%\play.json"
echo } >> "%~2\%Name%\play.json"
goto :eof

exit /b
