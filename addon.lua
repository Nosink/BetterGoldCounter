local name, ns = ...

local function onAddonLoaded(_, addonName)
    if addonName ~= name then return end

    ns:TriggerEvent(name .. "_ADDON_LOADED")
end

local function onPlayerEnteringWorld(_, isInitialLogin, isReloadingUi)
    if isInitialLogin then
        ns:TriggerEvent(name .. "_IS_INITIAL_LOGIN")
    elseif isReloadingUi then
        ns:TriggerEvent(name .. "_IS_RELOADING_UI")
    end
end

local function onPlayerLeavingWorld()
    ns:TriggerEvent(name .. "_PLAYER_LEAVING_WORLD")
end

ns:RegisterEvent("ADDON_LOADED", onAddonLoaded)
ns:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
ns:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)