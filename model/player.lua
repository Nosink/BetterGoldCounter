local name, ns = ...

local settings = ns.settings
local database = ns.db or { }

local money = 0
local session = 0
local isInitialLogin = false
local loginDate = tostring(date("%Y-%m-%d"))

local function getUnitName()
    if ns.unitName then return end

    ns.unitName = UnitName("player")
end

local function setDailyRecord(dateKey)
    database.records = database.records or { }
    database.records[ns.unitName] = database.records[ns.unitName] or { }
    database.records[ns.unitName][dateKey] = database.dailySession or 0
    database.dailySession = 0
end

local function evaluateLastLogin()
    local lastLogin = database.lastLogin
    if not lastLogin or lastLogin == loginDate then return end

    setDailyRecord(lastLogin)
    database.lastLogin = loginDate
end

local function evaluateInitialLogin()
    if not isInitialLogin then return end

    database.session = 0
end

local function getSession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "SESSION" then
        session = database.session or 0
    elseif frequency == "DAILY" then
        session = database.dailySession or 0
    elseif frequency == "NEVER" then
        session = database.allTimeRecord or 0
    else
        session = 0
    end
end

local function updateMoney()
    money = GetMoney()
end

local function onVariablesLoaded(_)
    getUnitName()
    evaluateLastLogin()
    evaluateInitialLogin()
    getSession()
    updateMoney()

    BGCBus:TriggerEvent(name .. "_PLAYER_MODAL_READY")
    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function updateSessions(amount)
    database.session = database.session + amount
    database.dailySession = database.dailySession + amount
    database.allTimeRecord = database.allTimeRecord + amount
end

local function onPlayerMoneyChanged(_, newAmount)
    local difference = newAmount - money
    session = session + difference

    updateMoney()
    updateSessions(difference)

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function onInitialLogin(_)
    isInitialLogin = true
end

local function clearSessions()
    session = 0
    database.session = 0
    database.dailySession = 0
    database.allTimeRecord = 0
end

local function onClearSessionRequested(_)
    setDailyRecord(loginDate)
    clearSessions()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function clearRecords()
    database.records = database.records or { }
    database.records[ns.unitName] = { }
end

local function onWipeRequested(_)
    clearSessions()
    clearRecords()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

local function updateDates()
    loginDate = tostring(date("%Y-%m-%d"))
    database.lastLogin = loginDate
end

local function onDailyReset(_)
    setDailyRecord(loginDate)
    updateDates()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", session)
end

BGCBus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
BGCBus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)
BGCBus:RegisterEvent(name .. "_IS_INITIAL_LOGIN", onInitialLogin)
BGCBus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
BGCBus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)
BGCBus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)