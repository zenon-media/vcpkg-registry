@echo off
setlocal
if not defined VCPKG_ROOT (
	echo Set VCPKG_ROOT to the vcpkg checkout containing vcpkg.exe.
	endlocal & exit /b 2
)
if not exist "%VCPKG_ROOT%\vcpkg.exe" (
	echo vcpkg.exe not found under VCPKG_ROOT: "%VCPKG_ROOT%"
	endlocal & exit /b 2
)
pushd "%~dp0" || (endlocal & exit /b 1)
"%VCPKG_ROOT%\vcpkg.exe" --x-builtin-ports-root="%~dp0ports" --x-builtin-registry-versions-dir="%~dp0versions" x-add-version --all %*
set "result=%ERRORLEVEL%"
popd
endlocal & exit /b %result%
