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
        ns.session = DB:GetDB().session or 0
    elseif frequency == "DAILY" then
        ns.session = DB:GetDB().dailySession or 0
    elseif frequency == "NEVER" then
        ns.session = DB:GetDB().allTimeRecord or 0
    else
        ns.session = 0
    end
end

local function storeDailyRecord(dateKey)
    DB:GetDB().records = DB:GetDB().records or { }
    DB:GetDB().records[ns.unitName] = DB:GetDB().records[ns.unitName] or { }
    DB:GetDB().records[ns.unitName][dateKey] = DB:GetDB().dailySession + (DB:GetDB().records[ns.unitName][dateKey] or 0)
end

local function evaluateLastLogin()
    local lastLogin = DB:GetDB().lastLogin
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
    DB:GetDB().dailySession = DB:GetDB().dailySession + amount
    DB:GetDB().allTimeRecord = DB:GetDB().allTimeRecord + amount
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
    local daily = DB:GetDB().dailySession or 0
    local allTime = DB:GetDB().allTimeRecord or 0

    DB:GetDB().lastLogin = loginDate

    DB:GetDB().temporal = DB:GetDB().temporal or { }
    DB:GetDB().temporal[ns.unitName] = { session = session , daily = daily, allTime = allTime }
end

local function onReloadingUI(_)
    ns.session = DB:GetDB().temporal and DB:GetDB().temporal[ns.unitName].session or 0
    DB:GetDB().dailySession = DB:GetDB().temporal and DB:GetDB().temporal[ns.unitName].daily or 0
    DB:GetDB().allTimeRecord = DB:GetDB().temporal and DB:GetDB().temporal[ns.unitName].allTime or 0

    DB:GetDB().temporal = nil

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end


local function onClearSessionRequested(_)
    local dateKey = tostring(date("%Y-%m-%d"))
    storeDailyRecord(dateKey)

    ns.session = 0
    DB:GetDB().dailySession = 0
    DB:GetDB().allTimeRecord = 0

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onWipeRequested(_)
    ns.session = 0
    DB:GetDB().dailySession = 0
    DB:GetDB().allTimeRecord = 0
    DB:GetDB().records = DB:GetDB().records or { }
    DB:GetDB().records[ns.unitName] = { }
    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function wipeDailySession()
    local frequency = settings.GetCleanFrequency()
    if frequency ~= "DAILY" then return end
    print(L["LKEY_CLEARING_DAILY_SESSION"] .. DB:GetDB().dailySession .. L["LKEY_CLEARED"])
    ns.session = 0
    DB:GetDB().dailySession = 0
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