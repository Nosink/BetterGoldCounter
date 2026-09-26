local name, ns = ...

local label = {}
local dropDown = {}

local function createLabel(section, params)
    local fontString = params and params.fontString or
        ns.builder.fontString(nil, "ARTWORK", "GameFontNormal")
    local point = params and params.textPoint or
        ns.builder.point("TOPLEFT", section.anchor, "BOTTOMLEFT", 0, -8)

    label = section.anchor:CreateFontString(fontString.name, fontString.layer, fontString.template)
    label:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setText(text, params)
    local color = params and params.textColor or
        ns.builder.color(1, 1, 1, 1)
    local size = params and params.size or
        12

    local file, _, flags = label:GetFont()
    label:SetFont(tostring(file), size, flags)
    label:SetTextColor(color.r, color.g, color.b, color.a)
    label:SetText(text)
end

local function createDropDown(section, key, params)
    local point = params and params.controlPoint or
        ns.builder.point("LEFT", label, "RIGHT", 6)

    dropDown = CreateFrame("Frame", nil, section.anchor, "UIDropDownMenuTemplate")
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
    createLabel(section, params)
    setText(text, params)

    createDropDown(section, key, params)
    setWidth(params)
    setOptions(options)
    setFetch(key)

    initialize(key)

    section:setAnchor(label)
    return dropDown
end
