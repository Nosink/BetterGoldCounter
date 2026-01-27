local name, ns = ...

local storedSession = 0
local dateTime = tostring(date("%Y-%m-%d"))

local function onVariablesLoaded(_)
    ns.database.records[ns.unitName] = ns.database.records[ns.unitName] or {}
    storedSession = ns.database.records[ns.unitName][dateTime] or 0
end

local function GetMoneyDelayed(delay)
    C_Timer.After(delay, function()
        ns.money = GetMoney()
    end)
end

local function onAddonLoaded(_)
    ns.unitName = UnitName("player")
    GetMoneyDelayed(1.0)
    ns.session = 0
end

local function onReloadingUI(_)
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

local function onPlayerLogout(_)
    storedSession = storedSession + ns.session
    ns.database.records[ns.unitName][dateTime] = storedSession
end

local function onPlayerLeavingWorld(_)
    ns.database.session = ns.session
end

local function onClearSessionRequested(_)
    onPlayerLogout(_)
    onAddonLoaded(_)
    ns:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

ns:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
ns:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
ns:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
ns:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)
ns:RegisterEvent(name .. "_PLAYER_LOGOUT", onPlayerLogout)
ns:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
ns:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)