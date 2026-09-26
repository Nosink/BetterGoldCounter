local _, ns = ...

ns.locale = GetLocale()

ns.L = setmetatable({}, {
    __index = function(table, key)
        local value = tostring(key)
        rawset(table, key, value)
        return value
    end,
})
