local LibStub = LibStub
local error = error

local major, minor = "LibSharedVariables-1.0", 1
if not LibStub then error(major .. " requires LibStub") end

local lib = LibStub:NewLibrary(major, minor)
if not lib then return end

local _G = _G
local next = next
local rawget = rawget
local setmetatable = setmetatable
local type = type

local proto = {}

function proto:__index(key)
    local state = rawget(self, "_state")

    local value = rawget(state.charDB, key)
    if value ~= nil then return value end

    value = rawget(state.accountDB, key)
    if value ~= nil then return value end

    local defaultsPC = state.defaultsPC
    if defaultsPC then
        value = rawget(defaultsPC, key)
        if value ~= nil then return value end
    end

    local defaults = state.defaults
    if defaults then
        value = rawget(defaults, key)
        if value ~= nil then return value end
    end
end

function proto:__newindex(key, value)
    local state = rawget(self, "_state")
    local charDB = state.charDB

    if rawget(charDB, key) ~= nil then
        charDB[key] = value
        return
    end

    local defaultsPC = state.defaultsPC
    if defaultsPC and rawget(defaultsPC, key) ~= nil then
        charDB[key] = value
        return
    end

    local defaults = state.defaults
    if defaults and rawget(defaults, key) ~= nil then
        state.accountDB[key] = value
        return
    end

    charDB[key] = value
end

function proto:__pairs()
    local state = rawget(self, "_state")
    local charDB = state.charDB
    local accountDB = state.accountDB
    local defaultsPC = state.defaultsPC
    local defaults = state.defaults

    local seen = {}
    local phase = 1
    local key

    local function iterator()
        while true do
            if phase == 1 then
                key = next(charDB, key)
                if key ~= nil then
                    seen[key] = true
                    return key, charDB[key]
                end
                phase = 2
                key = nil
            elseif phase == 2 then
                key = next(accountDB, key)
                while key ~= nil and seen[key] do
                    key = next(accountDB, key)
                end
                if key ~= nil then
                    seen[key] = true
                    return key, accountDB[key]
                end
                phase = 3
                key = nil
            elseif phase == 3 then
                if defaultsPC then
                    key = next(defaultsPC, key)
                    while key ~= nil and seen[key] do
                        key = next(defaultsPC, key)
                    end
                    if key ~= nil then
                        seen[key] = true
                        return key, defaultsPC[key]
                    end
                end
                phase = 4
                key = nil
            elseif phase == 4 then
                if defaults then
                    key = next(defaults, key)
                    while key ~= nil and seen[key] do
                        key = next(defaults, key)
                    end
                    if key ~= nil then
                        seen[key] = true
                        return key, defaults[key]
                    end
                end
                return nil
            end
        end
    end

    return iterator, self, nil
end

local proxy = {}
proxy.__index = proxy

function proxy:Get(key, default)
    return self.db[key] or default
end

function proxy:Set(key, value)
    self.db[key] = value
    return value
end

local function validateName(name)
    if type(name) == "string" and name ~= "" then return end
    error(major .. ": invalid \"name\" argument: expected non-empty string, got " .. type(name))
end

local function validateOnLoad(onLoad)
    if onLoad ~= nil and type(onLoad) == "function" then return end
    error(major .. ": invalid \"onLoad\" argument: expected function, got " .. type(onLoad))
end

local function ensureDB(table)
    local t = rawget(_G, table)
    if type(t) == "table" then return t end

    t = {}
    _G[table] = t
    return t
end

lib.handles = lib.handles or {}

function lib:Load(name, defaults, defaultsPC, onLoad)
    validateName(name)
    validateOnLoad(onLoad)

    local charDB = ensureDB(name .. "PCDB")
    local accountDB = ensureDB(name .. "DB")

    local handle = self.handles[name]
    if handle then
        if defaults ~= nil then
            handle.defaults = defaults
        end
        if defaultsPC ~= nil then
            handle.defaultsPC = defaultsPC
        end
        handle.accountDB = accountDB
        handle.charDB = charDB

        local state = handle._state
        state.accountDB = accountDB
        state.charDB = charDB
        if defaults ~= nil then
            state.defaults = defaults
        end
        if defaultsPC ~= nil then
            state.defaultsPC = defaultsPC
        end
        return handle
    end

    local state = {
        accountDB = accountDB,
        charDB = charDB,
        defaults = defaults,
        defaultsPC = defaultsPC,
    }

    handle = setmetatable({
        name = name,
        accountDB = accountDB,
        charDB = charDB,
        defaults = defaults,
        defaultsPC = defaultsPC,
        _state = state,
    }, proxy)

    handle.db = setmetatable({
        _state = state,
    }, proto)

    self.handles[name] = handle

    if onLoad then
        onLoad(handle.db, handle)
    end

    return handle
end
