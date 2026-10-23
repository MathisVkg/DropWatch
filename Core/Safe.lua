local _, ns = ...
local S = {}
ns.Safe = S
function S.IsSecret(value)
    -- Check before type tests, comparisons, formatting, or use as a key.
    return issecretvalue and issecretvalue(value) or false
end
function S.Value(value, expected)
    if S.IsSecret(value) then return nil end
    local kind = type(value)
    if expected and kind ~= expected then return nil end
    if kind == "string" or kind == "boolean" then return value end
    if kind == "number" and value == value and value ~= math.huge and value ~= -math.huge then return value end
end
function S.Pack(...) return { n = select("#", ...), ... } end
function S.Call(fn, ...)
    if type(fn) ~= "function" then return { n = 0 }, "API unavailable" end
    local result = S.Pack(pcall(fn, ...))
    if not result[1] then return { n = 0 }, "API call failed" end
    local values = { n = result.n - 1 }
    for i = 2, result.n do values[i - 1] = S.Value(result[i]) end
    return values
end
function S.Snapshot(value, depth, budget)
    if S.IsSecret(value) then return "<secret>" end
    local kind = type(value)
    if kind ~= "table" then
        if kind == "nil" then return "<nil>" end
        local safe = S.Value(value)
        if safe ~= nil then return safe end
        return "<" .. kind .. ">"
    end
    if not canaccesstable or not canaccesstable(value) then return "<inaccessible table>" end
    if issecrettable and issecrettable(value) then return "<secret table>" end
    if depth <= 0 then return "<depth limit>" end
    local out = {}
    for key, child in pairs(value) do
        if budget.left <= 0 then out["<truncated>"] = true; break end
        budget.left = budget.left - 1
        if not S.IsSecret(key) then
            local safeKey = S.Value(key)
            if safeKey ~= nil then out[safeKey] = S.Snapshot(child, depth - 1, budget) end
        end
    end
    return out
end
function S.Args(...)
    local out = { n = select("#", ...) }
    local budget = { left = 256 }
    for i = 1, math.min(out.n, 32) do out[i] = S.Snapshot(select(i, ...), 3, budget) end
    return out
end
function S.Text(value)
    local safe = S.Value(value)
    if safe == nil then return "?" end
    return tostring(safe)
end
function S.Dump(value, depth)
    if type(value) ~= "table" then return S.Text(value) end
    if depth <= 0 then return "{...}" end
    local parts = {}
    for key, child in pairs(value) do
        parts[#parts + 1] = S.Text(key) .. "=" .. S.Dump(child, depth - 1)
    end
    table.sort(parts)
    return "{" .. table.concat(parts, ", ") .. "}"
end
