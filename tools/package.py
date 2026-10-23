"""Build the install-only ZIP: python tools/package.py [destination-directory]."""
from pathlib import Path
import hashlib, re, sys, zipfile
ROOT=Path(__file__).resolve().parents[1]
toc=ROOT/"DropWatch.toc"
text=toc.read_text(encoding="utf-8")
assert "## Interface: 120105" in text
assert "## Title: DropWatch" in text and "## Version: 0.3.0" in text
modules=[s.strip() for s in text.splitlines() if s.strip() and not s.startswith("#")]
assert len(modules)==19 and len(set(modules))==19
assets=["Assets/DropWatch-Mini.tga","Assets/Settings.tga"]
members=["DropWatch.toc"]+modules+assets
assert all((ROOT/p).is_file() and ".." not in Path(p).parts for p in members)
for p in modules:
    source=(ROOT/p).read_text(encoding="utf-8")
    for asset in re.findall(r'Interface/AddOns/DropWatch/([^"]+)',source):
        assert asset in assets, (p,asset)
    assert "Interface/AddOns/LootTracker/" not in source
out=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else ROOT.parent/"dist"
out.mkdir(parents=True,exist_ok=True)
target=out/"DropWatch-0.3.0.zip"
with zipfile.ZipFile(target,"w",zipfile.ZIP_DEFLATED) as z:
    for p in members: z.write(ROOT/p,"DropWatch/"+p)
with zipfile.ZipFile(target) as z:
    assert z.testzip() is None
    assert set(z.namelist())=={"DropWatch/"+p for p in members}
    for p in members: assert z.read("DropWatch/"+p)==(ROOT/p).read_bytes()
print(f"PASS: install-only ZIP, {len(members)} files, single DropWatch/ root")
print(f"SHA256: {hashlib.sha256(target.read_bytes()).hexdigest()}")
print(target)
