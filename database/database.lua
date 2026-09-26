local name, ns = ...

local _G = _G
local type = type
local next = next
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable

ns.database = {
    defaults = {},
    defaultsPC = {},
}

local prototype = {
    __index = function(self, key)
        local state = rawget(self, "_state")

        local v = rawget(state.charDB, key)
        if v ~= nil then return v end

        v = rawget(state.accountDB, key)
        if v ~= nil then
            return v
        end

        v = state.defaultsPC and rawget(state.defaultsPC, key)
        if v ~= nil then
            return v
        end

        v = state.defaults and rawget(state.defaults, key)
        if v ~= nil then
            return v
        end
    end,

    __newindex = function(self, key, value)
        local state = rawget(self, "_state")

        if state.defaultsPC and rawget(state.defaultsPC, key) ~= nil then
            rawset(state.charDB, key, value)
            return
        end

        if state.defaults and rawget(state.defaults, key) ~= nil then
            rawset(state.accountDB, key, value)
            return
        end

        if rawget(state.charDB, key) ~= nil then
            rawset(state.charDB, key, value)
            return
        end

        if rawget(state.accountDB, key) ~= nil then
            rawset(state.accountDB, key, value)
            return
        end

        rawset(state.charDB, key, value)
    end,

    __pairs = function(self)
        local state = rawget(self, "_state")

        local layers = {}
        layers[#layers + 1] = state.charDB
        layers[#layers + 1] = state.accountDB
        if state.defaultsPC then layers[#layers + 1] = state.defaultsPC end
        if state.defaults then layers[#layers + 1] = state.defaults end

        local seen, i, key = {}, 1, nil

        local function iterator()
            while i <= #layers do
                local layer = layers[i]
                key = next(layer, key)
                while key ~= nil and seen[key] do
                    key = next(layer, key)
                end
                if key ~= nil then
                    seen[key] = true
                    return key, self[key]
                end
                i, key = i + 1, nil
            end
        end

        return iterator, self, nil
    end,
}

local function ensureDB(databaseName)
    local t = rawget(_G, databaseName)
    if type(t) == "table" then return t end

    t = {}
    _G[databaseName] = t
    return t
end

local function isFunction(callback)
    return type(callback) == "function"
end
local function validateCallback(callback)
    assert(callback == nil or isFunction(callback), "onLoad must be a function or nil")
end

function ns.database.Load(callback)
    validateCallback(callback)

    ns.db = setmetatable({
        _state = {
            charDB     = ensureDB(name .. "PCDB"),
            accountDB  = ensureDB(name .. "DB"),
            defaults   = ns.database.defaults,
            defaultsPC = ns.database.defaultsPC,
        }
    }, prototype)

    if isFunction(callback) then callback() end
end

local function evaluate(key, value)
    if value == nil then return end

    error("Duplicate key " .. tostring(key) .. " found in defaults.")
end

local function register(target, source)
    if not source then return end

    for key, value in pairs(source) do
        evaluate(key, target[key])
        target[key] = value
    end
end

function ns.database.Register(defaults, defaultsPC)
    register(ns.database.defaults, defaults)
    register(ns.database.defaultsPC, defaultsPC)
end
