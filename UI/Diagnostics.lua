local _, ns = ...
local U, S = { dirty=true, mode=1 }, ns.Safe
ns.UI = U
local function context(record)
    local c = record.context or {}
    local e = c.encounter or {}
    local encounterID=record.encounterID or e.id
    local encounterName=record.sourceEvents and record.encounterName or (e.id==encounterID and e.name or nil)
    local encounterState=e.id==encounterID and e.state or nil
    return S.Text(c.instance) .. " (" .. S.Text(c.difficultyName) .. ") / encounter=" ..
        S.Text(encounterID) .. " " .. S.Text(encounterName) .. " " .. S.Text(encounterState) ..
        " / keystone=" .. S.Text(c.challenge and c.challenge.state) ..
        " dungeon=" .. S.Text(c.challenge and (c.challenge.challengeMapID or c.challenge.mapID)) ..
        " / " .. (record.association or "observed context; association unconfirmed") ..
        (record.confidence and " (encounter=" .. record.confidence.encounter .. ")" or "")
end
function U:Render()
    if not self.frame or not self.frame:IsShown() then return end
    local list = self.mode == 1 and ns.raw or (self.mode == 2 and ns.records or ns.normalized)
    local lines = { "DropWatch " .. ns.version .. " | debug=" .. tostring(ns.db.debug) ..
        " | raw=" .. #ns.raw .. " | observations=" .. #ns.records .. " | normalized=" .. #ns.normalized,
        "Session counters: " .. S.Dump(ns.counters, 1),
        "Select text to copy. '?' means unavailable. Data is session-only. Newest first.", "" }
    for i = #list, 1, -1 do
        local r = list[i]
        if (self.mode ~= 4 or r.ambiguous) and (self.mode ~= 5 or r.selected) then
            lines[#lines+1] = "#" .. r.id .. " " .. date("%H:%M:%S", r.timestamp) .. " " .. (r.event or r.source or "canonical") .. " | " .. S.Text(r.status)
            if r.source or r.sourceEvents then
                lines[#lines+1] = "  " .. S.Text(r.player) .. (r.realm and "-" .. r.realm or "") ..
                    " | item=" .. S.Text(r.itemID) .. " ilvl=" .. S.Text(r.itemLevel) .. " qty=" .. S.Text(r.quantity)
                lines[#lines+1] = "  " .. (r.link or "<no original hyperlink>")
                lines[#lines+1] = "  category=" .. S.Text(r.category) .. " rarity=" .. S.Text(r.rarity) ..
                    " icon=" .. S.Text(r.icon) .. " slot=" .. S.Text(r.equipLoc)
                if r.sourceEvents then
                    lines[#lines+1]="  binding=" .. S.Text(r.bindingCategory) .. " reward=" .. S.Text(r.rewardSource) ..
                        " tradeability=" .. S.Text(r.tradeability) .. " confidence=" .. S.Text(r.classificationConfidence)
                    lines[#lines+1]="  exclusion=" .. S.Text(r.exclusionReason) .. " evidence=" .. S.Text(r.classificationEvidence)
                end
                if r.canonicalID then lines[#lines+1]="  Canonical #" .. r.canonicalID .. " | acquisition=" .. S.Text(r.acquisition) end
                if r.sourceEvents then
                    local sources={}
                    for _, source in ipairs(r.sourceEvents) do
                        sources[#sources+1]=source.event .. " (raw #" .. source.rawID .. ", observation #" .. source.observationID .. ")"
                    end
                    lines[#lines+1]="  Sources: " .. table.concat(sources, " + ")
                    if r.ambiguous then
                        lines[#lines+1]="  Ambiguity: " .. S.Dump(r.ambiguityReasons or {},1) ..
                            " unavailable=" .. S.Dump(r.uncertainties or {},1) .. " candidates=" .. S.Dump(r.candidateIDs or {},1)
                    end
                    if ns.db.debug then lines[#lines+1]="  Confidence: " .. S.Dump(r.confidence,1) end
                end
                if ns.db.debug then
                    lines[#lines+1] = "  recipient: " .. (r.recipientNote or "provenance unavailable") .. " | API: " .. (r.apiError or "no error reported")
                end
            elseif r.args then
                lines[#lines+1] = "  args=" .. S.Dump(r.args, ns.db.debug and 4 or 1)
            end
            lines[#lines+1] = "  " .. context(r)
            lines[#lines+1] = ""
        end
    end
    self.edit:SetText(table.concat(lines, "\n"))
    self.edit:SetCursorPosition(0)
    self.dirty = false
end
function U:Create()
    if self.frame then return end
    local f = CreateFrame("Frame", "DropWatchDiagnosticFrame", UIParent, "BackdropTemplate")
    self.frame = f
    f:SetSize(880, 520)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({ bgFile="Interface/Tooltips/UI-Tooltip-Background", edgeFile="Interface/Tooltips/UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=4,right=4,top=4,bottom=4} })
    f:SetBackdropColor(0.04, 0.04, 0.06, 0.97)
    local p = ns.db.position
    f:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = frame:GetPoint()
        ns.db.position = { point=point, relativePoint=relativePoint, x=x, y=y }
    end)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -15)
    title:SetText("DropWatch - diagnostic prototype")
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    local mode = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    self.modeButton = mode
    mode:SetSize(180, 24)
    mode:SetPoint("TOPLEFT", 16, -42)
    mode:SetText("View: Raw events")
    mode:SetScript("OnClick", function()
        self.mode = self.mode % 5 + 1
        mode:SetText(({ "View: Raw events", "View: Parsed observations", "View: Normalized Loot", "View: Ambiguous", "View: Equipment / mounts" })[self.mode])
        self.dirty = true
        self:Render()
    end)
    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("LEFT", mode, "RIGHT", 12, 0)
    hint:SetText("Drag background to move | /dropwatch clear | /dropwatch debug")
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -78)
    scroll:SetPoint("BOTTOMRIGHT", -34, 16)
    local edit = CreateFrame("EditBox", nil, scroll)
    self.edit = edit
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(820)
    edit:SetScript("OnEscapePressed", function(box) box:ClearFocus(); f:Hide() end)
    scroll:SetScrollChild(edit)
    f:SetScript("OnShow", function() self.dirty=true; self:Render() end)
    UISpecialFrames[#UISpecialFrames+1] = "DropWatchDiagnosticFrame"
    f:Hide()
end
function U:Toggle()
    self:Create()
    self.frame:SetShown(not self.frame:IsShown())
end
