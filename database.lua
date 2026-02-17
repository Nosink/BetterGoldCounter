local name, ns = ...

local LibSharedVariables = LibStub("LibSavedVariables-1.0")
if not LibSharedVariables then error(name .. " requires LibSavedVariables-1.0") end

local defaults = {
    x = nil,
    y = nil,

    locked = false,
    backdrop = true,

    fontSize = 12,
    fontAlignment = "CENTER",
    dynamicWidth = true,
    width = 150,

    fade = true,
    fadeOutOpacity = 0.5,
    fadeInOpacity = 1.0,
    fadeDuration = 0.1,
}

local defaultsPC = {
    lastLogin = nil,
    cleanFrequency = "SESSION", -- "SESSION", "DAILY", "NEVER"

    temporal = nil,
    records = { },
    allTimeRecord = nil,
}

local function onLoadCallback(db, _)
    ns.db = db
    BGCBus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

local dbOptions = {
    name = name,
    defaults = defaults,
    defaultsPC = defaultsPC,
    combined = true,
    onLoadCallback = onLoadCallback,
}

LibSharedVariables:Load(dbOptions)