local _, ns = ...

local type = type
local pairs = pairs
local error = error
local setmetatable = setmetatable

ns.enums = ns.enums or {}

function ns.Enum(values)
    if type(values) ~= "table" then
        error("Enum values must be a table", 2)
    end

    local enum = {}
    for key, value in pairs(values) do
        if type(key) ~= "string" then
            error("Enum keys must be strings", 2)
        end
        if value == nil then
            error("Enum values cannot be nil", 2)
        end
        enum[key] = value
    end

    return setmetatable(enum, {
        __newindex = function(_, key)
            error("Cannot add key to read-only enum: " .. tostring(key), 2)
        end,
    })
end

function ns.RegisterEnum(name, values)
    if type(name) ~= "string" or name == "" then
        error("Enum name must be a non-empty string", 2)
    end

    if type(values) ~= "table" then
        error("Enum values must be a table", 2)
    end

    if ns.enums[name] then
        error("Enum already registered: " .. name, 2)
    end

    ns.enums[name] = ns.Enum(values)
end
