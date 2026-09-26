local _, ns = ...

ns.builder = ns.builder or {}

function ns.builder.point(point, relativeTo, relativePoint, x, y)
    return {
        point = point or "CENTER",
        relativeTo = relativeTo or UIParent,
        relativePoint = relativePoint or "CENTER",
        x = x or 0,
        y = y or 0
    }
end

function ns.builder.color(r, g, b, a)
    r = r or 1
    g = g or 1
    b = b or 1
    a = a or 1

    return { r = r, g = g, b = b, a = a, r, g, b, a }
end

function ns.builder.fontString(name, layer, template)
    return {
        name = name or nil,
        layer = layer or "ARTWORK",
        template = template or "GameFontNormal"
    }
end
