local name, ns = ...

local function onPlayerMoney()
    local money = GetMoney()

    ns.bus:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

ns.bus:RegisterEvent("PLAYER_MONEY", onPlayerMoney)
