local _, ns = ...

local TextParams = {}
TextParams.__index = TextParams

function TextParams:new(params)
    params = params or {}

    return setmetatable({
        fontString = params.fontString,
        offset = params.offset,
        textPoint = params.textPoint,
        textColor = params.textColor,
        size = params.size,
        justify = params.justify,
    }, self)
end

ns.builder.TextParams = TextParams
