local name, ns = ...

local function onPlayerEnteringWorld(_, isInitialLogin)
    ns.bus:TriggerEvent(name .. "_PLAYER_ENTERING_WORLD", isInitialLogin)
end

ns.bus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
