local name, ns = ...

local _G = _G
local type = type
local pcall = pcall
local tostring = tostring
local setmetatable = setmetatable
local geterrorhandler = geterrorhandler

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

local frame = CreateFrame("Frame")
local subscribers = {}

frame:SetScript("OnEvent", function(_, event, ...)
    local list = subscribers[event]
    if not list then return end
    for i = 1, #list do
        list[i]:dispatch(event, ...)
    end
end)

local function subscribeNative(bus, event)
    local list = subscribers[event]
    if list then
        for i = 1, #list do
            if list[i] == bus then return true end
        end
        list[#list + 1] = bus
        return true
    end

    local ok = pcall(frame.RegisterEvent, frame, event)
    if not ok then return false end

    subscribers[event] = { bus }
    return true
end

local function unsubscribeNative(bus, event)
    local list = subscribers[event]
    if not list then return end

    for i = #list, 1, -1 do
        if list[i] == bus then
            table.remove(list, i)
            break
        end
    end

    if #list == 0 then
        subscribers[event] = nil
        pcall(frame.UnregisterEvent, frame, event)
    end
end

local proto = {}
proto.__index = proto

local function newBus(busName, safe)
    return setmetatable({
        name         = busName or "UnnamedBus",
        handlers     = {},
        onceHandlers = {},
        nativeEvents = {},
        safe         = safe ~= false,
    }, proto)
end

function proto:registerEvent(event)
    local list = self.handlers[event]
    if list then return list end

    list = {}
    self.handlers[event] = list

    if subscribeNative(self, event) then
        self.nativeEvents[event] = true
    end

    return list
end

function proto:unregisterEvent(event, list)
    if #list > 0 then return end

    self.handlers[event] = nil

    if self.nativeEvents[event] then
        unsubscribeNative(self, event)
        self.nativeEvents[event] = nil
    end

    self.onceHandlers[event] = nil
end

function proto:dispatch(event, ...)
    local list = self.handlers[event]
    if not list then return end

    local call = self.safe and safeCall or fastCall

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

    self:unregisterEvent(event, list)
end

function proto:clearHandler(event, fn)
    local list = self.handlers[event]
    if not list then return end

    for i = 1, #list do
        local entry = list[i]
        if entry.fn == fn then
            entry.active = false
            list.dirty = true
        end
    end
end

function proto:RegisterEvent(event, fn)
    if type(event) ~= "string" or type(fn) ~= "function" then return end

    local list = self:registerEvent(event)

    for i = 1, #list do
        if list[i].fn == fn then
            return
        end
    end

    local entry = { fn = fn, active = true }
    list[#list + 1] = entry

    local bus = self
    return function()
        bus:UnregisterEvent(event, fn)
    end
end

function proto:RegisterEventOnce(event, fn)
    if type(event) ~= "string" or type(fn) ~= "function" then return end

    local map = self.onceHandlers[event]
    if not map then
        map = {}
        self.onceHandlers[event] = map
    end

    if map[fn] then return end

    local bus = self
    local function wrapper(evt, ...)
        bus:UnregisterEvent(event, wrapper)
        map[fn] = nil
        safeCall(fn, evt, ...)
    end

    map[fn] = wrapper
    self:RegisterEvent(event, wrapper)

    return function()
        bus:UnregisterEvent(event, wrapper)
    end
end

function proto:UnregisterEvent(event, fn)
    local list = self.handlers[event]
    if not list or type(fn) ~= "function" then return end

    local proxy = fn
    local map = self.onceHandlers[event]
    if map and map[fn] then
        proxy = map[fn]
        map[fn] = nil
    end

    self:clearHandler(event, proxy)
    self:unregisterEvent(event, list)
end

function proto:UnregisterAll(event)
    local list = self.handlers[event]
    if not list then return end

    for i = 1, #list do
        list[i] = nil
    end

    self.onceHandlers[event] = nil
    self:unregisterEvent(event, list)
end

function proto:TriggerEvent(event, ...)
    self:dispatch(event, ...)
end

function proto:IsRegistered(event)
    local list = self.handlers[event]
    return list and #list > 0 or false
end

function proto:HookSecureFunc(...)
    return ns.HookSecureFunc(...)
end

function proto:HookScript(...)
    return ns.HookScript(...)
end

local hookedFuncs = {}
local hookedScripts = setmetatable({}, { __mode = "k" })

function ns.HookSecureFunc(frame, funcName, handler)
    if type(frame) == "string" then
        frame, funcName, handler = _G, frame, funcName
    end
    if type(handler) ~= "function" then return end

    local key = tostring(frame) .. ":" .. tostring(funcName)
    if hookedFuncs[key] then return end
    hookedFuncs[key] = true

    hooksecurefunc(frame, funcName --[[@as string]], function(...)
        safeCall(handler, ...)
    end)
end

function ns.HookScript(frame, script, handler)
    if type(frame) ~= "table" or type(handler) ~= "function" then return end

    local set = hookedScripts[frame]
    if not set then
        set = {}
        hookedScripts[frame] = set
    end
    if set[script] then return end
    set[script] = true

    frame:HookScript(script, function(...)
        safeCall(handler, ...)
    end)
end

ns.bus = newBus(name, true)

function ns.bus:NewBus(...)
    return newBus(...)
end
