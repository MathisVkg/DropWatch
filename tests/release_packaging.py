"""Build determinism, installed-content, safety and asset regressions."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
import hashlib, importlib.util, json, os, shutil, struct, tempfile, zipfile
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location("dropwatch_package",ROOT/"tools"/"package.py")
pack=importlib.util.module_from_spec(spec);spec.loader.exec_module(pack)
checks=0
def check(value,message):
    global checks
    checks+=1
    assert value,message
scratch=os.environ.get("DROPWATCH_TEST_TMP")
if scratch:
    scratch=Path(scratch).resolve(); scratch.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix="dropwatch-release-",dir=scratch) as temp:
    temp=Path(temp); clone=temp/"source"
    shutil.copytree(ROOT,clone,ignore=shutil.ignore_patterns("__pycache__",".git","dist","build","*.zip"))
    first,digest,count=pack.build(temp/"first",ROOT)
    for name in pack.release_members(clone):
        os.utime(clone/name,(1700000000,1700000000))
    second,other_digest,other_count=pack.build(temp/"second",clone)
    check(first.read_bytes()==second.read_bytes(),"same source bytes build identically despite changed file mtimes")
    check(digest==other_digest==hashlib.sha256(first.read_bytes()).hexdigest(),"deterministic SHA256")
    with zipfile.ZipFile(first) as archive:
        names=archive.namelist()
        check(archive.testzip() is None,"CRC integrity")
        check(all(n.startswith("DropWatch/") and ".." not in n.split("/") for n in names),"single safe addon root")
        check(len(names)==len(set(names))==count==other_count,"no duplicate/missing entries")
        check("DropWatch/DropWatch.toc" in names,"manifest matches root")
        check("DropWatch/LICENSE" in names,"MIT license installed")
        check(count==23,"only manifest, 19 Lua modules, two textures and LICENSE")
        legal=archive.read("DropWatch/LICENSE").decode("utf-8")
        check(legal==(ROOT/"LICENSE").read_text(encoding="utf-8"),"complete legal text preserved")
        check(legal.startswith("MIT License\n\nCopyright (c) 2026 Mathis Vankoekelberg\n"),"selected MIT copyright")
        check(legal.rstrip().endswith("SOFTWARE."),"MIT warranty text is complete")
        check(all("/tests/" not in n and "/docs/" not in n and "/tools/" not in n and ".git" not in n for n in names),"no development/debug files")
        check(all(i.date_time==(1980,1,1,0,0,0) for i in archive.infolist()),"portable fixed timestamps")
        lua=LuaRuntime(unpack_returned_tuples=True)
        lua.execute((ROOT/"tests"/"spec.lua").read_text(encoding="utf-8"))
        ns=lua.table()
        toc=archive.read("DropWatch/DropWatch.toc").decode("utf-8")
        for module in (line.strip() for line in toc.splitlines() if line.strip() and not line.startswith("#")):
            lua.execute("return assert(loadstring(...))",archive.read("DropWatch/"+module).decode("utf-8"))("DropWatch",ns)
        ns.eventFrame.scripts.OnEvent(ns.eventFrame,"ADDON_LOADED","DropWatch")
        ns.eventFrame.scripts.OnEvent(ns.eventFrame,"PLAYER_ENTERING_WORLD",True,False)
        check(ns.name=="DropWatch" and ns.version=="0.3.0","clean ZIP boots correct addon")
        check(ns.Session.ready is True,"clean ZIP initializes session")
        check(lua.globals().SLASH_DROPWATCH3=="/loottracker","clean ZIP registers compatible aliases")
        check(all(ns.registered[e]=="registered" for e in ns.events.values()),"clean ZIP registers all required events")
        for name in pack.release_members(ROOT):
            check(archive.read("DropWatch/"+name)==(ROOT/name).read_bytes(),"exact installed payload: "+name)
    manifest=json.loads((temp/"first"/"DropWatch-0.3.0.manifest.json").read_text())
    check(manifest["version"]=="0.3.0" and manifest["interface"]=="120105","release metadata sidecar")
    check(len(manifest["files"])==count,"manifest covers all installed files")
    check(digest in (temp/"first"/"DropWatch-0.3.0.sha256").read_text(),"adjacent checksum")
    # Optional legal notices must not silently disappear from distribution.
    (clone/"NOTICE").write_text("Fixture only; not a project notice")
    check("NOTICE" in pack.release_members(clone),"optional legal notice included")
    (clone/"Core/Namespace.lua").write_text('ns.version = "wrong"')
    try:
        pack.release_members(clone)
        raise AssertionError("inconsistent metadata accepted")
    except ValueError:
        check(True,"version drift rejected")
# Scan runtime source only: tools/tests intentionally have filesystem/subprocess operations.
for name in pack.release_members(ROOT):
    if not name.endswith(".lua"): continue
    source=(ROOT/name).read_text(encoding="utf-8")
    for forbidden in ("SendChatMessage(","SendAddonMessage(","RegisterAddonMessagePrefix(","RunScript(","loadstring(","os.execute(","io.open("):
        check(forbidden not in source,"no runtime transmission/execution path: "+name+" "+forbidden)
portal=(ROOT/"Assets/DropWatch-CurseForge.png").read_bytes()
check(struct.unpack(">II",portal[16:24])==(400,400),"square portal PNG prepared")
print(f"PASS: {checks} reproducible-release/security assertions")
