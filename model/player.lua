local name, ns = ...

local function GetMoneyDelayed(delay)
    C_Timer.After(delay, function()
        ns.money = GetMoney()
    end)
end

local function onAddonLoaded()
    ns.unitName = UnitName("player")
    GetMoneyDelayed(1.0)
    ns.session = 0
end

local function onReloadingUI()
    ns.session = ns.database.session
    ns.database.session = nil

    ns:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = newAmount

    ns:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerLeavingWorld()
    ns.database.session = ns.session
end

ns:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
ns:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
ns:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)
ns:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)