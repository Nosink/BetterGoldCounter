local LibStub = LibStub
local error = error

local major, minor = "LibOptions-1.0", 1
if not LibStub then error(major .. " requires LibStub") end

local bus = LibStub("LibEventBus-1.0")
local optionsBus = bus:NewBus("LibOptionsBus")

local lib = LibStub:NewLibrary(major, minor)
if not lib then return end
