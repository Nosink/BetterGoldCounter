local name, ns = ...
local bus = LibStub("LibEventBus-1.0")

local settings = ns.settings

local loginDate = tostring(date("%Y-%m-%d"))

local function onAddonLoaded(_)
    ns.unitName = UnitName("player")
end

local function updateMoney()
    ns.money = GetMoney()
end

local function getStoredSession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "DAILY" then
        if ns.database.lastLogin ~= loginDate then
            ns.database.dailySession = 0
        end
        return ns.database.dailySession
    end
    if frequency == "NEVER" then
        return ns.database.allTimeSession
    end
    return 0
end

local function onVariablesLoaded(_)
    updateMoney()
    ns.session = getStoredSession()
    ns.database.lastLogin = loginDate

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = newAmount

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerLeavingWorld(_)
    ns.database.session = ns.session
end

local function onReloadingUI(_)
    ns.session = ns.database.session
    ns.database.session = nil

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function storeDailySession(dateTime)
    local dailySession = ns.database.dailySession + ns.session
    ns.database.records = ns.database.records or { }
    ns.database.records[ns.unitName] = ns.database.records[ns.unitName] or { }
    ns.database.records[ns.unitName][dateTime] = dailySession
end

local function onPlayerLogout(_)

    local now = tostring(date("%Y-%m-%d"))

    ns.database.dailySession = ns.database.dailySession + ns.session
    ns.database.allTimeSession = ns.database.allTimeSession + ns.session

    storeDailySession(now)
end

local function updateLoginDate()
    loginDate = tostring(date("%Y-%m-%d"))
end

local function onDailyReset(_)

    storeDailySession(loginDate)
    updateLoginDate();

    local frequency = settings.GetCleanFrequency()
    if frequency == "DAILY" then
        print(name .. ": " .. "La sesión diaria ha sido reiniciada." .. "Hoy se genero un total de " .. ns.database.dailySession + ns.session .. " de oro.")
        ns.session = 0
    end

    ns.database.dailySession = 0

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onClearSessionRequested(_)
    onPlayerLogout(_)
    onVariablesLoaded(_)
    ns.session = 0
    local frequency = settings.GetCleanFrequency()
    if frequency == "NEVER" then
        ns.database.allTimeSession = 0
    end
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onWipeRequested(_)
    ns.database.dailySession = 0
    ns.database.allTimeSession = 0
    ns.database.records = ns.database.records or { }
    ns.database.records[ns.unitName] = { }
    ns.session = 0
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

bus:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
bus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)

bus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)

bus:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
bus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)

bus:RegisterEvent(name .. "_PLAYER_LOGOUT", onPlayerLogout)

bus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
bus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)

bus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)