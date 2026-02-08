local name, _ = ...

local function onPlayerMoney()
    local money = GetMoney()
    BGCBus:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

BGCBus:RegisterEvent("PLAYER_MONEY", onPlayerMoney)