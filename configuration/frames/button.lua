local name, ns = ...

function ns.builder.CreateButton(self, labelText, onClick, buttonText)
	local label = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("TOPLEFT", self.anchor, "BOTTOMLEFT", 0, -16)
	local font, _, flags = label:GetFont()
	label:SetFont(tostring(font), 12, flags)
	label:SetTextColor(1, 1, 1, 1)
	label:SetText(" " .. (labelText or ""))

	local button = CreateFrame("Button", nil, self.optionsPanel, "UIPanelButtonTemplate")
	button:SetPoint("LEFT", label, "RIGHT", 10, 0)
	button:SetSize(140, 22)
	button:SetText(buttonText or labelText or "")

	if type(onClick) == "function" then
		button:SetScript("OnClick", function(btn)
			onClick(btn)
		end)
	end

	button.SetOnClick = function(selfBtn, handler)
		if type(handler) == "function" then
			selfBtn:SetScript("OnClick", function(btn)
				handler(btn)
			end)
		else
			selfBtn:SetScript("OnClick", nil)
		end
	end

	button.FetchFromDB = function() end

	self.anchor = label
	return button
end
