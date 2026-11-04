local _, ns = ...

local function createFontString(section, settings)
    local label = section.optionsPanel:CreateFontString(settings.fontString.name, settings.fontString.layer,
        settings.fontString.template)
    label:SetPoint(settings.point.point, settings.point.relativeTo, settings.point.relativePoint, settings.point.x,
        settings.point.y)
    return label
end

local function setWidth(label, settings)
    if not settings.width then return end
    label:SetWidth(settings.width)
end

local function setText(label, text, settings)
    local file, _, _ = label:GetFont()
    label:SetFont(tostring(file), settings.size, settings.flags)
    label:SetTextColor(settings.color.r, settings.color.g, settings.color.b, settings.color.a)
    label:SetJustifyH(settings.justify.h)
    label:SetJustifyV(settings.justify.v)
    label:SetText(text)
end

function ns.builder.CreateText(section, text, settings)
    local label = createFontString(section, settings)

    setWidth(label, settings)
    setText(label, text, settings)

    return label, label
end
