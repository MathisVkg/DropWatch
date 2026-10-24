-- Synthetic names/links only; no real player identities or captured chat.
function run_acquisition(ns)
    local count = 0
    local function check(v, m) count=count+1; assert(v, m) end
    local function event(name, ...)
        ns.eventFrame.scripts.OnEvent(ns.eventFrame, name, ...)
        local last=ns.raw[#ns.raw]
        assert(not last or last.status~="unprocessed: handler error", "handler failed: "..name)
    end
    local state={quality=4,level=282,cached=true,instant=true,slot="INVTYPE_CLOAK",class=4}
    local function link(level)
        return "|cffa335ee|Hitem:123:0:0:0:0:0:0:0:80:0:0:1:"..(level or 282).."|h[Fixture Cloak]|h|r"
    end
    local line=100
    local function chat(who, item, sameLine, text)
        if not sameLine then line=line+1 end
        event("CHAT_MSG_LOOT", text or (who.." receives loot: "..item.."."), who,
            nil,nil,nil,nil,nil,nil,nil,nil,line)
    end
    local function encounter(who,item)
        event("ENCOUNTER_LOOT_RECEIVED",900,123,item,1,who,"MAGE")
    end
    GetInstanceInfo=function()
        return "Fixture Activity",state.instanceType or "party",state.difficulty or 2,
            "Fixture difficulty",5,0,false,state.instanceID or 123,5
    end
    C_Item.GetItemInfoInstant=function()
        if state.instant then return 123,"Armor","Cloth",state.slot,456,state.class,1 end
    end
    C_Item.GetItemInfo=function()
        if state.cached then return "Fixture Cloak","DO NOT USE",state.quality,1,1,"Armor","Cloth",1,
            state.slot,456,0,state.class,1,state.bind end
    end
    C_Item.GetDetailedItemLevelInfo=function() return state.level end
    C_Item.IsItemBindToAccount=function() return state.account end
    C_Item.IsItemBindToAccountUntilEquip=function() return state.account end
    C_MountJournal.GetMountFromItem=function() return state.mount end
    local upgradeReads=0
    C_ItemUpgrade={
        GetItemHyperlink=function() upgradeReads=upgradeReads+1; return state.upgradeLink or link(state.level) end,
        GetItemUpgradeCurrentLevel=function() return state.level end,
    }
    LOOT_ITEM_PUSHED="%s receives item: %s."
    LOOT_ITEM_PUSHED_SELF="You receive item: %s."
    LOOT_ITEM_CREATED_SELF="You create: %s."
    event("ADDON_LOADED","DropWatch"); event("PLAYER_ENTERING_WORLD",true,false)
    local function reset()
        ns:Clear(); ns.db.debug=false; ns.db.trackMounts=false; ns.db.displayMode="notification"
        ns.Main:Close(); ns.upgradeOpen=nil
        state.quality,state.level,state.cached,state.instant=4,282,true,true
        state.slot,state.class,state.account,state.mount,state.bind="INVTYPE_CLOAK",4,false,nil,nil
        state.upgradeLink=nil
        state.instanceType,state.difficulty,state.instanceID="party",2,123
    end
    reset(); ns.db.debug=true; state.quality=0
    chat("Party-Realm",link())
    check(#ns.normalized==0,"confirmed grey equipment never creates a canonical award")
    check(#ns.Session:Records(true)==0 and #ns.Session:Records(false)==0,"grey absent from Recent and History")
    check(ns.Notification.count==0 and (not ns.Notification.frame or not ns.Notification.frame:IsShown()),"grey does not notify")
    check(#ns.records==1 and #ns.raw==1 and ns.records[1].rarity==0,"grey diagnostic evidence retained")
    check(ns.records[1].status=="filtered: Poor-quality equipment","explicit grey filtering reason")
    ns.UI:Create(); ns.UI.frame:Show(); ns.UI.mode=2; ns.UI:Render()
    check(ns.UI.edit.text:find("Poor-quality",1,true)~=nil,"debug observations explain grey exclusion")
    -- All other supported qualities remain possible, not Epic-only.
    for _, quality in ipairs({1,2,3,4,5,6,7,8}) do
        reset(); state.quality=quality; chat("Party-Realm",link())
        check(#ns.Session:Records(true)==1,"supported equipment quality "..quality)
    end
    for _, mode in ipairs({"automatic","notification","manual"}) do
        reset(); ns.db.displayMode=mode; state.quality=nil
        chat("Party-Realm",link())
        check(#ns.normalized==1 and ns.records[1].qualityPending,"unknown quality retains acquisition candidate: "..mode)
        check(#ns.Session.entries==0 and ns.Notification.count==0 and (not ns.Main.frame or not ns.Main.frame:IsShown()),
            "unknown quality stays silent in "..mode)
        state.quality=0; event("ITEM_DATA_LOAD_RESULT",123,true)
        check(#ns.normalized==0 and #ns.Session.entries==0,"late grey safely removed in "..mode)
    end
    reset(); state.quality=nil; chat("Party-Realm",link())
    local pending=ns.normalized[1]; local stamp=pending.timestamp
    state.quality=3; event("ITEM_DATA_LOAD_RESULT",123,true)
    check(#ns.normalized==1 and ns.normalized[1]==pending and pending.rarity==3,"late Rare data enriches original candidate")
    check(#ns.Session.entries==1 and ns.Notification.count==1 and pending.timestamp==stamp,"late quality announces once at original acquisition time")
    local revision=pending.revision
    for i=1,10 do event("ITEM_DATA_LOAD_RESULT",123,true) end
    check(#ns.normalized==1 and #ns.Session.entries==1 and ns.Notification.count==1 and pending.revision==revision,
        "duplicate load callbacks do not create or announce awards")
    ns.Normalize:Ingest(ns.records[1])
    check(#ns.normalized==1 and ns.Notification.count==1,"repeated observation ingestion is idempotent")
    -- Cache/level changes and NPC activity alone are not acquisition events.
    reset(); ns.db.debug=true
    event("ITEM_UPGRADE_MASTER_OPENED")
    for _, level in ipairs({282,285,288}) do
        state.level=level
        event("ITEM_UPGRADE_MASTER_SET_ITEM"); event("ITEM_UPGRADE_MASTER_UPDATE")
        event("ITEM_DATA_LOAD_RESULT",123,true); event("ITEM_DATA_LOAD_RESULT",123,true)
        event("UNIT_INVENTORY_CHANGED","player"); event("PLAYER_EQUIPMENT_CHANGED",15,true)
    end
    event("ITEM_UPGRADE_MASTER_CLOSED")
    check(#ns.records==0 and #ns.normalized==0 and #ns.Session.entries==0,"repeated NPC upgrades/level changes without acquisition produce no awards")
    check(ns.Notification.count==0,"NPC-only events never notify")
    check(ns.raw[1].status=="upgrade diagnostic only (no acquisition)","upgrade markers are explicitly diagnostic")
    check(ns.raw[1].args.itemID==123 and ns.raw[1].args.itemLevel==282,"upgrade trace captures selected item ID/level")
    check(ns.raw[1].args.player==nil and ns.raw[1].args.link==nil,"upgrade trace adds no player identity or inventory/link dump")
    -- Do not claim an acquisition-sounding message is proven to be an upgrade.
    chat("Self-Realm",link(),false,string.format(LOOT_ITEM_PUSHED_SELF,link()))
    check(#ns.normalized==1,"recognized pushed acquisition remains supported pending live evidence")
    check(ns.raw[#ns.raw].upgradeOpen==false,"debug acquisition carries NPC correlation marker")
    -- Unknown upgrade-looking messages and creation are diagnostic-only.
    reset()
    chat("Self-Realm",link(285),false,"Your item was upgraded: "..link(285)..".")
    event("ITEM_DATA_LOAD_RESULT",123,true)
    check(#ns.records==1 and #ns.normalized==0,"unrecognized modification text is not acquisition evidence")
    chat("Self-Realm",link(),false,string.format(LOOT_ITEM_CREATED_SELF,link()))
    check(#ns.normalized==0,"creation not counted as loot")
    encounter("Other-Realm","|Hitem:124|h[Conflict]|h")
    check(#ns.normalized==0,"conflicting item identifiers cannot award")
    chat("Other-Realm",link(),false,"Different-Realm receives loot: "..link()..".")
    check(#ns.normalized==0,"conflicting recipient fields cannot award")
    -- Refreshes may complete metadata but never rewrite an already captured item level.
    reset(); state.account=nil; chat("Self-Realm",link(282))
    local award=ns.normalized[1]; local original=award.link
    check(ns.records[1].deadline~=nil,"binding-pending item remains refreshable")
    for _, level in ipairs({285,288,291}) do
        state.level=level; event("ITEM_UPGRADE_MASTER_UPDATE"); event("ITEM_DATA_LOAD_RESULT",123,true)
        check(award.itemLevel==282 and ns.records[1].itemLevel==282,"captured award level remains frozen at "..level)
        check(award.link==original and ns.Session.entries[1].link==original,"original hyperlink remains intact at "..level)
    end
    check(ns.Session.entries[1].itemLevel==282 and ns.Notification.count==1,"History snapshot retains acquisition level without extra notification")
    state.account=false; TestAPI.advance(16); ns.Loot:Expire()
    check(award.itemLevel==282 and #ns.normalized==1,"timeout enrichment cannot rewrite level")
    -- Standalone metadata-shaped observations cannot enter via normalization Update/Ingest.
    local fake={source="ITEM_DATA_LOAD_RESULT",itemID=123,parsed=true,acquisition="loot",equipment=true,rarity=4}
    ns.Normalize:Update(fake); ns.Normalize:Ingest(fake)
    check(#ns.normalized==1,"metadata event cannot be treated as acquisition")
    fake.source="CHAT_MSG_LOOT"; ns.Normalize:Update(fake)
    check(#ns.normalized==1,"Update requires an already captured acquisition candidate")
    -- Identical drops remain distinct across recipients and separate acquisitions.
    reset(); event("CHALLENGE_MODE_START",123); event("CHALLENGE_MODE_COMPLETED")
    chat("First-Realm",link()); chat("Second-Realm",link())
    encounter("Second-Realm",link()); encounter("First-Realm",link())
    check(#ns.normalized==2 and ns.counters.reconciled==2,"M+ multiple-source rewards reconcile per recipient")
    check(#ns.Session.entries==2 and ns.Notification.count==2,"M+ awards stay separately visible")
    check(ns.normalized[1].context.challenge.state=="completed","M+ completed context retained")
    TestAPI.advance(30); chat("First-Realm",link()); encounter("First-Realm",link())
    check(#ns.normalized==3 and ns.counters.reconciled==3,"same recipient can genuinely acquire same item later")
    TestAPI.advance(1); state.level=285; chat("First-Realm",link(285)); encounter("First-Realm",link(285))
    check(#ns.normalized==4 and ns.normalized[4].itemLevel==285 and ns.normalized[1].itemLevel==282,
        "genuine different-level acquisition supported without mutating older award")
    -- Normal dungeon/raid awards and context boundaries preserve real acquisitions.
    for _, activity in ipairs({{"party",2},{"raid",14}}) do
        reset(); state.instanceType,state.difficulty=activity[1],activity[2]
        event("PLAYER_ENTERING_WORLD",false,false); event("ENCOUNTER_START",900,"Fixture Boss",activity[2],5)
        chat("Party-Realm",link()); encounter("Party-Realm",link())
        check(#ns.normalized==1 and ns.counters.reconciled==1,"genuine boss drop reconciles in "..activity[1])
        check(#ns.Session:Records(true)==1,"genuine boss drop visible in "..activity[1])
    end
    reset(); chat("Party-Realm",link()); state.instanceID=124
    event("PLAYER_ENTERING_WORLD",false,false); encounter("Party-Realm",link())
    check(#ns.normalized==2 and ns.counters.reconciled==0,"different instance context never merges awards")
    reset(); chat("Party-Realm",link())
    local first=ns.normalized[1]; local before=#ns.normalized
    event("CHALLENGE_MODE_COMPLETED_REWARDS",123,1,1,1,{{rewardID=123}})
    event("ITEM_DATA_LOAD_RESULT",123,true)
    check(#ns.normalized==before and ns.normalized[1]==first,"reward summary and metadata never create acquisition candidates")
    ns.db.debug=true; event("ITEM_UPGRADE_MASTER_OPENED")
    chat("Other-Realm",link())
    check(#ns.normalized==2 and ns.raw[#ns.raw].upgradeOpen==true,"genuine loot is not suppressed while upgrade NPC is open")
    event("ITEM_UPGRADE_MASTER_CLOSED")
    -- Stable client line IDs, rather than item-ID/name global deduplication.
    reset(); chat("First-Realm",link()); TestAPI.advance(6); chat("First-Realm",link(),true)
    check(#ns.normalized==1 and #ns.records==1,"stable chat line replay after five seconds stays duplicate")
    chat("First-Realm",link())
    check(#ns.normalized==2,"new chat line permits genuine identical acquisition")
    reset(); state.account=true; chat("Party-Realm",link())
    check(#ns.Session:Records(false)==0 and ns.Notification.count==0,"Warbound exclusion intact")
    reset(); state.slot=""; state.class=15; state.mount=777; state.quality=nil
    chat("Party-Realm",link())
    check(#ns.normalized==0,"mount option off unchanged")
    ns.db.trackMounts=true; chat("Party-Realm",link())
    check(#ns.normalized==1 and #ns.Session:Records(true)==1,"mount option unaffected by equipment quality gate")
    -- Secret/malformed metadata stays unavailable and never becomes an unsafe comparison.
    for _, quality in ipairs({TestAPI.secret,"0",-1,0.5}) do
        reset(); state.quality=quality; chat("Party-Realm",link())
        check(#ns.Session.entries==0 and ns.records[1].qualityPending,"restricted/malformed quality deferred")
    end
    reset(); state.upgradeLink=TestAPI.secret; state.level=TestAPI.secret; ns.db.debug=true
    event("ITEM_UPGRADE_MASTER_SET_ITEM")
    check(ns.raw[1].args.itemID==nil and ns.raw[1].args.itemLevel==nil,"restricted upgrade data safely omitted")
    reset(); ns.db.debug=true
    local upgradeAPI=C_ItemUpgrade; C_ItemUpgrade=nil
    event("ITEM_UPGRADE_MASTER_UPDATE")
    check(ns.raw[1].args.itemID==nil and #ns.normalized==0,"missing upgrade API is safe and never awards")
    C_ItemUpgrade=upgradeAPI
    local guard=issecretvalue; issecretvalue=nil; local reads=upgradeReads
    event("ITEM_UPGRADE_MASTER_UPDATE")
    check(upgradeReads==reads and #ns.normalized==0,"missing secret guard disables diagnostic queries safely")
    issecretvalue=guard
    reset(); local before=upgradeReads; event("ITEM_UPGRADE_MASTER_OPENED"); event("ITEM_UPGRADE_MASTER_UPDATE")
    check(upgradeReads==before and #ns.raw==0,"debug off adds no upgrade queries or trace")
    -- Pending quality never becomes visible merely because a timer expires.
    state.quality=nil; chat("Party-Realm",link()); TestAPI.advance(16); ns.Loot:Expire()
    check(#ns.Session.entries==0 and ns.Notification.count==0,"quality timeout remains safely deferred")
    -- Reload recovery applies the same rule even to older cached snapshots.
    local saved={id=999,timestamp=time(),equipment=true,loaded=true,rarity=0,category="armor",context={}}
    ns.Session:Put(saved,false)
    check(not ns.Session.byID[999],"legacy grey snapshot cannot enter History")
    saved.rarity=nil; ns.Session:Put(saved,false)
    check(not ns.Session.byID[999],"legacy unknown-quality snapshot waits safely")
    -- Eviction cannot let a captured observation create a second award on direct replay.
    reset(); chat("Party-Realm",link())
    local captured=ns.records[1]; ns.normalized={}
    ns.Normalize:Ingest(captured); ns.Normalize:Update(captured)
    check(#ns.normalized==0,"late callbacks cannot resurrect a canonical record evicted from diagnostics")
    reset(); state.cached=false; state.instant=false; chat("Party-Realm",link())
    local id=ns.normalized[1].id
    state.cached=true; state.instant=true; state.quality=0
    event("ITEM_DATA_LOAD_RESULT",123,true); event("ITEM_DATA_LOAD_RESULT",123,true)
    check(#ns.normalized==0 and #ns.Session.entries==0 and ns.Notification.count==0,"uncached grey never flashes or creates History on repeated loads")
    check(ns.records[1].canonicalID==id,"filtered observation retains original diagnostic provenance")
    check(not ns.listenerErrors,"acquisition regression callbacks succeed")
    print("PASS: "..count.." acquisition/quality/upgrade assertions")
end
