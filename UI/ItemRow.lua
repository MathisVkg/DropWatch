local _, ns = ...
local Row,T,S = {},ns.Style,ns.Safe
ns.ItemRow=Row
function Row:IsSelf(record)
    local ownGUID=S.Call(UnitGUID,"player")
    if record.guid and ownGUID[1] and record.guid==ownGUID[1] then return true end
    local own=S.Call(UnitFullName,"player")
    return record.player==own[1] and record.realm and ns.Recipients.RealmKey(record.realm)==ns.Recipients.RealmKey(own[2]) or false
end
function Row:WhisperTarget(record)
    if record.demo then return end
    local name,realm=S.Value(record.player,"string"),S.Value(record.realm,"string")
    if not name or name=="" or name:find("[%s%c|/]") or not realm or realm=="" or realm:find("[%c|/]") then return end
    if self:IsSelf(record) then return end
    local key=ns.Recipients.RealmKey(realm)
    if key=="" then return end
    return name .. "-" .. key
end
function Row:Whisper(record)
    local target=self:WhisperTarget(record)
    if not target or not ChatFrameUtil or type(ChatFrameUtil.SendTell)~="function" then return false end
    -- This native helper opens/parses a whisper with an EMPTY message; it does not transmit.
    local ok=pcall(ChatFrameUtil.SendTell,target,DEFAULT_CHAT_FRAME)
    if ok and ChatFrameUtil.FocusActiveWindow then pcall(ChatFrameUtil.FocusActiveWindow) end
    if not ok then ns:Print("Whisper input is unavailable in the current client state.") end
    return ok
end
function Row:Create(parent)
    local row=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    row:SetHeight(48); T.Backdrop(row,0.90)
    row.item=CreateFrame("Button",nil,row)
    row.item:SetPoint("TOPLEFT",4,-5); row.item:SetPoint("BOTTOMRIGHT",row,"BOTTOMRIGHT",-76,5)
    row.iconBorder=CreateFrame("Frame",nil,row.item,"BackdropTemplate")
    row.iconBorder:SetSize(34,34); row.iconBorder:SetPoint("LEFT",0,0); T.Backdrop(row.iconBorder,1)
    row.icon=row.iconBorder:CreateTexture(nil,"ARTWORK"); row.icon:SetPoint("TOPLEFT",1,-1); row.icon:SetPoint("BOTTOMRIGHT",-1,1)
    row.icon:SetTexCoord(0.08,0.92,0.08,0.92)
    row.name=T.Text(row.item,11); row.name:SetPoint("TOPLEFT",row.iconBorder,"TOPRIGHT",7,-1); row.name:SetPoint("TOPRIGHT",row.item,"TOPRIGHT",-40,-3); row.name:SetHeight(14)
    row.recipient=T.Text(row.item,10); row.recipient:SetPoint("BOTTOMLEFT",row.iconBorder,"BOTTOMRIGHT",7,2); row.recipient:SetPoint("BOTTOMRIGHT",row.item,"BOTTOMRIGHT",-2,4); row.recipient:SetHeight(12)
    row.level=T.Text(row,11); row.level:SetPoint("TOPRIGHT",row,"TOPRIGHT",-8,-8)
    row.whisper=T.Button(row,"Whisper",62,19,function() self:Whisper(row.record) end)
    row.whisper:SetPoint("BOTTOMRIGHT",-6,5)
    row.item:SetScript("OnEnter",function(button)
        local record=row.record; local link=record and T.Link(record)
        if link and GameTooltip then
            GameTooltip:SetOwner(button,"ANCHOR_RIGHT"); pcall(GameTooltip.SetHyperlink,GameTooltip,link); GameTooltip:Show()
        end
    end)
    row.item:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    row.item:SetScript("OnClick",function()
        local link=row.record and T.Link(row.record)
        if link and HandleModifiedItemClick then pcall(HandleModifiedItemClick,link) end
    end)
    return row
end
function Row:Update(row,record,width)
    row.record=record; row:SetWidth(width)
    row.icon:SetTexture(S.Value(record.icon,"number") or "Interface/Icons/INV_Misc_QuestionMark")
    local quality=S.Value(record.rarity,"number")
    local r,g,b=0.65,0.68,0.7
    if quality and C_Item and C_Item.GetItemQualityColor then
        local colors=S.Call(C_Item.GetItemQualityColor,quality)
        r,g,b=colors[1] or r,colors[2] or g,colors[3] or b
    end
    row.name:SetText(T.Plain(record.itemName,"Loading item…")); row.name:SetTextColor(r,g,b)
    row.iconBorder:SetBackdropBorderColor(r,g,b,1)
    local recipient=T.Plain(record.player,"Recipient unavailable") .. (record.realm and "-" .. T.Plain(record.realm) or "")
    row.recipient:SetText(recipient)
    local token=S.Value(record.classToken,"string")
    if not token and record.player then
        local resolved=ns.Recipients:Resolve(record.player .. (record.realm and "-"..record.realm or ""))
        token=resolved.classToken
    end
    local color=token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
    row.recipient:SetTextColor(color and S.Value(color.r,"number") or 0.7,color and S.Value(color.g,"number") or 0.73,color and S.Value(color.b,"number") or 0.76)
    row.level:SetText(record.itemLevel and tostring(record.itemLevel) or "—")
    local enabled=self:WhisperTarget(record)~=nil
    row.whisper:SetShown(not self:IsSelf(record))
    row.whisper:SetEnabled(enabled)
    row.whisper.label:SetTextColor(enabled and 0.75 or 0.38,enabled and 0.8 or 0.4,enabled and 0.8 or 0.42)
    row:Show()
end
