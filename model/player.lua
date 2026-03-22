local name, ns = ...

local settings = ns.settings
local utils = ns.utils

local money = 0
local session = 0
local newLogin = false
local loginDate = tostring(date("%Y-%m-%d"))

local function clearDailySession()
    ns.db.dailySession = 0
end

local function setDailyRecord(dateKey)
    local unitName = utils.GetUnitName()

    ns.db.records = ns.db.records or {}
    ns.db.records[unitName] = ns.db.records[unitName] or {}
    ns.db.records[unitName][dateKey] = ns.db.dailySession or 0
end

local function clearSession()
    session = 0
    ns.db.session = 0
end

local function updateDates()
    loginDate = tostring(date("%Y-%m-%d"))
    ns.db.lastLogin = loginDate
end

local function evaluateLastLogin()
    local lastLogin = ns.db.lastLogin
    if not lastLogin or lastLogin == loginDate then return end

    setDailyRecord(lastLogin)
    clearSession()
    clearDailySession()
    updateDates()
end

local function evaluateNewLogin()
    if not newLogin then return end

    newLogin = false
    clearSession()
end

local function getSession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "SESSION" then
        session = ns.db.session or 0
    elseif frequency == "DAILY" then
        session = ns.db.dailySession or 0
    elseif frequency == "NEVER" then
        session = ns.db.allTimeSession or 0
    else
        session = 0
    end
end

local function updateMoney()
    money = GetMoney()
end

local function updateMoneyDelayed(seconds)
    C_Timer.After(seconds, updateMoney)
end

local function onVariablesLoaded(_)
    evaluateNewLogin()
    evaluateLastLogin()

    updateMoneyDelayed(0.5)

    BGCBus:TriggerEvent(name .. "_PLAYER_MODAL_READY")
end

local function updateSessions(amount)
    amount = amount or 0
    session = session + amount
    ns.db.session = ns.db.session + amount
    ns.db.dailySession = ns.db.dailySession + amount
    ns.db.allTimeSession = ns.db.allTimeSession + amount
end

local function onPlayerMoneyChanged(_, newAmount)
    local difference = newAmount - money

    updateMoney()
    updateSessions(difference)

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onReloadingUI(_)
    getSession()
    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onInitialLogin(_)
    newLogin = true
end

local function clearAllTimeSession()
    ns.db.allTimeSession = 0
end

local function clearAllSessions()
    clearSession()
    clearDailySession()
    clearAllTimeSession()
end

local function onClearSessionRequested(_)
    setDailyRecord(loginDate)
    clearSession()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function clearRecords()
    local unitName = utils.GetUnitName()

    ns.db.records = ns.db.records or {}
    ns.db.records[unitName] = {}
end

local function onWipeRequested(_)
    clearAllSessions()
    clearRecords()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onDailyReset(_)
    setDailyRecord(loginDate)
    updateDates()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

BGCBus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
BGCBus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
BGCBus:RegisterEvent(name .. "_IS_INITIAL_LOGIN", onInitialLogin)

BGCBus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)

BGCBus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
BGCBus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)
BGCBus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)
