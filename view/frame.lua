local name, ns = ...

local utils = ns.utils
local settings = ns.settings

local frame = nil

local function SetPosition()
    if not frame then return end

    frame.SetFramePosition = function(self)
        local x, y = settings.GetPosition()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    end
    frame:SetFramePosition()
end

local function SetFrameStrata()
    if not frame then return end

    frame:SetFrameStrata("HIGH")
end

local function SetAlpha()
    if not frame then return end

    frame.SetFrameAlpha = function(self)
        local alpha = settings.GetFadeOpacity()
        self:SetAlpha(alpha)
    end

    local function onEnter(self)
        if not settings.IsFadeEnabled() then return end
        local duration = settings.GetFadeDuration()
        local targetAlpha = settings.GetFadeInOpacity()
        utils.FadeIn(self, duration, targetAlpha)
    end

    local function onLeave(self)
        if not settings.IsFadeEnabled() then return end
        local duration = settings.GetFadeDuration()
        local targetAlpha = settings.GetFadeOutOpacity()
        utils.FadeOut(self, duration, targetAlpha)
    end

    frame:SetFrameAlpha()
    frame:SetScript("OnEnter", onEnter)
    frame:SetScript("OnLeave", onLeave)
end

local function SetBackdrop()
    if not frame then return end

    local backdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 11, edgeSize = 11,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    }
    frame.SetBackdropAlpha = function (self)
        local backdropAlpha = settings.GetBackdropAlpha()
        self:SetBackdropColor(0, 0, 0, backdropAlpha)
        self:SetBackdropBorderColor(1.0, 1.0, 1.0, backdropAlpha)
    end
    frame:SetBackdrop(backdrop)
    frame:SetBackdropAlpha()
end

local function RegisterDrag()
    if not frame then return end

    local function onUpdate(self)
        local x, y = self:GetCenter()
        settings.SetPosition(math.floor(x), math.floor(y))
    end

    local function onDragStop(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
    end

    local function onDragStart(self)
        if (settings.IsFrameUnlocked()) then
            self:StartMoving()
        end
        self:SetScript("OnDragStop", onDragStop)
        self:SetScript("OnUpdate", onUpdate)
    end

    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", onDragStart)
end

local function createFrame()
    if frame then return end

    frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

    SetPosition()
    SetFrameStrata()
    SetAlpha()
    SetBackdrop()
    RegisterDrag()

    frame:Show()
end

local function CreateLabelFontString()
    if not frame then return end

    local label = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetText("")

    frame.label = label
end

local function getMoneyString(amount)
    local sign = utils.GetSignSymbol(tonumber(amount))
    local moneyString = GetMoneyString(math.abs(amount))
    return (sign .. " " .. moneyString)
end

local function getSignColor(amount)
    if amount > 0 then
        return { r = 0.6, g = 1.0, b = 0.6 }
    elseif amount < 0 then
        return { r = 1.0, g = 0.6, b = 0.6 }
    end
    return { r = 1.0, g = 1.0, b = 1.0 }
end

local function SetTextColor(label, color)
    label:SetTextColor(color.r, color.g, color.b, 1.0)
end

local function CreateUpdateTextMethod()
    if not frame then return end

    frame.CalculateSize = function(self)
        local height = settings.GetFontSize() * 1.8
        local dynamicWidth = self.label:GetStringWidth() + settings.GetFontSize() * 2.2
        local width = settings.IsDynamicWidth() and dynamicWidth or settings.GetWidth()
        return width, height
    end

    frame.SetFrameSize = function(self)
        local fontName, _, flags = self.label:GetFont()
        self.label:SetFont(tostring(fontName), settings.GetFontSize(), flags)
        local alignment, offset = settings.GetFontPoint()
        self.label:ClearAllPoints()
        self.label:SetPoint(alignment, self, alignment, offset, 0)

        local width, height = self:CalculateSize()
        self:SetSize(width, height)
    end

    frame.UpdateFrameAndText = function(self, amount)
        if not self.label then return end

        local text = getMoneyString(amount)
        self.label:SetText(text)

        local color = getSignColor(amount)
        SetTextColor(self.label, color)

        self:SetFrameSize()
    end
end

local function CreateLabel()
    if not frame or frame.label then return end

    CreateLabelFontString()
    CreateUpdateTextMethod()

    frame.label:Show()
end

local function SetText(amount)
    if not frame then return end

    frame:UpdateFrameAndText(amount)
end

local function onPlayerModalReady(_)
    createFrame()
    CreateLabel()
end

local function onSessionMoneyChanged(_, sessionMoney)
    if not frame then return end

    SetText(sessionMoney)
end

local function onSettingChanged(_, key)
    if not frame then return end

    if (key == "xy") then
        frame:SetFramePosition()
    elseif (key == "width" or key == "dynamicWidth" or key == "fontSize" or key == "fontAlignment" or key == "xy") then
        frame:SetFrameSize()
    elseif (key == "fade" or key == "fadeInOpacity" or key == "fadeOutOpacity") then
        frame:SetFrameAlpha()
    elseif (key == "backdrop") then
        frame:SetBackdropAlpha()
    end
end

BGCBus:RegisterEvent(name .. "_PLAYER_MODAL_READY", onPlayerModalReady)
BGCBus:RegisterEvent(name .. "_SESSION_MONEY_CHANGED", onSessionMoneyChanged)
BGCBus:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingChanged)