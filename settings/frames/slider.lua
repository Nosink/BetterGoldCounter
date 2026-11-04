local name, ns = ...

local label = {}
local slider = {}
local editBox = {}

local function createLabel(section, text, params)
    local fontString = params and params.fontString or
        ns.builder.fontString(nil, "ARTWORK", "GameFontNormal")
    local offset = params and params.offset or
        ns.builder.offset(0, -8)
    local point = params and params.textPoint or
        ns.builder.point("TOPLEFT", section.anchor, "BOTTOMLEFT", offset.x, offset.y)

    label = section.optionsPanel:CreateFontString(fontString.name, fontString.layer, fontString.template)
    label:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setLabelText(text, params)
    local color = params and params.textColor or
        ns.builder.color(1, 1, 1, 1)
    local size = params and params.size or
        12

    local file, _, flags = label:GetFont()
    label:SetFont(tostring(file), size, flags)
    label:SetTextColor(color.r, color.g, color.b, color.a)
    label:SetText(text)
end

local function createSlider(section, params)
    local offset = params and params.offset or
        ns.builder.offset(10, 0)
    local point = params and params.controlPoint or
        ns.builder.point("LEFT", label, "RIGHT", offset.x, offset.y)

    slider = CreateFrame("Slider", nil, section.optionsPanel, "OptionsSliderTemplate")
    slider:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setValues(params)
    local minValue = params and params.values and params.values.min or
        0
    local maxValue = params and params.values and params.values.max or
        100
    local valueStep = params and params.values and params.values.step or
        1
    local obeyStepOnDrag = params and params.values and params.values.obeyStepOnDrag or
        true

    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(valueStep)
    slider:SetObeyStepOnDrag(obeyStepOnDrag)

    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))
end

local function setWidth(params)
    local width = params and params.width or
        100

    slider:SetWidth(width)
end

local function setEvents(key)
    slider:SetScript("OnValueChanged", function(self, value)
        ns.db[key] = value
        self:SetEditBoxText(value)
        ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)
end

local function setFetch(key)
    slider.Fetch = function(self)
        local value = ns.db[key]
        self:SetValue(value)
        self:SetEditBoxText(value)
    end
end

local function createEditBox(section, params)
    local point = params and params.editBoxPoint or
        ns.builder.point("LEFT", slider, "RIGHT", 10, 0)

    editBox = CreateFrame("EditBox", nil, section.optionsPanel, "InputBoxTemplate")
    editBox:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setEditBoxParams()
    editBox:SetAutoFocus(false)
    editBox:SetJustifyH("CENTER")
    editBox:SetNumeric(true)
    editBox:SetNumericFullRange(true)
    editBox:SetSize(45, 22)
end

local function setEditorBoxValidator(params)
    local minValue, maxValue = slider:GetMinMaxValues()
    local validator = params and params.validator or
        ns.builder.inRangeValidator(minValue, maxValue)

    editBox.validator = validator
end

local function setEditBoxEvents(key)
    ns.bus:HookScript(editBox, "OnShow", function(self)
        self:SetCursorPosition(0)
    end)

    editBox:SetScript("OnEditFocusLost", function(self)
        local text = self:GetText()
        if not self.validator.validate(text) then
            text = self.validator.normalize(text)
            self:SetText(text)
        end
        local value = tonumber(text)
        self:SetSliderValue(value)
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
end

local function linkEditBoxToSlider()
    slider.editBox = editBox
    slider.SetEditBoxText = function(self, value)
        self.editBox:SetText(value)
    end

    editBox.slider = slider
    editBox.SetSliderValue = function(self, value)
        self.slider:SetValue(value)
    end
end

function ns.builder.CreateSlider(section, text, key, params)
    --createLabel(section, text, params)
    --setLabelText(text, params)

    local _, frame = ns.builder.CreateText(section, text, params)
    label = frame

    createSlider(section, params)
    setValues(params)
    setWidth(params)
    setEvents(key)
    setFetch(key)

    createEditBox(section, params)
    setEditBoxParams()
    setEditorBoxValidator(params)
    setEditBoxEvents(key)

    linkEditBoxToSlider()

    section:setAnchor(label)
    return slider
end
