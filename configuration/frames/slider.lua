local name, ns = ...
local LibEvent = LibStub("LibEvent")

function ns.builder.CreateSlider(self, text, key)
    local slider = CreateFrame("Slider", name .. "Options" .. key .. "SL", self.optionsPanel, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", self.anchor, "BOTTOMLEFT", 0, -30)
    slider:SetMinMaxValues(0, 1)
    slider:SetValueStep(0.01)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(ns.database[key] or 0)

    local sText = _G[slider:GetName() .. "Text"]
    if sText then sText:SetText(text) end
    local low = _G[slider:GetName() .. "Low"]
    local high = _G[slider:GetName() .. "High"]
    if low then low:SetText("0.0") end
    if high then high:SetText("1.0") end

    local valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valueText:SetPoint("RIGHT", slider, "RIGHT", 40, 0)
    valueText:SetText(string.format("%.2f", ns.database[key] or "0.00"))

    local function updateValueLabel(v)
        valueText:SetText(string.format("%.2f", v or slider:GetValue()))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        ns.database[key] = value
        updateValueLabel(value)
        LibEvent:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)

    slider.FetchFromDB = function(self)
        self:SetValue(ns.database[key] or 0)
        updateValueLabel(ns.database[key] or 0)
    end

    self.anchor = slider
    return slider
end