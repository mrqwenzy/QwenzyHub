local Settings = {}

function Settings.Build(Tab, App, WindUI)
	App.ConfigFiles:BuildUI(Tab)

	local ThemeSection = Tab:Section({
		Title = "Appearance",
	})

	local Themes = {}
	for Name in pairs(WindUI:GetThemes()) do
		table.insert(Themes, Name)
	end
	table.sort(Themes)
	assert(#Themes > 0, "WindUI returned no themes")

	local CurrentTheme = WindUI:GetCurrentTheme() or "Dark"
	if not table.find(Themes, CurrentTheme) then
		CurrentTheme = Themes[1]
	end

	local ThemeDropdown = ThemeSection:Dropdown({
		Title = "Theme",
		Values = Themes,
		Value = CurrentTheme,
		AllowNone = false,
		Callback = function(Theme)
			WindUI:SetTheme(Theme)
		end,
	})

	App.ConfigFiles:Register("Appearance.Theme", ThemeDropdown, CurrentTheme, {
		Get = function()
			return WindUI:GetCurrentTheme()
		end,
		Set = function(Value)
			ThemeDropdown:Select(Value)
		end,
	})
end

return Settings
