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
        ns.session = Database:GetDB().session or 0
    elseif frequency == "DAILY" then
        ns.session = Database:GetDB().dailySession or 0
    elseif frequency == "NEVER" then
        ns.session = Database:GetDB().allTimeRecord or 0
    else
        ns.session = 0
    end
end

local function storeDailyRecord(dateKey)
    Database:GetDB().records = Database:GetDB().records or { }
    Database:GetDB().records[ns.unitName] = Database:GetDB().records[ns.unitName] or { }
    Database:GetDB().records[ns.unitName][dateKey] = Database:GetDB().dailySession + (Database:GetDB().records[ns.unitName][dateKey] or 0)
end

local function evaluateLastLogin()
    local lastLogin = Database:GetDB().lastLogin
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
    Database:GetDB().dailySession = Database:GetDB().dailySession + amount
    Database:GetDB().allTimeRecord = Database:GetDB().allTimeRecord + amount
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
    local daily = Database:GetDB().dailySession or 0
    local allTime = Database:GetDB().allTimeRecord or 0

    Database:GetDB().lastLogin = loginDate

    Database:GetDB().temporal = Database:GetDB().temporal or { }
    Database:GetDB().temporal[ns.unitName] = { session = session , daily = daily, allTime = allTime }
end

local function onReloadingUI(_)
    ns.session = Database:GetDB().temporal and Database:GetDB().temporal[ns.unitName].session or 0
    Database:GetDB().dailySession = Database:GetDB().temporal and Database:GetDB().temporal[ns.unitName].daily or 0
    Database:GetDB().allTimeRecord = Database:GetDB().temporal and Database:GetDB().temporal[ns.unitName].allTime or 0

    Database:GetDB().temporal = nil

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end


local function onClearSessionRequested(_)
    local dateKey = tostring(date("%Y-%m-%d"))
    storeDailyRecord(dateKey)

    ns.session = 0
    Database:GetDB().dailySession = 0
    Database:GetDB().allTimeRecord = 0

    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onWipeRequested(_)
    ns.session = 0
    Database:GetDB().dailySession = 0
    Database:GetDB().allTimeRecord = 0
    Database:GetDB().records = Database:GetDB().records or { }
    Database:GetDB().records[ns.unitName] = { }
    BGCBus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function wipeDailySession()
    local frequency = settings.GetCleanFrequency()
    if frequency ~= "DAILY" then return end
    print(L["LKEY_CLEARING_DAILY_SESSION"] .. Database:GetDB().dailySession .. L["LKEY_CLEARED"])
    ns.session = 0
    Database:GetDB().dailySession = 0
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