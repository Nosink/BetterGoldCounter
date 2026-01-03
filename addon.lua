local name, ns = ...

local utils = ns.utils 

local function initializeRecord()
    ns.date = date("%Y-%m-%d", GetServerTime())
    ns.databasePC.records = ns.databasePC.records or {}
    if not ns.databasePC.records[ns.date] then
        ns.databasePC.records[ns.date] = {ns.date, 0, ""}
    end
end

local function initializeVars()
    ns.current = GetMoney()
    ns.session = 0
end

local function onVariablesLoaded()

    initializeRecord()
    initializeVars()

    ns:TriggerEvent(name .. "_ADDON_LOADED")
end

local function storeSession(sessionAmount)
    ns.databasePC.records[ns.date][2] = ns.databasePC.records[ns.date][2] + (tonumber(sessionAmount) or 0)
    ns.databasePC.records[ns.date][3] = utils.GetSignSymbol(sessionAmount)
end

local function onPlayerLogout()
    storeSession(ns.session)
end

local function onSessionReset(_, sessionAmount)
    storeSession(sessionAmount)
end

local function onHistoryRequested()
    local total = 0
    local records = ns.databasePC.records or {}
    for _, value in pairs(records) do
        total = total + value[2]
        print(string.format("%s: %s %s", tostring(value[1]), tostring(value[3]), GetMoneyString(value[2])))
    end
    local sign = utils.GetSignSymbol(total)
    print(string.format("Total: %s %s", sign, GetMoneyString(total)))
end

local function onClearHistoryRequested()
    ns.databasePC.records = {}
end

ns:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
ns:RegisterEvent("PLAYER_LOGOUT", onPlayerLogout)

ns:RegisterEvent(name .. "_SESSION_RESET", onSessionReset)
ns:RegisterEvent(name .. "_HISTORY_REQUESTED", onHistoryRequested)
ns:RegisterEvent(name .. "_CLEAR_HISTORY_REQUESTED", onClearHistoryRequested)

local function onPlayerEnteringWorld()
    ns.session = ns.database.session or 0
    ns.database.session = nil
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
end

local function onPlayerLeavingWorld()
    ns.database.session = ns.session
end

ns:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
ns:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)