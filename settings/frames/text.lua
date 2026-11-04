local _, ns = ...

local label = {}

local function createFontString(section, settings)
    local fontString = settings and settings.fontString or
        ns.builder.fontString(nil, "ARTWORK", "GameFontNormal")
    local offset = settings and settings.offset or
        ns.builder.offset(0, 0)
    local point = settings and settings.textPoint or
        ns.builder.point("TOPLEFT", section.anchor, "BOTTOMLEFT", offset.x, offset.y)

    label = section.optionsPanel:CreateFontString(fontString.name, fontString.layer, fontString.template)
    label:SetPoint(point.point, point.relativeTo, point.relativePoint, point.x, point.y)
end

local function setText(text, settings)
    local color = settings and settings.textColor or
        ns.builder.color(1, 1, 1, 1)
    local size = settings and settings.size or
        12
    local justifyH = settings and settings.justify and settings.justify.h or
        "LEFT"
    local justifyV = settings and settings.justify and settings.justify.v or
        "TOP"

    local file, _, flags = label:GetFont()
    label:SetFont(tostring(file), size, flags)
    label:SetTextColor(color.r, color.g, color.b, color.a)
    label:SetJustifyH(justifyH)
    label:SetJustifyV(justifyV)
    label:SetText(text)
end

function ns.builder.CreateText(section, text, settings)
    createFontString(section, settings)

    setText(text, settings)

    return label, label
end
