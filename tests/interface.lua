function run_interface(ns)
    local checks=0
    local function check(value,message) checks=checks+1; assert(value,message) end
    local function event(name,...)
        ns.eventFrame.scripts.OnEvent(ns.eventFrame,name,...)
        assert(not ns.raw[#ns.raw] or ns.raw[#ns.raw].status~="unprocessed: handler error","handler failed: "..name)
    end
    local function draw() ns.Main:Render() end
    event("ADDON_LOADED","DropWatch"); event("PLAYER_ENTERING_WORLD",true,false)
    ns.db.displayMode="manual"
    local function record(id,age,run)
        return {id=id,revision=1,timestamp=time()-(age or 0),equipment=true,selected=true,loaded=true,
            player="Other",realm="Other Realm",guid="Player-other",itemID=193756,itemName="Fixture Blade",
            link="|cffa335ee|Hitem:193756:0:0:0:0:0:0:0:80:0:0:1:55|h[Fixture Blade]|h|r",
            itemLevel=311,icon=135274,rarity=4,category="weapon",equipLoc="INVTYPE_WEAPON",classToken="MAGE",quantity=1,
            context={instance="Fixture Dungeon",instanceID=123,difficulty=8,difficultyName="Mythic+",run=run or 1,
                challenge={state="completed",mapID=123,startedAt=1}}}
    end
    local function put(r,kind) ns:Notify(kind or "created",r) end
    local function reset()
        ns:Clear(); ns.db.displayMode="manual"; ns.db.trackMounts=false; ns.Main:Close()
    end
    -- 1-3: stable canonical identity and visible row reuse.
    local a=record(1); put(a); SlashCmdList.DROPWATCH(""); draw()
    check(#ns.Session.entries==1 and #ns.Main.descriptors==1,"one canonical record creates one row")
    local row=ns.Main.rows["item:1"]
    check(row and row.record.id==1,"row keyed by canonical ID")
    a.itemLevel=318; a.itemName="Enriched blade"; a.revision=2; put(a,"enriched"); draw()
    check(ns.Main.rows["item:1"]==row and row.record.itemLevel==318,"enrichment updates same frame")
    put(a,"reconciled"); put(a,"classification"); draw()
    check(#ns.Session.entries==1 and #ns.Main.descriptors==1,"reconciliation does not duplicate UI row")
    local b=record(2); b.player="Different"; put(b); draw()
    check(#ns.Main.descriptors==2,"two recipients with same item create two rows")
    -- 4-5: exact independent 900-second expiry, while closed; history outlives Recent.
    reset(); put(record(3)); TestAPI.advance(899); put(record(4))
    check(#ns.Session:Records(true)==2,"both items visible before first boundary")
    TestAPI.advance(1)
    check(#ns.Session:Records(true)==1 and ns.Session:Records(true)[1].id==4,"first expires exactly at acquisition +900")
    check(#ns.Session.entries==2,"expired award remains in history")
    TestAPI.advance(899)
    check(#ns.Session:Records(true)==0 and #ns.Session:Groups()[1].items==2,"expiry works while window closed")
    ns.Main:Show("loot"); check(ns.Main.empty.text=="No recent loot","minimal empty state")
    -- 6-7: same name/instance, separate activity IDs and conservative fallback.
    reset(); put(record(5,0,10)); put(record(6,0,11))
    local fallback=record(7); fallback.context={}; put(fallback)
    check(#ns.Session:Groups()==3,"separate runs and unassigned fallback")
    ns.Main:Show("history")
    local header
    for _,candidate in pairs(ns.Main.headers) do header=candidate; break end
    check(header and header.scripts.OnClick,"history group is interactive")
    local key=header.groupKey; header.scripts.OnClick(header)
    check(ns.Main.collapsed[key],"history group collapses")
    header.scripts.OnClick(header); check(not ns.Main.collapsed[key],"history group expands")
    -- 8-10: new qualification, no repeat display on enrichment; consolidated notification.
    reset(); ns.db.displayMode="automatic"; put(record(8))
    check(ns.Main.frame:IsShown() and ns.Main.tab=="loot","automatic mode opens Loot")
    ns.Main:Close(); local same=record(8); same.itemLevel=320; put(same,"enriched")
    check(not ns.Main.frame:IsShown(),"enrichment does not reopen a closed panel")
    put(same,"reconciled"); check(not ns.Main.frame:IsShown(),"reconciliation does not repeat automatic display")
    reset(); ns.db.displayMode="notification"; put(record(9)); put(record(10)); put(record(11))
    local notification=ns.Notification.frame
    check(notification:IsShown() and ns.Notification.count==3,"one consolidated notification for three awards")
    check(not ns.Main.frame:IsShown(),"notification mode does not open main panel")
    put(record(9),"enriched"); check(ns.Notification.count==3,"notification count not inflated by enrichment")
    TestAPI.advance(10)
    check(not notification:IsShown() and #ns.Session:Records(true)==3,"notification dismissal independent of Recent retention")
    put(record(12)); notification.scripts.OnClick(notification)
    check(ns.Main.frame:IsShown() and ns.Main.tab=="loot" and not notification:IsShown(),"notification click expands main panel")
    reset(); put(record(13)); check(not ns.Main.frame:IsShown() and not notification:IsShown(),"manual mode stays silent")
    -- 11: collection/detection after closing; real canonical engine integration.
    ns.Main:Show(); ns.Main:Close()
    local link=record(14).link
    event("CHAT_MSG_LOOT",string.format(LOOT_ITEM,"Live-OtherRealm",link),"Live-OtherRealm",nil,nil,nil,nil,nil,nil,nil,nil,999)
    event("ENCOUNTER_LOOT_RECEIVED",900,193756,link,1,"Live-OtherRealm","MAGE")
    check(#ns.normalized==1 and #ns.Session.entries==2,"closed panel still collects one real canonical award")
    check(ns.normalized[1].recipientNote:find("CHAT_MSG_LOOT",1,true)~=nil,"canonical recipient provenance propagated")
    -- 12-13: user click only, correct realm, empty native whisper, no sending API.
    local whispers,focus=0,0
    ChatFrameUtil={SendTell=function(target) whispers=whispers+1; ChatFrameUtil.target=target; ChatFrameUtil.body="" end,
        FocusActiveWindow=function() focus=focus+1 end}
    function SendChatMessage() error("forbidden automatic message send") end
    check(whispers==0,"no whisper action before click")
    check(ns.ItemRow:Whisper(record(15)) and ChatFrameUtil.target=="Other-otherrealm","quick whisper resolves normalized realm-qualified target")
    check(ChatFrameUtil.body=="" and focus==1 and whispers==1,"empty body focused, no message sent")
    local own=record(16); own.player="Self"; own.realm="Realm"
    check(not ns.ItemRow:Whisper(own),"own loot cannot whisper")
    local incomplete=record(17); incomplete.realm=nil
    check(not ns.ItemRow:Whisper(incomplete),"incomplete identity disables whisper")
    incomplete.player=TestAPI.secret; check(not ns.ItemRow:Whisper(incomplete),"restricted recipient safely disables whisper")
    -- Tooltip and modified click keep the full original hyperlink.
    ns.Main:Show("loot"); row=ns.Main.rows["item:13"] or next(ns.Main.rows) and select(2,next(ns.Main.rows))
    ns.ItemRow:Update(row,record(18),380)
    row.item.scripts.OnEnter(row.item)
    check(GameTooltip.hyperlink==record(18).link,"tooltip receives original full link")
    local clicked
    HandleModifiedItemClick=function(value) clicked=value end
    row.item.scripts.OnClick(row.item); check(clicked==record(18).link,"modified click receives full original link")
    RAID_CLASS_COLORS={MAGE={r=0.25,g=0.78,b=0.92}}
    C_Item.GetItemQualityColor=function() return 0.64,0.21,0.93,"ffa335ee" end
    ns.ItemRow:Update(row,record(18),380)
    check(row.name.color[1]==0.64 and row.name.color[3]==0.93,"item name uses native rarity RGB")
    check(row.recipient.color[1]==0.25 and row.recipient.color[3]==0.92,"known recipient class color applied")
    -- 14: settings validation/persistence, lifecycle restore only on reload.
    ns.Settings:Create(); ns.Settings.modes.manual.scripts.OnClick(ns.Settings.modes.manual)
    check(ns.db.displayMode=="manual","settings mode button uses correct mode")
    ns.Settings:Set("opacity",0.63); ns.Settings:Set("locked",true); ns.Settings:Set("hideMinimap",true)
    ns.Main:SaveWindow(); ns:LoadSettings()
    check(ns.db.opacity==0.63 and ns.db.locked and ns.db.hideMinimap and ns.db.displayMode=="manual","settings survive SavedVariables rebuild")
    ns.Session:Save(); local saved=LootTrackerSession; local before=#ns.Session.entries
    ns.Session.entries,ns.Session.byID={},{}; ns.Session.ready=false; LootTrackerSession=saved
    ns.Session:OnWorld(false,true)
    check(#ns.Session.entries==before and LootTrackerSession==nil,"explicit reload restores bounded genuine history")
    check(ns.recordSequence>=13,"restored IDs reserve canonical counter")
    ns.Session:Save(); saved=LootTrackerSession; ns.Session.entries,ns.Session.byID={},{}; ns.Session.ready=false; LootTrackerSession=saved
    ns.Session:OnWorld(true,false)
    check(#ns.Session.entries==0 and LootTrackerSession==nil,"genuine new login discards logout-written history")
    -- 15-16: diagnostics preserved; demo never touches genuine history or native chat.
    SlashCmdList.DROPWATCH("diag"); check(ns.UI.frame:IsShown(),"explicit diagnostic command works")
    put(record(20)); local genuine=#ns.Session.entries; local calls=whispers
    ns.Demo:Start(); check(ns.Session.demo and #ns.Session:Groups()==2,"demo includes separate history activities")
    check(#ns.Session:Records(true)==4 and ns.Session:Records(true)[1].demo,"demo recent list clearly isolated")
    for _,demo in ipairs(ns.Session.demoEntries) do check(not ns.ItemRow:Whisper(demo),"demo whisper disabled") end
    ns.Session:Put(ns.Session.demoEntries[1],true)
    check(#ns.Session.entries==genuine and whispers==calls,"simulated data cannot enter genuine store or whisper")
    ns.Session:Save(); check(#LootTrackerSession.entries==genuine,"demo not serialized")
    ns.db.displayMode="notification"; ns.Demo:Burst()
    check(ns.Notification.frame:IsShown() and ns.Notification.count==3,"demo burst exercises notification without real loot")
    ns.Demo:Stop(); check(#ns.Session.entries==genuine and not ns.Session.demo,"demo removal leaves genuine history unchanged")
    -- Minimize/restore, resizing persistence, settings and bounded virtualization.
    ns.Main:Show(); ns.Main:Minimize(true)
    check(ns.Main.minimized and ns.Main.frame:GetHeight()==32 and not ns.Main.scroll:IsShown(),"minimize to title bar")
    local storedHeight=ns.db.window.height
    ns.Main.bar.scripts.OnClick(ns.Main.bar)
    check(not ns.Main.minimized and ns.Main.frame:GetHeight()<=storedHeight and ns.db.window.height==storedHeight,"title restores adaptive panel within stored maximum")
    ns.Main.frame:SetSize(520,380); ns.Main:SaveWindow(true)
    check(ns.db.window.width==520 and ns.db.window.height==380,"window dimensions saved")
    reset()
    for id=30,250 do put(record(id)) end
    ns.Main:Show("loot"); draw()
    local visible=0; for _ in pairs(ns.Main.rows) do visible=visible+1 end
    check(#ns.Session.entries==221 and visible<15,"many awards use only visible row frames")
    ns.Main.scroll:SetVerticalScroll(4000)
    visible=0; for _ in pairs(ns.Main.rows) do visible=visible+1 end
    check(visible<15 and visible>0,"scrolling reuses a bounded visible pool")
    local retained=#ns.Session.entries
    ns:Notify("removed",{id=30},"capacity")
    check(#ns.Session.entries==retained,"diagnostic eviction does not erase session history")
    ns:Notify("removed",{id=30},"filtered after item load")
    check(#ns.Session.entries==retained-1,"filtered provisional record can be removed")
    ns.Settings:Set("displayMode","manual")
    ns.Main.minimap.scripts.OnClick(ns.Main.minimap,"RightButton")
    check(ns.Settings.frame:IsShown(),"minimap right-click settings")
    ns.Main:Close(); ns.Main.minimap.scripts.OnClick(ns.Main.minimap,"LeftButton")
    check(ns.Main.frame:IsShown(),"minimap left-click toggles panel")
    ns:Clear(); check(#ns.Session.entries==0 and #ns.Session:Records(true)==0,"clear removes history and recent records")
    local realLimit=ns.Session.limit; ns.Session.limit=5
    for id=300,309 do put(record(id)) end
    check(#ns.Session.entries==5 and not ns.Session.byID[300],"history and reload payload bounded with oldest eviction")
    ns.Session:Save(); check(#LootTrackerSession.entries==5,"only bounded snapshots serialized")
    ns.Session.limit=realLimit
    ns.Session.entries,ns.Session.byID={},{}; ns.Session.ready=false
    LootTrackerSession={version=1,owner="SomeoneElse",entries={record(400)}}
    ns.Session:OnWorld(false,true)
    check(#ns.Session.entries==0,"different character cannot restore history")
    check(ns.Session:Snapshot({id=500,timestamp=time(),equipment=TestAPI.secret,context=TestAPI.secret}).equipment==false,"restricted dynamic snapshot values scrubbed")
    check(not ns.listenerErrors,"no canonical subscriber errors")
    print("PASS: "..checks.." interface/session assertions (mock native UI, Lua 5.1)")
end
