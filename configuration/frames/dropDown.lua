local name, ns = ...
local bus = LibStub("LibEventBus-1.0")

function ns.builder.CreateDropDown(self, text, key, values, default)
    local label = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", self.anchor, "BOTTOMLEFT", 0, -16)
    local font, _, flags = label:GetFont()
    label:SetFont(tostring(font), 12, flags)
    label:SetTextColor(1, 1, 1, 1)
    label:SetText(" " .. text)

    local dropDown = CreateFrame("Frame", name .. "Options" .. key .. "DD", self.optionsPanel, "UIDropDownMenuTemplate")
    dropDown:SetPoint("LEFT", label, "RIGHT", 10, 0)

    local function normalizeValues(vals)
        local out = {}
        if type(vals) == "table" then
            local isArray = (#vals > 0)
            if isArray then
                for _, v in ipairs(vals) do
                    if type(v) == "table" then
                        table.insert(out, { value = v.value, text = v.text or tostring(v.value) })
                    else
                        table.insert(out, { value = v, text = tostring(v) })
                    end
                end
            else
                for v, t in pairs(vals) do
                    table.insert(out, { value = v, text = tostring(t) })
                end
            end
        end
        return out
    end

    local options = normalizeValues(values or {})

    local function findTextForValue(val)
        for _, opt in ipairs(options) do
            if opt.value == val then return opt.text end
        end
    end

    local function setSelection(val, silent)
        local txt = findTextForValue(val) or tostring(val)
        UIDropDownMenu_SetSelectedValue(dropDown, val)
        UIDropDownMenu_SetText(dropDown, txt)
        if not silent then
            ns.database[key] = val
            bus:TriggerEvent(name .. "_SETTINGS_CHANGED", key)
        end
    end

    UIDropDownMenu_SetWidth(dropDown, 140)

    UIDropDownMenu_Initialize(dropDown, function(self, level)
        for _, opt in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text
            info.value = opt.value
            info.func = function()
                setSelection(opt.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local initial = ns.database[key]
    if initial == nil then initial = default end
    if initial ~= nil then
        setSelection(initial, true)
    elseif options[1] then
        setSelection(options[1].value, true)
    end

    dropDown.FetchFromDB = function(self)
        local v = ns.database[key]
        if v ~= nil then
            setSelection(v, true)
        end
    end

    dropDown.SetOptions = function(self, newValues)
        options = normalizeValues(newValues or {})
        UIDropDownMenu_Initialize(dropDown, function(self, level)
            for _, opt in ipairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = opt.text
                info.value = opt.value
                info.func = function()
                    setSelection(opt.value)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        local v = ns.database[key]
        if v ~= nil then
            setSelection(v, true)
        elseif options[1] then
            setSelection(options[1].value, true)
        end
    end

    dropDown.GetValue = function()
        return UIDropDownMenu_GetSelectedValue(dropDown)
    end

    dropDown.SetValue = function(self, v)
        setSelection(v)
    end

    self.anchor = label
    return dropDown
end