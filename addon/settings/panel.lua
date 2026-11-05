local name, ns = ...

local L = ns.L

local builder = ns.builder

-- Frame
builder:CreateOptionsPanel()

-- Title
builder:CreateTitle(L["LKEY_OPTIONS_TITLE"])

-- Options
local positionSection = builder:CreateSection(L["LKEY_OPTIONS_POSITION_TITLE"])
positionSection:AddCheckBox(L["LKEY_OPTIONS_LOCKED_CB"], "locked")

local backDropSection = builder:CreateSection(L["LKEY_OPTIONS_BACKDROP_TITLE"])
backDropSection:AddCheckBox(L["LKEY_OPTIONS_BACKDROP_CB"], "backdrop")

local sizeSection = builder:CreateSection(L["LKEY_OPTIONS_FONT_SIZE_TITLE"])
sizeSection:AddEditBox(L["LKEY_OPTIONS_FONT_SIZE_EB"], "fontSize",
    builder.settings.editBox:NewSettings({
        isNumeric = true,
        allowDecimals = true,
        validator = builder.inRangeValidator(8, 36)
    }, sizeSection.anchor))
sizeSection:AddDropDown(L["LKEY_OPTIONS_FONT_ALIGNMENT_TITLE"], "fontAlignment", {
        { value = "LEFT",   text = L["LKEY_OPTIONS_FONT_ALIGNMENT_LEFT"] },
        { value = "CENTER", text = L["LKEY_OPTIONS_FONT_ALIGNMENT_CENTER"] },
        { value = "RIGHT",  text = L["LKEY_OPTIONS_FONT_ALIGNMENT_RIGHT"] },
    },
    builder.settings.dropDown:NewSettings({
        width = 75,
    }, sizeSection.anchor))

local widthSection = builder:CreateSection(L["LKEY_OPTIONS_DYNAMIC_WIDTH_TITLE"])
widthSection:AddCheckBox(L["LKEY_OPTIONS_DYNAMIC_WIDTH_CB"], "dynamicWidth")
widthSection:AddEditBox(L["LKEY_OPTIONS_STATIC_WIDTH_EB"], "width",
    builder.settings.editBox:NewSettings({
        validator = builder.inRangeValidator(50, 500), isNumeric = true,
    }, widthSection.anchor))

local fadeSection = builder:CreateSection(L["LKEY_OPTIONS_FADE_TITLE"])
fadeSection:AddCheckBox(L["LKEY_OPTIONS_FADE_CB"], "fade")
fadeSection:AddEditBox(L["LKEY_OPTIONS_FADE_DURATION_EB"], "fadeDuration",
    builder.settings.editBox:NewSettings({
        width = 50, isNumeric = true, allowDecimals = true, validator = builder.inRangeValidator(0, 5)
    }, fadeSection.anchor))
fadeSection:AddSlider(L["LKEY_OPTIONS_FADE_OUT_OPACITY_SLIDER"], "fadeOutOpacity", {
    values = { min = 0, max = 1, step = 0.01 }, width = 150
})
fadeSection:AddSlider(L["LKEY_OPTIONS_FADE_IN_OPACITY_SLIDER"], "fadeInOpacity", {
    values = { min = 0, max = 1, step = 0.01 }, width = 150
})

-- Register
builder:Register()

local function onShow()
    if not ns.db then return end
    builder:Fetch()
end

ns.bus:HookScript(builder.optionsPanel, "OnShow", onShow)
ns.bus:RegisterEvent(name .. "_SETTINGS_CHANGED", onShow)
ns.bus:RegisterEvent(name .. "_VARIABLES_LOADED", onShow)
