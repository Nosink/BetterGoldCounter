local name, ns = ...

function ns.builder.CreateCheckBox(self, text, key, anchor, offset)
    local checkBox = CreateFrame("CheckButton", name .. "Options" .. key .. "CB", self.optionsPanel,
        "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", anchor or self.anchor, "BOTTOMLEFT", offset or 0, 0)
    checkBox:SetChecked(ns.db[key] or false)

    local cbText = _G[checkBox:GetName() .. "Text"]
    local font, _, flags = cbText:GetFont()
    cbText:SetPoint("LEFT", checkBox, "RIGHT", 4, 0)
    cbText:SetFont(tostring(font), 12, flags)
    cbText:SetTextColor(1, 1, 1, 1)
    cbText:SetText(text)

    checkBox:SetScript("OnClick", function(self)
        ns.db[key] = self:GetChecked() or false
        BGCBus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
    end)

    checkBox.FetchFromDB = function(self)
        self:SetChecked(ns.db[key] or false)
    end

    self.anchor = checkBox
    return checkBox
end
