local name, ns = ...
local L = ns.L

if ns.locale == "esES" or ns.locale == "esMX" then
    L["LKEY_OPTIONS_TITLE"] = name .. " " .. "Opciones"

    L["LKEY_OPTIONS_POSITION_TITLE"] = "Posición"
    L["LKEY_OPTIONS_LOCKED_CB"] = "Bloquear Marco"

    L["LKEY_OPTIONS_BACKDROP_TITLE"] = "Fondo"
    L["LKEY_OPTIONS_BACKDROP_CB"] = "Habilitar Fondo"

    L["LKEY_OPTIONS_DYNAMIC_WIDTH_TITLE"] = "Ancho"
    L["LKEY_OPTIONS_DYNAMIC_WIDTH_CB"] = "Habilitar Ancho Dinámico"
    L["LKEY_OPTIONS_STATIC_WIDTH_EB"] = "Ancho Estático (mín 50): "

    L["LKEY_OPTIONS_FONT_SIZE_TITLE"] = "Tamaño de Fuente"
    L["LKEY_OPTIONS_FONT_SIZE_EB"] = "Tamaño de Fuente (mín 8): "

    L["LKEY_OPTIONS_FADE_TITLE"] = "Desvanecer"
    L["LKEY_OPTIONS_FADE_CB"] = "Habilitar Efecto de Desvanecimiento"
    L["LKEY_OPTIONS_FADE_OUT_OPACITY_SLIDER"] = "Opacidad al Desvanecer"
    L["LKEY_OPTIONS_FADE_IN_OPACITY_SLIDER"] = "Opacidad al Aparecer"
    L["LKEY_OPTIONS_FADE_DURATION_EB"] = "Duración del Desvanecimiento (segundos): "

    L["LKEY_TOTAL_CHAT_HISTORY"] = "Total"
end
