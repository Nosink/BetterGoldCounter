local name, ns = ...

ns.db = ns.db or {}

local LibSharedVariables = LibStub("LibSavedVariables-1.0")
if not LibSharedVariables then error(name .. " requires LibSavedVariables-1.0") end

local defaults = {
    x = GetScreenWidth() / 2,
    y = GetScreenHeight() / 2,

    locked = false,
    backdrop = true,

    fontSize = 12,
    fontAlignment = "RIGHT", -- "LEFT", "CENTER", "RIGHT"
    dynamicWidth = false,
    width = 150,

    fade = true,
    fadeOutOpacity = 0.5,
    fadeInOpacity = 1.0,
    fadeDuration = 0.1,
}

local defaultsPC = {
    lastLogin = "",
    cleanFrequency = "SESSION", -- "SESSION", "DAILY", "NEVER"

    temporal = { },
    records = { },
    allTimeRecord = 0,
}

local function onLoadCallback(database, _, _)
    ns.db = database
    BGCBus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

local options = {
    name = name,
    defaults = defaults,
    defaultsPC = defaultsPC,
    onLoadCallback = onLoadCallback,
}

LibSharedVariables:Load(options)