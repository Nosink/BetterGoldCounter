local name, ns = ...

local money = 0
local netChange = 0

local function updateMoney()
    money = GetMoney()
end

local function updateNetChange(difference)
    netChange = netChange + difference
    ns.db.session = netChange
end

local function getDateTime(record)
    return date("*t", record.timestamp)
end

local function ensureDatabase(record)
    local dt = getDateTime(record)

    ns.db.records = ns.db.records or {}
    ns.db.records[dt.year] = ns.db.records[dt.year] or {}
    ns.db.records[dt.year][dt.month] = ns.db.records[dt.year][dt.month] or {}
    ns.db.records[dt.year][dt.month][dt.day] = ns.db.records[dt.year][dt.month][dt.day] or {}
end

local function populateDatabase(record, difference)
    local dt = getDateTime(record)

    local entry = {
        timestamp = record.timestamp,
        money = record.money,
        difference = difference,
    }

    table.insert(ns.db.records[dt.year][dt.month][dt.day], entry)
end

local function onPlayerMoney(_, record)
    local difference = record.money - money

    updateMoney()
    updateNetChange(difference)

    ensureDatabase(record)
    populateDatabase(record, difference)

    ns.bus:TriggerEvent(name .. "_PLAYER_NET_CHANGE", netChange)
end

local function onPlayerEnteringWorld(_, isInitialLogin)
    local session = ns.db.session or 0

    updateMoney()

    if isInitialLogin then
        netChange = 0
    else
        netChange = session
    end

    ns.bus:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
end

ns.bus:RegisterEvent(name .. "_PLAYER_MONEY", onPlayerMoney)
ns.bus:RegisterEvent(name .. "_PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
