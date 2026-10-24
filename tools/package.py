"""Deterministic install-only build: python tools/package.py [destination-directory]."""
from pathlib import Path
import hashlib, json, re, sys, zipfile

ROOT=Path(__file__).resolve().parents[1]
VERSION="0.3.1"
INTERFACE="120105"
TEXTURES=("Assets/DropWatch-Mini.tga","Assets/Settings.tga")
def require(value,message):
    if not value:
        raise ValueError(message)

def release_members(root=ROOT):
    root=Path(root).resolve()
    toc=root/"DropWatch.toc"
    text=toc.read_text(encoding="utf-8")
    metadata=dict(re.findall(r"^##\s*([^:]+):\s*(.*?)\s*$",text,re.M))
    require(metadata.get("Title")=="DropWatch","Unexpected addon title")
    require(metadata.get("Version")==VERSION,"TOC version mismatch")
    require(metadata.get("Interface")==INTERFACE,"Unsupported/unreviewed interface number")
    internal=(root/"Core/Namespace.lua").read_text(encoding="utf-8")
    require('ns.version = "'+VERSION+'"' in internal,"Internal version mismatch")
    modules=[line.strip() for line in text.splitlines() if line.strip() and not line.startswith("#")]
    require(len(modules)==19 and len(set(modules))==19,"Invalid or duplicate module list")
    members=["DropWatch.toc"]+modules+list(TEXTURES)
    # Include the selected project license and any accompanying legal notice.
    members += [name for name in ("LICENSE","NOTICE") if (root/name).is_file()]
    for name in members:
        p=(root/name).resolve()
        require(p.is_relative_to(root) and p.is_file(),"Missing or escaping runtime path: "+name)
    for name in modules:
        require(name.endswith(".lua"),"Unexpected manifest entry")
        source=(root/name).read_text(encoding="utf-8")
        require("Interface/AddOns/LootTracker/" not in source,"Obsolete texture path")
        for asset in re.findall(r'Interface/AddOns/DropWatch/([^"]+)',source):
            require(asset in TEXTURES,"Undeclared runtime texture: "+asset)
    return members

def build(output,root=ROOT):
    root=Path(root).resolve()
    members=release_members(root)
    output=Path(output).resolve(); output.mkdir(parents=True,exist_ok=True)
    target=output/("DropWatch-"+VERSION+".zip")
    manifest={}
    with zipfile.ZipFile(target,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
        for name in members:
            payload=(root/name).read_bytes()
            info=zipfile.ZipInfo("DropWatch/"+name,date_time=(1980,1,1,0,0,0))
            info.create_system=3
            info.external_attr=0o100644 << 16
            info.compress_type=zipfile.ZIP_DEFLATED
            archive.writestr(info,payload,compress_type=zipfile.ZIP_DEFLATED,compresslevel=9)
            manifest[name]={"bytes":len(payload),"sha256":hashlib.sha256(payload).hexdigest()}
    with zipfile.ZipFile(target) as archive:
        require(archive.testzip() is None,"ZIP CRC/integrity failure")
        require(archive.namelist()==["DropWatch/"+name for name in members],"Archive root/order mismatch")
        for name in members:
            require(archive.read("DropWatch/"+name)==(root/name).read_bytes(),"Archive payload mismatch")
    digest=hashlib.sha256(target.read_bytes()).hexdigest()
    (output/("DropWatch-"+VERSION+".sha256")).write_text(digest+"  "+target.name+"\n",encoding="ascii")
    (output/("DropWatch-"+VERSION+".manifest.json")).write_text(
        json.dumps({"version":VERSION,"interface":INTERFACE,"files":manifest},indent=2,sort_keys=True)+"\n",
        encoding="utf-8")
    return target,digest,len(members)

if __name__=="__main__":
    target,digest,count=build(sys.argv[1] if len(sys.argv)>1 else ROOT.parent/"dist")
    print(f"PASS: deterministic install-only ZIP, {count} files, single DropWatch/ root")
    print(f"SHA256: {digest}")
    print(target)
