@echo off
if "%1" == "" (
  echo "Specify port name"
) else (
  pushd "%~dp0"
  if "%VCPKG_ROOT%" == "" set VCPKG_ROOT=D:\Builds\vcpkg
  %VCPKG_ROOT%\vcpkg.exe format-manifest "%~dp0\ports\%1\vcpkg.json"
  popd
)
