local _, ns = ...
local S = ns.Safe
ns.events = { "CHAT_MSG_LOOT", "ENCOUNTER_LOOT_RECEIVED", "ENCOUNTER_START", "ENCOUNTER_END",
    "CHALLENGE_MODE_START", "CHALLENGE_MODE_COMPLETED", "CHALLENGE_MODE_COMPLETED_REWARDS",
    "CHALLENGE_MODE_RESET", "PLAYER_ENTERING_WORLD", "ITEM_DATA_LOAD_RESULT", "GROUP_ROSTER_UPDATE", "PLAYER_LOGOUT",
    "ITEM_UPGRADE_MASTER_OPENED", "ITEM_UPGRADE_MASTER_CLOSED",
    "ITEM_UPGRADE_MASTER_SET_ITEM", "ITEM_UPGRADE_MASTER_UPDATE" }
ns.registered = {}
local frame = CreateFrame("Frame")
ns.eventFrame = frame
function ns:Status()
    local build = S.Call(GetBuildInfo)
    self:Print("v" .. self.version .. " | client=" .. S.Text(build[1]) .. " interface=" .. S.Text(build[4]) ..
        " | debug=" .. tostring(self.db.debug) .. " | secret guard=" .. tostring(type(issecretvalue)=="function") ..
        " | raw=" .. #self.raw .. "/200 observations=" .. #self.records .. "/200 normalized=" .. #self.normalized .. "/200")
    self:Print("Session counters: " .. S.Dump(self.counters, 1))
    self:Print("History=" .. #self.Session.entries .. "/1000 | recent=" .. #self.Session:Records(true) ..
        " | mode=" .. self.db.displayMode .. (self.Session.demo and " | DEMO active" or ""))
    for _, event in ipairs(self.events) do self:Print(event .. ": " .. self.registered[event]) end
end
function ns:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        if S.Value((...), "string") ~= self.name then return end
        self:LoadSettings()
        self.Recipients:Refresh()
        self.Session:Initialize()
        self.Main:Initialize()
        frame:UnregisterEvent("ADDON_LOADED")
        for _, wanted in ipairs(self.events) do
            local ok, result = pcall(frame.RegisterEvent, frame, wanted)
            self.registered[wanted] = ok and result ~= false and "registered" or "unavailable"
        end
        SLASH_DROPWATCH1 = "/dropwatch"
        SLASH_DROPWATCH2 = "/dw"
        SLASH_DROPWATCH3 = "/loottracker"
        SlashCmdList.DROPWATCH = function(text)
            local command = (text or ""):lower():match("^%s*(.-)%s*$")
            if command == "" then self.Main:Toggle()
            elseif command == "diag" then self.UI:Toggle()
            elseif command == "settings" then self.Settings:Toggle()
            elseif command == "demo" then if self.Session.demo then self.Demo:Stop() else self.Demo:Start() end
            elseif command == "demo off" then self.Demo:Stop()
            elseif command == "demo burst" then self.Demo:Burst()
            elseif command == "debug" then
                self.db.debug = not self.db.debug
                self:Print("Detailed diagnostics " .. (self.db.debug and "enabled." or "disabled.") .. " Raw data stays in memory until clear/reload.")
                self:Changed()
            elseif command == "clear" then self:Clear(); self:Print("Session history, recent loot and diagnostic records cleared.")
            elseif command == "status" then self:Status()
            else self:Print("Commands: /dropwatch (aliases: /dw, /loottracker) [diag | settings | demo [off|burst] | debug | clear | status]") end
        end
        self:Print("Loaded. /dropwatch opens loot; /dropwatch diag opens diagnostics.")
        return
    end
    if not self.db then return end
    if event=="PLAYER_LOGOUT" then self.Session:Save(); return end
    if type(issecretvalue) ~= "function" then
        if not self.guardWarning then self:Print("Secret-value guard unavailable; capture disabled."); self.guardWarning = true end
        return
    end
    local upgradeEvent = event == "ITEM_UPGRADE_MASTER_OPENED" or event == "ITEM_UPGRADE_MASTER_CLOSED"
        or event == "ITEM_UPGRADE_MASTER_SET_ITEM" or event == "ITEM_UPGRADE_MASTER_UPDATE"
    if event == "ITEM_UPGRADE_MASTER_OPENED" then self.upgradeOpen = true
    elseif event == "ITEM_UPGRADE_MASTER_CLOSED" then self.upgradeOpen = false
    elseif event == "PLAYER_ENTERING_WORLD" then self.upgradeOpen = nil end
    -- Upgrade markers are diagnostics only. Never infer an award or suppress loot from NPC proximity.
    if upgradeEvent and not self.db.debug then return end
    local args = S.Pack(...)
    if event=="PLAYER_ENTERING_WORLD" then self.Session:OnWorld(args[1],args[2]) end
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then self.Recipients:Refresh() end
    if event=="GROUP_ROSTER_UPDATE" then self.Main.dirty=true end
    self.Context:Update(event, args)
    self.sequence = self.sequence+1
    local raw = { id=self.sequence, event=event, timestamp=time(), clock=GetTime(), context=self.Context:Snapshot(),
        args=S.Args(...), status="context event (no loot assumed)" }
    if upgradeEvent then
        local selected = S.Call(C_ItemUpgrade and C_ItemUpgrade.GetItemHyperlink)
        local links = self.Parser.Links(selected[1])
        local level = S.Call(C_ItemUpgrade and C_ItemUpgrade.GetItemUpgradeCurrentLevel)
        raw.args = { itemID=links[1] and tonumber(links[1]:match("|Hitem:(%d+)")),
            itemLevel=S.Value(level[1], "number"), open=self.upgradeOpen }
        raw.status = "upgrade diagnostic only (no acquisition)"
    elseif self.db.debug and (event == "CHAT_MSG_LOOT" or event == "ENCOUNTER_LOOT_RECEIVED"
        or event == "ITEM_DATA_LOAD_RESULT") then
        raw.upgradeOpen = self.upgradeOpen
    end
    self:Push(self.raw, raw)
    if event == "ITEM_DATA_LOAD_RESULT" then self.Loot:Loaded(args[1], args[2]); raw.status="item data result"
    else self.Loot:Observe(raw, args) end
    self:Changed()
end
frame:SetScript("OnEvent", function(_, event, ...)
    local ok = pcall(ns.OnEvent, ns, event, ...)
    if not ok then
        -- Do not format an error object which could itself contain restricted data.
        if ns.db then
            ns:Push(ns.raw, { id=ns.sequence, event=event, timestamp=time(), status="unprocessed: handler error" })
            ns:Changed()
        end
        ns:Print("Event handler failed; inspect Raw events. Report event and client build.")
    end
end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed+delta
    if elapsed < 0.5 then return end
    elapsed = 0
    if ns.db then
        ns.Loot:Expire()
        if ns.UI.dirty then ns.UI:Render() end
        if ns.Main.dirty then ns.Main:Render() end
    end
end)
frame:RegisterEvent("ADDON_LOADED")
