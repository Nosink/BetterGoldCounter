local _, ns = ...

local builder = ns.builder

local settings = {}
settings.__index = settings

function settings:NewSettings(settings, anchor)
    settings = settings or {}

    local textSettings = settings.textSettings or
        ns.builder.settings.text:NewSettings({
            offset = { x = 0, y = -8 }
        }, anchor)

    return setmetatable({
        textSettings = settings.textSettings or textSettings,
        offset = settings.offset or builder.offset(6, -2),
        width = settings.width or 50,
        point = settings.point or nil,

        SetLabel = function(self, label)
            self.point = builder.point("LEFT", label, "RIGHT", self.offset.x, self.offset.y)
        end
    }, self)
end

ns.builder.settings = ns.builder.settings or {}
ns.builder.settings.dropDown = settings
