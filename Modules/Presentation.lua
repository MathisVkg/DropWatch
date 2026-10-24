local _,ns=...
local F,S={},ns.Safe
ns.Presentation=F
-- Item-link queries only: another player's inventory is not an ItemLocation.
function F:Classify(record)
    local previousEvidence=record.bindingCategory=="warbound" and record.classificationConfidence=="confirmed" and record.classificationEvidence
    local previousLink=record.classificationLink
    record.bindingCategory,record.tradeability,record.classificationConfidence="unknown","unknown","unavailable"
    record.exclusionReason,record.classificationEvidence=nil,nil
    record.rewardSource="unknown"
    for _,observation in ipairs(record.observations or {}) do
        local format=S.Value(observation.format,"string")
        if format and format:find("BONUS_ROLL",1,true) then record.rewardSource="bonus-roll"; break end
        if observation.acquisition=="loot" then record.rewardSource="ordinary-loot" end
    end
    local link=S.Value(record.link,"string")
    if not link then return end
    local untilEquip=S.Call(C_Item and C_Item.IsItemBindToAccountUntilEquip,link)
    local account=S.Call(C_Item and C_Item.IsItemBindToAccount,link)
    record.bindingPending=(C_Item and C_Item.IsItemBindToAccountUntilEquip and untilEquip[1]==nil)
        or (C_Item and C_Item.IsItemBindToAccount and account[1]==nil) or false
    local bind=S.Value(record.bindType,"number")
    local enums=Enum and Enum.ItemBind or {}
    local function is(name) return bind~=nil and enums[name]~=nil and bind==enums[name] end
    local accountEnum=is("ToWoWAccount") or is("ToBnetAccount") or is("ToBnetAccountUntilEquipped")
    if untilEquip[1]==true or account[1]==true or accountEnum or (previousEvidence and previousLink==link) then
        record.bindingPending=false; record.classificationLink=link
        record.bindingCategory="warbound"
        record.tradeability="confirmed-ineligible"
        record.classificationConfidence="confirmed"
        record.exclusionReason="Account / Warband binding"
        record.classificationEvidence=untilEquip[1]==true and "C_Item.IsItemBindToAccountUntilEquip(link)"
            or (account[1]==true and "C_Item.IsItemBindToAccount(link)" or (accountEnum and "GetItemInfo bindType enum" or previousEvidence))
    elseif is("OnAcquire") then
        record.bindingCategory="soulbound"; record.classificationConfidence="confirmed"
    elseif is("OnEquip") then
        record.bindingCategory="bind-on-equip"; record.classificationConfidence="confirmed"
    end
    -- Neither Soulbound nor a bonus-roll source proves absence of group trading.
end
function F:Visible(record)
    -- Canonical selection gate shared by Recent, History, restore and notifications.
    -- Unknown/secret quality is deferred; do not infer it from hyperlink color.
    if record.equipment then
        local quality = S.Value(record.rarity, "number")
        if quality == nil or quality == 0 or quality < 0 or quality % 1 ~= 0 then return false end
    end
    return not (record.tradeability=="confirmed-ineligible"
        and record.classificationConfidence=="confirmed" and record.exclusionReason~=nil)
end
