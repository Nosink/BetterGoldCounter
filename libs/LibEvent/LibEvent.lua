local MAJOR, MINOR = "LibEvent", 1
if not LibStub then error(MAJOR .. " requires LibStub") end

local Bus = LibStub:NewLibrary(MAJOR, MINOR)
if not Bus then return end

local type = type
local pcall = pcall
local tostring = tostring
local geterrorhandler = geterrorhandler


local handlers = {}
local onceHandlers = {}
local nativeEvents = {}
local hookedFuncs = {}
local hookedScripts = setmetatable({}, { __mode = "k" })


local BusProto = {}
BusProto.__index = BusProto

local frame = CreateFrame("Frame")

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        geterrorhandler()(err)
        return false, err
    end
    return true
end

local function fastCall(fn, ...)
    return fn(...)
end

BusProto.safe = true

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
        onceHandlers[eventName] = nil
    end
end

local function dispatch(_, event, ...)
    local list = handlers[event]
    if not list then return end

    local call = Bus.safe and safeCall or fastCall

    for i = 1, #list do
        local entry = list[i]
        if entry and entry.active then
            call(entry.fn, event, ...)
        end
    end

    if list.dirty then
        local write = 1
        for read = 1, #list do
            local entry = list[read]
            if entry and entry.active then
                list[write] = entry
                write = write + 1
            end
        end
        for i = write, #list do
            list[i] = nil
        end
        list.dirty = false
    end

    unregisterEvents(event, list)
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

function BusProto:RegisterEvent(eventName, handler)
    if type(eventName) ~= "string" or type(handler) ~= "function" then return end

    local handlerList = registerEvents(eventName)

    for i = 1, #handlerList do
        if handlerList[i].fn == handler then
            return
        end
    end

    local eventHandler = { fn = handler, active = true }
    table.insert(handlerList, eventHandler)
    return function()
        BusProto:UnregisterEvent(eventName, handler)
    end
end

function BusProto:RegisterEventOnce(eventName, handler)
    if type(eventName) ~= "string" or type(handler) ~= "function" then return end

    local map = onceHandlers[eventName]
    if not map then
        map = {}
        onceHandlers[eventName] = map
    end

    if map[handler] then
        return
    end

    local function onceWrapper(event, ...)
        Bus:UnregisterEvent(eventName, onceWrapper)
        map[handler] = nil
        safeCall(handler, event, ...)
    end

    map[handler] = onceWrapper
    Bus:RegisterEvent(eventName, onceWrapper)
    return function()
        Bus:UnregisterEvent(eventName, onceWrapper)
    end
end

local function clearHandler(handlerList, handler)
    for i = 1, #handlerList do
        local entry = handlerList[i]
        if entry.fn == handler then
            entry.active = false
            handlerList.dirty = true
        end
    end
end


function BusProto:UnregisterEvent(eventName, handler)
    local handlerList = handlers[eventName]
    if not handlerList or type(handler) ~= "function" then return end

    local proxy = handler
    local map = onceHandlers[eventName]
    if map and map[handler] then
        proxy = map[handler]
        map[handler] = nil
    end

    clearHandler(handlerList, proxy)
    unregisterEvents(eventName, handlerList)
end

function BusProto:UnregisterAll(eventName)
    if type(eventName) ~= "string" then return end
    local handlerList = handlers[eventName]
    if not handlerList then return end
    for i = #handlerList, 1, -1 do
        handlerList[i] = nil
    end
    onceHandlers[eventName] = nil
    unregisterEvents(eventName, handlerList)
end

function BusProto:TriggerEvent(eventName, ...)
    if type(eventName) ~= "string" then return end

    dispatch(frame, eventName, ...)
end

function BusProto:IsRegistered(eventName)
    if type(eventName) ~= "string" then return false end
    local handlerList = handlers[eventName]
    if not handlerList then return false end
    return #handlerList > 0
end

function BusProto:HookSecureFunc(frame, funcName, handler)
    if type(frame) == "string" then
        frame, funcName, handler = _G, frame, funcName
    end

    if type(handler) ~= "function" then return end

    local key = tostring(frame) .. ":" .. tostring(funcName)
    if hookedFuncs[key] then return end
    hookedFuncs[key] = true

    hooksecurefunc(frame, funcName, function(...)
        safeCall(handler, ...)
    end)
end

function BusProto:HookScript(frame, funcName, handler)
    if type(frame) ~= "table" or type(funcName) ~= "string" or type(handler) ~= "function" then return end

    local set = hookedScripts[frame]
    if not set then
        set = {}
        hookedScripts[frame] = set
    end
    if set[funcName] then return end
    set[funcName] = true

    frame:HookScript(funcName, function(...)
        safeCall(handler, ...)
    end)
end

frame:SetScript("OnEvent", dispatch)