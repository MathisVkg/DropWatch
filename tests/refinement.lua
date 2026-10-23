-- Synthetic links reproduce reported IDs/levels; all recipients and realms are pseudonyms.
function run_refinement(ns)
    local count=0
    local function check(value, message) count=count+1; assert(value,message) end
    local function event(name, ...)
        ns.eventFrame.scripts.OnEvent(ns.eventFrame,name,...)
        local last=ns.raw[#ns.raw]
        assert(not last or last.status~="unprocessed: handler error", "handler failed: "..name)
    end
    local state={ instance=123, difficulty=2, cache=true, instant=true, slot="INVTYPE_WEAPON", class=2, level=311 }
    local roster={player={"Self","Realm","Player-self"}}
    function UnitFullName(unit) local p=roster[unit]; if p then return p[1],p[2] end end
    function UnitGUID(unit) local p=roster[unit]; return p and p[3] end
    function IsInRaid() return false end
    function GetNumGroupMembers() return 5 end
    function GetInstanceInfo()
        if state.missingInstance then return end
        return "Fixture Dungeon", "party",state.difficulty,"Fixture difficulty",5,0,false,state.instance,5
    end
    C_ChallengeMode={GetActiveChallengeMapID=function() return state.activeMap end}
    local function id(query) return type(query)=="number" and query or tonumber(query:match("item:(%d+)")) end
    C_Item.GetItemInfoInstant=function(query)
        if state.instant then return id(query),"type","subtype",state.slot,1234,state.class,1 end
    end
    C_Item.GetItemInfo=function(query)
        if state.cache then return "Fixture Item","DO NOT REPLACE ORIGINAL LINK",4,1,1,"type","subtype",1,state.slot,1234,1,state.class,1 end
    end
    C_Item.GetDetailedItemLevelInfo=function(query) if state.cache then return state.level,false,1 end end
    C_MountJournal.GetMountFromItem=function() return state.mount end
    LOOT_ITEM_PUSHED_SELF="You receive item: %s."
    LOOT_ITEM_PUSHED_SELF_MULTIPLE="You receive item: %sx%d."
    LOOT_ITEM_PUSHED="%s receives item: %s."
    LOOT_ITEM_PUSHED_MULTIPLE="%s receives item: %sx%d."
    LOOT_ITEM_CREATED_SELF="You create: %s."
    LOOT_ITEM_CREATED_SELF_MULTIPLE="You create: %sx%d."
    event("ADDON_LOADED","DropWatch")
    local function reset()
        ns:Clear()
        state.instance,state.difficulty,state.activeMap,state.missingInstance=123,2,nil,false
        state.cache,state.instant,state.slot,state.class,state.level,state.mount=true,true,"INVTYPE_WEAPON",2,311,nil
        roster={player={"Self","Realm","Player-self"}}
        event("PLAYER_ENTERING_WORLD",false,true)
        ns.db.trackMounts=false
    end
    local function link(item,bonus,color,label)
        return (color or "|cffa335ee") .. "|Hitem:"..item..":0:0:0:0:0:0:0:80:0:0:1:"..(bonus or 55).."|h["..(label or "Fixture Item").."]|h|r"
    end
    local line=0
    local function chat(player,item,qty,pushed)
        line=line+1
        local format=pushed and LOOT_ITEM_PUSHED or LOOT_ITEM
        local message=string.format(format,player,item)
        if qty then message=string.format(pushed and LOOT_ITEM_PUSHED_MULTIPLE or LOOT_ITEM_MULTIPLE,player,item,qty) end
        event("CHAT_MSG_LOOT",message,player,nil,nil,nil,nil,nil,nil,nil,nil,line,"untrusted-system-guid")
    end
    local function encounter(player,item,qty,boss)
        event("ENCOUNTER_LOOT_RECEIVED",boss or 900,id(item),item,qty or 1,player,"WARRIOR")
    end
    local helm=link(193756)
    -- A: one Heroic award through both sources.
    reset(); chat("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",helm)
    check(#ns.records==2 and #ns.normalized==1,"A: two observations, one canonical award")
    local r=ns.normalized[1]
    check(#r.sourceEvents==2 and r.link==helm and r.quantity==1,"A: provenance and original link")
    check(r.encounterID==900 and r.confidence.encounter=="confirmed","A: explicit encounter association")
    check(ns.counters.rawLoot==2 and ns.counters.parsed==2 and ns.counters.reconciled==1 and ns.counters.equipment==1,"A: counters")
    -- B: identical Mythic+ drops for different recipients.
    reset(); state.difficulty=8; state.activeMap=456; event("CHALLENGE_MODE_START",123)
    local fang=link(251225)
    chat("Beta-RealmTwo",fang); chat("Gamma-RealmThree",fang)
    encounter("Gamma-RealmThree",fang); encounter("Beta-RealmTwo",fang)
    check(#ns.normalized==2 and ns.counters.reconciled==2,"B: exactly two awards")
    check(ns.normalized[1].player~=ns.normalized[2].player,"B: recipients remain distinct")
    check(ns.normalized[1].itemLevel==311 and ns.normalized[2].itemLevel==311,"B: effective levels")
    -- C: retain successful boss and completed run beyond the old 120-second cutoff.
    event("ENCOUNTER_START",901,"Final Boss",8,5)
    event("ENCOUNTER_END",901,"Final Boss",8,5,1,{})
    event("CHALLENGE_MODE_COMPLETED")
    TestAPI.advance(600)
    chat("Delta-RealmFour",link(251221),nil,true)
    r=ns.normalized[#ns.normalized]
    check(r.context.challenge.state=="completed" and r.context.challenge.challengeMapID==456,"C: delayed completed run")
    check(r.context.lastSuccessfulEncounter.id==901 and r.encounterID==901,"C: successful boss retained")
    check(r.confidence.encounter=="inferred" and r.confidence.mythicPlus=="inferred","C: associations not invented as confirmed")
    check(r.association=="completed run reward candidate","C: end chest does not require boss identity")
    state.instance,state.activeMap,state.difficulty=124,nil,2; event("PLAYER_ENTERING_WORLD",false,false)
    chat("Delta-RealmFour",helm)
    r=ns.normalized[#ns.normalized]
    check(not r.context.challenge and not r.encounterID,"C: new activity clears run and boss")
    -- D: pushed single/multiple, non-Latin and positional localized constants.
    reset(); state.level=318
    chat("Delta-RealmFour",link(251221),nil,true)
    check(ns.records[1].quantity==1 and ns.records[1].format=="LOOT_ITEM_PUSHED","D: single pushed message")
    chat("Delta-RealmFour",helm,3,true)
    check(ns.records[2].quantity==3,"D: localized quantity suffix")
    local previous=LOOT_ITEM_PUSHED
    LOOT_ITEM_PUSHED="%2$s reçu par %1$s."
    event("CHAT_MSG_LOOT",helm.." reçu par Игрок-Мир.","Игрок-Мир")
    check(ns.records[3].player=="Игрок" and ns.records[3].realm=="Мир" and ns.records[3].quantity==1,"D: positional non-Latin")
    LOOT_ITEM_PUSHED=previous
    event("CHAT_MSG_LOOT","Unknown format "..helm,"Delta-RealmFour")
    check(ns.records[4].quantity==nil and ns.normalized[#ns.normalized].confidence.quantity=="unavailable","D: unknown quantity is not fabricated")
    event("CHAT_MSG_LOOT","You receive item: "..helm.."x? .","Self-Realm")
    check(ns.records[#ns.records].quantity==nil,"D: malformed suffix cannot be parsed as single")
    local before=#ns.normalized
    event("CHAT_MSG_LOOT",string.format(LOOT_ITEM_CREATED_SELF,helm),"Self-Realm")
    check(#ns.normalized==before and ns.records[#ns.records].acquisition=="created","D: creation excluded, observation retained")
    -- E: real item data excludes materials, currency items, decorations regardless of rarity.
    reset(); state.slot=""; state.class=7
    chat("Alpha-RealmOne",link(200001))
    state.class=15; chat("Alpha-RealmOne",link(200002)); chat("Alpha-RealmOne",link(200003))
    check(#ns.normalized==0 and #ns.records==3,"E: non-equipment has no canonical equipment record")
    state.slot="INVTYPE_BAG"; state.class=1; chat("Alpha-RealmOne",link(200004))
    check(#ns.normalized==0,"E: bag not gear")
    state.slot="INVTYPE_HOLDABLE"; state.class=4; chat("Alpha-RealmOne",link(200005))
    check(#ns.normalized==1 and ns.normalized[1].category=="armor","E: genuinely equippable offhand")
    -- F: item classification unknown on arrival; merge observations before the async data is ready.
    reset(); state.cache=false; state.instant=false
    local notices={}
    local unsubscribe=ns:Subscribe(function(kind,record) notices[#notices+1]={kind=kind,id=record and record.id} end)
    chat("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",helm)
    check(#ns.normalized==1 and not ns.normalized[1].loaded,"F: one pending canonical record")
    local pending=ns.normalized[1]; local stableID=pending.id
    state.cache=true; state.instant=true
    event("ITEM_DATA_LOAD_RESULT",193756,true)
    check(#ns.normalized==1 and pending.id==stableID and pending.itemName=="Fixture Item" and pending.selected,"F: enrich existing stable record")
    local kinds={}
    for _,notice in ipairs(notices) do kinds[notice.kind]=true end
    check(kinds.created and kinds.reconciled and kinds.enriched and kinds.classification,"F: all subscription event types")
    unsubscribe()
    local unsubscribedCount=#notices
    chat("Other-RealmTwo",helm)
    check(#notices==unsubscribedCount,"subscription can be removed")
    reset(); state.cache=false; state.class=nil
    chat("Alpha-RealmOne",helm)
    check(#ns.normalized==0 and not ns.records[1].loaded,"F: incomplete classification remains a pending observation")
    local earlierTimestamp=ns.records[1].timestamp
    TestAPI.advance(1); state.cache=true; state.class=2
    encounter("Alpha-RealmOne",link(193756,55,"|cnIQ4:"))
    local lateID=ns.normalized[1].id
    event("ITEM_DATA_LOAD_RESULT",193756,true)
    check(#ns.normalized==1 and ns.normalized[1].id==lateID and ns.normalized[1].link==helm
        and ns.normalized[1].timestamp==earlierTimestamp,"F: earlier pending observation reconciles after later source and retains earliest link/time")
    -- G: same player genuinely gets two copies, each notified through both sources.
    reset(); chat("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",helm)
    chat("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",helm)
    check(#ns.normalized==2 and ns.counters.reconciled==2,"G: repeated awards retained and individually paired")
    reset(); chat("Alpha-RealmOne",helm); chat("Alpha-RealmOne",helm)
    encounter("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",helm)
    check(#ns.normalized==4 and ns.counters.reconciled==0 and ns.counters.ambiguous==2,"G: batched identical awards retain ambiguous observations")
    check(ns.normalized[1].ambiguous and ns.normalized[4].ambiguous,"G: candidate records exposed")
    -- H: unique roster expansion and cross-realm collision handling.
    reset(); roster.party1={"Twin","RealmOne","Player-twin-one"}; roster.party2={"Twin","RealmTwo","Player-twin-two"}
    event("GROUP_ROSTER_UPDATE")
    chat("Twin-RealmOne",helm); chat("Twin-RealmTwo",helm)
    encounter("Twin-RealmTwo",helm); encounter("Twin-RealmOne",helm)
    check(#ns.normalized==2 and ns.normalized[1].guid~=ns.normalized[2].guid,"H: same character name, different realms/GUIDs")
    reset(); roster.party1={"Unique","Realm One","Player-unique"}; event("GROUP_ROSTER_UPDATE")
    chat("Unique",helm); encounter("Unique-RealmOne",helm)
    check(#ns.normalized==1 and ns.normalized[1].guid=="Player-unique","H: safe bare name expansion")
    check(ns.records[1].recipient.realmConfidence=="inferred" and ns.normalized[1].confidence.realm=="confirmed","H: later explicit realm upgrades confidence")
    check(ns.Recipients.Match({name="Twin",realmKey="one",guid="Player-same"},{name="Twin",realmKey="two",guid="Player-same"})=="different","H: contradictory GUID cannot override different realms")
    reset(); chat("Bare",helm); encounter("Bare-RealmOne",helm)
    check(#ns.normalized==2 and ns.counters.ambiguous==1,"H: no roster evidence, no realm guess")
    -- I: inverse source order yields the same canonical information.
    reset(); encounter("Alpha-RealmOne",helm); chat("Alpha-RealmOne",helm)
    check(#ns.normalized==1 and #ns.normalized[1].sourceEvents==2 and ns.normalized[1].quantity==1,"I: encounter first")
    -- J: unavailable and restricted arguments/API results never create values.
    reset(); event("CHAT_MSG_LOOT",TestAPI.secret,TestAPI.secret,nil,nil,nil,nil,nil,nil,nil,nil,TestAPI.secret,TestAPI.secret)
    event("ENCOUNTER_LOOT_RECEIVED",TestAPI.secret,nil,TestAPI.secret,nil,TestAPI.secret)
    check(#ns.normalized==0 and ns.counters.failures==2,"J: missing/restricted payloads retained safely")
    event("ENCOUNTER_LOOT_RECEIVED",900,193756,nil,1,"Alpha-RealmOne")
    r=ns.normalized[1]
    check(r and not r.link and not r.itemLevel and r.confidence.link=="unavailable","J: ID-only lookup never invents original link or effective level")
    local getLevel=C_Item.GetDetailedItemLevelInfo
    C_Item.GetDetailedItemLevelInfo=function() return TestAPI.secret end
    chat("Beta-RealmTwo",helm)
    check(ns.normalized[#ns.normalized].itemLevel==nil,"J: secret API result scrubbed")
    C_Item.GetDetailedItemLevelInfo=getLevel
    reset(); event("ENCOUNTER_LOOT_RECEIVED",900,193755,helm,1,"Alpha-RealmOne")
    check(ns.normalized[1].ambiguous and not ns.normalized[1].itemID and ns.counters.failures==1,"J: conflicting event/link IDs are not presented as confirmed")
    reset()
    roster.party1={"Private","RealmOne","Player-private"}
    local getGUID=UnitGUID
    UnitGUID=function(unit) if unit=="party1" then return TestAPI.secret end; return getGUID(unit) end
    event("GROUP_ROSTER_UPDATE"); chat("Private-RealmOne",helm)
    check(not ns.normalized[1].guid and ns.normalized[1].confidence.guid=="unavailable","J: restricted roster GUID is not used")
    UnitGUID=getGUID
    local fullName,raidCount,isRaid=UnitFullName,GetNumGroupMembers,IsInRaid
    UnitFullName=function() return 123,true end
    GetNumGroupMembers=function() return "unexpected" end
    IsInRaid=function() return true end
    event("GROUP_ROSTER_UPDATE")
    check(next(ns.Recipients.byName)==nil,"J: unexpected roster scalar types handled")
    UnitFullName,GetNumGroupMembers,IsInRaid=fullName,raidCount,isRaid
    event("GROUP_ROSTER_UPDATE")
    -- Link display changes can match; variant changes and unequal quantities cannot.
    reset(); chat("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",link(193756,55,"|cnIQ4:","Autre nom"))
    check(#ns.normalized==1 and ns.normalized[1].link==helm,"same variant ignores display/color, preserves original")
    reset(); chat("Alpha-RealmOne",helm); encounter("Alpha-RealmOne",link(193756,56))
    check(#ns.normalized==2 and ns.counters.ambiguous==1,"different item bonus payload not merged")
    reset(); chat("Alpha-RealmOne",helm,2); encounter("Alpha-RealmOne",helm,1)
    check(#ns.normalized==2 and ns.counters.reconciled==0,"different quantities not merged")
    reset(); chat("Alpha-RealmOne",helm); TestAPI.advance(11); encounter("Alpha-RealmOne",helm)
    check(#ns.normalized==2 and ns.counters.ambiguous==1,"outside pairing window retained as ambiguity")
    -- Context reset, wipe, no boss, missing instance and immutable snapshots.
    reset(); state.difficulty=8; state.activeMap=456; event("CHALLENGE_MODE_START",123)
    event("CHALLENGE_MODE_COMPLETED"); chat("Alpha-RealmOne",helm)
    local old=ns.normalized[1].context
    check(old.challenge.state=="completed" and not old.encounter,"end-of-run reward needs no boss")
    event("PLAYER_ENTERING_WORLD",false,false)
    check(ns.Context:Snapshot().challenge.state=="completed","same-activity world transition keeps completed context")
    event("CHALLENGE_MODE_RESET",123)
    check(not ns.Context:Snapshot().challenge and old.challenge.state=="completed","reset clears current context without mutating snapshots")
    event("ENCOUNTER_START",902,"Wiped Boss",8,5); event("ENCOUNTER_END",902,"Wiped Boss",8,5,0,{})
    check(not ns.Context:Snapshot().lastSuccessfulEncounter,"failed encounter is not last success")
    state.activeMap=nil; state.missingInstance=true; event("PLAYER_ENTERING_WORLD",false,false)
    state.missingInstance=false; state.instance=999; event("PLAYER_ENTERING_WORLD",false,false)
    check(not ns.Context:Snapshot().encounter and not ns.Context:Snapshot().challenge,"missing snapshot does not hide an activity transition")
    -- Mount option and asynchronous filtering.
    reset(); state.mount=777; state.slot=""; state.class=15; chat("Alpha-RealmOne",helm)
    check(#ns.normalized==0 and ns.records[1].category=="mount","mount excluded by default")
    ns.db.trackMounts=true; chat("Alpha-RealmOne",helm)
    check(#ns.normalized==1 and ns.normalized[1].mountID==777,"optional mount normalized")
    reset(); state.cache=false; state.instant=false; chat("Alpha-RealmOne",helm)
    state.cache=true; state.instant=true; state.slot=""; state.class=7
    event("ITEM_DATA_LOAD_RESULT",193756,true)
    check(#ns.normalized==0 and #ns.records==1,"pending irrelevant item removed, diagnostic observation retained")
    -- Stable chat IDs, bounds, late callbacks, all diagnostic views and listener isolation.
    reset(); chat("Alpha-RealmOne",helm)
    event("CHAT_MSG_LOOT",string.format(LOOT_ITEM,"Alpha-RealmOne",helm),"Alpha-RealmOne",nil,nil,nil,nil,nil,nil,nil,nil,line)
    check(#ns.normalized==1 and #ns.records==1 and ns.counters.rawLoot==2,"stable chat line repeat processed once")
    reset(); state.cache=false; state.instant=false; chat("Alpha-RealmOne",helm)
    local retained=ns.normalized[1]
    state.cache=true; state.instant=true; state.slot=""; state.class=7
    for i=1,205 do chat("Material-RealmOne",link(200001)) end
    state.slot="INVTYPE_WEAPON"; state.class=2
    event("ITEM_DATA_LOAD_RESULT",193756,true)
    check(retained.loaded and #ns.normalized==1,"pending canonical enriches after observation row eviction")
    reset()
    for i=1,205 do chat("Player"..i.."-RealmOne",helm) end
    check(#ns.raw==200 and #ns.records==200 and #ns.normalized==200,"all stores independently bounded")
    SlashCmdList.DROPWATCH("diag")
    for i=1,5 do
        ns.UI.mode=i; ns.UI:Render()
        check(type(ns.UI.edit.text)=="string" and #ns.UI.edit.text>0,"diagnostic view "..i)
    end
    ns.UI.mode=3; ns.UI:Render()
    check(ns.UI.edit.text:find("Sources:",1,true)~=nil,"normalized view exposes source provenance")
    -- Explicit encounter IDs must never borrow the name of a different retained boss.
    reset(); event("ENCOUNTER_START",999,"Unrelated Boss",2,5); event("ENCOUNTER_END",999,"Unrelated Boss",2,5,1,{})
    encounter("Alpha-RealmOne",helm,1,900)
    ns.UI.mode=3; ns.UI:Render()
    check(not ns.normalized[1].encounterName and not ns.UI.edit.text:find("Unrelated Boss",1,true),"explicit encounter does not borrow unrelated boss name")
    local off=ns:Subscribe(function() error("listener failure") end)
    chat("New-RealmOne",helm)
    check(ns.listenerErrors and ns.listenerErrors>0,"listener error isolated")
    off(); ns:Clear(); event("ITEM_DATA_LOAD_RESULT",193756,true)
    check(#ns.normalized==0 and #ns.records==0 and ns.counters.rawLoot==0,"clear resets all stores/counters; no late resurrection")
    print("PASS: "..count.." refinement assertions (A-J fixtures and edge cases, Lua 5.1)")
end
