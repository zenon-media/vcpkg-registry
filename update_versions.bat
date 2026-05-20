@echo off
pushd "%~dp0"
if "%VCPKG_ROOT%" == "" set VCPKG_ROOT=D:\Builds\vcpkg
%VCPKG_ROOT%\vcpkg.exe --x-builtin-ports-root="%~dp0\ports" --x-builtin-registry-versions-dir="%~dp0\versions" x-add-version --all %*
popd