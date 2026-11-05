local _, ns = ...

local section = {}
section.__index = section

function section:setAnchor(anchor)
    self.anchor = anchor
    self.builder.anchor = anchor
    self.builder:UpdateContentSize()
end

function section:addControl(control)
    self.controls[#self.controls + 1] = control
    self:setAnchor(self.anchor)
    return control
end

function section:AddCheckBox(text, key, params)
    local anchor, checkBox = ns.builder.CreateCheckBox(self, text, key, params)
    self:setAnchor(anchor)
    return self:addControl(checkBox)
end

function section:AddDropDown(text, key, options, settings)
    if not settings then settings = ns.builder.settings.dropDown:NewSettings({}, self.anchor) end
    local anchor, dropDown = ns.builder.CreateDropDown(self, text, key, options, settings)
    self:setAnchor(anchor)
    return self:addControl(dropDown)
end

function section:AddText(text, settings)
    if not settings then settings = ns.builder.settings.text:NewSettings({}, self.anchor) end
    local anchor, _ = ns.builder.CreateText(self, text, settings)
    self:setAnchor(anchor)
    return self:addControl(anchor)
end

function section:AddEditBox(text, key, settings)
    if not settings then settings = ns.builder.settings.editBox:NewSettings({}, self.anchor) end
    local anchor, editBox = ns.builder.CreateEditBox(self, text, key, settings)
    self:setAnchor(anchor)
    return self:addControl(editBox)
end

function section:AddSlider(text, key, settings)
    local anchor, slider = ns.builder.CreateSlider(self, text, key, settings)
    self:setAnchor(anchor)
    return self:addControl(slider)
end

function section:Fetch()
    for _, control in ipairs(self.controls) do
        if control.Fetch then control:Fetch() end
    end
end

function ns.builder:CreateSection(text, anchor)
    local title = self.optionsPanel.content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", anchor or self.anchor, "BOTTOMLEFT", 0, -8)
    title:SetTextColor(1, 0.82, 0, 1)
    title:SetHeight(30)
    title:SetText(text)
    title:Show()

    local newSection = setmetatable({
        builder = self,
        optionsPanel = self.optionsPanel.content,
        anchor = title,
        controls = {},
    }, section)

    self.optionsPanel.sections[#self.optionsPanel.sections + 1] = newSection
    self.anchor = title
    return newSection
end
