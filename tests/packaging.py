"""Structural identity and runtime packaging checks; uses only Python stdlib."""
from pathlib import Path
import re, struct, xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
checks=0
def check(value,message):
    global checks
    checks+=1
    assert value,message
toc=(ROOT/"DropWatch.toc").read_text()
check(not (ROOT/"LootTracker.toc").exists(),"old addon manifest removed")
check("## Title: DropWatch" in toc,"new visible addon title")
check("## Notes: Group Loot Tracker for Dungeons, Raids & Mythic+" in toc,"exact description")
check("## Version: 0.3.1" in toc,"target version")
check("## Interface: 120105" in toc,"validated interface unchanged")
check("## SavedVariables: LootTrackerDB, LootTrackerSession" in toc,"legacy global declarations preserve manual-copy settings")
modules=[x.strip() for x in toc.splitlines() if x.strip() and not x.startswith("#")]
check(len(modules)==19 and len(set(modules))==19,"complete unique module order")
check(all((ROOT/f).is_file() for f in modules),"all module paths exist")
for f in modules:
    text=(ROOT/f).read_text(encoding="utf-8")
    check("Interface/AddOns/LootTracker/" not in text,"no invalid old texture path: "+f)
    for asset in re.findall(r'Interface/AddOns/DropWatch/([^"]+)',text):
        check((ROOT/asset).is_file(),"new runtime texture exists: "+asset)
for name,size in (("DropWatch-Project",1024),("DropWatch-Mini",64)):
    b=(ROOT/"Assets"/(name+".png")).read_bytes()
    check(b[:8]==bytes((137,80,78,71,13,10,26,10)),"valid PNG signature")
    check(struct.unpack(">II",b[16:24])==(size,size),"square exported PNG dimensions")
    tree=ET.parse(ROOT/"Assets"/(name+".svg"))
    check(tree.getroot().attrib["viewBox"]=="0 0 100 100","scalable source")
b=(ROOT/"Assets/DropWatch-Mini.tga").read_bytes()
check(b[2]==2 and b[16]==32,"uncompressed 32-bit game texture")
check(struct.unpack("<HH",b[12:16])==(64,64),"power-of-two game texture")
check(not (ROOT/"Assets/LootTracker.tga").exists(),"old cube asset removed")
check((ROOT/"Assets/Settings.tga").is_file(),"settings texture retained")
print(f"PASS: {checks} TOC/path/artwork packaging assertions")
