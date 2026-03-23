local name, ns = ...

function ns.builder.CreateButton(self, labelText, onClick, buttonText, size, anchor, offset)
	local label = self.optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("TOPLEFT", anchor or self.anchor, "BOTTOMLEFT", 0, 0)

	local button = CreateFrame("Button", nil, self.optionsPanel, "UIPanelButtonTemplate")
	button:SetPoint("LEFT", anchor, "RIGHT", offset or 0, 0)
	button:SetSize(size.width or 140, size.height or 22)
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
