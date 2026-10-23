local name, ns = ...
ns.name = name
ns.version = "0.2.2"
ns.raw, ns.records, ns.normalized = {}, {}, {}
ns.sequence = 0
ns.recordSequence, ns.observationSequence = 0, 0
ns.listeners = {}
function ns:ResetCounters()
    self.counters = { rawLoot=0, parsed=0, equipment=0, reconciled=0, ambiguous=0, failures=0 }
end
ns:ResetCounters()
-- Private addon namespace API: callbacks receive (kind, record, detail).
function ns:Subscribe(callback)
    assert(type(callback) == "function", "callback must be a function")
    self.listeners[callback] = true
    return function() self.listeners[callback] = nil end
end
function ns:Notify(kind, record, detail)
    for callback in pairs(self.listeners) do
        local ok = pcall(callback, kind, record, detail)
        if not ok then self.listenerErrors = (self.listenerErrors or 0)+1 end
    end
end
function ns:Push(list, value)
    list[#list + 1] = value
    while #list > self.db.maxRecords do
        local removed = table.remove(list, 1)
        if list == self.normalized then self:Notify("removed", removed, "capacity") end
    end
end
function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff80c0ffLoot Tracker:|r " .. message)
end
function ns:Changed()
    if self.UI then self.UI.dirty = true end
end
function ns:Clear()
    self.raw, self.records, self.normalized = {}, {}, {}
    self:ResetCounters()
    self:Notify("reset")
    self:Changed()
end
