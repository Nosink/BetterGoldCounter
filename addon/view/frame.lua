local name, ns = ...

local frame = nil
local default = 0
local defaultBackdropAlpha = 0.85
local defaultFontSize = 8
local defaultWidth = 50
local defaultFadeDuration = 0.01

local function getSignSymbol(amount)
    if type(amount) ~= "number" then return "" end

    return amount < 0 and "-" or amount > 0 and "+" or ""
end

local function fadeIn(target, duration, targetAlpha)
    if not target then return end

    UIFrameFade(target, {
        mode = "IN",
        timeToFade = duration or 0.5,
        startAlpha = target:GetAlpha() or 0,
        endAlpha = targetAlpha or 1,
    })
end

local function fadeOut(target, duration, targetAlpha)
    if not target then return end

    UIFrameFade(target, {
        mode = "OUT",
        timeToFade = duration or 0.5,
        startAlpha = target:GetAlpha() or 1,
        endAlpha = targetAlpha or 0,
    })
end

local function SetPosition()
    if not frame then return end

    frame.SetFramePosition = function(self)
        local x, y = ns.db.x, ns.db.y
        if not x or not y then
            local width, height = UIParent:GetSize()
            x, y = math.floor(width / 2), math.floor(height / 2)
        else
            x, y = tonumber(x), tonumber(y)
        end
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
        local alpha = ns.db.fade and ns.db.fadeOutOpacity or ns.db.fadeInOpacity
        self:SetAlpha(alpha)
    end

    local function onEnter(self)
        if not ns.db.fade then return end
        local duration = tonumber(ns.db.fadeDuration) or defaultFadeDuration
        if duration < defaultFadeDuration then duration = defaultFadeDuration end
        fadeIn(self, duration, ns.db.fadeInOpacity)
    end

    local function onLeave(self)
        if not ns.db.fade then return end
        local duration = tonumber(ns.db.fadeDuration) or defaultFadeDuration
        if duration < defaultFadeDuration then duration = defaultFadeDuration end
        fadeOut(self, duration, ns.db.fadeOutOpacity)
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
        tile = true,
        tileSize = 11,
        edgeSize = 11,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    }
    frame.SetBackdropAlpha = function(self)
        local backdropAlpha = ns.db.backdrop and defaultBackdropAlpha or 0.0
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
        ns.db.x, ns.db.y = math.floor(x), math.floor(y)
    end

    local function onDragStop(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
    end

    local function onDragStart(self)
        if not ns.db.locked then
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
    local sign = getSignSymbol(tonumber(amount))
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
        local fontSize = tonumber(ns.db.fontSize) or defaultFontSize
        if fontSize < defaultFontSize then fontSize = defaultFontSize end
        local height = fontSize * 1.8
        local dynamicWidth = self.label:GetStringWidth() + fontSize * 2.2
        local staticWidth = tonumber(ns.db.width) or defaultWidth
        if staticWidth < defaultWidth then staticWidth = defaultWidth end
        local width = ns.db.dynamicWidth and dynamicWidth or staticWidth
        return width, height
    end

    frame.SetFrameSize = function(self)
        local fontName, _, flags = self.label:GetFont()
        local fontSize = tonumber(ns.db.fontSize) or defaultFontSize
        if fontSize < defaultFontSize then fontSize = defaultFontSize end
        self.label:SetFont(tostring(fontName), fontSize, flags)
        local alignment = ns.db.fontAlignment
        local offset = 0
        if alignment == "LEFT" then
            offset = fontSize * 0.6
        elseif alignment == "RIGHT" then
            offset = -fontSize * 1.5
        elseif alignment ~= "CENTER" then
            alignment = "RIGHT"
            offset = -fontSize * 1.5
        end
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

local function onAddonLoaded(_)
    createFrame()
    CreateLabel()

    SetText(default)
end

local function onSessionMoneyChanged(_, sessionMoney)
    if not frame then return end

    SetText(sessionMoney)
end

ns.bus:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
ns.bus:RegisterEvent(name .. "_PLAYER_MONEY_CACHED", onSessionMoneyChanged)

local function onSettingChanged(_, key)
    if not frame then return end

    if key == "xy" then
        frame:SetFramePosition()
    elseif key == "width" or key == "dynamicWidth" or key == "fontSize" or key == "fontAlignment" then
        frame:SetFrameSize()
    elseif key == "fade" or key == "fadeInOpacity" or key == "fadeOutOpacity" then
        frame:SetFrameAlpha()
    elseif key == "backdrop" then
        frame:SetBackdropAlpha()
    end
end

ns.bus:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingChanged)
