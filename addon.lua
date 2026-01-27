local name, ns = ...
local LibEvent = LibStub("LibEvent")

local function onAddonLoaded(_, addonName)
    if addonName ~= name then return end

    LibEvent:TriggerEvent(name .. "_ADDON_LOADED")
end

local function onPlayerLogout()
    LibEvent:TriggerEvent(name .. "_PLAYER_LOGOUT")
end

local function onPlayerEnteringWorld(_, _, isReloadingUi)
    if not isReloadingUi then return end
    LibEvent:TriggerEvent(name .. "_IS_RELOADING_UI")
end

local function onPlayerLeavingWorld()
    LibEvent:TriggerEvent(name .. "_PLAYER_LEAVING_WORLD")
end

LibEvent:RegisterEvent("ADDON_LOADED", onAddonLoaded)
LibEvent:RegisterEvent("PLAYER_LOGOUT", onPlayerLogout)
LibEvent:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
LibEvent:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)