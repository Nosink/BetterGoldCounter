local _, ns = ...

local defaults = {
    -- Position
    x = nil,
    y = nil,

    -- Backdrop
    locked = false,
    backdrop = true,

    -- Font
    fontSize = 12,
    fontAlignment = "RIGHT",

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
    cleanFrequency = "SESSION",

    records = nil,
}

ns.database.Register(defaults, defaultsPC)
