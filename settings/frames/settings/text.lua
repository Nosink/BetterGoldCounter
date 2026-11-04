local _, ns = ...

local settings = {}
settings.__index = settings

function settings:NewSettings(settings)
    settings = settings or {}

    return setmetatable({
        fontString = settings.fontString,
        offset = settings.offset,
        textPoint = settings.point,
        textColor = settings.color,
        size = settings.size,
        justify = settings.justify,

        setFontString = function(self, name, layer, template)
            self.fontString = ns.builder.fontString(name, layer, template)
        end,

        setOffset = function(self, x, y)
            self.offset = ns.builder.offset(x, y)
        end,

        setTextPoint = function(self, point, relativeTo, relativePoint, x, y)
            self.textPoint = ns.builder.point(point, relativeTo, relativePoint, x, y)
        end,

        setColor = function(self, r, g, b, a)
            self.textColor = ns.builder.color(r, g, b, a)
        end,

        setSize = function(self, size)
            self.size = size
        end,

        setJustify = function(self, horizontal, vertical)
            self.justify = { h = horizontal, v = vertical }
        end,
    }, self)
end

ns.builder.settings = ns.builder.settings or {}
ns.builder.settings.text = settings
