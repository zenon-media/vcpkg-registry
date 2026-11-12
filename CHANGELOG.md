# Changelog

## 2026-11-11 - bump made by ChatGPT

### OTL: 4.0.502 -> 4.0.509

- Rebased the single private patch after upstream removed `shell_state` and flattened `otl_stream`.
- Preserved ZMediaService's `get_shell()->adb` access by returning the stream itself and exposing only `adb`.

### ImageMagick: 7.1.2-27 -> 7.1.2-35

- Applied the Windows path-initialization workaround to `configure.ac`, so it survives Autotools regeneration.
- Fixed compiler-wrapper library lookup when Libtool forwards paths through `-Wl,...` or places them after library arguments.
- Translated forwarded `-l` options and removed GCC-only `-Xlinker` markers before invoking the MSVC linker.
- Exported the Windows `ssize_t=ptrdiff_t` build definition through pkg-config and generated CMake targets.

#### Security findings

Severity is Grype's assessment for ImageMagick 7.1.2-27 in the isolated comparison.

The table lists findings no longer detected at 7.1.2-35 that also have an upstream ImageMagick advisory with a patched version in the 7.1.2 series.

| Grype severity | Confirmed upstream fixes |
| :------------- | -----------------------: |
| Critical       | 0                        |
| High           | 20                       |
| Medium         | 51                       |
| Low            | 11                       |
| Total          | 82                       |

##### Fixed upstream

