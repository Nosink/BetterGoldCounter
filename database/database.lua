local name, ns = ...
local LibEvent = LibStub("LibEventBus-1.0")

ns.database = ns.database or {}
ns.databasePC = ns.databasePC or {}

local function loadDatabase()
    _G[name .. "DB"] = setmetatable(_G[name .. "DB"] or {}, {
        __index = ns.defaults,
    })
    ns.database = _G[name .. "DB"]
end

local function loadDatabasePerCharacter()
    _G[name .. "PCDB"] = setmetatable(_G[name .. "PCDB"] or {}, {
        __index = ns.defaultsPC,
    })
    ns.databasePC = _G[name .. "PCDB"]
end

local function onVariablesLoaded()
    loadDatabase()
    loadDatabasePerCharacter()

    LibEvent:TriggerEvent(name .. "_VARIABLES_LOADED")
end

LibEvent:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)