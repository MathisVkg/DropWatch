local _, ns = ...
local H,S = { entries={}, byID={}, limit=1000, retention=900 }, ns.Safe
ns.Session=H
local function tableValue(value)
    if S.IsSecret(value) or type(value)~="table" then return nil end
    if canaccesstable and not canaccesstable(value) then return nil end
    if issecrettable and issecrettable(value) then return nil end
    return value
end
local function text(value)
    value=S.Value(value,"string")
    return value and #value<=4096 and value or nil
end
function H:Snapshot(record)
    if not tableValue(record) then return end
    if S.Value(record.demo,"boolean")==true then return end
    local id,timestamp=S.Value(record.id,"number"),S.Value(record.timestamp,"number")
    if not id or id<1 or id%1~=0 or not timestamp or timestamp>time()+5 or timestamp<0 then return end
    local out={id=id,timestamp=timestamp,revision=S.Value(record.revision,"number") or 1}
    for _,field in ipairs({"player","realm","guid","itemName","link","category","equipLoc","classToken","bindingCategory","rewardSource","tradeability","exclusionReason","classificationConfidence","classificationEvidence"}) do out[field]=text(record[field]) end
    for _,field in ipairs({"itemID","icon","rarity","itemLevel","quantity","mountID","encounterID"}) do out[field]=S.Value(record[field],"number") end
    out.equipment=S.Value(record.equipment,"boolean")==true
    out.loaded=S.Value(record.loaded,"boolean")==true
    out.ambiguous=S.Value(record.ambiguous,"boolean")==true
    local c=tableValue(record.context) or {}
    out.context={instance=text(c.instance),instanceID=S.Value(c.instanceID,"number"),difficulty=S.Value(c.difficulty,"number"),
        difficultyName=text(c.difficultyName),run=S.Value(c.run,"number")}
    local challenge=tableValue(c.challenge)
    if challenge then
        out.context.challenge={state=text(challenge.state),mapID=S.Value(challenge.mapID,"number"),
            challengeMapID=S.Value(challenge.challengeMapID,"number"),startedAt=S.Value(challenge.startedAt,"number"),recovered=S.Value(challenge.recovered,"boolean")==true}
    end
    return out
end
function H:Qualifies(record)
    return ns.Presentation:Visible(record) and (record.equipment==true or (ns.db.trackMounts and record.category=="mount"))
end
function H:Changed()
    if ns.Main then ns.Main.dirty=true end
