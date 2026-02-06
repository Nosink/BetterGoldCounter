local _, ns = ...

ns.defaults = {
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

    temporal = nil,

    lastLogin = nil,
    cleanFrequency = "SESSION", -- "SESSION", "DAILY", "NEVER"

    records = { },
    allTimeRecord = nil,

}

ns.defaultsPC = {
}