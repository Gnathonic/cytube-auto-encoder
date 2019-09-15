@echo off
TITLE "%4p"
set root=%~dp0..
set ffmpeg=%~dp0ffmpeg.exe

set /a "width=%4*16/18*2"

start /min /wait /%5 "%~3-%4p" "%ffmpeg%" -i %1 -y -c:v libx264 -crf 22 -preset slow -vf scale="%width%:-2" -movflags faststart -c:a aac -ac 2 "%~2\~~%~3-%4p.mp4"

move /y %2\~~%3-%4p.mp4 %2\%3-%4p.mp4