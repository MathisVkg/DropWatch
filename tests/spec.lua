local clock, requests, frames, messages = 0, {}, {}, {}
local secret = setmetatable({}, { __tostring=function() error("secret formatted") end,
    __concat=function() error("secret concatenated") end })
function issecretvalue(value) return rawequal(value, secret) end
function canaccesstable(value) return not value.forbidden end
function issecrettable(value) return value.secretTable == true end
function GetTime() return clock end
function time() return 100000+clock end
function date() return "12:00:00" end
function UnitFullName() return "Self", "Realm" end
function GetBuildInfo() return "12.1.5", "70077", "Oct 13 2026", 120105 end
function GetInstanceInfo() return "Test Dungeon", "party", 8, "Mythic Keystone", 5, 0, false, 123, 5 end
DEFAULT_CHAT_FRAME = { AddMessage=function(_, text) messages[#messages+1]=text end }
SlashCmdList, UISpecialFrames = {}, {}
UIParent = {}
function CreateFrame(kind,name,parent,template)
    local f = { scripts={}, events={}, shown=true, kind=kind, parent=parent, template=template, enabled=true }
    local noop = function() end
    setmetatable(f, { __index=function(_,key) if type(key)=="string" and key:match("^[A-Z]") then return noop end end })
    function f:SetScript(name, fn) self.scripts[name]=fn end
    function f:HookScript(name,fn)
        local old=self.scripts[name]
        self.scripts[name]=function(...) if old then old(...) end; fn(...) end
    end
    function f:RegisterEvent(event) self.events[event]=true; return true end
    function f:UnregisterEvent(event) self.events[event]=nil end
    function f:CreateFontString() return CreateFrame() end
    function f:CreateLine() return CreateFrame("Line",nil,self) end
    function f:SetBackdropColor(...) self.backgroundColor={...} end
    function f:SetBackdropBorderColor(...) self.borderColor={...} end
    function f:SetAlpha(value) self.alpha=value end
    function f:CreateTexture() return CreateFrame("Texture",nil,self) end
    function f:SetSize(w,h) self.width,self.height=w,h; if self.scripts.OnSizeChanged then self.scripts.OnSizeChanged(self,w,h) end end
    function f:SetWidth(w) self.width=w end
    function f:SetHeight(h) self.height=h end
    function f:GetWidth() local parent=rawget(self,"parent"); return rawget(self,"width") or (parent and parent:GetWidth()-(self.kind=="ScrollFrame" and 40 or 0)) or 380 end
    function f:GetHeight() local parent=rawget(self,"parent"); return rawget(self,"height") or (parent and parent:GetHeight()-(self.kind=="ScrollFrame" and 78 or 0)) or 222 end
    function f:SetPoint(point,relative,relativePoint,x,y)
        if type(relative)=="number" then x,y,relative,relativePoint=relative,relativePoint,UIParent,point end
        self.point={point,relative or UIParent,relativePoint or point,x or 0,y or 0}
    end
    function f:ClearAllPoints() self.point=nil end
    function f:GetPoint() local p=rawget(self,"point") or {"CENTER",UIParent,"CENTER",10,20}; return unpack(p) end
    function f:GetFrameLevel() return 1 end
    function f:GetCenter() return 500,400 end
    function f:GetEffectiveScale() return rawget(self,"scale") or 1 end
    function f:GetLeft() return 100 end
    function f:GetTop() return 600 end
    function f:SetVerticalScroll(value) self.offset=value; if self.scripts.OnVerticalScroll then self.scripts.OnVerticalScroll(self,value) end end
    function f:GetVerticalScroll() return rawget(self,"offset") or 0 end
    function f:GetThumbTexture() self.thumb=rawget(self,"thumb") or CreateFrame("Texture"); return self.thumb end
    function f:SetValue(value) self.value=value; if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,value) end end
    function f:SetEnabled(value) self.enabled=value end
    function f:SetTexture(value) self.texture=value end
    function f:SetTextColor(...) self.color={...} end
    function f:SetText(text) self.text=text end
    function f:IsShown() return self.shown end
    function f:SetShown(show)
        local changed=self.shown~=show
        self.shown=show
        if changed and show and self.scripts.OnShow then self.scripts.OnShow(self) end
        if changed and not show and self.scripts.OnHide then self.scripts.OnHide(self) end
    end
    function f:Hide() self:SetShown(false) end
    function f:Show() self:SetShown(true) end
    frames[#frames+1]=f
    return f
end
UIParent=CreateFrame("Frame"); UIParent:SetSize(1920,1080)
Minimap=CreateFrame("Frame",nil,UIParent); Minimap:SetSize(150,150)
GameTooltip=CreateFrame("Tooltip")
function GameTooltip:SetHyperlink(link) self.hyperlink=link end
local timers={}
C_Timer={NewTimer=function(delay,callback)
    local timer={deadline=clock+delay,callback=callback}
    function timer:Cancel() self.cancelled=true end
    timers[#timers+1]=timer; return timer
end}
local function advance(seconds)
    local target=clock+seconds
    for iteration=1,10000 do
        local nextTimer
        for _,timer in ipairs(timers) do
            if not timer.cancelled and not timer.fired and timer.deadline<=target and (not nextTimer or timer.deadline<nextTimer.deadline) then nextTimer=timer end
        end
        if not nextTimer then clock=target; return end
        clock=nextTimer.deadline; nextTimer.fired=true; nextTimer.callback()
    end
    error("timer runaway")
end
LOOT_ITEM_SELF = "You receive loot: %s."
LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d."
LOOT_ITEM = "%s receives loot: %s."
LOOT_ITEM_MULTIPLE = "%s receives loot: %sx%d."
local cached = true
C_Item = {
    GetItemInfoInstant=function(query) return 123, "Armor", "Plate", "INVTYPE_HEAD", 456, 4, 4 end,
    GetItemInfo=function(query)
        if cached then return "Helm", "REBUILT LINK MUST NOT BE USED", 4, 90, 1, "Armor", "Plate", 1, "INVTYPE_HEAD", 456, 1, 4, 4 end
    end,
    GetDetailedItemLevelInfo=function(query) if cached then return 100, false, 90 end end,
    RequestLoadItemDataByID=function(id) requests[#requests+1]=id end,
}
C_MountJournal = { GetMountFromItem=function() return nil end }
local count = 0
TestAPI={ secret=secret, advance=advance, frames=frames }
local function check(condition, message)
    count=count+1
    assert(condition, message)
end
function run_tests(ns)
    local P, S = ns.Parser, ns.Safe
    local link = "|cffa335ee|Hitem:123:0:0:0:0:0:0:0:80:0:0:2:1:2|h[Test Helm]|h|r"
    local function event(name, ...) ns.eventFrame.scripts.OnEvent(ns.eventFrame, name, ...) end
    event("ADDON_LOADED", "LootTracker")
    check(ns.db.debug == false and ns.db.maxRecords == 200, "settings defaults")
    for _, name in ipairs(ns.events) do check(ns.registered[name] == "registered", "registration " .. name) end
    check(P.Links("prefix "..link.." suffix")[1] == link, "preserve complete hyperlink")
    check(#P.Links(link.." "..link)==2, "multiple links")
    local namedLink="|cnIQ4:|Hitem:123|h[Named color item]|h|r"
    check(P.Links("prefix "..namedLink)[1]==namedLink, "named color and short link preserved")
    check(#P.Links(secret)==0, "secret message")
    check(S.Snapshot(secret, 3, {left=10})=="<secret>", "secret redaction")
    check(S.Snapshot(false, 3, {left=10})==false, "false preserved")
    check(S.Snapshot({forbidden=true}, 3, {left=10})=="<inaccessible table>", "forbidden tables")
    check(S.Snapshot({secretTable=true}, 3, {left=10})=="<secret table>", "secret tables")
    local cycle={}; cycle.self=cycle
    check(type(S.Snapshot(cycle, 3, {left=10}))=="table", "cyclic table bounded")
    local args=S.Args("a", nil, false)
    check(args.n==3 and args[2]=="<nil>" and args[3]==false, "nil holes preserved")
    local positional=P.Format("%2$s pour %1$s x%3$d.", link.." pour Alice x2.")
    check(positional[1]=="Alice" and positional[2]==link and positional[3]=="2", "positional localization")
    local who, qty=P.Chat("You receive loot: "..link.."x2.")
    check(who=="Self-Realm" and qty==2, "self recipient and quantity")
    who,qty=P.Chat("Alice-Other receives loot: "..link..".")
    check(who=="Alice-Other" and qty==1, "other recipient")
    who,qty=P.Chat("unrecognized "..link, "")
    check(who==nil and qty==nil, "unknown locale remains unknown")
    local name,realm=P.Name("Alice-Other")
    check(name=="Alice" and realm=="Other", "realm split")
    for _, pair in ipairs({{"INVTYPE_WEAPON",2,"weapon"},{"INVTYPE_HEAD",4,"armor"},
        {"INVTYPE_FINGER",4,"ring"},{"INVTYPE_NECK",4,"necklace"},{"INVTYPE_TRINKET",4,"trinket"}}) do
        local category, equipment=P.Category(pair[1],pair[2])
        check(category==pair[3] and equipment, "equipment category "..pair[3])
    end
    local category,equipment=P.Category("INVTYPE_BAG",1)
    check(category=="irrelevant" and not equipment, "bag filtered")
    check(P.Category("INVTYPE_TABARD",4)=="armor", "genuinely equippable tabard classified by slot/class")
    check(P.Category("",15,777)=="mount", "mount separated")
    event("CHAT_MSG_LOOT", "You receive loot: "..link..".", "", nil,nil,nil,nil,nil,nil,nil,nil,42)
    local r=ns.records[1]
    check(r.link==link and r.itemLevel==100 and r.equipment, "loot resolution uses variant")
    check(r.itemName=="Helm" and r.icon==456 and r.rarity==4, "metadata")
    event("CHAT_MSG_LOOT", "You receive loot: "..link..".", "", nil,nil,nil,nil,nil,nil,nil,nil,42)
    check(#ns.records==1 and ns.raw[#ns.raw].status:find("duplicate notification"), "same chat line processed once")
    event("CHAT_MSG_LOOT", "You receive loot: "..link..".", "", nil,nil,nil,nil,nil,nil,nil,nil,43)
    check(#ns.records==2 and not ns.records[2].duplicateOf, "legitimate identical second drop retained")
    event("ENCOUNTER_LOOT_RECEIVED", 789,123,link,1,"Self-Realm","WARRIOR")
    check(ns.records[3].ambiguous and not ns.records[3].duplicateOf, "multiple counterpart ambiguity retained")
    event("ENCOUNTER_LOOT_RECEIVED", 789,123,link,1,"Other-Realm","WARRIOR")
    check(not ns.records[4].duplicateOf and not ns.records[4].ambiguous, "different recipient retained")
    cached=false
    event("ENCOUNTER_LOOT_RECEIVED",789,123,link,1,"Late-Realm","WARRIOR")
    r=ns.records[#ns.records]
    check(r.status=="pending item data" and #requests==1, "async requested")
    cached=true; event("ITEM_DATA_LOAD_RESULT",123,true)
    check(r.loaded and not r.deadline and r.link==link, "async updates original record")
    cached=false
    event("ENCOUNTER_LOOT_RECEIVED",789,123,link,1,"Fail","WARRIOR")
    r=ns.records[#ns.records]; event("ITEM_DATA_LOAD_RESULT",123,false)
    check(r.status=="unprocessed: item load failed", "failed load retained")
    event("ENCOUNTER_LOOT_RECEIVED",789,123,link,1,"Timeout","WARRIOR")
    r=ns.records[#ns.records]; clock=20; ns.Loot:Expire()
    check(r.status=="unprocessed: item data timeout", "timeout retained")
    event("CHAT_MSG_LOOT",secret,secret)
    check(ns.records[#ns.records].status=="unprocessed: no readable item ID", "restricted payload retained safely")
    event("ENCOUNTER_START",789,"Boss",8,5)
    event("ENCOUNTER_END",789,"Boss",8,5,1,{})
    check(ns.raw[#ns.raw].context.encounter.state=="ended", "encounter context")
    event("CHALLENGE_MODE_START",123)
    check(ns.Context:Snapshot().encounter==nil, "new challenge clears boss")
    local before=#ns.records
    event("CHALLENGE_MODE_COMPLETED_REWARDS",123,1,1000,10,{{rewardID=123}})
    check(#ns.records==before, "reward summary not fabricated as awards")
    event("PLAYER_ENTERING_WORLD",false,true)
    check(ns.Context:Snapshot().challenge==nil, "world transition clears context")
    SlashCmdList.LOOTTRACKER("diag")
    check(ns.UI.frame:IsShown(), "window opens")
    SlashCmdList.LOOTTRACKER("diag")
    check(not ns.UI.frame:IsShown(), "window closes")
    SlashCmdList.LOOTTRACKER("debug")
    check(ns.db.debug, "debug toggles")
    SlashCmdList.LOOTTRACKER("status")
    check(#messages>10, "status feedback")
    for i=1,220 do event("PLAYER_ENTERING_WORLD",false,true) end
    check(#ns.raw==200 and #ns.records<=200, "bounded records")
    cached=true
    for i=1,220 do event("CHAT_MSG_LOOT", "You receive loot: "..link..".", "", nil,nil,nil,nil,nil,nil,nil,nil,1000+i) end
    check(#ns.records==200 and #ns.raw==200, "processed cap independently enforced")
    local savedQuery=C_Item.GetItemInfo
    C_Item.GetItemInfo=function() error("unexpected query failure") end
    event("CHAT_MSG_LOOT", "You receive loot: "..link..".")
    check(ns.records[#ns.records].apiError=="API call failed", "ordinary API error retained")
    C_Item.GetItemInfo=nil
    event("CHAT_MSG_LOOT", "You receive loot: "..link..".")
    check(ns.records[#ns.records].apiError=="API unavailable", "missing API handled")
    C_Item.GetItemInfo=savedQuery
    event("CHAT_MSG_LOOT",nil,nil)
    check(ns.records[#ns.records].status=="unprocessed: no readable item ID", "nil payload retained")
    SlashCmdList.LOOTTRACKER("clear")
    check(#ns.raw==0 and #ns.records==0, "clear")
    ns.db.position={point="CENTER",relativePoint="CENTER",x=10,y=20}
    ns:LoadSettings()
    check(ns.db.debug and ns.db.position.x==10 and ns.db.raw==nil, "configuration reload")
    print("PASS: "..count.." assertions (mock WoW API, Lua 5.1)")
end
