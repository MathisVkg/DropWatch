local _, ns = ...
local T,S = {},ns.Safe
ns.Style=T
T.accent={0.18,0.62,0.59}
function T.Plain(value,fallback)
    local text=S.Value(value,"string")
    return text and text:gsub("|","||") or (fallback or "Unknown")
end
function T.Backdrop(frame,alpha)
    frame:SetBackdrop({bgFile="Interface/Buttons/WHITE8X8",edgeFile="Interface/Buttons/WHITE8X8",edgeSize=1})
    frame:SetBackdropColor(0.045,0.052,0.058,alpha or 0.96)
    frame:SetBackdropBorderColor(0.24,0.27,0.29,1)
end
function T.Text(parent,size)
    local text=parent:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    text:SetFont(STANDARD_TEXT_FONT or "Fonts/FRIZQT__.TTF",size or 11,"")
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    return text
end
function T.Button(parent,label,width,height,callback)
    local button=CreateFrame("Button",nil,parent,"BackdropTemplate")
    button:SetSize(width or 24,height or 22); T.Backdrop(button,0.94)
    button.label=T.Text(button,11); button.label:SetPoint("CENTER"); button.label:SetText(label)
    button:SetScript("OnClick",callback)
    button:SetScript("OnEnter",function(b) b:SetBackdropBorderColor(unpack(T.accent)) end)
    button:SetScript("OnLeave",function(b) b:SetBackdropBorderColor(0.24,0.27,0.29,1) end)
    return button
end
function T.Active(button,active)
    button:SetBackdropBorderColor(active and 0.18 or 0.24,active and 0.62 or 0.27,active and 0.59 or 0.29,1)
    button.label:SetTextColor(active and 0.45 or 0.75,active and 0.85 or 0.77,active and 0.81 or 0.79)
end
function T.Link(record)
    local link=S.Value(record.link,"string")
    return link and ns.Parser.Links(link)[1]==link and link or nil
end
