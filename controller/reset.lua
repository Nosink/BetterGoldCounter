local name, _ = ...

local dailyResetAction = nil

local function clearDailyReset()
    if not dailyResetAction then return end

    dailyResetAction:Cancel()
    dailyResetAction = nil
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
end

BGCBus:RegisterEvent(name .. "_VARIABLES_LOADED", onVariablesLoaded)