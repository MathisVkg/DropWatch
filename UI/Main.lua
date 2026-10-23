local _, ns = ...
local M,T={totalHeight=0,tab="loot",dirty=true,collapsed={},rows={},freeRows={},headers={},freeHeaders={}},ns.Style
ns.Main=M
function M:NewAward(count,id)
    if ns.db.displayMode=="automatic" then self:Show("loot")
    elseif ns.db.displayMode=="notification" then ns.Notification:Add(count,id) end
end
function M:Initialize()
    ns.Minimap:Initialize()
    self.minimap=ns.Minimap.button
end
function M:SaveWindow(dimensions)
    if not self.frame then return end
    local p=ns.db.window
    local point,_,relative,x,y=self.frame:GetPoint()
    p.point,p.relativePoint,p.x,p.y=point,relative,x,y
    p.width=self.frame:GetWidth()
    if dimensions and not self.minimized then p.height=math.max(180,math.min(900,self.frame:GetHeight())) end
end
function M:ApplySettings(reset)
    ns.Minimap:Refresh()
    if self.frame then
        T.Backdrop(self.frame,ns.db.opacity)
        self.frame:SetMovable(not ns.db.locked)
        self.frame:SetResizable(not ns.db.locked and not self.minimized)
        self.resize:SetShown(not ns.db.locked and not self.minimized)
        if reset then
            self.minimized=false
            self.frame:ClearAllPoints(); self.frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
            self.frame:SetResizeBounds(360,128,1000,900); self.frame:SetSize(420,300)
            self.tabs:Show(); self.scroll:Show(); self.minimize.label:SetText("−"); self:SaveWindow(true)
            self.resize:SetShown(not ns.db.locked)
        end
        self.dirty=true
    end
    ns.Session:ScheduleExpiry(); ns.Session:Changed()
end
function M:Create()
    if self.frame then return end
    local f=CreateFrame("Frame","LootTrackerMainFrame",UIParent,"BackdropTemplate")
    self.frame=f; T.Backdrop(f,ns.db.opacity); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
    local p=ns.db.window
    f:SetResizeBounds(360,128,1000,900); f:SetSize(p.width,p.height); f:SetPoint(p.point,UIParent,p.relativePoint,p.x,p.y)
    local bar=CreateFrame("Button",nil,f); self.bar=bar
    bar:SetPoint("TOPLEFT",1,-1); bar:SetPoint("TOPRIGHT",-1,-1); bar:SetHeight(30)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnDragStart",function() if not ns.db.locked then self.interacting="move"; f:StartMoving() end end)
    bar:SetScript("OnDragStop",function() f:StopMovingOrSizing(); self.interacting=nil; self:SaveWindow(); self:Render() end)
    bar:SetScript("OnClick",function() if self.minimized then self:Minimize(false) end end)
    local icon=bar:CreateTexture(nil,"ARTWORK"); icon:SetSize(16,16); icon:SetPoint("LEFT",8,0); icon:SetTexture("Interface/AddOns/LootTracker/Assets/LootTracker.tga")
    self.title=T.Text(bar,12); self.title:SetPoint("LEFT",icon,"RIGHT",7,0); self.title:SetText("Loot Tracker")
    local close=T.Button(bar,"×",22,20,function() self:Close() end); close:SetPoint("RIGHT",-5,0)
    self.minimize=T.Button(bar,"−",22,20,function() self:Minimize(not self.minimized) end); self.minimize:SetPoint("RIGHT",close,"LEFT",-3,0)
    local settings=T.Button(bar,"⚙",22,20,function() ns.Settings:Toggle() end); settings:SetPoint("RIGHT",self.minimize,"LEFT",-3,0)
    settings.label:SetText("")
    settings.icon=settings:CreateTexture(nil,"ARTWORK"); settings.icon:SetSize(14,14); settings.icon:SetPoint("CENTER")
    settings.icon:SetTexture("Interface/AddOns/LootTracker/Assets/Settings.tga")
    settings:SetScript("OnEnter",function(b)
        b:SetBackdropBorderColor(unpack(T.accent)); if GameTooltip then GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:SetText("Loot Tracker settings"); GameTooltip:Show() end
    end)
    settings:SetScript("OnLeave",function(b) b:SetBackdropBorderColor(0.24,0.27,0.29,1); if GameTooltip then GameTooltip:Hide() end end)
    self.tabs=CreateFrame("Frame",nil,f); self.tabs:SetPoint("TOPLEFT",8,-34); self.tabs:SetPoint("TOPRIGHT",-8,-34); self.tabs:SetHeight(24)
    self.lootTab=T.Button(self.tabs,"Loot",64,23,function() self:SetTab("loot") end); self.lootTab:SetPoint("LEFT")
    self.historyTab=T.Button(self.tabs,"History",72,23,function() self:SetTab("history") end); self.historyTab:SetPoint("LEFT",self.lootTab,"RIGHT",4,0)
    self.demoLabel=T.Text(self.tabs,10); self.demoLabel:SetPoint("RIGHT"); self.demoLabel:SetTextColor(0.4,0.8,0.75)
    local line=f:CreateTexture(nil,"ARTWORK"); line:SetColorTexture(0.18,0.55,0.52,0.65); line:SetHeight(1)
    line:SetPoint("TOPLEFT",1,-31); line:SetPoint("TOPRIGHT",-1,-31)
    self.scroll=CreateFrame("ScrollFrame",nil,f)
    self.scroll:SetPoint("TOPLEFT",8,-64); self.scroll:SetPoint("BOTTOMRIGHT",-18,14)
    self.content=CreateFrame("Frame",nil,self.scroll); self.content:SetSize(380,1); self.scroll:SetScrollChild(self.content)
    self.scroll:SetScript("OnVerticalScroll",function() self:SyncScrollbar(); self:RenderVisible() end)
    self.scroll:EnableMouseWheel(true)
    self.scroll:SetScript("OnMouseWheel",function(_,delta)
        self.scroll:SetVerticalScroll(math.max(0,math.min(self.scrollMaximum or 0,self.scroll:GetVerticalScroll()-delta*51)))
    end)
    local slider=CreateFrame("Slider",nil,f); self.scrollbar=slider
    slider:SetWidth(4); slider:SetPoint("TOPRIGHT",-7,-64); slider:SetPoint("BOTTOMRIGHT",-7,22)
    slider:SetOrientation("VERTICAL"); slider:SetMinMaxValues(0,0); slider:SetValueStep(1); slider:SetObeyStepOnDrag(false)
    slider:SetHitRectInsets(-5,-5,0,0)
    local track=slider:CreateTexture(nil,"BACKGROUND"); track:SetAllPoints(); track:SetColorTexture(0.07,0.08,0.09,1)
    slider:SetThumbTexture("Interface/Buttons/WHITE8X8")
    local thumb=slider:GetThumbTexture(); thumb:SetWidth(4); thumb:SetVertexColor(0.38,0.41,0.43,1)
    slider:SetScript("OnEnter",function() thumb:SetVertexColor(0.57,0.60,0.62,1) end)
    slider:SetScript("OnLeave",function() thumb:SetVertexColor(0.38,0.41,0.43,1) end)
    slider:SetScript("OnValueChanged",function(_,value)
        if not self.syncing then self.scroll:SetVerticalScroll(math.max(0,math.min(self.scrollMaximum or 0,value))) end
    end)
    slider:SetScript("OnMouseDown",function() self.interacting="scroll" end)
    slider:SetScript("OnMouseUp",function() self.interacting=nil; self:Render() end)
    self.empty=T.Text(f,11); self.empty:SetPoint("CENTER",f,"CENTER",0,-12); self.empty:SetTextColor(0.55,0.59,0.61)
    self.resize=CreateFrame("Button",nil,f); self.resize:SetSize(20,20); self.resize:SetPoint("BOTTOMRIGHT",-1,1)
    for i=1,3 do
        local mark=self.resize:CreateLine(nil,"ARTWORK")
        mark:SetThickness(1); mark:SetColorTexture(0.34,0.48,0.47,1)
        mark:SetStartPoint("BOTTOMRIGHT",-3-i*3,3); mark:SetEndPoint("BOTTOMRIGHT",-3,3+i*3)
    end
    self.resize:SetScript("OnMouseDown",function(_,button) if button=="LeftButton" and not ns.db.locked and not self.minimized then self:PinTop(); self.interacting="resize"; f:StartSizing("BOTTOMRIGHT") end end)
    self.resize:SetScript("OnMouseUp",function() if self.interacting=="resize" then f:StopMovingOrSizing(); self:SaveWindow(true); self.interacting=nil; self.dirty=true; self:Render() end end)
    -- Native mouse capture normally supplies OnMouseUp; global release also handles an outside release.
    f:RegisterEvent("GLOBAL_MOUSE_UP")
    f:SetScript("OnEvent",function(_,event)
        if event=="GLOBAL_MOUSE_UP" and self.interacting then
            local sizing=self.interacting=="resize"
            f:StopMovingOrSizing(); self:SaveWindow(sizing); self.interacting=nil; self:Render()
        end
    end)
    f:SetScript("OnHide",function()
        if self.interacting then f:StopMovingOrSizing(); self.interacting=nil end
    end)
    f:SetScript("OnSizeChanged",function() self.dirty=true end)
    f:SetScript("OnShow",function() self.dirty=true; self:Render() end)
    UISpecialFrames[#UISpecialFrames+1]="LootTrackerMainFrame"
    f:Hide(); self:ApplySettings()
end
function M:SetTab(tab)
    self.tab=tab; self.dirty=true
    if self.scroll then self.scroll:SetVerticalScroll(0) end
    self:Render()
end
function M:Show(tab)
    self:Create()
    if self.minimized then self:Minimize(false) end
    if tab then self.tab=tab; self.scroll:SetVerticalScroll(0) end
    self.frame:Show(); self.dirty=true; self:Render()
end
function M:Close()
    if self.frame then self:SaveWindow(); self.frame:Hide() end
    if ns.Settings.frame then ns.Settings.frame:Hide() end
    ns.Notification:Dismiss()
end
function M:Toggle()
    if self.frame and self.frame:IsShown() then self:Close() else self:Show() end
end
function M:Minimize(value)
    if not self.frame then return end
    if value then self:SaveWindow() end
    local left,top=self.frame:GetLeft(),self.frame:GetTop()
    if left and top then self.frame:ClearAllPoints(); self.frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left,top) end
    self.minimized=value
    self.frame:SetResizeBounds(360,value and 32 or 128,1000,900)
    self.frame:SetHeight(value and 32 or ns.db.window.height)
    self.tabs:SetShown(not value); self.scroll:SetShown(not value); self.empty:Hide()
    self.minimize.label:SetText(value and "+" or "−")
    if ns.Settings.frame then ns.Settings.frame:Hide() end
    self:ApplySettings(); self:SaveWindow(); self:Render()
