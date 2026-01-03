local name, ns = ...

local utils = ns.utils

local function onHistoryRequested()
    local total = 0
    local records = ns.database[ns.unit].records or {}
    for _, value in pairs(records) do
        total = total + value[2]
        print(string.format("%s: %s %s", tostring(value[1]), tostring(value[3]), GetMoneyString(value[2])))
    end
    local sign = utils.GetSignSymbol(total)
    print(string.format("Total: %s %s", sign, GetMoneyString(total)))
end

ns:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)