| Severity | CVE and upstream advisory                                                                             | First fixed in |
| :------- | :---------------------------------------------------------------------------------------------------- | :------------- |
| High     | [CVE-2026-106565](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-m9c7-gf3j-hx6h) | 7.1.2-32       |
| High     | [CVE-2026-106567](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-g6p6-3ggg-3w7j) | 7.1.2-32       |
| High     | [CVE-2026-106573](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-qr53-hc3p-fc62) | 7.1.2-31       |
| High     | [CVE-2026-106576](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-v45j-x8p4-3mh4) | 7.1.2-31       |
| High     | [CVE-2026-106578](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-6xf5-c3jx-rp39) | 7.1.2-31       |
| High     | [CVE-2026-106579](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-vcjj-32hg-qpx5) | 7.1.2-31       |
| High     | [CVE-2026-106580](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-r868-pmwh-fv2c) | 7.1.2-31       |
| High     | [CVE-2026-107209](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-f2r2-qw7g-3c8x) | 7.1.2-30       |
| High     | [CVE-2026-109258](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-pv8x-gq6w-gp4r) | 7.1.2-32       |
| High     | [CVE-2026-109260](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-hvwf-wmm6-hvc3) | 7.1.2-32       |
| High     | [CVE-2026-109261](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-w68r-6fmr-cvg4) | 7.1.2-32       |
| High     | [CVE-2026-109262](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-w288-jj5x-hhvp) | 7.1.2-32       |
| High     | [CVE-2026-109263](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-69jx-j2x2-g5w4) | 7.1.2-32       |
| High     | [CVE-2026-109268](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-j39j-wmxg-j8mv) | 7.1.2-32       |
| High     | [CVE-2026-116149](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-pwpf-8799-94cj) | 7.1.2-33       |
| High     | [CVE-2026-119123](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-g5j8-ff59-wp88) | 7.1.2-34       |
| High     | [CVE-2026-86420](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-4mwf-mggw-29vp)  | 7.1.2-30       |
| High     | [CVE-2026-86421](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-4jv7-q6xw-6f4x)  | 7.1.2-30       |
| High     | [CVE-2026-93589](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-4gg2-hfgh-6f5c)  | 7.1.2-31       |
| High     | [CVE-2026-93590](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-7hjx-392p-f8cm)  | 7.1.2-31       |
| Medium   | [CVE-2026-102635](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-rvv7-5mh8-vcfc) | 7.1.2-32       |
| Medium   | [CVE-2026-105081](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-79p5-w6jv-r997) | 7.1.2-33       |
| Medium   | [CVE-2026-105083](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-jjp4-3fwf-393j) | 7.1.2-32       |
| Medium   | [CVE-2026-106564](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-54rx-5x9g-g465) | 7.1.2-32       |
| Medium   | [CVE-2026-106566](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-54hm-vrmh-75qj) | 7.1.2-32       |
| Medium   | [CVE-2026-106568](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-9p7q-63hw-mcr4) | 7.1.2-32       |
| Medium   | [CVE-2026-106569](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-gwj6-pm7x-3r63) | 7.1.2-32       |
| Medium   | [CVE-2026-106570](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-2vwg-3g4g-qprm) | 7.1.2-32       |
| Medium   | [CVE-2026-106571](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-jvjm-9f73-fhpq) | 7.1.2-31       |
| Medium   | [CVE-2026-106572](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-wxw6-98rj-hjfr) | 7.1.2-30       |
| Medium   | [CVE-2026-106574](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-4fq9-vrx7-gv92) | 7.1.2-31       |
| Medium   | [CVE-2026-106575](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-2w4h-697j-4vrm) | 7.1.2-31       |
| Medium   | [CVE-2026-106577](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-5rg6-j44q-q892) | 7.1.2-31       |
| Medium   | [CVE-2026-107208](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-27m9-54jx-fgvq) | 7.1.2-30       |
| Medium   | [CVE-2026-107210](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-3j4w-pvxj-fpjc) | 7.1.2-30       |
| Medium   | [CVE-2026-109259](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-h499-883p-vph8) | 7.1.2-32       |
| Medium   | [CVE-2026-109264](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-pmqj-84pr-qc7c) | 7.1.2-32       |
| Medium   | [CVE-2026-109265](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-jph3-37cg-79wg) | 7.1.2-32       |
| Medium   | [CVE-2026-109267](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-462x-739v-qvq2) | 7.1.2-32       |
| Medium   | [CVE-2026-109269](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-xxrx-rjp3-27rj) | 7.1.2-32       |
| Medium   | [CVE-2026-109270](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-f32c-2v6j-wvh5) | 7.1.2-32       |
| Medium   | [CVE-2026-109272](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-58h4-rwr6-wj72) | 7.1.2-32       |
| Medium   | [CVE-2026-109273](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-5j8x-vq8c-vrp9) | 7.1.2-32       |
| Medium   | [CVE-2026-109275](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-233r-2p53-wqf5) | 7.1.2-32       |
| Medium   | [CVE-2026-109276](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-f983-243h-9x4r) | 7.1.2-32       |
| Medium   | [CVE-2026-109277](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-vv56-wmgw-m36w) | 7.1.2-32       |
| Medium   | [CVE-2026-109278](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-9f9w-84g3-vp2c) | 7.1.2-32       |
| Medium   | [CVE-2026-109281](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-cvgp-q487-j22w) | 7.1.2-32       |
| Medium   | [CVE-2026-109964](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-mqmp-r5jh-jx7w) | 7.1.2-33       |
| Medium   | [CVE-2026-116140](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-528x-2384-jmxp) | 7.1.2-33       |
| Medium   | [CVE-2026-116141](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-h3qx-937j-245g) | 7.1.2-33       |
| Medium   | [CVE-2026-116142](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-5222-mhv9-26rg) | 7.1.2-33       |
| Medium   | [CVE-2026-116143](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-fp46-842c-2v83) | 7.1.2-33       |
| Medium   | [CVE-2026-116144](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-x258-xjqf-6j3f) | 7.1.2-33       |
| Medium   | [CVE-2026-116146](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-j657-rmv3-4m94) | 7.1.2-33       |
| Medium   | [CVE-2026-116147](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-v5f5-4v9x-p3f2) | 7.1.2-33       |
| Medium   | [CVE-2026-116148](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-qq8x-fq3x-43h4) | 7.1.2-33       |
| Medium   | [CVE-2026-116151](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-v9q4-cm37-q2jm) | 7.1.2-33       |
| Medium   | [CVE-2026-116152](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-83w9-w85j-h9jc) | 7.1.2-33       |
| Medium   | [CVE-2026-116154](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-8ghq-p369-g395) | 7.1.2-33       |
| Medium   | [CVE-2026-116155](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-5jf2-9gcp-q234) | 7.1.2-33       |
| Medium   | [CVE-2026-116156](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-7r5g-p7ff-jgcp) | 7.1.2-33       |
| Medium   | [CVE-2026-116157](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-pj4h-g4pf-66v3) | 7.1.2-33       |
| Medium   | [CVE-2026-116158](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-m938-565c-h9qf) | 7.1.2-33       |
| Medium   | [CVE-2026-116159](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-c2qq-jqw7-q4mx) | 7.1.2-33       |
| Medium   | [CVE-2026-116160](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-6p6q-wfrv-ffhh) | 7.1.2-33       |
| Medium   | [CVE-2026-119124](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-x48p-6655-8qgv) | 7.1.2-34       |
| Medium   | [CVE-2026-86423](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-5m9j-96ff-j6qc)  | 7.1.2-30       |
| Medium   | [CVE-2026-86425](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-chf5-8rv9-gjqr)  | 7.1.2-30       |
| Medium   | [CVE-2026-93587](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-89wq-f8f6-2j2v)  | 7.1.2-31       |
| Medium   | [CVE-2026-93588](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-92rw-c5mw-27v4)  | 7.1.2-31       |
| Low      | [CVE-2026-109266](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-3429-f84m-8qhw) | 7.1.2-32       |
| Low      | [CVE-2026-109274](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-7q74-r26w-fwcx) | 7.1.2-32       |
| Low      | [CVE-2026-109279](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-8x3v-wr32-qqh4) | 7.1.2-32       |
| Low      | [CVE-2026-109280](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-v2x3-wpmg-c4w6) | 7.1.2-32       |
| Low      | [CVE-2026-109282](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-8xmr-6q99-c4x8) | 7.1.2-32       |
| Low      | [CVE-2026-116145](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-4wfv-467j-fqh9) | 7.1.2-32       |
| Low      | [CVE-2026-116150](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-8w9c-hj38-8pf9) | 7.1.2-33       |
| Low      | [CVE-2026-116153](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-7438-vh5v-v52h) | 7.1.2-33       |
| Low      | [CVE-2026-86422](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-x8g2-7r3w-h44p)  | 7.1.2-30       |
| Low      | [CVE-2026-86424](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-9x6f-98x9-rx6g)  | 7.1.2-30       |
| Low      | [CVE-2026-93586](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-3rjr-534c-8v67)  | 7.1.2-31       |

