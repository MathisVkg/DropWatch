local _, ns = ...
local P, S = {}, ns.Safe
ns.Parser = P
function P.Name(full)
    full = S.Value(full, "string")
    if not full or full == "" then return nil end
    full = full:match("|Hplayer:([^:|]+)[^|]*|h.-|h") or full
    full = full:gsub("^|c%x%x%x%x%x%x%x%x", ""):gsub("^|cn[%w_]+:", ""):gsub("|r$", "")
    full = full:match("^%s*(.-)%s*$")
    if full == "" then return nil end
    local name, realm = full:match("^([^%-]+)%-(.+)$")
    return name or full, realm
end
function P.Links(text)
    local links = {}
    text = S.Value(text, "string")
    if not text then return links end
    local at = 1
    while true do
        local first, last = text:find("|Hitem:%d+[^|]*|h.-|h", at)
        if not first then break end
        local start = first
        if first > 10 and text:sub(first-10, first-1):match("^|c%x%x%x%x%x%x%x%x$") then start = first-10 end
        local namedColor = text:sub(at, first-1):match("(|cn[%w_]+:)$")
        if namedColor then start = first-#namedColor end
        if text:sub(last+1, last+2) == "|r" then last = last+2 end
        links[#links+1] = text:sub(start, last)
        at = last+1
    end
    return links
end
-- Match Blizzard's localized global format strings, including positional tokens.
function P.Format(format, text)
    if type(format) ~= "string" or type(text) ~= "string" then return end
    local pattern, order, cursor, nextArg = "^", {}, 1, 1
    while cursor <= #format do
        local a, b, pos, spec = format:find("%%(%d*)%$?([sd])", cursor)
        local literal = format:sub(cursor, a and a-1 or #format)
        pattern = pattern .. literal:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
        if not a then break end
        order[#order+1] = tonumber(pos) or nextArg
        nextArg = nextArg+1
        pattern = pattern .. (spec == "d" and "(%d+)" or "(.-)")
        cursor = b+1
    end
    local captures = { text:match(pattern .. "$") }
    if #captures == 0 then return end
    local args = {}
    for i, value in ipairs(captures) do args[order[i]] = value end
    return args
end
function P.Chat(text, sender)
    text = S.Value(text, "string")
    local meta = { kind="unknown", known=false }
    if not text then return nil, nil, "restricted or missing message", meta end
    -- Read client constants at parse time. Absent constants are simply unsupported.
    local families = { {"LOOT_ITEM_CREATED", "created"}, {"LOOT_ITEM_PUSHED", "received"},
        {"LOOT_ITEM_BONUS_ROLL", "loot"}, {"LOOT_ITEM", "loot"} }
    for _, family in ipairs(families) do
        for _, variant in ipairs({ {"_SELF_MULTIPLE",true,true}, {"_MULTIPLE",false,true},
            {"_SELF",true,false}, {"",false,false} }) do
            local formatName = family[1] .. variant[1]
            local args = P.Format(_G[formatName], text)
            local itemArg = args and args[variant[2] and 1 or 2]
            local itemLinks = P.Links(itemArg)
            -- A permissive %s must not swallow an unknown suffix and imply quantity=1.
            if args and #itemLinks == 1 and itemArg == itemLinks[1] then
                local recipient = args[1]
                if variant[2] then
                    local player = S.Call(UnitFullName, "player")
                    recipient = player[1]
                    if recipient and player[2] and player[2] ~= "" then recipient = recipient .. "-" .. player[2] end
                end
                local name, realm = P.Name(recipient)
                local senderName, senderRealm = P.Name(sender)
                if name and senderName == name then
                    if not realm and senderRealm then realm=senderRealm
                    elseif realm and senderRealm and ns.Recipients.RealmKey(realm) ~= ns.Recipients.RealmKey(senderRealm) then
                        meta.recipientConflict = true
                    end
                elseif name and senderName and senderName ~= name then meta.recipientConflict = true end
                recipient = name and (name .. (realm and "-" .. realm or "")) or nil
                local quantity = variant[3] and tonumber(args[variant[2] and 2 or 3]) or 1
                if quantity and (quantity <= 0 or quantity % 1 ~= 0) then quantity=nil end
                meta.kind, meta.known, meta.format = family[2], true, formatName
                return recipient, quantity, "localized " .. formatName, meta
            end
        end
    end
    sender = S.Value(sender, "string")
    return sender ~= "" and sender or nil, nil, "unrecognized loot format; quantity unknown", meta
end
function P.Category(equipLoc, classID, mountID)
    if mountID then return "mount", false end
    if equipLoc == "INVTYPE_TRINKET" then return "trinket", true end
    if equipLoc == "INVTYPE_FINGER" then return "ring", true end
    if equipLoc == "INVTYPE_NECK" then return "necklace", true end
    local weapon = { INVTYPE_WEAPON=true, INVTYPE_2HWEAPON=true, INVTYPE_WEAPONMAINHAND=true,
        INVTYPE_WEAPONOFFHAND=true, INVTYPE_RANGED=true, INVTYPE_RANGEDRIGHT=true, INVTYPE_THROWN=true }
    local armor = { INVTYPE_HEAD=true, INVTYPE_SHOULDER=true, INVTYPE_CHEST=true, INVTYPE_ROBE=true,
        INVTYPE_WAIST=true, INVTYPE_LEGS=true, INVTYPE_FEET=true, INVTYPE_WRIST=true, INVTYPE_HAND=true,
        INVTYPE_CLOAK=true, INVTYPE_SHIELD=true, INVTYPE_HOLDABLE=true, INVTYPE_RELIC=true,
        INVTYPE_BODY=true, INVTYPE_TABARD=true }
    if weapon[equipLoc] and classID == 2 then return "weapon", true end
    if armor[equipLoc] and classID == 4 then return "armor", true end
    return "irrelevant", false
end
