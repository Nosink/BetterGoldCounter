local name, ns = ...

local function onPlayerMoney()
    local entry = {
        money = GetMoney(),
        date = C_DateAndTime.GetCurrentCalendarTime(),
    }

    ns.bus:TriggerEvent(name .. "_PLAYER_MONEY", entry)
end

ns.bus:RegisterEvent("PLAYER_MONEY", onPlayerMoney)
