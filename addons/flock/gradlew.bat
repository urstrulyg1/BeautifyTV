@echo off
rem Use the repository's shared Gradle wrapper; this add-on remains an independent project.
set "ADDON_DIR=%~dp0"
call "%ADDON_DIR%..\ad-blocking\gradlew.bat" -p "%ADDON_DIR%." %*
exit /b %ERRORLEVEL%
