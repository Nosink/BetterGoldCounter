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
    return self:addControl(ns.builder.CreateCheckBox(self, text, key, params))
end

function section:AddDropDown(text, key, options, params)
    return self:addControl(ns.builder.CreateDropDown(self, text, key, options, params))
end

function section:AddText(text, params)
    return self:addControl(ns.builder.CreateText(self, text, params))
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
