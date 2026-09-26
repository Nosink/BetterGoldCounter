local name, ns = ...

function ns.builder:CreateOptionsPanel()
    local optionsPanel = CreateFrame("Frame", name .. "OptionsPanel", UIParent)
    optionsPanel.name = name
    optionsPanel.sections = {}

    local scrollFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -44)
    scrollFrame:SetPoint("BOTTOMRIGHT", -24, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    content:SetPoint("TOPLEFT", 8, 0)
    scrollFrame:SetScrollChild(content)

    local function updateScrollBar()
        local scrollBar = scrollFrame.ScrollBar
        if not scrollBar then return end

        if content:GetHeight() > scrollFrame:GetHeight() then
            scrollBar:Show()
        else
            scrollFrame:SetVerticalScroll(0)
            scrollBar:Hide()
        end
    end

    scrollFrame:SetScript("OnSizeChanged", function(frame)
        content:SetWidth(math.max(frame:GetWidth() - 8, 1))
        updateScrollBar()
    end)
    content:SetScript("OnSizeChanged", updateScrollBar)

    optionsPanel.scrollFrame = scrollFrame
    optionsPanel.content = content
    optionsPanel.updateScrollBar = updateScrollBar
    self.optionsPanel = optionsPanel
    return optionsPanel
end

function ns.builder:CreateTitle(text)
    local title = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -16)

    local file, _, flags = title:GetFont()
    title:SetFont(tostring(file), 20, flags)
    title:SetTextColor(0.2, 0.6, 1, 1)
    title:SetText(text)

    local separator = self.optionsPanel:CreateTexture(nil, "BORDER")
    separator:SetPoint("TOPLEFT", self.optionsPanel, "TOPLEFT", 8, -38)
    separator:SetPoint("TOPRIGHT", self.optionsPanel, "TOPRIGHT", -8, -38)
    separator:SetColorTexture(1, 1, 1, 0.15)
    separator:SetHeight(2)

    self.optionsPanel.content:SetWidth(math.max(self.optionsPanel.scrollFrame:GetWidth() - 8, 1))
    self.anchor = self.optionsPanel.content
    self:UpdateContentSize()
end

function ns.builder:UpdateContentSize()
    local content = self.optionsPanel.content
    local anchor = self.anchor
    if not anchor or not anchor.GetBottom then return end

    local top = content:GetTop()
    local bottom = anchor:GetBottom()
    if top and bottom then
        content:SetHeight(math.max(content:GetHeight(), top - bottom + 16))
    end
    self.optionsPanel.updateScrollBar()
end

function ns.builder:Fetch()
    for _, section in ipairs(self.optionsPanel.sections) do
        section:Fetch()
    end
end

function ns.builder:Register()
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        ns.settingsCategory = Settings.RegisterCanvasLayoutCategory(self.optionsPanel, name)
        Settings.RegisterAddOnCategory(ns.settingsCategory)
    end
end
