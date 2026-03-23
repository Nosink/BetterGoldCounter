local name, _ = ...

local LibEventBus = LibStub("LibEventBus-1.0")
BGCBus = LibEventBus:NewBus("BGCBus")

local function onPlayerEnteringWorld(_, isInitialLogin, _)
    if isInitialLogin then
        BGCBus:TriggerEvent(name .. "_IS_INITIAL_LOGIN")
    else
        BGCBus:TriggerEvent(name .. "_IS_RELOADING_UI")
    end
end

BGCBus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
