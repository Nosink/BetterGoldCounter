local name, ns = ...

SLASH_BETTERGOLDCounter1 = "/bettergoldcounter"
SLASH_BETTERGOLDCounter2 = "/bgc"

local function openSettings()
    if Settings and Settings.OpenToCategory and ns.settingsCategory then
        Settings.OpenToCategory(ns.settingsCategory:GetID())
    end
end

local function clearSessionRequest()
    ns:TriggerEvent(name .. "_CLEAR_SESSION_REQUESTED")
end

local function historyRequest()
    ns:TriggerEvent(name .. "_HISTORY_REQUESTED")
end

local function clearHistoryRequest()
    ns:TriggerEvent(name .. "_CLEAR_HISTORY_REQUESTED")
end

SlashCmdList.BETTERGOLDCounter = function(msg)
    msg = (msg or ""):match("^%s*(.-)%s*$"):lower()

    if msg == "" or msg == "config" or msg == "options" or msg == "settings" then
        return openSettings()
    elseif msg == "clear" or msg == "clear session" then
        return clearSessionRequest()
    elseif msg == "clear history" then
        return clearHistoryRequest()
    elseif msg == "history" then
        return historyRequest()
    else
        print("|cffffd200" .. name  .. ":|r Unknown Command:", msg)
    end
end