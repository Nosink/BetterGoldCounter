local name, ns = ...

local label = {}
local slider = {}
local editBox = {}

local function createSlider(section, settings)
    local offset = settings and settings.offset or
        ns.builder.offset(10, 0)
    local point = settings and settings.controlPoint or
        ns.builder.point("LEFT", label, "RIGHT", offset.x, offset.y)

    slider = CreateFrame("Slider", nil, section.optionsPanel, "OptionsSliderTemplate")
    slider:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setValues(settings)
    local minValue = settings and settings.values and settings.values.min or
        0
    local maxValue = settings and settings.values and settings.values.max or
        100
    local valueStep = settings and settings.values and settings.values.step or
        1
    local obeyStepOnDrag = settings and settings.values and settings.values.obeyStepOnDrag or
        true

    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(valueStep)
    slider:SetObeyStepOnDrag(obeyStepOnDrag)

    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))
end

local function setWidth(settings)
    local width = settings and settings.width or
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

local function createEditBox(section, settings)
    local point = settings and settings.editBoxPoint or
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

local function setEditorBoxValidator(settings)
    local minValue, maxValue = slider:GetMinMaxValues()
    local validator = settings and settings.validator or
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

function ns.builder.CreateSlider(section, text, key, settings)
    --
    local textSettings = ns.builder.settings.text:NewSettings({
        offset = { x = 0, y = -8 }
    }, section.anchor)

    local _, frame = ns.builder.CreateText(section, text, textSettings)
    label = frame

    createSlider(section, settings)
    setValues(settings)
    setWidth(settings)
    setEvents(key)
    setFetch(key)

    createEditBox(section, settings)
    setEditBoxParams()
    setEditorBoxValidator(settings)
    setEditBoxEvents(key)

    linkEditBoxToSlider()

    return label, slider
end
