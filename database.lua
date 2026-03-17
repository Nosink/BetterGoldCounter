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

local db, dbPc = {}, {}

local function loadSavedVariableTables()
    _G[name .. "DB"] = _G[name .. "DB"] or {}
    _G[name .. "PCDB"] = _G[name .. "PCDB"] or {}

    db = _G[name .. "DB"]
    dbPc = _G[name .. "PCDB"]
end

local function createCombinedDatabase()
    local proxy = {}

    setmetatable(proxy, {
        __index = function(_, key)
            local rawPcDb = rawget(dbPc, key)
            if rawPcDb ~= nil then return rawPcDb end

            local rawDb = rawget(db, key)
            if rawDb ~= nil then return rawDb end

            local rawDefault = defaultsPC[key]
            if rawDefault ~= nil then return rawDefault end

            return defaults[key]
        end,
        __newindex = function(_, key, value)
            local inPcDb = rawget(dbPc, key) ~= nil or defaultsPC[key] ~= nil
            local notInDb = not (rawget(db, key) ~= nil or defaults[key] ~= nil)

            if inPcDb or notInDb then
                dbPc[key] = value
            else
                db[key] = value
            end
        end,
        __pairs = function()
            local seen = {}
            local pc_key = nil
            local db_key = nil
            local pc_done = false

            return function()
                local value

                if not pc_done then
                    pc_key, value = next(dbPc, pc_key)
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
