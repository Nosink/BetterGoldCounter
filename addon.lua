local name, ns = ...

local utils = ns.utils 

local function initializeUnit()
    ns.unit = ns.unit or UnitName("player") or "Unknown"
end

local function initializeRecord()
    ns.date = ns.date or date("%Y-%m-%d", GetServerTime())
    ns.database.records = ns.database.records or {}
    ns.database.records[ns.unit] = ns.database.records[ns.unit] or {}
    ns.database.records[ns.unit][ns.date] = ns.database.records[ns.unit][ns.date] or { ns.date, 0, ""}
end

local function initializeVars()
    ns.current = GetMoney()
    ns.session = ns.database.session or 0
    ns.database.session = nil
end

local function onVariablesLoaded()

    initializeUnit()
    initializeRecord()
    initializeVars()

    ns:TriggerEvent(name .. "_ADDON_LOADED")
end

local function storeSession(sessionAmount)
    ns.database.records[ns.unit][ns.date][2] = ns.database.records[ns.unit][ns.date][2] + (tonumber(sessionAmount) or 0)
    ns.database.records[ns.unit][ns.date][3] = utils.GetSignSymbol(sessionAmount)
    ns.database.session = nil
end

local function onSessionReset(_, sessionAmount)
    storeSession(sessionAmount)
end

local function onPlayerLogout()
    storeSession(ns.session)
end

local function onPlayerLeavingWorld()
    if ns.database.session then return end
    ns.database.session = ns.session
end

ns:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
ns:RegisterEvent(name .. "_SESSION_RESET", onSessionReset)

ns:RegisterEvent("PLAYER_LOGOUT", onPlayerLogout)
ns:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)