local _, ns = ...
local P,T={},ns.Style
ns.Settings=P
function P:Set(key,value)
    ns.db[key]=value
    if key=="displayMode" then ns.Notification:Dismiss() end
    ns.Main:ApplySettings(); self:Refresh()
end
function P:Refresh()
    if not self.frame then return end
    for key,button in pairs(self.modes) do T.Active(button,ns.db.displayMode==key) end
    self.mounts.label:SetText("Mounts: "..(ns.db.trackMounts and "enabled" or "disabled"))
    self.lock.label:SetText(ns.db.locked and "Position / resize: locked" or "Position / resize: unlocked")
    self.minimap.label:SetText(ns.db.hideMinimap and "Minimap button: hidden" or "Minimap button: shown")
    self.opacityLabel:SetText("Background opacity: "..math.floor(ns.db.opacity*100+0.5).."%")
    T.Backdrop(self.frame)
end
function P:Create()
    if self.frame then return end
    local f=CreateFrame("Frame","LootTrackerSettingsFrame",UIParent,"BackdropTemplate")
    self.frame=f; f:SetSize(320,340); local p=ns.db.settingsPosition; f:SetPoint(p.point,UIParent,p.relativePoint,p.x,p.y); f:SetMovable(true); f:SetClampedToScreen(true); f:SetFrameStrata("DIALOG"); T.Backdrop(f)
    self.bar=CreateFrame("Button",nil,f)
    self.bar:SetPoint("TOPLEFT",1,-1); self.bar:SetPoint("TOPRIGHT",-32,-1); self.bar:SetHeight(30)
    self.bar:RegisterForDrag("LeftButton")
    self.bar:SetScript("OnDragStart",function() f:StartMoving() end)
    self.bar:SetScript("OnDragStop",function()
        f:StopMovingOrSizing()
        local point,_,relativePoint,x,y=f:GetPoint()
        ns.db.settingsPosition={point=point,relativePoint=relativePoint,x=x,y=y}
    end)
    local title=T.Text(self.bar,12); title:SetPoint("TOPLEFT",12,-12); title:SetText("Loot Tracker · Settings")
    local close=T.Button(f,"×",22,20,function() f:Hide() end); close:SetPoint("TOPRIGHT",-6,-6)
    local label=T.Text(f,11); label:SetPoint("TOPLEFT",12,-45); label:SetText("Display behavior")
    self.modes={}
    for i,mode in ipairs({{"automatic","Automatic panel"},{"notification","Compact notification"},{"manual","Manual"}}) do
        local button=T.Button(f,mode[2],296,24,function() self:Set("displayMode",mode[1]) end)
        button:SetPoint("TOPLEFT",12,-63-(i-1)*27); self.modes[mode[1]]=button
    end
    local equipment=T.Text(f,11); equipment:SetPoint("TOPLEFT",12,-151); equipment:SetText("Equipment: always enabled")
    self.mounts=T.Button(f,"",296,24,function() self:Set("trackMounts",not ns.db.trackMounts) end); self.mounts:SetPoint("TOPLEFT",12,-173)
    self.opacityLabel=T.Text(f,11); self.opacityLabel:SetPoint("TOPLEFT",12,-209)
    self.opacity=CreateFrame("Slider",nil,f,"BackdropTemplate"); self.opacity:SetPoint("TOPLEFT",12,-230); self.opacity:SetSize(296,10)
    self.opacity:SetOrientation("HORIZONTAL"); self.opacity:SetMinMaxValues(0.2,1); self.opacity:SetValueStep(0.01); self.opacity:SetObeyStepOnDrag(true)
    T.Backdrop(self.opacity,1); self.opacity:SetThumbTexture("Interface/Buttons/WHITE8X8")
    local thumb=self.opacity:GetThumbTexture(); thumb:SetSize(8,16); thumb:SetVertexColor(0.25,0.65,0.6)
    self.opacity:SetValue(ns.db.opacity)
    self.opacity:SetScript("OnValueChanged",function(_,value)
        local safe=ns.Safe.Value(value,"number")
        if safe then self:Set("opacity",math.max(0.2,math.min(1,safe))) end
    end)
    self.lock=T.Button(f,"",296,24,function() self:Set("locked",not ns.db.locked) end); self.lock:SetPoint("TOPLEFT",12,-252)
    self.minimap=T.Button(f,"",296,24,function() self:Set("hideMinimap",not ns.db.hideMinimap) end); self.minimap:SetPoint("TOPLEFT",12,-279)
    local reset=T.Button(f,"Reset panel position / size",296,24,function()
        ns.db.window={point="CENTER",relativePoint="CENTER",x=0,y=0,width=420,height=300}
        ns.Main:ApplySettings(true)
    end); reset:SetPoint("TOPLEFT",12,-306)
    UISpecialFrames[#UISpecialFrames+1]="LootTrackerSettingsFrame"
    f:Hide(); self:Refresh()
end
function P:Toggle()
    self:Create(); self.frame:SetShown(not self.frame:IsShown())
    if self.frame:IsShown() then self.frame:Raise() end
    self:Refresh()
end
