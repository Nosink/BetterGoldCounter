local name, ns = ...

ns.db = ns.db or {}

local next = next
local rawget = rawget
local setmetatable = setmetatable

local defaults = {
    -- Position
    x = GetScreenWidth() / 2,
    y = GetScreenHeight() / 2,

    -- Backdrop
    locked = false,
    backdrop = true,

    -- Font
    fontSize = 12,
    fontAlignment = "RIGHT", -- "LEFT", "CENTER", "RIGHT"

    -- Width
    dynamicWidth = false,
    width = 150,

    -- Fade
    fade = true,
    fadeOutOpacity = 0.5,
    fadeInOpacity = 1.0,
    fadeDuration = 0.1,
}

local defaultsPC = {
    -- Data consistency
    lastLogin = "",
    cleanFrequency = "SESSION", -- "SESSION", "DAILY", "NEVER"

    -- Stored data
    records = { },

    -- Session tracking
    session = 0,
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

local function combinedPairs()
    local seen = { }
    local dbpcKey, dbKey
    local dbpcDone = false

    local function iter()
        local value

        if not dbpcDone then
            dbpcKey, value = next(dbpc, dbpcKey)
            if dbpcKey ~= nil then
                seen[dbpcKey] = true
                return dbpcKey, value
            end
            dbpcDone = true
        end

        repeat
            dbKey, value = next(db, dbKey)
        until dbKey == nil or not seen[dbKey]

        if dbKey ~= nil then
            return dbKey, value
        end
    end

    return iter, nil, nil
end

local function createCombinedDatabase()
    local database = {}
    setmetatable(database, {
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
        __pairs = combinedPairs,
    })

    ns.db = database
end

local function onVariablesLoaded()

    loadSavedVariableTables()
    applyDefaultValues()

    createCombinedDatabase()

    BGCBus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

BGCBus:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)