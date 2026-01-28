local name, _ = ...
local bus = LibStub("LibEventBus-1.0")

local function onAddonLoaded(_, addonName)
    if addonName ~= name then return end

    bus:TriggerEvent(name .. "_ADDON_LOADED")
end

local function onPlayerLogout()
    bus:TriggerEvent(name .. "_PLAYER_LOGOUT")
end

local function onPlayerEnteringWorld(_, _, isReloadingUi)
    if not isReloadingUi then return end
    bus:TriggerEvent(name .. "_IS_RELOADING_UI")
end

local function onPlayerLeavingWorld()
    bus:TriggerEvent(name .. "_PLAYER_LEAVING_WORLD")
end

bus:RegisterEvent("ADDON_LOADED", onAddonLoaded)
bus:RegisterEvent("PLAYER_LOGOUT", onPlayerLogout)
bus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
bus:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)