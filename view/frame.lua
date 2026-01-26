local name, ns = ...

local utils = ns.utils
local settings = ns.settings

local function SetPosition(frame)
    local x, y = settings.GetPosition()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end

local function SetFrameStrata(frame)
    frame:SetFrameStrata("HIGH")
end

local function RegisterDrag(frame)
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

local function SetBackdrop(frame)
    local backdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 11, edgeSize = 11,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    }
    frame.SetBackdropAlpha = function (self)
        local backdropAlpha = settings.GetBackdropAlpha()
        self:SetBackdropColor(0, 0, 0, backdropAlpha)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, backdropAlpha)
    end
    frame:SetBackdrop(backdrop)
    frame:SetBackdropAlpha()
end

local function SetAlpha(frame)
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

local function CreateLabel(frame)

    local label = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetText("")
    label:Show()

    frame.label = label
end

local function getMoneyString(amount)
    local sign = utils.GetSignSymbol(tonumber(amount))
    local moneyString = GetMoneyString(abs(amount))
    return (sign .. " " .. moneyString)
end

local function CreateUpdateTextMethod(frame)

    frame.CalculateSize = function(self)
        local height = settings.GetFontSize() * 1.8
        local dynamicWidth = self.label:GetStringWidth() + settings.GetFontSize() * 1.5
        local width = settings.IsDynamicWidth() and dynamicWidth or settings.GetWidth()
        return width, height
    end

    frame.SetFrameSize = function(self)
        local fontName, _, flags = self.label:GetFont()
        self.label:SetFont(tostring(fontName), settings.GetFontSize(), flags)
        self.label:SetPoint("RIGHT", self, "RIGHT", -settings.GetFontSize() * 0.8, 0)

        local width, height = self:CalculateSize()
        self:SetSize(width, height)
    end

    frame.UpdateFrameAndText = function(self, amount)
        if not self.label then return end

        local text = getMoneyString(amount)
        self.label:SetText(text)

        self:SetFrameSize()
    end
end

local function SetText(amount)
    local frame = ns.frame
    if not frame then return end

    frame:UpdateFrameAndText(amount)
end

local function createFrame()

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

    SetPosition(frame)
    SetFrameStrata(frame)
    SetAlpha(frame)
    SetBackdrop(frame)
    RegisterDrag(frame)

    CreateLabel(frame)
    CreateUpdateTextMethod(frame)

    ns.frame = frame
    ns.frame:Show()
end

local function onVariablesLoaded(_)
    createFrame()
    ns:TriggerEvent(name .. "_FRAME_CREATED")
end

local function onFrameCreated(_)
    print (name .. ": Frame created.")
    SetText(ns.session)
end

local function onSessionMoneyChanged(_, sessionMoney)
    local frame = ns.frame
    if not frame then return end

    SetText(sessionMoney)
end

local function onSettingChanged(_, key)
    if (key == "width" or key == "dynamicWidth" or key == "fontSize") then
        ns.frame:SetFrameSize()
    elseif (key == "fade" or key == "fadeInOpacity" or key == "fadeOutOpacity") then
        ns.frame:SetFrameAlpha()
    elseif (key == "backdrop") then
        ns.frame:SetBackdropAlpha()
    end
end

ns:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
ns:RegisterEvent(name .. "_FRAME_CREATED", onFrameCreated)
ns:RegisterEvent(name .. "_SESSION_MONEY_CHANGED", onSessionMoneyChanged)
ns:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingChanged)