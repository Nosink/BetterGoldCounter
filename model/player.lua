local name, ns = ...
local bus = LibStub("LibEventBus-1.0")

local settings = ns.settings
local database = ns.database

local dateTime = tostring(date("%Y-%m-%d"))

local dailySession = 0

local function onVariablesLoaded(_)
    database.records[ns.unitName] = database.records[ns.unitName] or {}
    dailySession = database.records[ns.unitName][dateTime] or 0

    local frequency = settings.GetCleanFrequency()
    print ("BetterGoldCounter: Loaded session clean frequency: " .. frequency)
    if frequency == "DAILY" then
        ns.session = dailySession
    end
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function GetMoneyDelayed()
    C_Timer.After(1.0, function()
        ns.money = GetMoney()
    end)
end

local function onAddonLoaded(_)
    ns.unitName = UnitName("player")
    GetMoneyDelayed()
    ns.session = 0
end

local function onReloadingUI(_)
    ns.session = database.session
    database.session = nil

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerMoneyChanged(_, newAmount)
    local session = newAmount - ns.money
    ns.session = ns.session + session
    ns.money = newAmount

    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onPlayerLogout(_)
    local frequency = settings.GetCleanFrequency()
    if frequency == "DAILY" then
        dailySession = ns.session
    elseif frequency == "SESSION" then
        dailySession = dailySession + ns.session
    end
    database.records[ns.unitName][dateTime] = dailySession
end

local function onPlayerLeavingWorld(_)
    database.session = ns.session
end

local function onClearSessionRequested(_)
    onPlayerLogout(_)
    onAddonLoaded(_)
    bus:TriggerEvent(name .. "_SESSION_MONEY_CHANGED", ns.session)
end

local function onDailyReset(_)
    
end

bus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
bus:RegisterEvent(name .. "_DAILY_RESET", onDailyReset)
bus:RegisterEvent(name .. "_ADDON_LOADED", onAddonLoaded)
bus:RegisterEvent(name .. "_IS_RELOADING_UI", onReloadingUI)
bus:RegisterEvent(name .. "_PLAYER_MONEY_CHANGED", onPlayerMoneyChanged)
bus:RegisterEvent(name .. "_PLAYER_LOGOUT", onPlayerLogout)
bus:RegisterEvent(name .. "_PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)
bus:RegisterEvent(name .. "_CLEAR_SESSION_REQUESTED", onClearSessionRequested)