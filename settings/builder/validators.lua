local _, ns = ...

function ns.builder.noValidator()
    return {
        validate = function(_) return true end,
        normalize = function(text) return text end
    }
end

function ns.builder.inRangeValidator(min, max)
    return {
        validate = function(text)
            local number = tonumber(text)
            return number and number >= min and number <= max
        end,
        normalize = function(text)
            local number = tonumber(text)
            if not number then return tostring(min) end
            if number < min then return tostring(min) end
            if number > max then return tostring(max) end
            return tostring(number)
        end
    }
end
