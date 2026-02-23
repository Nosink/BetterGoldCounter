local name, ns = ...

ns.db = ns.db or {}

local next = next
local rawget = rawget
local setmetatable = setmetatable

local defaults = {
    x = GetScreenWidth() / 2,
    y = GetScreenHeight() / 2,

    locked = false,
    backdrop = true,

    fontSize = 12,
    fontAlignment = "RIGHT", -- "LEFT", "CENTER", "RIGHT"
    dynamicWidth = false,
    width = 150,

    fade = true,
    fadeOutOpacity = 0.5,
    fadeInOpacity = 1.0,
    fadeDuration = 0.1,
}

local defaultsPC = {
    lastLogin = "",
    cleanFrequency = "SESSION", -- "SESSION", "DAILY", "NEVER"

    temporal = { },
    records = { },

    dailySession = 0,
    allTimeRecord = 0,
}

local db, dbpc = { }, { }

local function loadSavedVariableTables()
    _G[name.."DB"] = _G[name.."DB"] or {}
    _G[name.."PCDB"] = _G[name.."PCDB"] or {}

    db = _G[name.."DB"]
    dbpc = _G[name.."PCDB"]
end

local function applyDefaultValues()
    setmetatable(db, { __index = defaults })
    setmetatable(dbpc, { __index = defaultsPC })
end

local function createCombinedDatabase()
    setmetatable(ns.db, {
        __index = function(_, key)
            local value = dbpc[key]
            if value ~= nil then
                return value
            end

            return db[key]
        end,
        __newindex = function(_, key, value)
            if rawget(dbpc, key) ~= nil or defaultsPC[key] ~= nil then
                dbpc[key] = value
                return
            end

            if rawget(db, key) ~= nil or defaults[key] ~= nil then
                db[key] = value
                return
            end

            dbpc[key] = value
        end,
        __pairs = function()
            local seen = {}
            local globalKey, perCharacterKey

            return function()
                local value

                perCharacterKey, value = next(dbpc, perCharacterKey)
                if perCharacterKey ~= nil then
                    seen[perCharacterKey] = true
                    return perCharacterKey, value
                end

                repeat
                    globalKey, value = next(db, globalKey)
                until globalKey == nil or not seen[globalKey]

                if globalKey ~= nil then
                    return globalKey, value
                end
            end
        end,
    })
end

local function onVariablesLoaded()

    loadSavedVariableTables()
    applyDefaultValues()

    createCombinedDatabase()

    BGCBus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

BGCBus:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)