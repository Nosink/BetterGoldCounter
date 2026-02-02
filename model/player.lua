local name, ns = ...
local bus = LibStub("LibEventBus-1.0")

local settings = ns.settings

local dateTime = tostring(date("%Y-%m-%d"))

local function getStoredDailySession()
    ns.database.records = ns.database.records or {}
    ns.database.records[ns.unitName] = ns.database.records[ns.unitName] or {}
    return ns.database.records[ns.unitName][dateTime] or 0
end

local function getAllDailySessions()
    ns.database.records = ns.database.records or {}
    ns.database.records[ns.unitName] = ns.database.records[ns.unitName] or {}
    local total = 0
    for _, amount in pairs(ns.database.records[ns.unitName]) do
        total = total + amount
    end
    return total
end

local function setSession(amount)
    ns.session = amount
end

local function setDailySession(amount)
    ns.dailySession = amount
end

local function onVariablesLoaded(_)

    local frequency = settings.GetCleanFrequency()

    if frequency == "DAILY" then
        setSession(getStoredDailySession())
    elseif frequency == "SESSION" then
        setSession(0)
    elseif frequency == "NEVER" then
        setSession(getAllDailySessions())
    end

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function updateMoney()
    ns.money = GetMoney()
end

local function GetMoneyDelayed()
    C_Timer.After(1.0, function()
        updateMoney()
    end)
end

local function onAddonLoaded(_)
    ns.unitName = UnitName("player")
    GetMoneyDelayed()
end

local function onReloadingUI(_)
    ns.session = ns.database.session
    ns.database.session = nil

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = newAmount
    
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function updateDailySession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "DAILY" then
        setDailySession(ns.session)
    elseif frequency == "SESSION" then
        setDailySession(ns.dailySession + ns.session)
    elseif frequency == "NEVER" then
        local dailySession = getStoredDailySession()
        setDailySession(ns.session - dailySession)
    end
end

local function storeDailySession()
    ns.database.records[ns.unitName][dateTime] = ns.dailySession
end

local function onPlayerLogout(_)
    updateDailySession()
    storeDailySession()
end

local function onPlayerLeavingWorld(_)
    ns.database.session = ns.session
end

local function onClearSessionRequested(_)
    updateDailySession()
    storeDailySession()

    updateMoney()
    setSession(0)
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onDailyReset(_)
    updateDailySession()
    storeDailySession()
    
    updateMoney()
    setDailySession(0)
    setSession(ns.dailySession)
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

bus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
bus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)
bus:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
bus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
bus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)
bus:RegisterEvent(name .. "_PLAYER_LOGOUT", onPlayerLogout)
bus:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
bus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)