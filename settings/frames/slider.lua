local name, ns = ...

local slider = {}

local function createSlider(section, key, params)
    local point = params and params.controlPoint or
        ns.builder.point("TOPLEFT", section.anchor, "BOTTOMLEFT", 0, -30)

    slider = CreateFrame("Slider", name .. "Options" .. key .. "SL", section.optionsPanel, "OptionsSliderTemplate")
    slider:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
    slider:SetMinMaxValues(0, 1)
    slider:SetValueStep(0.01)
    slider:SetObeyStepOnDrag(true)
end

local function setText(text)
    if slider.Text then slider.Text:SetText(text) end
    if slider.Low then slider.Low:SetText("0.0") end
    if slider.High then slider.High:SetText("1.0") end
end

local function createValueText()
    slider.valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.valueText:SetPoint("RIGHT", slider, "RIGHT", 40, 0)
end

local function updateValueText(value)
    slider.valueText:SetText(string.format("%.2f", value or slider:GetValue()))
end

local function setOnValueChanged(key)
    slider:SetScript("OnValueChanged", function(self, value)
        ns.db[key] = value
        updateValueText(value)
        ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)
end

local function setFetch(key)
    slider.Fetch = function(self)
        self:SetValue(ns.db[key] or 0)
        updateValueText(ns.db[key] or 0)
    end
end

function ns.builder.CreateSlider(section, text, key, params)
    createSlider(section, key, params)
    setText(text)
    createValueText()
    setFetch(key)
    setOnValueChanged(key)
    slider:Fetch()

    section:setAnchor(slider)
    return slider
end