end
function M:Descriptors()
    local result={}
    if self.tab=="loot" then
        for _,record in ipairs(ns.Session:Records(true)) do result[#result+1]={key="item:"..record.id,record=record,height=48} end
    else
        local groups=ns.Session:Groups()
        local active={}
        for _,group in ipairs(groups) do active[group.key]=true end
        for key in pairs(self.collapsed) do if not active[key] then self.collapsed[key]=nil end end
        for _,group in ipairs(groups) do
            result[#result+1]={key="group:"..group.key,group=group,height=36}
            if not self.collapsed[group.key] then
                for _,record in ipairs(group.items) do result[#result+1]={key="item:"..record.id,record=record,height=48} end
            end
        end
    end
    local top=0
    for _,entry in ipairs(result) do entry.top=top; top=top+entry.height+3 end
    self.totalHeight=math.max(0,top-3)
    return result
end
function M:PinTop()
    local left,top=self.frame:GetLeft(),self.frame:GetTop()
    if left and top then
        self.frame:ClearAllPoints(); self.frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left,top)
        self:SaveWindow()
    end
end
function M:AdaptHeight()
    if self.minimized or self.interacting then return end
    local height=math.min(ns.db.window.height,math.max(128,78+self.totalHeight))
    if math.abs(self.frame:GetHeight()-height)>0.5 then
        self:PinTop(); self.frame:SetHeight(height)
    end
end
function M:SyncScrollbar()
    if not self.scrollbar then return end
    local maximum=self.scrollMaximum or 0
    self.scrollbar:SetShown(maximum>0 and not self.minimized)
    self.syncing=true
    self.scrollbar:SetMinMaxValues(0,maximum)
    local trackHeight=math.max(1,self.frame:GetHeight()-86)
    self.scrollbar:GetThumbTexture():SetHeight(math.min(trackHeight,math.max(18,trackHeight*self.scroll:GetHeight()/math.max(1,self.totalHeight or 0))))
    self.scrollbar:SetValue(math.max(0,math.min(maximum,self.scroll:GetVerticalScroll())))
    self.syncing=nil
end
function M:Render()
    if not self.frame or not self.frame:IsShown() then return end
    if self.interacting then self.dirty=true; return end
    self.title:SetText(ns.Session.demo and "Loot Tracker · DEMO" or "Loot Tracker")
    if self.minimized then self.scrollbar:Hide(); self.dirty=false; return end
    T.Active(self.lootTab,self.tab=="loot"); T.Active(self.historyTab,self.tab=="history")
    self.demoLabel:SetText(ns.Session.demo and "SIMULATED" or "")
    self.descriptors=self:Descriptors()
    self:AdaptHeight()
    self.content:SetWidth(self.scroll:GetWidth()); self.content:SetHeight(math.max(1,self.totalHeight))
    local maximum=math.max(0,self.totalHeight-self.scroll:GetHeight())
    self.scrollMaximum=maximum
    self:SyncScrollbar()
    if self.scroll:GetVerticalScroll()>maximum then self.scroll:SetVerticalScroll(maximum) end
    self.empty:SetText(self.tab=="loot" and "No recent loot" or "No session history")
    self.empty:SetShown(#self.descriptors==0)
    self:RenderVisible(); self.dirty=false
end
function M:RenderVisible()
    if not self.descriptors or not self.frame:IsShown() or self.minimized then return end
    local offset,height=self.scroll:GetVerticalScroll(),self.scroll:GetHeight()
    local wanted={}
    for _,entry in ipairs(self.descriptors) do
        if entry.top+entry.height>=offset and entry.top<=offset+height then wanted[entry.key]=entry end
    end
    for key,row in pairs(self.rows) do if not wanted[key] then row:Hide(); self.freeRows[#self.freeRows+1]=row; self.rows[key]=nil end end
    for key,row in pairs(self.headers) do if not wanted[key] then row:Hide(); self.freeHeaders[#self.freeHeaders+1]=row; self.headers[key]=nil end end
    for key,entry in pairs(wanted) do
        local row
        if entry.record then
            row=self.rows[key] or table.remove(self.freeRows) or ns.ItemRow:Create(self.content)
            self.rows[key]=row; ns.ItemRow:Update(row,entry.record,self.content:GetWidth())
        else
            row=self.headers[key] or table.remove(self.freeHeaders) or T.Button(self.content,"",self.content:GetWidth(),36)
            self.headers[key]=row
            if not row.summary then row.summary=T.Text(row,9); row.summary:SetPoint("BOTTOMLEFT",7,3); row.label:ClearAllPoints(); row.label:SetPoint("TOPLEFT",7,-4) end
            local group=entry.group
            row.groupKey=group.key; row:SetWidth(self.content:GetWidth())
            row.label:SetWidth(math.max(1,self.content:GetWidth()-14))
            row.label:SetText((self.collapsed[group.key] and "+ " or "− ")..T.Plain(group.name).." · "..T.Plain(group.difficulty))
            row.summary:SetText(group.equipment.." equipment"..(group.mounts>0 and " · "..group.mounts.." mounts" or "").." · "..date("%H:%M",group.timestamp)..(group.uncertain and " · run unconfirmed" or ""))
            row:SetScript("OnClick",function(b) self.collapsed[b.groupKey]=not self.collapsed[b.groupKey]; self.dirty=true; self:Render() end)
            row:Show()
        end
        row:ClearAllPoints(); row:SetPoint("TOPLEFT",self.content,"TOPLEFT",0,-entry.top)
    end
end