##### No longer detected; upstream fix not confirmed

| Severity | CVE                                                                 | Note                                                                                                                                     |
| :------- | :------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------- |
| High     | [CVE-2026-108693](https://nvd.nist.gov/vuln/detail/CVE-2026-108693) | Windows Ghostscript executable search-path finding; no upstream patched-version record verified. Not included in the 82 confirmed fixes. |

##### Still detected at 7.1.2-35

| Severity | CVE                                                             | Note                                                                   |
| :------- | :-------------------------------------------------------------- | :--------------------------------------------------------------------- |
| Critical | [CVE-2014-9826](https://nvd.nist.gov/vuln/detail/CVE-2014-9826) | Still reported by the isolated scan.                                   |
| High     | [CVE-2017-5506](https://nvd.nist.gov/vuln/detail/CVE-2017-5506) | Still reported by the isolated scan.                                   |
| Medium   | [CVE-2016-7538](https://nvd.nist.gov/vuln/detail/CVE-2016-7538) | Still reported by the isolated scan.                                   |
| Medium   | [CVE-2023-5341](https://nvd.nist.gov/vuln/detail/CVE-2023-5341) | Advertises a fix of 7.1.2 but still matches 7.1.2-35; requires triage. |

The four remaining entries are scanner findings, not assertions that the corresponding defects are present in this build.
CPE-based findings require triage.

##### Validation status

- ImageMagick 7.1.2-35: isolated vcpkg Debug/Release installation and post-build checks passed.
- Magick++ and MagickWand consumers: MSVC and clang-cl, Debug and Release (eight combinations) passed.
