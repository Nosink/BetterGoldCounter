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
function proto:GetDB()
	return _G[self.dbName]
end

-- Get Per-Character Database
function proto:GetPCDB()
	return _G[self.pcdbName]
end

-- Load and Initialization
function proto:Load()
	_G[self.dbName] = setmetatable(_G[self.dbName] or {}, { __index = self.defaults or {} })

	if self.pcdbName then
		_G[self.pcdbName] = setmetatable(_G[self.pcdbName] or {}, { __index = self.defaultsPC or {} })
	end

	local ok, err = true, nil
	if self.onLoadCallback then
		ok, err = pcall(function()
			self.onLoadCallback(self:GetDB(), self:GetPCDB())
		end)
	end
	if not ok then
		geterrorhandler()(tostring(err))
	end
end

function proto:Init()
	-- Ensure tables exist and are usable immediately
	_G[self.dbName] = _G[self.dbName] or {}
	setmetatable(_G[self.dbName], { __index = self.defaults or {} })

	if self.pcdbName then
		_G[self.pcdbName] = _G[self.pcdbName] or {}
		setmetatable(_G[self.pcdbName], { __index = self.defaultsPC or {} })
	end

	-- Also handle the official VARIABLES_LOADED event for consistency
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:SetScript("OnEvent", function(_, event)
		if event == "VARIABLES_LOADED" then
			self:Load()
		end
	end)
	return self
end

-- Api Proxies
function lib:New(opts)
	if type(opts) ~= "table" then error(major .. ": opts must be a table") end

	local instance = {
		defaults = opts.defaults or {},
		defaultsPC = opts.defaultsPC or {},
		dbName = opts.dbName or ("Database"),
		pcdbName = opts.pcdbName or ("DatabasePerCharacter"),
		onLoadCallback = opts.onLoadCallback or nil,
	}
	return setmetatable(instance, proto)
end

