local name, ns = ...

local function onPlayerMoney()
    local money = GetMoney()
    ns.session = ns.session + (money - ns.current)
    ns.current = money
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
end

local function onResetSessionRequested()
    ns:TriggerEvent(name .. "_SESSION_RESET", ns.session)
    ns.session = 0
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
end

ns:RegisterEvent("PLAYER_MONEY", onPlayerMoney)

ns:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onResetSessionRequested)
