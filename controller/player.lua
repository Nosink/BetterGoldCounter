local name, ns = ...
local LibEvent = LibStub("LibEventBus-1.0")

local function onPlayerMoney()
    local money = GetMoney()
    LibEvent:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

LibEvent:RegisterEvent("PLAYER_MONEY", onPlayerMoney)