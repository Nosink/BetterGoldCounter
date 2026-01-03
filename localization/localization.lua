local _, ns = ...

ns.locale = ns.locale or GetLocale()

local L = setmetatable({}, { __index = function(t, k)
    local v = tostring(k) rawset(t, k, v) return v
end })

ns.L = L