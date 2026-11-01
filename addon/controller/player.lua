local name, ns = ...

local function onPlayerMoney()
    local record = {
        money = GetMoney(),
        timestamp = C_DateAndTime.GetServerTimeLocal(),
    }

    ns.bus:TriggerEvent(name .. "_PLAYER_MONEY", record)
end

ns.bus:RegisterEvent("PLAYER_MONEY", onPlayerMoney)
