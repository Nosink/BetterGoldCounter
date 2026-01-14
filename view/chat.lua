local name, ns = ...
local L = ns.L

local utils = ns.utils

local function onHistoryRequested()
    local total = 0
    local records = {}
    if ns.database and ns.unit and ns.database[ns.unit] and ns.database[ns.unit].records then
        records = ns.database[ns.unit].records
    end
    for _, value in pairs(records) do
        local amount = tonumber(value[2]) or 0
        total = total + amount
        print(string.format("%s: %s %s", tostring(value[1] or ""), tostring(value[3] or utils.GetSignSymbol(amount)), GetMoneyString(amount)))
    end
    local sign = utils.GetSignSymbol(total)
    print(string.format("%s: %s %s", L["LKEY_TOTAL_CHAT_HISTORY"], sign, GetMoneyString(total)))
end

ns:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)