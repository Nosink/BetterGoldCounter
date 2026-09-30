local name, ns = ...

local label = {}
local editBox = {}

local function createLabel(section, text, params)
    local fontString = params and params.fontString or
        ns.builder.fontString(nil, "ARTWORK", "GameFontNormal")
    local point = params and params.textPoint or
        ns.builder.point("TOPLEFT", section.anchor, "BOTTOMLEFT", 0, -4)

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

local function createEditBox(section, key, params)
    local point = params and params.controlPoint or
        ns.builder.point("LEFT", label, "RIGHT", 10, 5)

    editBox = CreateFrame("EditBox", nil, section.optionsPanel, "InputBoxTemplate")
    editBox:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setEditBoxText(key)
    local value = ns.db and ns.db[key]
    editBox:SetText(value == nil and "" or tostring(value))
end

local function setEvents(key)
    editBox:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        ns.db[key] = self:GetText()
        ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
end

local function setSize(params)
    local width = params and params.width or 45
    local height = params and params.height or 22

    editBox:SetAutoFocus(false)
    editBox:SetJustifyH(params and params.justifyH or "CENTER")
    editBox:SetSize(width, height)
end

local function setFetch(key)
    editBox.Fetch = function(self)
        local currentValue = ns.db[key]
        self:SetText(currentValue == nil and "" or tostring(currentValue))
    end
end

function ns.builder.CreateEditBox(section, text, key, params)
    createLabel(section, text, params)
    setLabelText(text, params)

    createEditBox(section, key, params)
    setSize(params)
    setEvents(key)
    setEditBoxText(key)
    setFetch(key)

    section:setAnchor(label)
    return editBox
end
