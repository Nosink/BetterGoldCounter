local name, ns = ...

local label = {}
local editBox = {}

local function createEditBox(section, key, params)
    local point = params and params.controlPoint or
        ns.builder.point("LEFT", label, "RIGHT", 10, 0)
    local isNumeric = params and params.isNumeric or
        false
    local allowDecimals = params and params.allowDecimals or
        false

    editBox = CreateFrame("EditBox", nil, section.optionsPanel, "InputBoxTemplate")
    editBox:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
    editBox:SetNumeric(isNumeric)
    if (allowDecimals and isNumeric) then
        editBox:SetNumericFullRange(isNumeric)
    end
end

local function setSize(params)
    local width = params and params.width or
        45
    local height = params and params.height or
        22

    editBox:SetAutoFocus(false)
    editBox:SetJustifyH(params and params.justifyH or "CENTER")
    editBox:SetSize(width, height)
end

local function setValidator(params)
    local validator = params and params.validator or
        ns.builder.noValidator()

    editBox.validator = validator
end

local function setEvents(key)
    ns.bus:HookScript(editBox, "OnShow", function(self)
        self:SetCursorPosition(0)
    end)

    editBox:SetScript("OnEditFocusLost", function(self)
        local text = self:GetText()
        if not self.validator.validate(text) then
            text = self.validator.normalize(text)
            self:SetText(text)
        end
        ns.db[key] = text
        ns.bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
end

local function setFetch(key)
    editBox.Fetch = function(self)
        local value = ns.db and ns.db[key]
        self:SetText(tostring(value))
    end
end

function ns.builder.CreateEditBox(section, text, key, params)
    --
    local textSettings = ns.builder.settings.text:NewSettings({
        offset = { x = 0, y = -10 }, point = params.point
    }, section.anchor)

    local _, frame = ns.builder.CreateText(section, text, textSettings)
    label = frame

    createEditBox(section, key, params)
    setSize(params)
    setValidator(params)
    setEvents(key)
    setFetch(key)

    return label, editBox
end