end
function H:Put(record,announce)
    local snapshot=self:Snapshot(record)
    if not snapshot then return end
    if not self:Qualifies(snapshot) and ns.Notification then ns.Notification:Remove(snapshot.id) end
    local existing=self.byID[snapshot.id]
    if not existing and not self:Qualifies(snapshot) then return end
    if existing then
        for key in pairs(existing) do existing[key]=nil end
        for key,value in pairs(snapshot) do existing[key]=value end
    else
        self.entries[#self.entries+1]=snapshot
        self.byID[snapshot.id]=snapshot
        if #self.entries>self.limit then
            local oldestIndex=1
            for i,entry in ipairs(self.entries) do if entry.timestamp<self.entries[oldestIndex].timestamp then oldestIndex=i end end
            local oldest=table.remove(self.entries,oldestIndex)
            self.byID[oldest.id]=nil
            if ns.Notification then ns.Notification:Remove(oldest.id) end
        end
        if announce and self.ready and not self.demo and self:Qualifies(snapshot) and snapshot.timestamp+self.retention>time() then
            ns.Main:NewAward(1,snapshot.id)
        end
    end
    self:Changed()
    if not self.restoring then self:ScheduleExpiry() end
end
function H:Remove(id)
    if ns.Notification then ns.Notification:Remove(id) end
    if not self.byID[id] then return end
    self.byID[id]=nil
    for i,entry in ipairs(self.entries) do if entry.id==id then table.remove(self.entries,i); break end end
    self:Changed(); self:ScheduleExpiry()
end
function H:Initialize()
    self.unsubscribe=ns:Subscribe(function(kind,record,detail)
        if kind=="reset" then self:Clear()
        elseif kind=="removed" then
            if detail~="capacity" then self:Remove(record.id) end
        elseif record and (kind=="created" or kind=="enriched" or kind=="reconciled" or kind=="classification") then
            self:Put(record,true)
        end
    end)
end
function H:Owner()
    local guid=S.Call(UnitGUID,"player")
    local player=S.Call(UnitFullName,"player")
    local guidValue=S.Value(guid[1],"string")
    if guidValue then return guidValue end
    local name,realm=S.Value(player[1],"string"),S.Value(player[2],"string")
    if name and realm then return name .. "-" .. realm end
end
function H:OnWorld(initial,reload)
    if self.ready then return end
    self.ready=true
    local saved=tableValue(LootTrackerSession)
    local owner=self:Owner()
    if S.Value(reload,"boolean")==true and S.Value(initial,"boolean")==false and saved
        and S.Value(saved.version,"number")==1 and owner and S.Value(saved.owner,"string")==owner and tableValue(saved.entries) then
        self.restoring=true
        for i=1,math.min(#saved.entries,self.limit) do
            local record=self:Snapshot(saved.entries[i])
            if record then
                self:Put(record,false)
                ns.recordSequence=math.max(ns.recordSequence,record.id)
                ns.Context.run=math.max(ns.Context.run,record.context.run or 0)
            end
        end
        self.restoring=false
    end
    -- Even data written during a real logout is restored only with an explicit reload flag.
    LootTrackerSession=nil
    self:Changed(); self:ScheduleExpiry()
end
function H:Save()
    if not self.ready then LootTrackerSession=nil; return end
    local entries={}
    for _,record in ipairs(self.entries) do
        local snapshot=self:Snapshot(record)
        if snapshot then entries[#entries+1]=snapshot end
    end
    LootTrackerSession={version=1,owner=self:Owner(),entries=entries}
end
function H:Clear()
    self.entries,self.byID={},{}
    self.demo,self.demoEntries=nil,nil
    if ns.Main then ns.Main.collapsed={} end
    LootTrackerSession=nil
    if ns.Notification then ns.Notification:Dismiss() end
    self:Changed(); self:ScheduleExpiry()
end
function H:Records(recent)
    local result={}
    for _,entry in ipairs(self.demo and self.demoEntries or self.entries) do
        if self:Qualifies(entry) and (not recent or time()<entry.timestamp+self.retention) then result[#result+1]=entry end
    end
    table.sort(result,function(a,b) if a.timestamp==b.timestamp then return a.id>b.id end; return a.timestamp>b.timestamp end)
    return result
end
function H:Groups()
    local groups,lookup={},{}
    for _,entry in ipairs(self:Records(false)) do
        local c=entry.context or {}
        local known=c.instanceID and c.run
        local key=(entry.demo and "demo:" or "real:") .. (known and (c.instanceID .. ":" .. (c.difficulty or "?") .. ":" .. c.run) or "unassigned")
        local group=lookup[key]
        if not group then
            group={key=key,name=c.instance or "Unassigned activity",difficulty=c.challenge and "Mythic+" or (c.difficultyName or "Difficulty unavailable"),
                uncertain=not known or not (c.challenge and c.challenge.startedAt),timestamp=entry.timestamp,items={},equipment=0,mounts=0}
            lookup[key]=group; groups[#groups+1]=group
        end
        group.timestamp=math.max(group.timestamp,entry.timestamp)
        group.items[#group.items+1]=entry
        if entry.equipment then group.equipment=group.equipment+1 else group.mounts=group.mounts+1 end
    end
    table.sort(groups,function(a,b) if a.timestamp==b.timestamp then return a.key>b.key end; return a.timestamp>b.timestamp end)
    return groups
end
function H:ScheduleExpiry()
    local nextExpiry
    for _,entry in ipairs(self:Records(true)) do
        local expires=entry.timestamp+self.retention
        if not nextExpiry or expires<nextExpiry then nextExpiry=expires end
    end
    if nextExpiry==self.nextExpiry then return end
    if self.expiryTimer then self.expiryTimer:Cancel(); self.expiryTimer=nil end
    self.nextExpiry=nextExpiry
    if nextExpiry and C_Timer and C_Timer.NewTimer then
        self.expiryTimer=C_Timer.NewTimer(math.max(0.01,nextExpiry-time()),function()
            self.nextExpiry,self.expiryTimer=nil,nil
            self:Changed(); self:ScheduleExpiry()
        end)
    end
end
