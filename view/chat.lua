local name, ns = ...

local L = ns.L
local utils = ns.utils
local database = ns.db or { }

local blueSeparator = function () print("|cff3399ff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|r") end

local function onHistoryRequested()
    local total = 0
    local records = {}
    if database and ns.unitName and database.records and database.records[ns.unitName] then
        records = database.records[ns.unitName]
    end
    blueSeparator()
    print("|cff3399ff█ " .. name  .. "|r ~ |cffffeb3b" .. L["LKEY_CHAT_G_HISTORY"] .. "|r " .. L["LKEY_CHAT_HISTORY"])
    blueSeparator()
    for key, value in pairs(records) do
        local amount = tonumber(value) or 0
        total = total + amount
        if amount > 0 then
            print(string.format("%s: |cff99FF99%s %s|r", tostring(key or ""), utils.GetSignSymbol(amount), GetMoneyString(abs(amount))))
        elseif amount < 0 then
            print(string.format("%s: |cffFF9999%s %s|r", tostring(key or ""), utils.GetSignSymbol(amount), GetMoneyString(abs(amount))))
        else
            print(string.format("%s: %s %s", tostring(key or ""), utils.GetSignSymbol(amount), GetMoneyString(abs(amount))))
        end
    end
    blueSeparator()
    local sign = utils.GetSignSymbol(total)
    if total > 0 then
        print(string.format("%s: |cff99FF99%s %s|r", L["LKEY_TOTAL_CHAT_HISTORY"], sign, GetMoneyString(abs(total))))
    elseif total < 0 then
        print(string.format("%s: |cffFF9999%s %s|r", L["LKEY_TOTAL_CHAT_HISTORY"], sign, GetMoneyString(abs(total))))
    else
        print(string.format("%s: %s %s", L["LKEY_TOTAL_CHAT_HISTORY"], sign, GetMoneyString(abs(total))))
    end
    blueSeparator()
end

BGCBus:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)