local name, ns = ...

local function onPlayerMoney()
    local money = GetMoney()
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

ns:RegisterEvent("PLAYER_MONEY", onPlayerMoney)