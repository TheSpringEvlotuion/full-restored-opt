@echo off
color 0a
cd ..
echo BUILDING GAME
lime test android
echo.
echo done.
pause
pwd
explorer.exe export\release\android\bin\app\build\outputs\apk\debug