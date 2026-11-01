local name, ns = ...

local function onPlayerMoney()
    local money = GetMoney()
    local now = GetServerTime()
    print(string.format("Player money: %d, time: %s", money, date("%Y-%m-%d %H:%M:%S", now)))

    ns.bus:TriggerEvent(name .. "_PLAYER_MONEY", money)
end

ns.bus:RegisterEvent("PLAYER_MONEY", onPlayerMoney)
