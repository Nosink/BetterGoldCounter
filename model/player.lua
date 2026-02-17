local name, ns = ...

local L = ns.L

local settings = ns.settings

local loginDate = tostring(date("%Y-%m-%d"))

local function onAddonLoaded(_)
    ns.unitName = UnitName("player")
end

local function updateLocalSession()
    local frequency = settings.GetCleanFrequency()
    if frequency == "SESSION" then
        ns.session = ns.db.session or 0
    elseif frequency == "DAILY" then
        ns.session = ns.db.dailySession or 0
    elseif frequency == "NEVER" then
        ns.session = ns.db.allTimeRecord or 0
    else
        ns.session = 0
    end
end

local function storeDailyRecord(dateKey)
    ns.db.records = ns.db.records or { }
    ns.db.records[ns.unitName] = ns.db.records[ns.unitName] or { }
    ns.db.records[ns.unitName][dateKey] = ns.db.dailySession + (ns.db.records[ns.unitName][dateKey] or 0)
end

local function evaluateLastLogin()
    local lastLogin = ns.db.lastLogin
    if not lastLogin then return end

    if lastLogin ~= loginDate then
        storeDailyRecord(lastLogin)
        lastLogin = loginDate
    end
end

local function onVariablesLoaded(_)
    evaluateLastLogin()
    updateLocalSession()

    C_Timer.After(1, function()
        ns.money = GetMoney()
    end)

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function updateDatabaseSessions(amount)
    ns.db.dailySession = ns.db.dailySession + amount
    ns.db.allTimeRecord = ns.db.allTimeRecord + amount
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = GetMoney()

    updateDatabaseSessions(session)

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerLeavingWorld(_)
    local session = ns.session
    local daily = ns.db.dailySession or 0
    local allTime = ns.db.allTimeRecord or 0

    ns.db.lastLogin = loginDate

    ns.db.temporal = ns.db.temporal or { }
    ns.db.temporal[ns.unitName] = { session = session , daily = daily, allTime = allTime }
end

local function onReloadingUI(_)
    ns.session = ns.db.temporal and ns.db.temporal[ns.unitName].session or 0
    ns.db.dailySession = ns.db.temporal and ns.db.temporal[ns.unitName].daily or 0
    ns.db.allTimeRecord = ns.db.temporal and ns.db.temporal[ns.unitName].allTime or 0

    ns.db.temporal = nil

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end


local function onClearSessionRequested(_)
    local dateKey = tostring(date("%Y-%m-%d"))
    storeDailyRecord(dateKey)

    ns.session = 0
    ns.db.dailySession = 0
    ns.db.allTimeRecord = 0

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onWipeRequested(_)
    ns.session = 0
    ns.db.dailySession = 0
    ns.db.allTimeRecord = 0
    ns.db.records = ns.db.records or { }
    ns.db.records[ns.unitName] = { }
    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function wipeDailySession()
    local frequency = settings.GetCleanFrequency()
    if frequency ~= "DAILY" then return end
    print(L["LKEY_CLEARING_DAILY_SESSION"] .. ns.db.dailySession .. L["LKEY_CLEARED"])
    ns.session = 0
    ns.db.dailySession = 0
end

local function updateLoginDate()
    loginDate = tostring(date("%Y-%m-%d"))
end

local function onDailyReset(_)

    storeDailyRecord(loginDate)
    wipeDailySession()
    updateLoginDate()

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

BGCBus:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
BGCBus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)

BGCBus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)

BGCBus:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
BGCBus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)

BGCBus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)
BGCBus:RegisterEvent(name .. "_WIPE_REQUESTED", onWipeRequested)

BGCBus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)