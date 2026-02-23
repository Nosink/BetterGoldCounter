local LibStub = LibStub
local error = error

local major, minor = "LibSavedVariables-1.0", 1
if not LibStub then error(major .. " requires LibStub") end

local lib = LibStub:NewLibrary(major, minor)
if not lib then return end

local pcall = pcall
local geterrorhandler = geterrorhandler
local type = type
local tostring = tostring
local setmetatable = setmetatable
local pairs = pairs
local _G = _G

-- Prototype
local proto = {}
proto.__index = proto

local function copyTable(value)
	if type(value) ~= "table" then
		return value
	end

	local out = {}
	for key, entry in pairs(value) do
		out[key] = copyTable(entry)
	end

	return out
end

local function applyDefaults(target, defaults)
	if type(target) ~= "table" or type(defaults) ~= "table" then
		return
	end

	for key, defaultValue in pairs(defaults) do
		local currentValue = target[key]

		if currentValue == nil then
			if defaultValue ~= nil then
				target[key] = copyTable(defaultValue)
			end
		elseif type(currentValue) == "table" and type(defaultValue) == "table" then
			applyDefaults(currentValue, defaultValue)
		end
	end
end

-- Public API
function proto:GetKey(key, default)
	if type(key) ~= "string" then error(major .. ": key must be a string") end

	local value = self.database[key]
	if value == nil then
		return default
	end

	return value
end

function proto:SetKey(key, value)
	if type(key) ~= "string" then error(major .. ": key must be a string") end

	self.database[key] = value
end

-- Load and Initialization
function proto:initialize()
	_G[self.dbName] = _G[self.dbName] or {}
	self.db = _G[self.dbName]

	_G[self.pcdbName] = _G[self.pcdbName] or {}
	self.dbpc = _G[self.pcdbName]

	applyDefaults(self.db, self.defaults)
	applyDefaults(self.dbpc, self.defaultsPC)

	setmetatable(self.db, { __index = self.defaults or {} })
	setmetatable(self.dbpc, { __index = self.defaultsPC or {} })

	self.database = setmetatable({}, {
		__index = function(_, key)
			local v = self.dbpc[key]
			if v ~= nil then
				return v
			end
			return self.db[key]
		end,
		__newindex = function(_, key, value)
			if self.dbpc[key] ~= nil then
				self.dbpc[key] = value
			elseif self.db[key] ~= nil then
				self.db[key] = value
			else
				self.dbpc[key] = value
			end
		end,
		__pairs = function()
			local seen = {}
			local k1, k2
			return function()
				local v
				k1, v = next(self.dbpc, k1)
				if k1 then
					seen[k1] = true
					return k1, v
				end
				k2, v = next(self.db, k2)
				while k2 and seen[k2] do
					k2, v = next(self.db, k2)
				end
				return k2, v
			end
		end
	})
end

function proto:load()
	self:initialize()

	local ok, err = true, nil
	if self.onLoadCallback then
		ok, err = pcall(function()
			self.onLoadCallback(self.database, self.db, self.dbpc)
		end)
	end

	if not ok then
		geterrorhandler()(tostring(err))
	end
end

function proto:register()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:SetScript("OnEvent", function(_, event)
		if event == "VARIABLES_LOADED" then
			self:load()
		end
	end)
end

-- Api Proxies
function lib:Load(options)
	if type(options) ~= "table" then error(major .. ": opts must be a table") end

	local instance = {
		name = options.name or error(major .. ": name is required"),
		defaults = options.defaults or {},
		defaultsPC = options.defaultsPC or {},
		dbName = options.dbName or (options.name .. "DB"),
		pcdbName = options.pcdbName or (options.name .. "PCDB"),
		onLoadCallback = options.onLoadCallback or nil,
	}

	setmetatable(instance, proto)

	instance:register()
	instance:initialize()

	return instance
end

