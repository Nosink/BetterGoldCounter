local name, ns = ...

local L = ns.L
local utils = ns.utils

local blueSeparator = function() print("|cff3399ff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|r") end

local function getColor(amount)
    if amount > 0 then
        return "|cff99FF99"
    elseif amount < 0 then
        return "|cffFF9999"
    else
        return ""
    end
end

local function onHistoryRequested()
    local total = 0
    local records = {}
    if ns.db and ns.unitName and ns.db.records and ns.db.records[ns.unitName] then
        records = ns.db.records[ns.unitName]
    end
    blueSeparator()
    print("|cff3399ff█ " .. name .. "|r ~ |cffffeb3b" .. L["LKEY_CHAT_G_HISTORY"] .. "|r " .. L["LKEY_CHAT_HISTORY"])
    blueSeparator()

    for key, value in pairs(records) do
        local amount = tonumber(value) or 0
        total = total + amount
        print(string.format("%s: %s%s %s|r", tostring(key or ""), getColor(amount), utils.GetSignSymbol(amount),
            GetMoneyString(abs(amount))))
    end

    blueSeparator()
    local sign = utils.GetSignSymbol(total)
    print(string.format("%s: %s%s %s|r", L["LKEY_TOTAL_CHAT_HISTORY"], getColor(total), sign, GetMoneyString(abs(total))))
    blueSeparator()
end

BGCBus:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)
