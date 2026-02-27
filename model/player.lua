local name, ns = ...

local settings = ns.settings

local money = 0
local session = 0
local loginDate = tostring(date("%Y-%m-%d"))

ns.db = ns.db or { }

local function retrieveUnitName()
    ns.unitName = UnitName("player")
end

local function storeDailyRecord(dateKey)
    ns.db.records = ns.db.records or { }
    ns.db.records[ns.unitName] = ns.db.records[ns.unitName] or { }
    ns.db.records[ns.unitName][dateKey] = ns.db.dailySession or 0
end

local function evaluateLastLogin()
    local lastLogin = ns.db.lastLogin
    if not lastLogin then return end

    if lastLogin ~= loginDate then
        storeDailyRecord(lastLogin)
        ns.db.dailySession = 0
        lastLogin = loginDate
    end
end

local function updateLocalSession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "SESSION" then
        session = ns.db.session or 0
    elseif frequency == "DAILY" then
        session = ns.db.dailySession or 0
    elseif frequency == "NEVER" then
        session = ns.db.allTimeRecord or 0
    else
        session = 0
    end
end

local function updateMoney()
    money = GetMoney()
end

local function onVariablesLoaded(_)
    retrieveUnitName()
    evaluateLastLogin()
    updateLocalSession()
    updateMoney()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function updateDatabaseSessions(amount)
    ns.db.session = ns.db.session + amount
    ns.db.dailySession = ns.db.dailySession + amount
    ns.db.allTimeRecord = ns.db.allTimeRecord + amount
end

local function onPlayerMoneyChanged(_, newAmount)
    session = newAmount - money

    updateMoney()
    updateDatabaseSessions(session)

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onReloadingUI(_)
    updateLocalSession()
    updateMoney()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onPlayerLogout(_)
    ns.db.session = 0
end

local function onPlayerLeavingWorld(_)
    ns.db.session = 0
end

local function onClearSessionRequested(_)
    local dateKey = tostring(date("%Y-%m-%d"))
    storeDailyRecord(dateKey)

    ns.db.session = 0
    ns.db.dailySession = 0
    ns.db.allTimeRecord = 0

    updateLocalSession()
    updateMoney()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onWipeRequested(_)
    ns.db.session = 0
    ns.db.dailySession = 0
    ns.db.allTimeRecord = 0

    ns.db.records = ns.db.records or { }
    ns.db.records[ns.unitName] = { }

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function updateLoginDate()
    loginDate = tostring(date("%Y-%m-%d"))
end

local function onDailyReset(_)
    storeDailyRecord(loginDate)
    ns.db.dailySession = 0
    updateLoginDate()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

BGCBus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)

BGCBus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)

BGCBus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
BGCBus:RegisterEvent(name .. "_PLAYER_LOGOUT", onPlayerLogout)
BGCBus:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)

BGCBus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
BGCBus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)

BGCBus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)