@echo off
setlocal
if "%~1"=="" (
  echo Usage: %~nx0 ^<port^>
  endlocal & exit /b 2
)
if not defined VCPKG_ROOT (
  echo Set VCPKG_ROOT to the vcpkg checkout containing vcpkg.exe.
  endlocal & exit /b 2
)
if not exist "%VCPKG_ROOT%\vcpkg.exe" (
  echo vcpkg.exe not found under VCPKG_ROOT: "%VCPKG_ROOT%"
  endlocal & exit /b 2
)
if not exist "%~dp0ports\%~1\vcpkg.json" (
  echo Port manifest not found: "%~dp0ports\%~1\vcpkg.json"
  endlocal & exit /b 2
)
pushd "%~dp0" || (endlocal & exit /b 1)
"%VCPKG_ROOT%\vcpkg.exe" format-manifest "%~dp0ports\%~1\vcpkg.json"
set "result=%ERRORLEVEL%"
popd
endlocal & exit /b %result%
