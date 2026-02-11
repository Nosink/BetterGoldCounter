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

-- Internal prototype for instances
local Instance = {}
Instance.__index = Instance

function Instance:GetDB()
	return _G[self.dbName]
end

function Instance:GetPCDB()
	return _G[self.pcdbName]
end

function Instance:Load()
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

function Instance:Init()
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

-- Public API: create a new saved variables instance
-- addonName: string, ns: table (addon namespace), opts: table
-- opts.defaults: table, opts.defaultsPC: table (optional)
-- opts.dbName: string (defaults to addonName .. "DB")
-- opts.pcdbName: string (defaults to addonName .. "PCDB")
function lib:New(addonName, opts)
	if type(addonName) ~= "string" then error(major .. ": addonName must be a string") end
	if type(opts) ~= "table" then error(major .. ": opts must be a table") end

	local instance = {
		addonName = addonName,
		defaults = opts.defaults or {},
		defaultsPC = opts.defaultsPC or {},
		dbName = opts.dbName or (addonName .. "DB"),
		pcdbName = opts.pcdbName or (addonName .. "PCDB"),
		onLoadCallback = opts.onLoadCallback or nil,
	}
	return setmetatable(instance, Instance)
end

