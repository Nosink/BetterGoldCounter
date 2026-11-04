local name, ns = ...

local label = {}
local dropDown = {}

local function createDropDown(section, params)
    local point = params and params.controlPoint or
        ns.builder.point("LEFT", label, "RIGHT", 6, -2)

    dropDown = CreateFrame("Frame", nil, section.optionsPanel, "UIDropDownMenuTemplate")
    dropDown:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setWidth(params)
    local width = params and params.width or
        50
    UIDropDownMenu_SetWidth(dropDown, width)
end

local function setOptions(options)
    local normalizedOptions = {}
    for _, option in ipairs(options) do
        if type(option) == "table" and option.value and option.text then
            table.insert(normalizedOptions, option)
        elseif option ~= nil then
            table.insert(normalizedOptions, {
                value = option,
                text = tostring(option),
            })
        end
    end
    dropDown.options = normalizedOptions
end

local function getTextForValue(value)
    for _, opt in ipairs(dropDown.options) do
        if opt.value == value then return opt.text end
    end
    return tostring(value)
end

local function triggerSettingsChanged(key, value)
    ns.db[key] = value
    ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
end

local function setSelection(key, value, silent)
    local text = getTextForValue(value)
    UIDropDownMenu_SetSelectedValue(dropDown, value)
    UIDropDownMenu_SetText(dropDown, text)
    if not silent then
        triggerSettingsChanged(key, value)
    end
end

local function setFetch(key)
    dropDown.Fetch = function(self)
        local value = ns.db[key]
        if value == nil and self.options[1] then
            value = self.options[1].value
        end
        if value ~= nil then
            setSelection(key, value, true)
        end
    end
end

local function initialize(key)
    local function initFunction(_, level)
        for _, opt in ipairs(dropDown.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text
            info.value = opt.value
            info.func = function()
                setSelection(key, opt.value, false)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropDown, initFunction)
end

function ns.builder.CreateDropDown(section, text, key, options, params)
    --
    local textSettings = ns.builder.settings.text:NewSettings({
        offset = { x = 0, y = -8 }
    }, section.anchor)

    local _, frame = ns.builder.CreateText(section, text, textSettings)
    label = frame

    createDropDown(section, params)
    setWidth(params)
    setOptions(options)
    setFetch(key)

    initialize(key)

    return label, dropDown
end
