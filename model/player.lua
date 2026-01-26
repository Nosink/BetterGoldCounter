local name, ns = ...

local database = ns.database

local function onAddonLoaded()
    ns.unitName = UnitName("player")
    ns.money = GetMoney()
end

local function onInitialLogin()
    ns.session = 0
    database.session = nil
end

local function onReloadingUI()
    ns.session = database.session or 0
    database.session = nil
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = newAmount

    ns:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerLeavingWorld()
    database.session = ns.session
end

ns:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
ns:RegisterEvent(name .. "_IS_INITIAL_LOGIN", onInitialLogin)
ns:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
ns:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)
ns:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)