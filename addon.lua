local name, ns = ...
local bus = LibStub("LibEventBus-1.0")

bus:GetGlobalBus():SetDebug(true)

local settings = ns.settings

local dailyResetAction = nil

local function clearDailyReset()
    if dailyResetAction then
        dailyResetAction:Cancel()
        dailyResetAction = nil
    end
end

local function setDailyReset()
    local timeLeft = (24 - tonumber(date("%H"))) * 3600 - tonumber(date("%M")) * 60 - tonumber(date("%S")) + 1
    dailyResetAction = C_Timer.NewTimer(timeLeft, function()
        bus:TriggerEvent(name .. "_DAILY_RESET")
        clearDailyReset()
        setDailyReset()
    end)
end

local function onAddonLoaded(_, addonName)
    if addonName ~= name then return end

    setDailyReset()

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


local function onSettingsChanged(_, key)
    if key ~= "cleanFrequency" then return end

    clearDailyReset()
    local cleanFrequency = settings.GetCleanFrequency()
    if cleanFrequency == "DAILY" then
        setDailyReset()
    end

end

bus:RegisterEvent("ADDON_LOADED", onAddonLoaded)
bus:RegisterEvent("PLAYER_LOGOUT", onPlayerLogout)
bus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
bus:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)

bus:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingsChanged)