local _, ns = ...
local R, S, P = { byName={} }, ns.Safe, ns.Parser
ns.Recipients = R
function R.RealmKey(realm)
    return realm and realm:gsub("[%s%-']", ""):lower() or nil
end
function R:Refresh()
    self.byName = {}
    local raid = S.Call(IsInRaid)
    local count = S.Call(GetNumGroupMembers)
    local units = { "player" }
    local isRaid=S.Value(raid[1],"boolean")==true
    local maximum = isRaid and math.max(0,math.min(math.floor(S.Value(count[1],"number") or 0),40)) or 4
    for i=1,maximum do units[#units+1] = (isRaid and "raid" or "party") .. i end
    local selfInfo = S.Call(UnitFullName, "player")
    for _, unit in ipairs(units) do
        local info = S.Call(UnitFullName, unit)
        local name, realm = S.Value(info[1],"string"), S.Value(info[2],"string")
        if name and name ~= "" then
            -- A same-realm unit may report an empty realm; only current roster units get this fallback.
            if not realm or realm == "" then realm = S.Value(selfInfo[2],"string") end
            local key = R.RealmKey(realm)
            if key and key ~= "" then
                local guid = S.Call(UnitGUID, unit)
                local class = S.Call(UnitClass, unit)
                self.byName[name] = self.byName[name] or {}
                local guidValue=S.Value(guid[1],"string")
                if guidValue and not guidValue:match("^Player%-") then guidValue=nil end
                self.byName[name][key] = { realm=realm, guid=guidValue, classToken=S.Value(class[2],"string") }
            end
        end
    end
end
function R:Resolve(full)
    local name, realm = P.Name(full)
    local result = { name=name, realm=realm, realmKey=R.RealmKey(realm),
        nameConfidence=name and "confirmed" or "unavailable", realmConfidence=realm and "confirmed" or "unavailable" }
    local matches = name and self.byName[name]
    local entry
    if matches then
        if result.realmKey then entry = matches[result.realmKey]
        else
            local count=0
            for _, candidate in pairs(matches) do entry=candidate; count=count+1 end
            if count ~= 1 then entry=nil; result.ambiguous = count>1 end
            if entry then
                result.realm, result.realmKey, result.realmConfidence = entry.realm, R.RealmKey(entry.realm), "inferred"
            end
        end
    end
    if entry then
        result.guid = entry.guid
        result.classToken = entry.classToken
        result.guidConfidence = result.realmConfidence == "inferred" and "inferred" or "confirmed"
    end
    return result
end
function R.Match(a, b)
    if not a or not b or not a.name or not b.name or a.name ~= b.name then return "different" end
    if a.realmKey and b.realmKey and a.realmKey~=b.realmKey then return "different" end
    if a.guid and b.guid then return a.guid == b.guid and "same" or "different" end
    if a.realmKey and b.realmKey then return a.realmKey == b.realmKey and "same" or "different" end
    return "uncertain" -- A bare name is not enough to collapse same-name cross-realm awards.
end
