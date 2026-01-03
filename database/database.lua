local name, ns = ...

ns.database = ns.database or {}
ns.databasePC = ns.databasePC or {}

local function loadGlobalDatabase()
    _G[name.."DB"] = setmetatable(_G[name.."DB"] or {}, {
        __index = ns.defaults,
    })
    ns.database = _G[name.."DB"]
end

local function loadPercharacterDatabase()
    _G[name.."PCDB"] = setmetatable(_G[name.."PCDB"] or {}, {
        __index = ns.defaultsPC,
    })
    ns.databasePC = _G[name.."PCDB"]
end

local function onVariablesLoaded()
    loadGlobalDatabase()
    loadPercharacterDatabase()

    ns:TriggerEvent(name .. "_VARIABLES_LOADED")
end

ns:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)