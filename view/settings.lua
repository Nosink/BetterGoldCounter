local name, ns = ...

local settings = ns.settings

local function onSettingChanged(_, key)
    if (key == "width" or key == "dynamicWidth" or key == "fontSize") then
        ns:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
    elseif (key == "fade" or key == "fadeInOpacity" or key == "fadeOutOpacity") then
        local alpha = settings.GetFadeOpacity()
        ns.frame:SetAlpha(alpha)
    elseif (key == "backdrop") then
        ns.frame:SetBackdropAlpha()
    end
end


ns:RegisterEvent(name .. "_SETTINGS_CHANGED", onSettingChanged)