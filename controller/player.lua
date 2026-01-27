local name, ns = ...
local LibEvent = LibStub("LibEvent")

local function onPlayerMoney()
    local money = GetMoney()
    LibEvent:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

LibEvent:RegisterEvent("PLAYER_MONEY", onPlayerMoney)