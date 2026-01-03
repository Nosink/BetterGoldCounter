local name, ns = ...

local utils = ns.utils
local settings = ns.settings

local function createGoldCounterFrame()
    if ns.frame then return end

    ns.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    local x, y = settings.GetPosition()
    ns.frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    ns.frame:RegisterForDrag("LeftButton")
    ns.frame:SetFrameStrata("HIGH")
    ns.frame:SetMovable(true)
    local alpha = settings.GetFadeOpacity()
    ns.frame:SetAlpha(alpha)    
    ns.frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 11,
        edgeSize = 11,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    ns.frame.SetBackdropAlpha = function (self)
        local backdropAlpha, backdropBorderalpha = settings.GetBackdropAlphas()
        self:SetBackdropColor(0, 0, 0, backdropAlpha)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, backdropBorderalpha)
    end
    ns.frame:SetBackdropAlpha()

    ns.frame:SetScript("OnDragStart", function(self)
        if (settings.IsFrameUnlocked()) then
            self:StartMoving()
        end
        self:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            self:SetScript("OnUpdate", nil)
        end)
        self:SetScript("OnUpdate", function(self)
            x, y = self:GetCenter()
            settings.SetPosition(math.floor(x), math.floor(y))
        end)
    end)

    ns.frame:SetScript("OnEnter", function(self)
        local duration = settings.GetFadeDuration()
        local targetAlpha = settings.GetFadeInOpacity()
        utils.FadeIn(self, duration, targetAlpha)
    end)

    ns.frame:SetScript("OnLeave", function(self)
        local duration = settings.GetFadeDuration()
        local targetAlpha = settings.GetFadeOutOpacity()
        utils.FadeOut(self, duration, targetAlpha)
    end)

    ns.frame.UpdateText = function(self, text)
        if not self.label then return end
        self.label:SetText(text)

        local fontName, _, flags = self.label:GetFont()
        self.label:SetFont(tostring(fontName), settings.GetFontSize(), flags)
        self.label:SetPoint("RIGHT", ns.frame, "RIGHT", -settings.GetFontSize() * 0.8, 0)

        local height = settings.GetFontSize() * 1.8
        local dynamicWidth = self.label:GetStringWidth() + settings.GetFontSize() * 1.5
        local width = settings.IsDynamicWidth() and dynamicWidth or settings.GetWidth()

        ns.frame:SetSize(width, height)
        self.label:Show()
    end

end

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
    ns.frame.label = label
end

local function onAddonLoaded(_)
    createGoldCounterFrame()
    createGoldCounterLabel()
    ns:TriggerEvent(name .. "_PLAYER_MONEY_READY")
end

local function onSettingChanged(_, key)
    if (key == "width" or key == "dynamicWidth" or key == "fontSize") then
        ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
    elseif (key == "fade" or key == "fadeInOpacity" or key == "fadeOutOpacity") then
        local alpha = settings.GetFadeOpacity()
        ns.frame:SetAlpha(alpha)
    elseif (key == "backdrop") then
        ns.frame:SetBackdropAlpha()
    end
end

ns:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
ns:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingChanged)