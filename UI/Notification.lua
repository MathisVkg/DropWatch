local _, ns = ...
local N,T={count=0,ids={}},ns.Style
ns.Notification=N
function N:Create()
    if self.frame then return end
    local f=T.Button(UIParent,"",310,34,function() self:Dismiss(); ns.Main:Show("loot") end)
    self.frame=f; f:SetPoint("TOP",UIParent,"TOP",0,-160); f:SetClampedToScreen(true)
    f:SetFrameStrata("DIALOG"); f:Hide()
end
function N:Dismiss()
    if self.timer then self.timer:Cancel(); self.timer=nil end
    self.count=0; self.ids={}
    if self.frame then self.frame:Hide() end
end
function N:Label()
    self.frame.label:SetText((ns.Session.demo and "DEMO · " or "") .. "Loot Tracker · " .. self.count .. " new item" .. (self.count==1 and "" or "s") .. "  ›")
end
function N:Remove(id)
    if not self.ids[id] then return end
    self.count=math.max(0,self.count-self.ids[id]); self.ids[id]=nil
    if self.count==0 then self:Dismiss() elseif self.frame then self:Label() end
end
function N:Add(count,id)
    self:Create()
    if not self.frame:IsShown() then self.count=0; self.ids={} end
    if id and self.ids[id] then return end
    if id then self.ids[id]=count end
    self.count=self.count+count; self:Label(); self.frame:Show()
    if self.timer then self.timer:Cancel() end
    if C_Timer and C_Timer.NewTimer then self.timer=C_Timer.NewTimer(10,function() self:Dismiss() end) end
end
