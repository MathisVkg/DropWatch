"""Run with Python + lupa (development only); no addon runtime dependencies."""
from pathlib import Path
import runpy
import math
from lupa.lua51 import LuaRuntime

root = Path(__file__).resolve().parents[1]
files = [line.strip() for line in (root / "DropWatch.toc").read_text().splitlines()
         if line.strip() and not line.startswith("#")]
for suite, entry in [("spec.lua", "run_tests"), ("refinement.lua", "run_refinement"), ("interface.lua", "run_interface"), ("polish.lua", "run_polish"), ("minimap.lua", "run_minimap"), ("branding.lua", "run_branding")]:
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((root / "tests" / "spec.lua").read_text(encoding="utf-8"))
    ns = lua.table()
    for file in files:
        source = (root / file).read_text(encoding="utf-8")
        lua.execute("return assert(loadstring(...))", source)("DropWatch", ns)
    if suite != "spec.lua":
        lua.execute((root / "tests" / suite).read_text(encoding="utf-8"))
    lua.globals()[entry](ns)
# Fresh addon boots exercise SavedVariables restoration for both world-entry paths.
boot_assertions = 0
for reload_ui in (False, True):
    for scale, size, angle, hidden in ((0.64,120,225,False),(1,150,42.5,True),(1.5,240,315,False)):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute((root / "tests" / "spec.lua").read_text(encoding="utf-8"))
        lua.globals().LootTrackerDB = lua.table_from({"minimapAngle":angle,"hideMinimap":hidden})
        lua.globals().Minimap.SetSize(lua.globals().Minimap,size,size)
        lua.globals().Minimap.scale = scale
        ns = lua.table()
        for file in files:
            lua.execute("return assert(loadstring(...))",(root/file).read_text(encoding="utf-8"))("DropWatch",ns)
        dispatch=ns.eventFrame.scripts.OnEvent
        dispatch(ns.eventFrame,"ADDON_LOADED","DropWatch")
        dispatch(ns.eventFrame,"PLAYER_ENTERING_WORLD",not reload_ui,reload_ui)
        button=ns.Main.minimap
        point,relative,relative_point,x,y=button.GetPoint(button)
        radius=size/2
        assert ns.db.minimapAngle==angle
        assert point=="CENTER" and relative_point=="CENTER"
        assert abs(x-math.cos(math.radians(angle))*radius)<1e-6
        assert abs(y-math.sin(math.radians(angle))*radius)<1e-6
        assert button.IsShown(button)==(not hidden)
        boot_assertions += 5
print(f"PASS: {boot_assertions} fresh-login/reload minimap assertions")
print(f"PASS: all {len(files)} manifest Lua files compile and load in Lua 5.1")
runpy.run_path(str(root/"tests"/"packaging.py"))
