# Build and verify DropWatch 0.3.0

## Development tools

Python 3.12+ (bundled interpreter used for this review) and lupa 2.8 for Lua 5.1 tests:
python -m pip install lupa==2.8
python tests/run.py

Pillow 12.3.0 is needed only to rebuild artwork:
python -m pip install Pillow==12.3.0
python tools/build_icons.py

In restricted environments set DROPWATCH_TEST_TMP to an existing writable scratch directory before tests. Tests use isolated temporary source copies and clean them up. No dependency above is required by WoW.

Reviewed toolchain: Python 3.12.14, zlib 1.3.2, lupa 2.8 (Lua 5.1), Pillow 12.3.0.

## Deterministic archive

python tools/package.py <output-directory>

Outputs:
- DropWatch-0.3.0.zip
- DropWatch-0.3.0.sha256
- DropWatch-0.3.0.manifest.json

The packager validates title/version/interface, internal version, unique manifest files, original-source texture paths and safe file resolution. It installs only the TOC, 19 Lua files, two TGA textures and the approved MIT LICENSE (23 files). An optional NOTICE is also included if present. Exactly one DropWatch/ root is created.

Entries follow manifest order, use fixed 1980 timestamps/0644 attributes and fixed deflate settings. Identical source bytes produce identical ZIP bytes despite filesystem timestamp/permission changes on the tested Python/zlib toolchain. Record the toolchain when reproducing across hosts; different compression implementations may differ in compressed bytes.

The ZIP is reopened for CRC and byte-for-byte source validation. SHA256 and per-file hashes are written beside it, not inside the addon. A SHA256 checksum is integrity evidence, not a digital signature.

The suite additionally builds from a temporary clone with changed mtimes, compares exact archives and boots installed ZIP Lua in a fresh mocked client namespace. This cannot replace the final WoW/CurseForge clean-install test.

## Approval boundary

Keep 0.3.0 as the candidate. MIT has been selected by the owner and LICENSE is packaged. Do not push, tag or upload from this script. After source changes, rerun tests and build from the validated commit. Review the archive manifest and manual checklist before author approval.
