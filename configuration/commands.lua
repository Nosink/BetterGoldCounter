local name, ns = ...

SLASH_BETTERGOLDCOUNTER1 = "/bettergoldcounter"
SLASH_BETTERGOLDCOUNTER2 = "/bgc"

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

SlashCmdList.BETTERGOLDCOUNTER = function(msg)
    msg = (msg or ""):match("^%s*(.-)%s*$"):lower()

    if msg == "" or msg == "config" or msg == "options" or msg == "settings" then
        return openSettings()
    elseif msg == "clear" or msg == "clear session" or msg == "reset" or msg == "reset session" then
        return clearSessionRequest()
    elseif msg == "history" then
        return historyRequest()
    else
        print("|cffffd200" .. name  .. ":|r Unknown Command:", msg)
    end
end