local name, ns = ...
local bus = LibStub("LibEventBus-1.0")
local L = ns.L

local builder = ns.builder

-- Frame
builder:CreateOptionsPanel()

-- Title
builder:CreateTitle(L["LKEY_OPTIONS_TITLE"])

-- Options
builder:CreateSection(L["LKEY_OPTIONS_POSITION_TITLE"])
local lockedCB = builder:CreateCheckBox(L["LKEY_OPTIONS_LOCKED_CB"], "locked")

builder:CreateButton("Up", function()
    local x, y = ns.settings.GetPosition()
    local newY = y + 1
    ns.settings.SetPosition(x, newY)
    bus:TriggerEvent(name .. "_SETTINGS_CHANGED", "xy")
end)
builder:CreateButton("Down", function()
    local x, y = ns.settings.GetPosition()
    local newY = y - 1
    ns.settings.SetPosition(x, newY)
    bus:TriggerEvent(name .. "_SETTINGS_CHANGED", "xy")
end)
builder:CreateButton("Left", function()
    local x, y = ns.settings.GetPosition()
    local newX = x - 1
    ns.settings.SetPosition(newX, y)
    bus:TriggerEvent(name .. "_SETTINGS_CHANGED", "xy")
end)
builder:CreateButton("Right", function()
    local x, y = ns.settings.GetPosition()
    local newX = x + 1
    ns.settings.SetPosition(newX, y)
    bus:TriggerEvent(name .. "_SETTINGS_CHANGED", "xy")
end)

builder:CreateSection(L["LKEY_OPTIONS_BACKDROP_TITLE"])
local backdropCB = builder:CreateCheckBox(L["LKEY_OPTIONS_BACKDROP_CB"], "backdrop")

builder:CreateSection(L["LKEY_OPTIONS_FONT_SIZE_TITLE"])
local fontSizeEB = builder:CreateEditBox(L["LKEY_OPTIONS_FONT_SIZE_EB"], "fontSize")
local fontAlignmentDD = builder:CreateDropDown(L["LKEY_OPTIONS_FONT_ALIGNMENT_TITLE"], "fontAlignment", {
    { value = "LEFT", text = L["LKEY_OPTIONS_FONT_ALIGNMENT_LEFT"]},
    { value = "CENTER", text = L["LKEY_OPTIONS_FONT_ALIGNMENT_CENTER"]},
    { value = "RIGHT", text = L["LKEY_OPTIONS_FONT_ALIGNMENT_RIGHT"]},
}, "LEFT")

builder:CreateSection(L["LKEY_OPTIONS_SESSION_TITLE"])
local cleanFrequencyDD = builder:CreateDropDown(L["LKEY_OPTIONS_AUTO_CLEAN_TITLE"], "cleanFrequency", {
    { value = "SESSION", text = L["LKEY_OPTIONS_CLEAN_FREQ_SESSION"]},
    { value = "DAILY", text = L["LKEY_OPTIONS_CLEAN_FREQ_DAILY"]},
    { value = "NEVER", text = L["LKEY_OPTIONS_CLEAN_FREQ_NEVER"]},
}, "LEFT")

builder:CreateSection(L["LKEY_OPTIONS_DYNAMIC_WIDTH_TITLE"])
local dynamicWidthCB = builder:CreateCheckBox(L["LKEY_OPTIONS_DYNAMIC_WIDTH_CB"], "dynamicWidth")
local widthEB = builder:CreateEditBox(L["LKEY_OPTIONS_STATIC_WIDTH_EB"], "width")

builder:CreateSection(L["LKEY_OPTIONS_FADE_TITLE"])
local fadeCB = builder:CreateCheckBox(L["LKEY_OPTIONS_FADE_CB"], "fade")
local fadeDurationEB =  builder:CreateEditBox(L["LKEY_OPTIONS_FADE_DURATION_EB"], "fadeDuration")
local fadeOutOpacitySL = builder:CreateSlider(L["LKEY_OPTIONS_FADE_OUT_OPACITY_SLIDER"], "fadeOutOpacity")
local fadeInOpacitySL = builder:CreateSlider(L["LKEY_OPTIONS_FADE_IN_OPACITY_SLIDER"], "fadeInOpacity")

-- Register
builder:Register()

local function onShow()
    lockedCB:FetchFromDB()
    backdropCB:FetchFromDB()
    fontAlignmentDD:FetchFromDB()
    fontSizeEB:FetchFromDB()
    cleanFrequencyDD:FetchFromDB()
    dynamicWidthCB:FetchFromDB()
    widthEB:FetchFromDB()
    fadeCB:FetchFromDB()
    fadeDurationEB:FetchFromDB()
    fadeOutOpacitySL:FetchFromDB()
    fadeInOpacitySL:FetchFromDB()
end

bus:HookScript(builder.optionsPanel, "OnShow", onShow)