local name, ns = ...

ns.builder = ns.builder or {}

function ns.builder.CreateOptionsPanel(self)
    local optionsPanel = CreateFrame("Frame", name .. "OptionsPanel", UIParent)
    optionsPanel.name = name
    self.optionsPanel = optionsPanel
end

function ns.builder.CreateTitle(self, text)
    local title = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -16)
    local fontName, _, flags = title:GetFont()
    title:SetFont(tostring(fontName), 18, flags)
    title:SetTextColor(0.2, 0.6, 1, 1)
    title:SetText(text)

    local body = CreateFrame("Frame", nil, self.optionsPanel)
    body:SetPoint("TOPLEFT", 16, -38)
    body:SetSize(1, 1)

    local separator = body:CreateTexture(nil, "BORDER")
    separator:SetPoint("TOPLEFT", self.optionsPanel, "TOPLEFT", 8, -38)
    separator:SetPoint("TOPRIGHT", self.optionsPanel, "TOPRIGHT", -8, -38)
    separator:SetColorTexture(1, 1, 1, 0.15)
    separator:SetHeight(2)

    self.anchor = body
end

function ns.builder.CreateSection(self, text)
    local title = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", self.anchor, "BOTTOMLEFT", 0, -8)
    title:SetTextColor(1, 0.82, 0, 1)
    title:SetHeight(30)
    title:SetText(text)
    title:Show()

    self.anchor = title
end

function ns.builder.Register(self)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        ns.settingsCategory = Settings.RegisterCanvasLayoutCategory(self.optionsPanel, name)
        Settings.RegisterAddOnCategory(ns.settingsCategory)
    end
end