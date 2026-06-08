#define LUA_CORE

#include "lprefix.h"
#include "lua.h"

#include "lgc.h"

#include <stdio.h>
#include "windows_utf8_support.h"


LUA_API void Z_luaC_checkGC(lua_State* L)
{
	luaC_condGC(L, (void)0, (void)0);
}

LUA_API const char *Z_luaO_pushvfstring(lua_State *L, const char *fmt, va_list argp)
{
	return luaO_pushvfstring(L, fmt, argp);
}

FILE* fopen_utf8(const char* filename, const char* mode) {
	wchar_t wfilename[MAX_PATH];
	wchar_t wmode[5];
	if (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, filename, -1, wfilename, MAX_PATH) > 0 &&
		MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, mode, -1, wmode, 5) > 0)
		return _wfopen(wfilename, wmode);
	else
		return fopen(filename, mode);
}

FILE* popen_utf8(const char* filename, const char* mode) {
	wchar_t wfilename[MAX_PATH];
	wchar_t wmode[5];
	if (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, filename, -1, wfilename, MAX_PATH) > 0 &&
		MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, mode, -1, wmode, 5) > 0)
		return _wpopen(wfilename, wmode);
	else
		return _popen(filename, mode);
}
