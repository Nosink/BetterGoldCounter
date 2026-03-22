local name, ns = ...

ns.db = ns.db or {}
ns.dbHandle = ns.dbHandle or nil

local LibSharedVariables = LibStub("LibSharedVariables-1.0")

local defaults = {
    -- Position
    x = GetScreenWidth() / 2,
    y = GetScreenHeight() / 2,

    -- Backdrop
    locked = false,
    backdrop = true,

    -- Font
    fontSize = 12,
    fontAlignment = "RIGHT", -- "LEFT", "CENTER", "RIGHT"

    -- Width
    dynamicWidth = false,
    width = 150,

    -- Fade
    fade = true,
    fadeOutOpacity = 0.5,
    fadeInOpacity = 1.0,
    fadeDuration = 0.1,
}

local defaultsPC = {
    -- Data consistency
    lastLogin = "",
    cleanFrequency = "SESSION", -- "SESSION", "DAILY", "NEVER"

    -- Stored data (false sentinel: avoids mutable table aliasing through defaults)
    records = false,

    -- Session tracking
    session = 0,
    dailySession = 0,
    allTimeSession = 0,
}

local function onVariablesLoaded()
    local handle = LibSharedVariables:New(name, defaults, defaultsPC)
    ns.db = handle.db

    BGCBus:TriggerEvent(name .. "_VARIABLES_LOADED")
end

BGCBus:RegisterEvent("VARIABLES_LOADED", onVariablesLoaded)
