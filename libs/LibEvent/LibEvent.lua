local MAJOR, MINOR = "LibEvent", 1
if not LibStub then error(MAJOR .. " requires LibStub") end

local LibEvent = LibStub:NewLibrary(MAJOR, MINOR)
if not LibEvent then return end

local handlers = {}
local onceHandlers = {}
local nativeEvents = {}

local frame = CreateFrame("Frame")

local function dispatch(_, event, ...)
    local list = handlers[event]
    if not list then
        return
    end

    -- Snapshot handlers to avoid iteration issues if list mutates during dispatch
    local snapshot = {}
    for i = 1, #list do
        snapshot[i] = list[i]
    end

    for i = 1, #snapshot do
        local entry = snapshot[i]
        if entry and entry.fn then
            local ok, err = pcall(entry.fn, event, ...)
            if not ok then
                geterrorhandler()(err)
            end
        end
    end
end

local function registerEvents(eventName)
    if handlers[eventName] then
        return handlers[eventName]
    end

    local handlerList = {}
    handlers[eventName] = handlerList

    local ok = pcall(frame.RegisterEvent, frame, eventName)
    if ok then
        nativeEvents[eventName] = true
    end

    return handlerList
end

function LibEvent:RegisterEvent(eventName, handler)
    if type(eventName) ~= "string" or type(handler) ~= "function" then return end

    local handlerList = registerEvents(eventName)

    -- Prevent duplicate registrations for the same handler
    for i = 1, #handlerList do
        if handlerList[i].fn == handler then
            return
        end
    end

    local eventHandler = { fn = handler }
    table.insert(handlerList, eventHandler)
end

function LibEvent:RegisterEventOnce(eventName, handler)
    if type(eventName) ~= "string" or type(handler) ~= "function" then return end

    local map = onceHandlers[eventName]
    if not map then
        map = {}
        onceHandlers[eventName] = map
    end

    if map[handler] then
        -- already registered once for this handler
        return
    end

    local function onceWrapper(event, ...)
        -- unregister this wrapper before invoking to guarantee single fire
        LibEvent:UnregisterEvent(eventName, onceWrapper)
        -- clear mapping
        map[handler] = nil
        local ok, err = pcall(handler, event, ...)
        if not ok then
            geterrorhandler()(err)
        end
    end

    map[handler] = onceWrapper
    LibEvent:RegisterEvent(eventName, onceWrapper)
end

local function clearHandler(handlerList, handler)
    for i = #handlerList, 1, -1 do
        if handlerList[i].fn == handler then
            table.remove(handlerList, i)
        end
    end
end

local function unregisterEvents(eventName, handlerList)
    if #handlerList == 0 then
        handlers[eventName] = nil
        if nativeEvents[eventName] then
            local ok, err = pcall(frame.UnregisterEvent, frame, eventName)
            if not ok then
                local msg = string.format("LibEvent: UnregisterEvent failed for '%s': %s", tostring(eventName), tostring(err))
                geterrorhandler()(msg)
            end
            nativeEvents[eventName] = nil
        end
        -- clear any once-handlers bookkeeping for this event
        onceHandlers[eventName] = nil
    end
end

function LibEvent:UnregisterEvent(eventName, handler)
    local handlerList = handlers[eventName]
    if not handlerList or type(handler) ~= "function" then return end

    clearHandler(handlerList, handler)
    unregisterEvents(eventName, handlerList)
end

function LibEvent:UnregisterAll(eventName)
    if type(eventName) ~= "string" then return end
    local handlerList = handlers[eventName]
    if not handlerList then return end
    for i = #handlerList, 1, -1 do
        handlerList[i] = nil
    end
    onceHandlers[eventName] = nil
    unregisterEvents(eventName, handlerList)
end

function LibEvent:TriggerEvent(eventName, ...)
    if type(eventName) ~= "string" then return end

    dispatch(frame, eventName, ...)
end

function LibEvent:IsRegistered(eventName)
    if type(eventName) ~= "string" then return false end
    local handlerList = handlers[eventName]
    if not handlerList then return false end
    return #handlerList > 0
end

function LibEvent:HookSecureFunc(frame, funcName, handler)
    if type(frame) == "string" then
        frame, funcName, handler = _G, frame, funcName
    end

    if type(handler) ~= "function" then return end

    hooksecurefunc(frame, funcName, function(...)
        local ok, err = pcall(handler, ...)
        if not ok then
            geterrorhandler()(err)
        end
    end)
end

function LibEvent:HookScript(frame, funcName, handler)
    if type(frame) ~= "table" or type(funcName) ~= "string" or type(handler) ~= "function" then return end

    frame:HookScript(funcName, function(...)
        local ok, err = pcall(handler, ...)
        if not ok then
            geterrorhandler()(err)
        end
    end)
end

frame:SetScript("OnEvent", dispatch)