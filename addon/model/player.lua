local name, ns = ...

local money = 0
local netChange = 0

local function updateMoney()
    money = GetMoney()
end

local function setDifference(record, difference)
    local entry = {
        money = record.money,
        difference = difference,
        hour = record.date.hour,
        minute = record.date.minute,
    }
    local year = ns.db.records[record.date.year]
    local month = year["-"][record.date.month]
    local day = month["-"][record.date.monthDay]
    local hour = day["-"][record.date.hour]
    local minute = hour["-"][record.date.minute]

    ns.db.records[record.date.year]["-"][record.date.month]["-"][record.date.monthDay] = entry
end

local function updateNetChange(difference)
    netChange = netChange + difference
end

local function onPlayerMoney(_, record)
    local difference = record.money - money

    updateMoney()
    updateNetChange(difference)
    setDifference(record, difference)

    ns.bus:TriggerEvent(name .. "_PLAYER_NET_CHANGE", netChange)
end

ns.bus:RegisterEvent(name .. "_PLAYER_MONEY", onPlayerMoney)

-- local function fetchSession()
--     local difference = money - session
--     updateSession(difference)
-- end
--
-- local function onPlayerEnteringWorld(_, isInitialLogin)
--     updateMoney()
--     fetchSession()
--
--     ns.bus:TriggerEvent(name .. "_PLAYER_MONEY_CACHED")
-- end
--
-- ns.bus:RegisterEvent(name .. "_PLAYER_ENTERING_WORLD", onPlayerEnteringWorld)
