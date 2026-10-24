local _, ns = ...
local L, S, P = {}, ns.Safe, ns.Parser
ns.Loot = L
function L:Resolve(record)
    local query = record.link or record.itemID
    if not query then record.status = "unprocessed: no readable item"; return end
    local instant, instantError = S.Call(C_Item and C_Item.GetItemInfoInstant, query)
    record.itemID = record.itemID or instant[1]
    record.equipLoc, record.icon, record.classID, record.subclassID = instant[4] or record.equipLoc,
        instant[5] or record.icon, instant[6] or record.classID, instant[7] or record.subclassID
    local info, infoError = S.Call(C_Item and C_Item.GetItemInfo, query)
    record.itemName = S.Value(info[1], "string") or record.itemName
    local quality = S.Value(info[3], "number")
    if quality and quality >= 0 and quality % 1 == 0 then record.rarity = quality end
    record.equipLoc, record.icon, record.classID, record.subclassID = info[9] or record.equipLoc,
        info[10] or record.icon, info[12] or record.classID, info[13] or record.subclassID
    record.bindType = info[14] or record.bindType
    local levels, levelError = {}, nil
    if record.link and record.itemLevel == nil then levels, levelError = S.Call(C_Item and C_Item.GetDetailedItemLevelInfo, record.link) end
    -- Freeze the first readable level for this captured hyperlink; refreshes are not upgrades to an award.
    record.itemLevel = record.itemLevel or S.Value(levels[1], "number")
    local mount, mountError = {}, nil
    if record.itemID then mount, mountError = S.Call(C_MountJournal and C_MountJournal.GetMountFromItem, record.itemID) end
    record.mountID = mount[1] or record.mountID
    record.category, record.equipment = P.Category(record.equipLoc, record.classID, record.mountID)
    ns.Presentation:Classify(record)
    record.apiError = instantError or infoError or levelError or mountError
    record.qualityPending = record.equipment and record.rarity == nil
    record.selected = (record.equipment and not record.qualityPending and record.rarity ~= 0)
        or (ns.db.trackMounts and record.category == "mount")
    record.loaded = record.itemName ~= nil and record.equipLoc ~= nil
    if record.equipment and record.rarity == 0 then record.status = "filtered: Poor-quality equipment"
    elseif not record.loaded then record.status = "pending item data"
    elseif record.qualityPending then record.status = "pending item quality"
    elseif record.duplicateOf then record.status = "duplicate notification #" .. record.duplicateOf
    elseif record.equipment then record.status = "equipment: " .. record.category
    elseif record.category == "mount" then record.status = ns.db.trackMounts and "mount selected" or "mount (tracking off)"
    else record.status = "filtered: irrelevant" end
    if record.loaded and record.itemLevel == nil then record.status = record.status .. "; level unavailable" end
    if not ns.Normalize:HasAcquisition(record) then
        record.status = "unprocessed: acquisition evidence unavailable or conflicting"
    end
end
function L:Duplicate(record)
    for i = #ns.records, 1, -1 do
        local previous = ns.records[i]
        if record.lineID and record.lineID > 0 and previous.source == record.source
            and previous.lineID == record.lineID and previous.link == record.link then
            record.duplicateOf = previous.duplicateOf or previous.id
            return
        end
    end
end
function L:Observe(raw, args)
    local source, links, player, quantity, note, itemID, meta = raw.event
    if source == "CHAT_MSG_LOOT" then
        links = P.Links(args[1])
        player, quantity, note, meta = P.Chat(args[1], args[2])
    elseif source == "ENCOUNTER_LOOT_RECEIVED" then
        links = P.Links(args[3])
        itemID, player, quantity = S.Value(args[2], "number"), S.Value(args[5], "string"), S.Value(args[4], "number")
        note = "arg5 recipient (validated in Task 01 Heroic/M+ observations)"
        meta = { kind="loot", known=true }
    else return end
    ns.counters.rawLoot=ns.counters.rawLoot+1
    if quantity and (quantity <= 0 or quantity % 1 ~= 0) then quantity=nil end
    if #links == 0 then links[1] = false end
    for _, link in ipairs(links) do
        local recipient = ns.Recipients:Resolve(player)
        local record = { rawID=raw.id, source=source, timestamp=raw.timestamp, clock=raw.clock,
            player=recipient.name, realm=recipient.realm, guid=recipient.guid, recipient=recipient,
            classToken=recipient.classToken,
            quantity=quantity, recipientNote=note, link=link or nil, acquisition=meta.kind,
            recipientConflict=meta.recipientConflict, format=meta.format,
            itemID=itemID or (link and tonumber(link:match("|Hitem:(%d+)"))), context=raw.context,
            lineID=source == "CHAT_MSG_LOOT" and S.Value(args[11], "number") or nil }
        local linkID=link and tonumber(link:match("|Hitem:(%d+)"))
        record.itemIdentityConflict=itemID and linkID and itemID~=linkID or false
        if source == "ENCOUNTER_LOOT_RECEIVED" then record.encounterID = S.Value(args[1], "number") end
        self:Duplicate(record)
        if record.duplicateOf then
            raw.status = "duplicate notification of processed #" .. record.duplicateOf
            return -- The raw notification remains; a stable chat line is processed once.
        end
        ns.observationSequence=ns.observationSequence+1
        record.id=ns.observationSequence
        record.parsed=record.itemID ~= nil and record.player ~= nil and quantity ~= nil and meta.known
            and not record.itemIdentityConflict and not record.recipientConflict
        local counter=record.parsed and "parsed" or "failures"
        ns.counters[counter]=ns.counters[counter]+1
        ns:Push(ns.records, record)
        self:Resolve(record)
        if not record.loaded and not record.itemID then record.status = "unprocessed: no readable item ID" end
        if (not record.loaded or record.qualityPending or record.bindingPending or (record.equipment and not record.itemLevel)) and record.itemID then
            record.deadline = GetTime()+15
            local _, err = S.Call(C_Item and C_Item.RequestLoadItemDataByID, record.itemID)
            if err then record.status = "unprocessed: " .. err; record.deadline = nil end
        end
        ns.Normalize:Ingest(record)
        raw.status = record.status
    end
end
function L:EachPending(callback)
    -- Canonical records can outlive their rows in the bounded observation view.
    local seen, pending={}, {}
    local function visit(record)
        if record.deadline and not seen[record] then seen[record]=true; pending[#pending+1]=record end
    end
    for _, record in ipairs(ns.records) do visit(record) end
    for _, canonical in ipairs(ns.normalized) do
        for _, record in ipairs(canonical.observations) do visit(record) end
    end
    for _, record in ipairs(pending) do callback(record) end
end
function L:Loaded(itemID, success)
    itemID, success = S.Value(itemID, "number"), S.Value(success, "boolean")
    if not itemID then return end
    self:EachPending(function(record)
        if record.itemID == itemID then
            if success == false then record.status = "unprocessed: item load failed"; record.deadline = nil
            elseif success then
                self:Resolve(record)
                if record.loaded and not record.qualityPending and not record.bindingPending and (not record.equipment or record.itemLevel) then record.deadline = nil end
            end
            ns.Normalize:Update(record)
        end
    end)
    ns:Changed()
end
function L:Expire()
    self:EachPending(function(record)
        if GetTime() >= record.deadline then
            self:Resolve(record)
            if not record.loaded then record.status = "unprocessed: item data timeout" end
            record.deadline = nil
            ns.Normalize:Update(record)
            ns:Changed()
        end
    end)
end
