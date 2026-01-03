
local _, ns = ...

ns.utils = ns.utils or {}

ns.utils.GetItemQualityColor = function(quality)
    local q = tonumber(quality) or 0

    if C_Item and C_Item.GetItemQualityColor then
        local r, g, b = C_Item.GetItemQualityColor(q)
        if type(r) == "table" then
            return r.r, r.g, r.b
        end
        if type(r) == "number" then
            return r, g, b
        end
    end

    return 1, 1, 1
end

function ns.utils.GetSignSymbol(amount)
    return amount < 0 and "-" or amount > 0 and "+" or ""
end

function ns.utils.FadeIn(frame, duration, targetAlpha)
    local fadeInfo = {
        mode = "IN",
        timeToFade = duration,
        startAlpha = frame:GetAlpha(),
        endAlpha = targetAlpha }
    UIFrameFade(frame, fadeInfo)
end

function ns.utils.FadeOut(frame, duration, targetAlpha)
    local fadeInfo = {
        mode = "OUT",
        timeToFade = duration,
        startAlpha = frame:GetAlpha(),
        endAlpha = targetAlpha }
    UIFrameFade(frame, fadeInfo)
end