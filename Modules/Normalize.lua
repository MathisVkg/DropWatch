local _, ns = ...
local N, R, S = { matchWindow=10, diagnosticWindow=60 }, ns.Recipients, ns.Safe
ns.Normalize = N
local fields = { "player", "realm", "guid", "itemID", "link", "itemName", "icon", "rarity", "itemLevel",
    "category", "equipLoc", "quantity", "mountID", "classID", "subclassID", "acquisition", "classToken", "bindType" }
local ranks = { unavailable=0, inferred=1, confirmed=2 }
function N:Find(id)
    for _, record in ipairs(ns.normalized) do if record.id == id then return record end end
end
function N:Eligible(observation)
    if observation.acquisition == "created" or not observation.itemID then return false end
    return observation.equipment or (ns.db.trackMounts and observation.category == "mount")
        or (not observation.loaded and observation.equipLoc == nil)
end
local function variant(link)
    return link and link:match("|H(item:[^|]+)|h")
end
local function confidence(observation, field)
    if observation[field] == nil then return "unavailable" end
    if field == "realm" then return observation.recipient.realmConfidence end
    if field == "guid" then return observation.recipient.guidConfidence or "unavailable" end
    if field == "classToken" then return observation.recipient.guidConfidence or observation.recipient.realmConfidence or "unavailable" end
    if field == "itemID" and observation.itemIdentityConflict then return "unavailable" end
    if field == "acquisition" and observation.acquisition == "unknown" then return "unavailable" end
    if field == "category" and not observation.loaded and not observation.equipLoc then return "unavailable" end
    return "confirmed"
