local name, ns = ...

local utils = ns.utils

local function updateGoldCounterFrame()
    local sign = utils.GetSignSymbol(ns.session)
    local moneyString = GetMoneyString(math.abs(ns.session))
    local text = string.format("%s %s", sign, moneyString)
    ns.frame:UpdateText(text)
end

ns:RegisterEvent(name .. "_PLAYER_MONEY_READY", updateGoldCounterFrame)
ns:RegisterEvent(name .. "_PLAYER_MONEY_CACHED", updateGoldCounterFrame)