# vcpkg-registry
Private vcpkg registry for ports that are not available in the public registry or require project-specific patches.

## Ports

- `asihpi`: AudioScience HPI - library needed to build the legacy ZFramework
- `dtoa-milo`: double ←→ string conversion "library" - needed to build the legacy ZFramework
- `imagemagick`: not accepted by upstream vcpkg because GraphicsMagick has longstanding precedence in the registry; this port supports a broader range of read/write formats and security policies
- `lua53`: patched old Lua - needed to build the legacy ZFramework
- `otl`: patched OTL that exports `get_shell` for all backends - needed to build the legacy ZFramework

## Updating a port

The helper batch files require Windows and a vcpkg checkout containing `vcpkg.exe`. Set `VCPKG_ROOT` to that checkout before running them. For example, in PowerShell:

```powershell
$env:VCPKG_ROOT = 'D:\Builds\vcpkg'
```

Use a feature branch based on `master` and keep the port source changes separate from the generated version database update:

1. Start from the latest `master` and create a branch:

    ```powershell
    git switch master
    git pull --ff-only
    git switch -c update/<port>-<version>
    ```

2. Update `ports/<port>/vcpkg.json`, its portfile, patches, and any relevant documentation. Verify source URLs and checksums, and increment the port version or `port-version` as appropriate.

3. Format each changed manifest and test the port using the consuming project's registry configuration and supported triplets:

    ```powershell
    .\format_manifest.bat <port>
    ```

4. Commit the port files and release notes before generating version metadata. `x-add-version` records the committed port tree, so do not run it against uncommitted port changes.

    ```powershell
    git add ports/<port> CHANGELOG CHANGELOG.md
    git commit -m "Update <port> to <version>"
    ```

5. Add the port to the registry version database. Run this once for each changed port:

    ```powershell
    .\update_version.bat <port>
    ```

  Review the generated `versions/` files and `versions/baseline.json`. Then commit them separately:

    ```powershell
    git diff -- versions
    git add versions
    git commit -m "Update registry versions for <port>"
    ```

6. Push the branch and open a pull request against `master`:

    ```powershell
    git push --set-upstream origin HEAD
    ```

  Include the port version, validation performed, and any platform or integration tests that were not run in the pull request description.

### Helper scripts

- `format_manifest.bat <port>` formats one `ports/<port>/vcpkg.json` manifest.
- `update_version.bat <port> [x-add-version options]` updates one port's version history and baseline. Prefer this for routine port updates.
- `update_versions.bat [x-add-version options]` runs `x-add-version --all`. Use it only when intentionally refreshing the version metadata for every port in the registry.

The helpers exit with an error if `VCPKG_ROOT` is unset, `vcpkg.exe` is missing, or the vcpkg command fails. Do not use `--overwrite-version` unless intentionally replacing metadata for an existing version.
