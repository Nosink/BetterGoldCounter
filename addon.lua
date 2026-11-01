local name, ns = ...

local function onLoad()
    ns.bus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

local function onVariablesLoaded(_)
    ns.database.Load(onLoad)
end

local function onPlayerEnteringWorld(_, isInitialLogin)
    ns.bus:TriggerEvent(name .. "_PLAYER_ENTERING_WORLD", isInitialLogin)
end

ns.bus:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)
ns.bus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
