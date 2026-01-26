
local _, ns = ...

ns.utils = ns.utils or {}

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