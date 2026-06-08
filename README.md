# vcpkg-registry
Private registry for ports not accepted in the official vcpkg, or being developped

Current ports:

- `asihpi`: AudioScience HPI - library needed to build the legacy ZFramework
- `dtoa-milo`: double ←→ string conversion "library" - needed to build the legacy ZFramework
- `imagemagick`: rejected by vcpkg because they already have graphicsmagick  
  imagemagick supports much more formats in R/W and has security policies.
- `lua53`: patched old Lua - needed to build the legacy ZFramework
- `otl`: patched OTL that exports `get_shell` for all backends - needed to build the legacy ZFramework
