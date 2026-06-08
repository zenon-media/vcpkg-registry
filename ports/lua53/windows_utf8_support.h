#pragma once

#define _AMD64_

#include <stringapiset.h>

extern FILE* fopen_utf8(const char* filename, const char* mode);
extern FILE* popen_utf8(const char* filename, const char* mode);
