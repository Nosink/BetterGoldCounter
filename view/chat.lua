local name, ns = ...
local bus = LibStub("LibEventBus-1.0")
local L = ns.L

local utils = ns.utils

local function onHistoryRequested()
    local total = 0
    local records = {}
    if ns.database and ns.unitName and ns.database.records and ns.database.records[ns.unitName] then
        records = ns.database.records[ns.unitName]
    end
    print("------DAILY HISTORY------")
    for key, value in pairs(records) do
        local amount = tonumber(value) or 0
        total = total + amount
        print(string.format("%s: %s %s", tostring(key or ""), utils.GetSignSymbol(amount), GetMoneyString(abs(amount))))
    end
    local sign = utils.GetSignSymbol(total)
    print("------TOTAL HISTORY------")
    print(string.format("%s: %s %s", L["LKEY_TOTAL_CHAT_HISTORY"], sign, GetMoneyString(abs(total))))
    print("------ DEBUG ------")
    local session = ns.session or 0
    print ("session: " .. utils.GetSignSymbol(session) .. GetMoneyString(abs(session)))
    local dailySession = ns.database.dailySession or 0
    print ("dailySession: " .. utils.GetSignSymbol(dailySession) .. GetMoneyString(abs(dailySession)))
    local allTimeRecord = ns.database.allTimeRecord or 0
    print ("allTimeRecord: " .. utils.GetSignSymbol(allTimeRecord) .. GetMoneyString(abs(allTimeRecord)))
    print("------ xx ------")
end

bus:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)