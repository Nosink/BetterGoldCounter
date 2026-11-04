local _, ns = ...

local builder = ns.builder

local settings = {}
settings.__index = settings

function settings:NewSettings(settings, anchor)
    settings = settings or {}

    local textSettings = settings.textSettings or
        ns.builder.settings.text:NewSettings({
            offset = { x = 0, y = -10 }
        }, anchor)

    return setmetatable({
        textSettings = settings.textSettings or textSettings,
        offset = settings.offset or builder.offset(10),
        validator = settings.validator or builder.noValidator(),
        allowDecimals = settings.allowDecimals or false,
        isNumeric = settings.isNumeric or false,
        width = settings.width or 45,
        height = settings.height or 22,
        point = settings.point or nil,
        justify = settings.justify or builder.justify("CENTER"),

        SetLabel = function(self, label)
            self.point = builder.point("LEFT", label, "RIGHT", self.offset.x, self.offset.y)
        end
    }, self)
end

ns.builder.settings = ns.builder.settings or {}
ns.builder.settings.editBox = settings
