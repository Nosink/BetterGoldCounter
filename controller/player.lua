local name, ns = ...

local function onPlayerMoney()
    local money = GetMoney()
    ns:TriggerEvent(name .. "_PLAYER_MONEY_CHANGED", money)
end

local function onSettingChanged(_, key)
    if (key == "width" or key == "dynamicWidth" or key == "fontSize") then
    elseif (key == "fade" or key == "fadeInOpacity" or key == "fadeOutOpacity") then
    elseif (key == "backdrop") then
    end
end

ns:RegisterEvent("PLAYER_MONEY", onPlayerMoney)
ns:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingChanged)