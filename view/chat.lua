local name, ns = ...

local L = ns.L
local utils = ns.utils

local blueSeparator = function() print("|cff3399ff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|r") end

local function printTitle()
    local blueBlock = utils.ColoredText("ff3399ff", "█")
    local goldTilde = utils.ColoredText("ffffeb3b", "~")
    local blueName = utils.ColoredText("ff3399ff", name)
    local goldWord = utils.ColoredText("ffffeb3b", L["LKEY_CHAT_G_HISTORY"])
    local historyWord = utils.ColoredText("FFC7C7C7", L["LKEY_CHAT_HISTORY"])

    blueSeparator()
    print(string.format("%s %s %s %s %s %s", blueBlock, blueName, goldTilde, goldWord, historyWord, goldTilde))
end

local function getColor(amount)
    if amount > 0 then
        return "ff99FF99"
    elseif amount < 0 then
        return "ffFF9999"
    else
        return "ffffffff"
    end
end

local function getColoredMoneyString(amount)
    local color = getColor(amount)
    local sign = utils.GetSignSymbol(amount)
    local moneyString = string.format("%s %s", sign, GetMoneyString(abs(amount)))
    return utils.ColoredText(color, moneyString)
end

local function printEntry(key, amount)
    local date = tostring(key or "")
    local coloredMoneyString = getColoredMoneyString(amount)

    print(string.format("%s: %s", date, coloredMoneyString))
end

local function getRecords()
    local unitName = utils.GetUnitName()
    return ns.db.records[unitName] or {}
end

local function printRecords()
    local records = getRecords()
    blueSeparator()
    for key, value in pairs(records) do
        local amount = tonumber(value) or 0
        printEntry(key, amount)
    end
end

local function getTotal()
    local total = 0
    local records = getRecords()
    for _, value in pairs(records) do
        local amount = tonumber(value) or 0
        total = total + amount
    end
    return total
end

local function printTotal()
    local total = getTotal()
    local totalString = L["LKEY_TOTAL_CHAT_HISTORY"]
    local coloredTotal = getColoredMoneyString(total)

    blueSeparator()
    print(string.format("%s: %s", totalString, coloredTotal))
    blueSeparator()
end

local function onHistoryRequested()
    printTitle()
    printRecords()
    printTotal()
end

BGCBus:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)
