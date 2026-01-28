local name, _ = ...
local bus = LibStub("LibEventBus-1.0")

local function onPlayerMoney()
    local money = GetMoney()
    bus:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

bus:RegisterEvent("PLAYER_MONEY", onPlayerMoney)