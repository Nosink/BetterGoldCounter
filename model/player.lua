local name, ns = ...
local bus = LibStub("LibEventBus-1.0")

local L = ns.L

local settings = ns.settings

local loginDate = tostring(date("%Y-%m-%d"))

local function onAddonLoaded(_)
    ns.unitName = UnitName("player")
end

local function updateSession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "SESSION" then
        ns.session = ns.database.session or 0
    elseif frequency == "DAILY" then
        ns.session = ns.database.dailySession or 0
    elseif frequency == "NEVER" then
        ns.session = ns.database.allTimeSession or 0
    else
        ns.session = 0
    end
end

local function updateMoney()
    ns.money = GetMoney()
end

local function onVariablesLoaded(_)
    updateMoney()
    updateSession()

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = newAmount
    ns.database.allTimeSession = ns.database.allTimeSession + session

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

local function storeDailyRecord(dateKey, amount)
    ns.database.records = ns.database.records or { }
    ns.database.records[ns.unitName] = ns.database.records[ns.unitName] or { }
    ns.database.records[ns.unitName][dateKey] = amount
end

local function storeRecords()
    ns.database.dailySession = ns.database.dailySession + ns.session
    ns.database.allTimeSession = ns.database.allTimeSession + ns.session
    storeDailyRecord(loginDate, ns.database.dailySession)
end

local function onClearSessionRequested(_)
    local dateKey = tostring(date("%Y-%m-%d"))
    storeDailyRecord(dateKey, ns.database.dailySession + ns.session)
    updateMoney()
    ns.session = 0
    ns.database.dailySession = 0
    ns.database.allTimeSession = 0

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onWipeRequested(_)
    ns.session = 0
    ns.database.dailySession = 0
    ns.database.allTimeSession = 0
    ns.database.records = ns.database.records or { }
    ns.database.records[ns.unitName] = { }
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function wipeDailySession()
    local frequency = settings.GetCleanFrequency()
    if frequency ~= "DAILY" then return end
    print(L["LKEY_CLEARING_DAILY_SESSION"] .. ns.database.dailySession .. L["LKEY_CLEARED"])
    ns.session = 0
    ns.database.dailySession = 0
end

local function updateLoginDate()
    loginDate = tostring(date("%Y-%m-%d"))
end

local function onDailyReset(_)
    print(loginDate)
    storeRecords()
    wipeDailySession()
    updateLoginDate()
    print(loginDate)

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

bus:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
bus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)

bus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)

bus:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
bus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)

bus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
bus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)

bus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)