local name, ns = ...

local LibEventBus = LibStub("LibEventBus-1.0")
BGCBus = LibEventBus:NewBus("BGCBus", true)

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
        BGCBus:TriggerEvent(name .. "_DAILY_RESET")
        clearDailyReset()
        setDailyReset()
    end)
end

local function onVariablesLoaded(_)
    setDailyReset()

    BGCBus:TriggerEvent(name .. "_ADDON_LOADED")
end

local function onPlayerLogout()
    BGCBus:TriggerEvent(name .. "_PLAYER_LOGOUT")
end

local function onPlayerEnteringWorld(_, _, isReloadingUi)
    if not isReloadingUi then return end
    BGCBus:TriggerEvent(name .. "_IS_RELOADING_UI")
end

local function onPlayerLeavingWorld()
    BGCBus:TriggerEvent(name .. "_PLAYER_LEAVING_WORLD")
end


local function onSettingsChanged(_, key)
    if key ~= "cleanFrequency" then return end

    clearDailyReset()
    local cleanFrequency = ns.settings.GetCleanFrequency()
    if cleanFrequency == "DAILY" then
        setDailyReset()
    end

end

BGCBus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)
BGCBus:RegisterEvent("PLAYER_LOGOUT", onPlayerLogout)
BGCBus:RegisterEvent("PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
BGCBus:RegisterEvent("PLAYER_LEAVING_WORLD", onPlayerLeavingWorld)

BGCBus:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingsChanged)