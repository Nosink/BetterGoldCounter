local name, ns = ...

local checkBox = {}

local function createCheckBox(section, params)
    local point = params and params.point or
        ns.builder.point("TOPLEFT", section.anchor, "BOTTOMLEFT")

    checkBox = CreateFrame("CheckButton", nil, section.optionsPanel, "InterfaceOptionsCheckButtonTemplate")
    local fontString = checkBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBox:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setText(text, params)
    local point = params and params.textPoint or
        ns.builder.point("LEFT", checkBox, "RIGHT", 4)
    local color = params and params.textColor or
        ns.builder.color(1, 1, 1, 1)
    local size = params and params.size or
        12

    local file, _, flags = checkBox.Text:GetFont()
    checkBox.Text:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
    checkBox.Text:SetFont(tostring(file), size, flags)
    checkBox.Text:SetTextColor(color.r, color.g, color.b, color.a)
    checkBox.Text:SetText(text)
end

local function triggerSettingsChanged(key, value)
    ns.db[key] = value
    ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
end

local function setOnClick(key)
    checkBox:SetScript("OnClick", function(self)
        local value = self:GetChecked() or false
        triggerSettingsChanged(key, value)
    end)
end

local function setFetch(key)
    checkBox.Fetch = function(self)
        self:SetChecked(ns.db[key] or false)
    end
end

function ns.builder.CreateCheckBox(section, text, key, params)
    createCheckBox(section, params)

    setText(text, params)
    setOnClick(key)
    setFetch(key)

    section:setAnchor(checkBox)
    return checkBox
end
