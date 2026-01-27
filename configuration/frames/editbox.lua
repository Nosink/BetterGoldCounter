local name, ns = ...
local LibEvent = LibStub("LibEvent")

function ns.builder.CreateEditBox(self, text, key)
    local label = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", self.anchor, "BOTTOMLEFT", 0, -4)
    local font, _, flags = label:GetFont()
    label:SetFont(tostring(font), 12, flags)
    label:SetTextColor(1, 1, 1, 1)
    label:SetText(" " .. text)

    local editBox = CreateFrame("EditBox", name .. "Options" .. key .. "EB", self.optionsPanel, "InputBoxTemplate")
    editBox:SetPoint("LEFT", label, "RIGHT", 10, 0)
    editBox:SetAutoFocus(false)
    editBox:SetJustifyH("CENTER")
    editBox:SetSize(45, 22)
    editBox:SetText(tostring(ns.database[key]) or "")

    editBox:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        ns.database[key] = self:GetText()
        LibEvent:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    editBox.FetchFromDB = function(self)
        self:SetText(tostring(ns.database[key]))
    end

    self.anchor = label
    return editBox
end