local name, ns = ...

local utils = ns.utils

local money = 0
local session = 0
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

local function updateMoney()
    money = GetMoney()
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

    ns.bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
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

    ns.bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function clearRecords()
    local unitName = utils.GetUnitName()

    ns.db.records = ns.db.records or {}
    ns.db.records[unitName] = {}
end

local function onWipeRequested(_)
    clearAllSessions()
    clearRecords()

    ns.bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end


ns.bus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)

ns.bus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
ns.bus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)
