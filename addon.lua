local name, _ = ...

local LibEventBus = LibStub("LibEventBus-1.0")
BGCBus = LibEventBus:NewBus("BGCBus")

local function onPlayerEnteringWorld(_, isInitialLogin, _)
    if not isInitialLogin then return end
    BGCBus:TriggerEvent(name .. "_IS_INITIAL_LOGIN")
end

local function onPlayerLeavingWorld()
    BGCBus:TriggerEvent(name .. "_PLAYER_LEAVING_WORLD")
end

BGCBus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
BGCBus:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)