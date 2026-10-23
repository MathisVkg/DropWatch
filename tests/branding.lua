function run_branding(ns)
    local checks=0
    local function check(v,m) checks=checks+1; assert(v,m) end
    local function event(name,...) ns.eventFrame.scripts.OnEvent(ns.eventFrame,name,...) end
    -- This is exactly the legacy global assignment copied into DropWatch.lua.
    LootTrackerDB={debug=true,trackMounts=true,displayMode="notification",opacity=.57,locked=true,
        hideMinimap=true,minimapAngle=237.25,
        window={point="TOPLEFT",relativePoint="TOPLEFT",x=71,y=-83,width=617,height=431},
        settingsPosition={point="BOTTOMRIGHT",relativePoint="BOTTOMRIGHT",x=-90,y=120},
        position={point="CENTER",relativePoint="CENTER",x=28,y=-36}}
    event("ADDON_LOADED","UnrelatedAddon")
    check(ns.db==nil,"unrelated addon event does not initialize DropWatch")
    event("ADDON_LOADED","DropWatch"); event("PLAYER_ENTERING_WORLD",true,false)
    check(ns.name=="DropWatch" and ns.version=="0.3.0","new addon namespace and version")
    check(ns.db==LootTrackerDB and DropWatchDB==nil,"legacy settings global intentionally retained")
    check(ns.db.debug and ns.db.trackMounts and ns.db.displayMode=="notification","legacy behavior preferences preserved")
    check(ns.db.opacity==.57 and ns.db.locked and ns.db.hideMinimap and ns.db.minimapAngle==237.25,"opacity/lock/minimap preferences preserved")
    check(ns.db.window.width==617 and ns.db.window.height==431 and ns.db.window.x==71 and ns.db.window.y==-83,"preferred geometry preserved")
    check(ns.db.settingsPosition.x==-90 and ns.db.settingsPosition.y==120 and ns.db.position.x==28,"independent settings/diagnostic positions preserved")
    check(not ns.Main.minimap:IsShown(),"saved hidden minimap remains hidden")
    local function command(alias,args)
        for i=1,3 do if _G["SLASH_DROPWATCH"..i]==alias then return SlashCmdList.DROPWATCH(args) end end
        error("unregistered slash alias: "..alias)
    end
    check(SLASH_DROPWATCH1=="/dropwatch" and SLASH_DROPWATCH2=="/dw" and SLASH_DROPWATCH3=="/loottracker","all three slash aliases registered")
    command("/dropwatch",""); check(ns.Main.frame:IsShown() and ns.Main.title.text=="DropWatch","primary command and title")
    command("/dw",""); check(not ns.Main.frame:IsShown(),"short alias toggles same panel")
    command("/loottracker",""); check(ns.Main.frame:IsShown(),"legacy alias toggles same panel")
    command("/dw","status"); command("/loottracker","status")
    command("/dropwatch","settings")
    check(ns.Settings.frame:IsShown(),"settings command preserved")
    command("/loottracker","diag"); check(ns.UI.frame:IsShown(),"legacy diagnostic command preserved")
    local expected="Interface/AddOns/DropWatch/Assets/DropWatch-Mini.tga"
    check(ns.Main.minimap.icon.texture==expected,"radar minimap texture path")
    local headerIcon=false
    for _,f in ipairs(TestAPI.frames) do if f.parent==ns.Main.bar and f.texture==expected then headerIcon=true end end
    check(headerIcon,"header loads the simplified radar texture")
    ns.Settings:Set("hideMinimap",false)
    ns.Main.minimap.scripts.OnEnter(ns.Main.minimap)
    check(GameTooltip.text:find("DropWatch",1,true)==1,"new minimap tooltip branding")
    ns.Main.minimap.scripts.OnClick(ns.Main.minimap,"RightButton")
    check(not ns.Settings.frame:IsShown(),"minimap right click preserved")
    command("/dw","demo"); ns.Main:Render(); check(ns.Session.demo and ns.Main.title.text=="DropWatch · DEMO","new command preserves branded isolated demo")
    command("/loottracker","demo burst")
    check(ns.Notification.frame.label.text:find("DropWatch",1,true)~=nil,"notification uses new brand")
    command("/dropwatch","demo off"); check(not ns.Session.demo and #ns.Session.entries==0,"demo isolation preserved")
    command("/dw","clear"); check(#ns.normalized==0,"clear alias preserved")
    local prior=ns.db.debug; command("/loottracker","debug")
    check(ns.db.debug~=prior,"legacy debug preserved")
    local found={}
    for _,name in ipairs(UISpecialFrames) do found[name]=true end
    check(found.DropWatchMainFrame and found.DropWatchSettingsFrame and found.DropWatchDiagnosticFrame,"native Escape frame names renamed consistently")
    check(not ns.listenerErrors,"single event/subscriber feed remains healthy")
    print("PASS: "..checks.." rebranding/migration/slash assertions")
end
