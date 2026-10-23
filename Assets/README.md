# DropWatch radar artwork

Original code-native geometric artwork, no external illustration or font.

- DropWatch-Project.svg: resolution-independent detailed source, with a 1024×1024 viewport.
- DropWatch-Project.png: 1024×1024 high-resolution export for future GitHub/CurseForge use.
- DropWatch-Mini.svg and DropWatch-Mini.png: simplified 64×64 radar/shield variant, intended for 24–32px minimap use and the existing 16px header.
- DropWatch-Mini.tga: uncompressed 64×64 32-bit RGBA texture supported by the WoW client. Transparent corners preserve the existing circular presentation.
- DropWatch-CurseForge.png: 400×400 portal export of the project master, excluded from runtime installation.
- Settings.tga: unchanged original 32×32 settings gear.

The palette is teal #58C4BD, gold #DDAA55 and charcoal #14191C, with flat muted sweep geometry. No text, heavy glow or gradients. The project variant adds radar rings and two detections; the minimap variant omits fine details.

## Reproduce the assets

Use Python and Pillow 12.3.0 (development only):
python -m pip install Pillow==12.3.0
python tools/build_icons.py

One geometric scene definition produces vector SVG plus supersampled PNG; the simplified raster is saved as uncompressed 32-bit TGA by Pillow. The game loads TGA only, never PNG/SVG. No image conversion or extra library runs inside WoW. Re-running the generator with this version reproduces the delivered assets. tools/package.py includes only the two runtime TGA textures, excluding project artwork, source SVG/PNG, docs and development tools.

The 16/24/30px raster previews were inspected locally. In-client texture rendering remains pending.

## License

The original radar SVG/PNG/TGA artwork, portal export and original Settings.tga gear are covered by the project [MIT license](../LICENSE). These assets were created specifically for this project from geometric primitives without imported artwork or fonts. See [provenance and third-party exclusions](../docs/LICENSE_REVIEW.md). Blizzard native game resources and trademarks are not included in this grant.
