local _, ns = ...
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

builder:CreateSection(L["LKEY_OPTIONS_BACKDROP_TITLE"])
local backdropCB = builder:CreateCheckBox(L["LKEY_OPTIONS_BACKDROP_CB"], "backdrop")

builder:CreateSection(L["LKEY_OPTIONS_FONT_SIZE_TITLE"])
local fontSizeEB = builder:CreateEditBox(L["LKEY_OPTIONS_FONT_SIZE_EB"], "fontSize")

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
    fontSizeEB:FetchFromDB()
    dynamicWidthCB:FetchFromDB()
    widthEB:FetchFromDB()
    fadeCB:FetchFromDB()
    fadeDurationEB:FetchFromDB()
    fadeOutOpacitySL:FetchFromDB()
    fadeInOpacitySL:FetchFromDB()
end

bus:HookScript(builder.optionsPanel, "OnShow", onShow)