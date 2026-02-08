local name, ns = ...

ns.settings = ns.settings or {}

local defaultBackdropAlpha = 0.85
local defaultFontSize = 8
local defaultWidth = 50
local defaultFadeDuration = 0.01

function ns.settings.GetFontPoint()
    local offset = 0
    local alignment = ns.database.fontAlignment
    if alignment == "LEFT" or alignment == "RIGHT" or alignment == "CENTER" then
        if alignment == "LEFT" then
            offset = ns.settings.GetFontSize() * 0.6
        elseif alignment == "RIGHT" then
            offset = -ns.settings.GetFontSize() * 1.5
        elseif alignment == "CENTER" then
            offset = 0
        end
    end
    return alignment, offset
end

function ns.settings.IsFrameUnlocked()
    return not ns.database.locked
end

function ns.settings.GetPosition()
    if not ns.database.x or not ns.database.y then
        local width, height = UIParent:GetSize()
        return math.floor(width / 2), math.floor(height / 2)
    end
    return tonumber(ns.database.x), tonumber(ns.database.y)
end

function ns.settings.SetPosition(x, y)
    ns.database.x, ns.database.y = x, y
     BGCBus:TriggerEvent(name .. "_SETTINGS_CHANGED", "xy")
end

function ns.settings.GetBackdropAlpha()
    return ns.database.backdrop and defaultBackdropAlpha or 0.0
end

function ns.settings.GetFontSize()
    local fontSize = tonumber(ns.database.fontSize) or defaultFontSize
    if not fontSize or fontSize < defaultFontSize then fontSize = defaultFontSize end
    return fontSize
end

function ns.settings.GetWidth()
    local width = tonumber(ns.database.width) or defaultWidth
    if not width or width < defaultWidth then width = defaultWidth end
    return width
end

function ns.settings.IsDynamicWidth()
    return ns.database.dynamicWidth
end

function ns.settings.IsFadeEnabled()
    return ns.database.fade
end

function ns.settings.GetFadeOpacity()
    local db = ns.database
    return db.fade and db.fadeOutOpacity or not db.fade and db.fadeInOpacity
end

function ns.settings.GetFadeOutOpacity()
    return ns.database.fadeOutOpacity
end

function ns.settings.GetFadeInOpacity()
    return ns.database.fadeInOpacity
end

function ns.settings.GetFadeDuration()
    local fadeDuration = tonumber(ns.database.fadeDuration) or defaultFadeDuration
    if not fadeDuration or fadeDuration < defaultFadeDuration then fadeDuration = defaultFadeDuration end
    return fadeDuration
end

function ns.settings.GetCleanFrequency()
    return ns.database.cleanFrequency
end

function ns.settings.IsAutoCleanEnabled()
    return ns.database.autoClean
end