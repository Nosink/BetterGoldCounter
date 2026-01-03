local name, ns = ...

local settings = ns.settings

local function createGoldCounterLabel()
    if ns.label then return end

    local label = ns.frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    local fontFile, _, flags = label:GetFont()
    local fontSize = settings.GetFontSize()
    label:SetFont(tostring(fontFile), fontSize, flags)
    label:SetPoint("RIGHT", ns.frame, "RIGHT", -fontSize * 0.9, 0)
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    local text = GetMoneyString(0)
    label:SetText(text)
    label:Show()

    ns.label = label
    ns.frame.label = ns.label
end

local function onFrameReady(_)
    createGoldCounterLabel()
    ns:TriggerEvent(name .. "_PLAYER_MONEY_READY")
end

ns:RegisterEvent(name .. "_FRAME_READY", onFrameReady)