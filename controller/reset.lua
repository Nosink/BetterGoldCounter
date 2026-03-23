local name, _ = ...

local dailyResetAction = nil



local function clearDailyReset()
    if not dailyResetAction then return end

    dailyResetAction:Cancel()
    dailyResetAction = nil
end

local function getNow()
    local now = time()
    return date("*t", now)
end

local function getTimeLeft()
    local now = getNow()
    local extraSeconds = 5
    local hoursLeft = (23 - now.hour) * 3600
    local minutesLeft = (59 - now.min) * 60
    local secondsLeft = 59 - now.sec
    return hoursLeft + minutesLeft + secondsLeft + extraSeconds
end

local function setDailyReset()
    local timeLeft = getTimeLeft()
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
