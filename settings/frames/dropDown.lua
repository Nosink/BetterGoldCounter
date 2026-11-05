local name, ns = ...

local function createDropDown(section, settings)
    local dropDown = CreateFrame("Frame", nil, section.optionsPanel, "UIDropDownMenuTemplate")
    dropDown:SetPoint(settings.point.point, settings.point.relativeTo, settings.point.relativePoint, settings.point.x,
        settings.point.y)
    return dropDown
end

local function setWidth(dropDown, settings)
    UIDropDownMenu_SetWidth(dropDown, settings.width)
end

local function setOptions(dropDown, options)
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

local function getTextForValue(dropDown, value)
    for _, opt in ipairs(dropDown.options) do
        if opt.value == value then return opt.text end
    end
    return tostring(value)
end

local function triggerSettingsChanged(key, value)
    ns.db[key] = value
    ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
end

local function setSelection(dropDown, key, value, silent)
    local text = getTextForValue(dropDown, value)
    UIDropDownMenu_SetSelectedValue(dropDown, value)
    UIDropDownMenu_SetText(dropDown, text)
    if not silent then
        triggerSettingsChanged(key, value)
    end
end

local function setFetch(dropDown, key)
    dropDown.Fetch = function(self)
        local value = ns.db[key]
        if value == nil and self.options[1] then
            value = self.options[1].value
        end
        if value ~= nil then
            setSelection(dropDown, key, value, true)
        end
    end
end

local function initialize(dropDown, key)
    local function initFunction(_, level)
        for _, opt in ipairs(dropDown.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text
            info.value = opt.value
            info.func = function()
                setSelection(dropDown, key, opt.value, false)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropDown, initFunction)
end

function ns.builder.CreateDropDown(section, text, key, options, settings)
    local _, label = ns.builder.CreateText(section, text, settings.textSettings)
    settings:SetLabel(label)

    local dropDown = createDropDown(section, settings)
    setWidth(dropDown, settings)
    setOptions(dropDown, options)
    setFetch(dropDown, key)

    initialize(dropDown, key)

    return label, dropDown
end
