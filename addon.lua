local name, ns = ...


local function onPlayerEnteringWorld(_, isInitialLogin, _)
    if isInitialLogin then
        ns.bus:TriggerEvent(name .. "_IS_INITIAL_LOGIN")
    else
        ns.bus:TriggerEvent(name .. "_IS_RELOADING_UI")
    end
end

ns.bus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
