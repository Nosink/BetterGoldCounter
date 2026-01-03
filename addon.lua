local name, ns = ...

local utils = ns.utils 

local function initializeUnit()
    ns.unit = UnitName("player") or "Unknown"
end

local function initializeRecord()
    ns.date = date("%Y-%m-%d", GetServerTime())
    ns.database[ns.unit] = ns.database[ns.unit] or {records = {}}
    if not ns.database[ns.unit].records[ns.date] then
        ns.database[ns.unit].records[ns.date] = {ns.date, 0, ""}
    end
end

local function initializeVars()
    ns.current = GetMoney()
    ns.session, ns.database.session = ns.database.session or 0, nil
end

local function onVariablesLoaded()

    initializeUnit()
    initializeRecord()
    initializeVars()

    ns:TriggerEvent(name .. "_ADDON_LOADED")
end

local function storeSession(sessionAmount)
    ns.database[ns.unit].records[ns.date][2] = ns.database[ns.unit].records[ns.date][2] + (tonumber(sessionAmount) or 0)
    ns.database[ns.unit].records[ns.date][3] = utils.GetSignSymbol(sessionAmount)
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