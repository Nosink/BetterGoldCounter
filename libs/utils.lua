local _, ns = ...

local utils = {}

function utils.GetUnitName()
    return UnitName("player")
end

function utils.GetSignSymbol(amount)
    if type(amount) ~= "number" then return "" end

    return amount < 0 and "-" or amount > 0 and "+" or ""
end

function utils.FadeIn(frame, duration, targetAlpha)
    if not frame then return end

    local fadeInfo = {
        mode = "IN",
        timeToFade = duration or 0.5,
        startAlpha = frame:GetAlpha() or 0,
        endAlpha = targetAlpha or 1
    }
    UIFrameFade(frame, fadeInfo)
end

function utils.FadeOut(frame, duration, targetAlpha)
    if not frame then return end

    local fadeInfo = {
        mode = "OUT",
        timeToFade = duration or 0.5,
        startAlpha = frame:GetAlpha() or 1,
        endAlpha = targetAlpha or 0
    }
    UIFrameFade(frame, fadeInfo)
end

function utils.ColoredText(color, text)
    return string.format("|c%s%s|r", color, text)
end

ns.utils = utils
