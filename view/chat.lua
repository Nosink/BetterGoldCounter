local name, ns = ...
local L = ns.L

local utils = ns.utils

local function onHistoryRequested()
    local total = 0
    local records = {}
    if ns.database and ns.unitName and ns.database.records and ns.database.records[ns.unitName] then
        records = ns.database.records[ns.unitName]
    end
    for key, value in pairs(records) do
        local amount = tonumber(value) or 0
        total = total + amount
        print(string.format("%s: %s %s", tostring(key or ""), utils.GetSignSymbol(abs(amount)), GetMoneyString(amount)))
    end
    local sign = utils.GetSignSymbol(total)
    print(string.format("%s: %s %s", L["LKEY_TOTAL_CHAT_HISTORY"], sign, GetMoneyString(total)))
end

ns:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)