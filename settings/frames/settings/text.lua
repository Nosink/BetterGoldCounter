local _, ns = ...

local builder = ns.builder

local settings = {}
settings.__index = settings

function settings:NewSettings(settings, anchor)
    settings = settings or {}

    local offset = settings.offset or builder.offset()
    local point = builder.point("TOPLEFT", anchor, "BOTTOMLEFT", offset.x, offset.y)

    return setmetatable({
        fontString = settings.fontString or builder.fontString(),
        offset = offset,
        point = settings.point or point,
        color = settings.color or builder.color(),
        size = settings.size or 12,
        width = settings.width or nil,
        flags = settings.flags or "",
        justify = settings.justify or builder.justify()
    }, self)
end

ns.builder.settings = ns.builder.settings or {}
ns.builder.settings.text = settings
