local name, ns = ...

ns.settings = ns.settings or {}

local defaultBackdropAlpha = 0.85
local defaultBackdropBorderAlpha = 1.0
local defaultFontSize = 8
local defaultWidth = 50
local defaultFadeDuration = 0.01

-- General Frame
function ns.settings.IsFrameLocked()
    return ns.database.locked
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
    ns:TriggerEvent(name .. "_SETTINGS_CHANGED", "xy")
end

-- Backdrop
function ns.settings.IsBackdropEnabled()
    return ns.database.backdrop
end

function ns.settings.GetBackdropAlphas()
    local backdropAlpha = ns.database.backdrop and defaultBackdropAlpha or 0.0
    local backdropBorderalpha = ns.database.backdrop and defaultBackdropBorderAlpha or 0.0
    return backdropAlpha, backdropBorderalpha
end

-- Font Size
function ns.settings.GetFontSize()
    local fontSize = tonumber(ns.database.fontSize) or defaultFontSize
    if not fontSize or fontSize < defaultFontSize then fontSize = defaultFontSize end
    return fontSize
end

-- Width
function ns.settings.GetWidth()
    local width = tonumber(ns.database.width) or defaultWidth
    if not width or width < defaultWidth then width = defaultWidth end
    return width
end

function ns.settings.IsDynamicWidth()
    return ns.database.dynamicWidth
end

-- Fade
function ns.settings.IsFadeEnabled()
    return ns.database.fade
end

function ns.settings.IsFadeDisabled()
    return not ns.database.fade
end

function ns.settings.GetFadeOpacity()
    local db = ns.database
    return db.fade and db.fadeOutOpacity or not db.fade and db.fadeInOpacity or 0
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