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

    -- Stored data (false sentinel: avoids mutable table aliasing through defaults)
    records = false,

    -- Session tracking
    session = 0,
    dailySession = 0,
    allTimeSession = 0,
}

local db, dbpc = { }, { }

local function loadSavedVariableTables()
    _G[name.."DB"] = _G[name.."DB"] or {}
    _G[name.."PCDB"] = _G[name.."PCDB"] or {}

    db = _G[name.."DB"]
    dbpc = _G[name.."PCDB"]
end

local function createCombinedDatabase()
    local proxy = {}
    setmetatable(proxy, {
        __index = function(_, key)
            -- Check per-character table first
            local value = rawget(dbpc, key)
            if value ~= nil then
                return value
            end
            
            -- Check account table
            value = rawget(db, key)
            if value ~= nil then
                return value
            end
            
            -- Apply per-character default if available
            if defaultsPC[key] ~= nil then
                return defaultsPC[key]
            end
            
            -- Apply account default if available
            return defaults[key]
        end,
        __newindex = function(_, key, value)
            -- Check if per-character table owns this key (stored or in defaults)
            if rawget(dbpc, key) ~= nil or defaultsPC[key] ~= nil then
                dbpc[key] = value
            -- Check if account table owns this key (stored or in defaults)
            elseif rawget(db, key) ~= nil or defaults[key] ~= nil then
                db[key] = value
            -- Default to per-character for new keys
            else
                dbpc[key] = value
            end
        end,
        -- NOTE: __pairs is a Lua 5.2+ metamethod.
        -- In Lua 5.1, pairs(ns.db) iterates the empty proxy and yields nothing.
        -- Use ns.debug.pairs(ns.db) or getmetatable(ns.db).__pairs() instead.
        __pairs = function()
            local seen = {}
            local pc_key = nil
            local db_key = nil
            local pc_done = false

            return function()
                local value

                if not pc_done then
                    pc_key, value = next(dbpc, pc_key)
                    if pc_key ~= nil then
                        seen[pc_key] = true
                        return pc_key, value
                    end
                    pc_done = true
                end

                repeat
                    db_key, value = next(db, db_key)
                until db_key == nil or not seen[db_key]

                if db_key ~= nil then
                    return db_key, value
                end
            end, nil, nil
        end,
    })

    ns.db = proxy
end

local function onVariablesLoaded()

    loadSavedVariableTables()
    createCombinedDatabase()

    BGCBus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

BGCBus:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)