end
local function signature(record)
    local result={ record.status or "", tostring(record.selected), tostring(record.equipment), tostring(record.ambiguous) }
    for _, field in ipairs(fields) do result[#result+1]=S.Text(record[field]) end
    result[#result+1]=S.Text(record.bindingCategory) .. S.Text(record.rewardSource) .. S.Text(record.tradeability) .. S.Text(record.exclusionReason)
    result[#result+1]=S.Dump(record.confidence or {}, 2)
    return table.concat(result, "\031")
end
function N:Rebuild(record, change, detail)
    local before, oldCategory, oldSelected = signature(record), record.category, record.selected
    record.confidence, record.loaded, record.selected, record.equipment = {}, false, false, false
    -- Keep the earliest complete original link as the primary; each contributing link is also retained.
    for _, field in ipairs(fields) do
        record[field]=nil
        record.confidence[field]="unavailable"
        for _, observation in ipairs(record.observations) do
            local level=confidence(observation, field)
            if ranks[level] > ranks[record.confidence[field]] then
                record[field], record.confidence[field] = observation[field], level
            end
        end
    end
    record.explicitEncounterID=nil
    local provenance, errors={},{}
    for _, observation in ipairs(record.observations) do
        record.loaded = record.loaded or observation.loaded
        record.equipment = record.equipment or observation.equipment
        record.selected = record.selected or observation.selected
        if observation.encounterID then record.explicitEncounterID=observation.encounterID end
        if observation.recipientNote then provenance[#provenance+1]=observation.source .. ": " .. observation.recipientNote end
        if observation.apiError then errors[#errors+1]=observation.source .. ": " .. observation.apiError end
    end
    record.recipientNote=#provenance>0 and table.concat(provenance,"; ") or "recipient provenance unavailable"
    record.apiError=#errors>0 and table.concat(errors,"; ") or nil
    local ctx = record.context
    local hint = ctx.activeEncounter or ctx.lastSuccessfulEncounter
    record.encounterID = record.explicitEncounterID or (hint and hint.id)
    record.encounterName = hint and hint.id == record.encounterID and hint.name or nil
    record.confidence.encounter = record.explicitEncounterID and "confirmed" or (hint and "inferred" or "unavailable")
    record.confidence.instance = ctx.instanceID and "confirmed" or "unavailable"
    record.confidence.mythicPlus = ctx.challenge and "inferred" or "unavailable"
    record.confidence.uniqueness = #record.observations == 2 and "inferred" or "unavailable"
    record.association = ctx.challenge and ctx.challenge.state == "completed" and "completed run reward candidate"
        or (record.explicitEncounterID and "explicit encounter award")
        or (hint and "recent encounter candidate" or "unassociated")
    record.ambiguous = record.matchAmbiguous or not record.player or not record.quantity or not record.realm
    record.uncertainties={}
    if not record.player then record.uncertainties.recipient="unavailable" end
    if not record.realm then record.uncertainties.realm="unavailable" end
    if not record.quantity then record.uncertainties.quantity="unavailable" end
    if not record.loaded then
        record.status="pending item data"
        for _, observation in ipairs(record.observations) do
            if observation.status and observation.status:match("^unprocessed:") then record.status=observation.status end
        end
    elseif record.equipment then record.status="equipment: " .. (record.category or "unknown")
    elseif record.category == "mount" then record.status=record.selected and "mount selected" or "mount tracking off"
    else record.status="filtered: irrelevant" end
    if record.ambiguous then record.status=record.status .. "; ambiguous" end
    if record.confidence.itemLevel == "unavailable" then record.status=record.status .. "; level unavailable" end
    if record.equipment and not record.countedEquipment then
        record.countedEquipment=true
        ns.counters.equipment=ns.counters.equipment+1
    end
    ns.Presentation:Classify(record)
    if change == "created" or change == "reconciled" or before ~= signature(record) then
        record.revision=(record.revision or 0)+1
        ns:Notify(change, record, detail)
        if change ~= "created" and (oldCategory ~= record.category or oldSelected ~= record.selected) then
            ns:Notify("classification", record, { previousCategory=oldCategory, previousSelected=oldSelected })
        end
        ns:Changed()
    end
end
function N:Mark(record, reason, candidateID)
    record.matchAmbiguous=true
    record.ambiguityReasons=record.ambiguityReasons or {}
    record.ambiguityReasons[reason]=true
    record.candidateIDs=record.candidateIDs or {}
    if candidateID and #record.candidateIDs<8 then
        for _, existing in ipairs(record.candidateIDs) do if existing==candidateID then return end end
        record.candidateIDs[#record.candidateIDs+1]=candidateID
    end
end
function N:Candidates(observation)
    local strong, uncertain = {}, {}
    for _, record in ipairs(ns.normalized) do
        local age=math.abs(observation.clock-record.clock)
        local previous=record.observations[1]
        local a,b=observation.context,record.context
        local sameScope=a.instanceID and b.instanceID and a.instanceID==b.instanceID and a.run==b.run
            and a.difficulty==b.difficulty
        if age<=self.diagnosticWindow and sameScope and not record.sources[observation.source]
            and #record.observations==1 and observation.itemID==record.itemID then
            local recipient=R.Match(observation.recipient, previous.recipient)
            if recipient~="different" then
                local sameVariant=variant(observation.link) and variant(observation.link)==variant(record.link)
                local sameQuantity=observation.quantity and observation.quantity==record.quantity
                local encounterConflict=observation.encounterID and record.explicitEncounterID
                    and observation.encounterID~=record.explicitEncounterID
                if recipient=="same" and sameVariant and sameQuantity and age<=self.matchWindow
                    and not record.matchAmbiguous and not observation.recipientConflict and not previous.recipientConflict
                    and not observation.itemIdentityConflict and not previous.itemIdentityConflict
                    and not encounterConflict and observation.acquisition~="unknown" and previous.acquisition~="unknown" then
                    strong[#strong+1]=record
                else uncertain[#uncertain+1]=record end
            end
        end
    end
    return strong, uncertain
end
function N:AddSource(record, observation)
    record.observations[#record.observations+1]=observation
    table.sort(record.observations,function(a,b)
        if a.clock==b.clock then return a.id<b.id end
        return a.clock<b.clock
    end)
    record.clock=math.min(record.clock,observation.clock)
    record.timestamp=math.min(record.timestamp,observation.timestamp)
    record.sources[observation.source]=true
    record.sourceEvents[#record.sourceEvents+1]={ event=observation.source, rawID=observation.rawID,
        observationID=observation.id, timestamp=observation.timestamp, link=observation.link }
    observation.canonicalID=record.id
    local incoming=observation.context.challenge
    local current=record.context.challenge
    if incoming and (not current or (incoming.state=="completed" and current.state~="completed")) then
        record.context=observation.context
    end
end
function N:Ingest(observation)
    if not self:Eligible(observation) then return end
    local strong, uncertain=self:Candidates(observation)
    if #strong==1 and #uncertain==0 then
        local record=strong[1]
        self:AddSource(record, observation)
        ns.counters.reconciled=ns.counters.reconciled+1
        self:Rebuild(record, "reconciled", { observationID=observation.id })
        return record
    end
    ns.recordSequence=ns.recordSequence+1
    local record={ id=ns.recordSequence, timestamp=observation.timestamp, clock=observation.clock,
        context=observation.context, observations={}, sources={}, sourceEvents={} }
    self:AddSource(record, observation)
    if #strong+#uncertain>0 then
        ns.counters.ambiguous=ns.counters.ambiguous+1
        for _, group in ipairs({strong,uncertain}) do
            for _, candidate in ipairs(group) do
                self:Mark(record,"correspondence uncertain",candidate.id)
                self:Mark(candidate,"correspondence uncertain",record.id)
                self:Rebuild(candidate,"enriched", { ambiguity=true })
            end
        end
        observation.ambiguous=true
    elseif observation.recipientConflict then self:Mark(record,"recipient fields conflict")
    elseif observation.itemIdentityConflict then self:Mark(record,"item ID and link conflict") end
    ns:Push(ns.normalized,record)
    self:Rebuild(record,"created", { observationID=observation.id })
    return record
end
function N:Update(observation)
    local record=self:Find(observation.canonicalID)
    if observation.canonicalID and not record then return end -- Never resurrect an evicted record on a late callback.
    if not record then return self:Ingest(observation) end
    local eligible=false
    for _, source in ipairs(record.observations) do eligible=eligible or self:Eligible(source) end
    if not eligible then
        for i,candidate in ipairs(ns.normalized) do
            if candidate==record then table.remove(ns.normalized,i); break end
        end
        ns:Notify("removed",record,"filtered after item load")
        ns:Changed()
    else self:Rebuild(record,"enriched", { observationID=observation.id }) end
end
