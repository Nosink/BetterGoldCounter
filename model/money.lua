local name, ns = ...

local function onPlayerMoney()
    local current = GetMoney()
    ns.session = ns.session + (current - ns.current)
    ns.current = current
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
end

local function onResetSessionRequested()
    local sessionAmount = ns.session
    ns.session = 0
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
    ns:TriggerEvent(name .. "_SESSION_RESET", sessionAmount)
end

ns:RegisterEvent("PLAYER_MONEY", onPlayerMoney)
ns:RegisterEvent(name .. "_PLAYER_MONEY_READY", onPlayerMoney)

ns:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onResetSessionRequested)
