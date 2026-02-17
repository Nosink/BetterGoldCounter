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
local _G = _G

-- Prototype
local proto = {}
proto.__index = proto

-- Public API
function proto:getKey(key, default)
	return self[key] or default
end

function proto:setKey(key, value)
	self[key] = value
end

function proto:init()
	_G[self.dbName] = _G[self.dbName] or {}
	_G[self.pcdbName] = _G[self.pcdbName] or {}

	self.db = setmetatable(_G[self.dbName], { __index = self.defaults or {} })
	self.dbpc = setmetatable(_G[self.pcdbName], { __index = self.defaultsPC or {} })
end

-- Load and Initialization
function proto:load()

	print (major .. " loading " .. self.name)

	self:init()

	if self.combined then
		for k, v in pairs(_G[self.pcdbName]) do
			_G[self.dbName][k] = v
		end
	end

	local ok, err = true, nil
	if self.onLoadCallback then
		ok, err = pcall(function()
			self.onLoadCallback(self.db, self.dbpc)
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
function lib:Load(opts)
	if type(opts) ~= "table" then error(major .. ": opts must be a table") end

	local instance = {
		name = opts.name or error(major .. ": name is required"),
		defaults = opts.defaults or {},
		defaultsPC = opts.defaultsPC or {},
		dbName = opts.dbName or (opts.name .. "DB"),
		pcdbName = opts.pcdbName or (opts.name .. "PCDB"),
		combined = opts.combined or false,
		onLoadCallback = opts.onLoadCallback or nil,
	}

	setmetatable(instance, proto)

	instance:register()
	instance:init()

	return instance
end

