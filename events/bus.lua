local _, ns = ...

ns.handlers = ns.handlers or {}

MAX_PRIORITY = 0
MID_PRIORITY = 5
MIN_PRIORITY = 9

local frame = CreateFrame("Frame")

local DEFAULT_PRIORITY = MID_PRIORITY

local function dispatch(_, event, ...)
    local handlers = ns.handlers[event]
    if not handlers then
        return
    end

    for i = 1, #handlers do
        local entry = handlers[i]
        if entry and entry.fn then
            local ok, err = pcall(entry.fn, event, ...)
            if not ok then
                geterrorhandler()(err)
            end
        end
    end
end

local function clampPriority(priority)
    local prio = tonumber(priority) or DEFAULT_PRIORITY
    if prio < 0 then
        prio = 0
    elseif prio > 9 then
        prio = 9
    end
    return prio
end

local function registerEvents(eventName)
    if ns.handlers[eventName] then
        return ns.handlers[eventName]
    end

    local handlerList = {}
    ns.handlers[eventName] = handlerList

    pcall(frame.RegisterEvent, frame, eventName)

    return handlerList
end

local function setEventPriority(handlerList, handler, priority)
    for i = 1, #handlerList do
        if handlerList[i].fn == handler then
            handlerList[i].priority = priority
            return
        end
    end
end

local function getInsertIndex(handlerList, priority)
    local insertIndex = #handlerList + 1
    for i = 1, #handlerList do
        if priority < handlerList[i].priority then
            insertIndex = i
            break
        end
    end
    return insertIndex
end

function ns:RegisterEvent(eventName, handler, priority)
    if type(eventName) ~= "string" or type(handler) ~= "function" then return end

    local handlerList = registerEvents(eventName)
    priority = clampPriority(priority)

    setEventPriority(handlerList, handler, priority)

    local insertIndex = getInsertIndex(handlerList, priority)
    local eventHandler = { fn = handler, priority = priority }

    table.insert(handlerList, insertIndex, eventHandler)
end

local function clearHandler(handlerList, handler)
    for i = #handlerList, 1, -1 do
        if handlerList[i].fn == handler then
            table.remove(handlerList, i)
            break
        end
    end
end

local function unregisterEvents(eventName, handlerList)
    if #handlerList == 0 then
        ns.handlers[eventName] = nil
        pcall(frame.UnregisterEvent, frame, eventName)
    end
end

function ns:UnregisterEvent(eventName, handler)
    local handlerList = ns.handlers[eventName]
    if not handlerList or type(handler) ~= "function" then return end

    clearHandler(handlerList, handler)
    unregisterEvents(eventName, handlerList)
end

function ns:TriggerEvent(eventName, ...)
    if type(eventName) ~= "string" then return end

    dispatch(frame, eventName, ...)
end

function ns:HookSecureFunc(frame, funcName, handler)
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

function ns:HookScript(frame, funcName, handler)
    if type(frame) ~= "table" or type(funcName) ~= "string" or type(handler) ~= "function" then return end

    frame:HookScript(funcName, function(...)
        local ok, err = pcall(handler, ...)
        if not ok then
            geterrorhandler()(err)
        end
    end)
end

frame:SetScript("OnEvent", dispatch)