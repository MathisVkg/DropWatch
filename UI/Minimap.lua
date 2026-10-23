local _,ns=...
local B,S={},ns.Safe
ns.Minimap=B
-- Both frames share Minimap's coordinate system; never multiply anchor offsets by UI scale.
function B:Position()
    local button=self.button
    if not button or not Minimap then return end
    local width,height=S.Value(Minimap:GetWidth(),"number"),S.Value(Minimap:GetHeight(),"number")
    if not width or not height or width<=0 or height<=0 then return end -- Hidden/unlaid-out map: retry on show/size change.
    -- Center anchoring accounts for button dimensions: half the icon overlaps the rim.
    -- Adding half its diameter here would detach the icon from the circular border.
    local radius=math.min(width,height)/2
    local angle=math.rad(ns.db.minimapAngle)
    button:ClearAllPoints()
    button:SetPoint("CENTER",Minimap,"CENTER",math.cos(angle)*radius,math.sin(angle)*radius)
end
function B:Drag()
    local button=self.button
    if not button or not button.dragging then return end
    local cx,cy=Minimap:GetCenter()
    cx,cy=S.Value(cx,"number"),S.Value(cy,"number")
    local scale=S.Value(Minimap:GetEffectiveScale(),"number")
    local x,y=GetCursorPosition()
    x,y=S.Value(x,"number"),S.Value(y,"number")
    if not cx or not cy or not scale or scale<=0 or not x or not y then return end
    x,y=x/scale-cx,y/scale-cy
    if x==0 and y==0 then return end -- atan2 at the center has no meaningful direction.
    ns.db.minimapAngle=math.deg(math.atan2(y,x))%360
    self:Position()
end
function B:StopDrag()
    local button=self.button
    if not button or not button.dragging then return end
    self:Drag()
    button.dragging=nil; button:SetScript("OnUpdate",nil)
    -- A native click can arrive after GLOBAL_MOUSE_UP/OnDragStop for the same release.
    button.suppressUntil=GetTime()+0.1
end
function B:Refresh()
    if not self.button then return end
    self.button:SetShown(not ns.db.hideMinimap)
    self:Position()
end
function B:Initialize()
    if self.button or not Minimap then return end
    local button=CreateFrame("Button",nil,Minimap)
    self.button=button; button:SetSize(30,30)
    button:SetFrameLevel(Minimap:GetFrameLevel()+5)
    button:RegisterForClicks("LeftButtonUp","RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button.icon=button:CreateTexture(nil,"ARTWORK"); button.icon:SetAllPoints()
    button.icon:SetTexture("Interface/AddOns/DropWatch/Assets/DropWatch-Mini.tga")
    button:SetScript("OnClick",function(_,mouse)
        if button.dragging or (button.suppressUntil and GetTime()<button.suppressUntil) then return end
        if mouse=="RightButton" then ns.Settings:Toggle() else ns.Main:Toggle() end
    end)
    button:SetScript("OnEnter",function(b)
        if not button.dragging and GameTooltip then
            GameTooltip:SetOwner(b,"ANCHOR_LEFT")
            GameTooltip:SetText([[DropWatch
Left-click: panel
Right-click: settings
Drag: move around minimap]])
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    button:SetScript("OnDragStart",function()
        button.dragging=true
        if GameTooltip then GameTooltip:Hide() end
        button:SetScript("OnUpdate",function() self:Drag() end)
        self:Drag()
    end)
    button:SetScript("OnDragStop",function() self:StopDrag() end)
    button:SetScript("OnMouseUp",function(_,mouse) if mouse=="LeftButton" then self:StopDrag() end end)
    button:SetScript("OnHide",function()
        self:StopDrag()
        if GameTooltip then GameTooltip:Hide() end
    end)
    button:SetScript("OnShow",function() self:Position() end)
    button:SetScript("OnSizeChanged",function() self:Position() end)
    Minimap:HookScript("OnSizeChanged",function() self:Position() end)
    Minimap:HookScript("OnShow",function() self:Position() end)
    button:RegisterEvent("UI_SCALE_CHANGED")
    button:RegisterEvent("DISPLAY_SIZE_CHANGED")
    button:RegisterEvent("GLOBAL_MOUSE_UP")
    button:SetScript("OnEvent",function(_,event,mouse)
        if event=="GLOBAL_MOUSE_UP" then
            if mouse=="LeftButton" then self:StopDrag() end
        else self:Position() end
    end)
    self:Refresh()
end
