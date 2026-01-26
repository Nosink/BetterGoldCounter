local name, ns = ...

local utils = ns.utils
local settings = ns.settings

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
        tile = true,
        tileSize = 11,
        edgeSize = 11,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    }
    frame:SetBackdrop(backdrop)
    frame.SetBackdropAlpha = function (self)
        local backdropAlpha, backdropBorderalpha = settings.GetBackdropAlphas()
        self:SetBackdropColor(0, 0, 0, backdropAlpha)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, backdropBorderalpha)
    end
    frame:SetBackdropAlpha()
end

local function SetAlphaBehaviour(frame)
    local alpha = settings.GetFadeOpacity()
    frame:SetAlpha(alpha)

    frame:SetScript("OnEnter", function(self)
        if not settings.IsFadeEnabled() then return end
        local duration = settings.GetFadeDuration()
        local targetAlpha = settings.GetFadeInOpacity()
        utils.FadeIn(self, duration, targetAlpha)
    end)
    
    frame:SetScript("OnLeave", function(self)
        if not settings.IsFadeEnabled() then return end
        local duration = settings.GetFadeDuration()
        local targetAlpha = settings.GetFadeOutOpacity()
        utils.FadeOut(self, duration, targetAlpha)
    end)
end

local function createLabel(frame)

    local label = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    local fontFile, _, flags = label:GetFont()
    local fontSize = settings.GetFontSize()
    label:SetFont(tostring(fontFile), fontSize, flags)
    label:SetPoint("RIGHT", frame, "LEFT", -fontSize * 0.9, 0)
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    local text = GetMoneyString(0)
    label:SetText(text)
    label:Show()

    frame.UpdateText = function(self, amount)
        if not self.label then return end
        local sign = utils.GetSignSymbol(tonumber(amount))
        local newText = GetMoneyString(abs(amount))

        self.label:SetText(sign .. " " .. newText)

        local fontName, _, flags = self.label:GetFont()
        self.label:SetFont(tostring(fontName), settings.GetFontSize(), flags)
        self.label:SetPoint("RIGHT", frame, "RIGHT", -settings.GetFontSize() * 0.8, 0)

        local height = settings.GetFontSize() * 1.8
        local dynamicWidth = self.label:GetStringWidth() + settings.GetFontSize() * 1.5
        local width = settings.IsDynamicWidth() and dynamicWidth or settings.GetWidth()

        frame:SetSize(width, height)
        self.label:Show()
    end

    frame.label = label
end

local function createFrame()

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    local x, y = settings.GetPosition()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    frame:SetFrameStrata("HIGH")

    RegisterDrag(frame)
    SetBackdrop(frame)
    SetAlphaBehaviour(frame)
    createLabel(frame)

    ns.frame = frame
    ns.frame:Show()
end

local function onVariablesLoaded(_)
    createFrame()

    ns.frame:UpdateText("0")

    ns:TriggerEvent(name .. "_FRAME_CREATED")
end

local function onSessionMoneyChanged(_, sessionMoney)
    local frame = ns.frame
    if not frame then return end

    frame:UpdateText(sessionMoney)
end

ns:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
ns:RegisterEvent(name .. "_SESSION_MONEY_CHANGED", onSessionMoneyChanged)