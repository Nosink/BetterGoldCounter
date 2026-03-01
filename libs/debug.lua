local _, ns = ...

local debug = {}

function debug.pairs(table)
    local metaTable = getmetatable(table)

    if metaTable and metaTable.__pairs then
        return metaTable.__pairs(table)
    end

    return pairs(table)
end

function debug.printPairs(t, indent)
    indent = indent or 1
    for k, v in debug.pairs(t) do
        if type(v) == "table" then
            print(string.rep("  ", indent) .. k .. ":")
            debug.printPairs(v, indent + 1)
        else
            print(string.rep("  ", indent) .. k .. " : " .. tostring(v))
        end
    end
end

ns.debug = debug
