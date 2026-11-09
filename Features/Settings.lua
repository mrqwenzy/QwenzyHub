local Settings = {}

local function AddCustomTheme(WindUI, Name, C)
	WindUI:AddTheme({
		Name = Name,

		Primary = C.Primary,
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),

		Dialog = C.Background,
		Background = C.Background,
		BackgroundTransparency = 0,
		Hover = C.Text,

		PanelBackground = Color3.new(1, 1, 1),
		PanelBackgroundTransparency = 0.95,

		WindowBackground = C.Background,
		WindowShadow = Color3.new(0, 0, 0),

		WindowTopbarTitle = C.Text,
		WindowTopbarAuthor = C.Text,
		WindowTopbarIcon = C.Primary,
		WindowTopbarButtonIcon = C.Primary,
		WindowSearchBarBackground = C.Background,

		TabBackground = C.Text,
		TabBackgroundHover = C.Primary,
		TabBackgroundHoverTransparency = 0.95,
		TabBackgroundActive = C.Primary,
		TabBackgroundActiveTransparency = 0.88,
		TabText = C.Text,
		TabTextTransparency = 0.3,
		TabTextTransparencyActive = 0,
		TabTitle = C.Text,
		TabIcon = C.Primary,
		TabIconTransparency = 0.4,
		TabIconTransparencyActive = 0.1,
		TabBorderTransparency = 1,
		TabBorderTransparencyActive = 0.75,
		TabBorder = C.Text,

		ElementBackground = C.Text,
		ElementBackgroundTransparency = 0.94,
		ElementBackgroundHover = WindUI.Creator:AddColor("ElementBackground", C.ElementHover, 0.1),
		ElementTitle = C.Text,
		ElementDesc = C.Secondary,
		ElementIcon = C.Primary,

		PopupBackground = C.Background,
		PopupBackgroundTransparency = 0,
		PopupTitle = C.Text,
		PopupContent = C.Secondary,
		PopupIcon = C.Primary,

		DialogBackground = C.Background,
		DialogBackgroundTransparency = 0,
		DialogTitle = C.Text,
		DialogContent = C.Secondary,
		DialogIcon = C.Primary,

		Toggle = C.ElementHover,
		ToggleBar = C.Text,

		Checkbox = C.Primary,
		CheckboxIcon = Color3.new(1, 1, 1),
		CheckboxBorder = C.Text,
		CheckboxBorderTransparency = 0.75,

		SliderIcon = C.Primary,
		Slider = C.Primary,
		SliderThumb = Color3.new(1, 1, 1),
		SliderIconFrom = C.Primary,
		SliderIconTo = C.Primary,

		Tooltip = C.ElementHover,
		TooltipText = C.Text,
		TooltipSecondary = C.Primary,
		TooltipSecondaryText = Color3.new(1, 1, 1),

		TabSectionIcon = C.Primary,
		SectionIcon = C.Primary,
		SectionExpandIcon = C.Text,
		SectionExpandIconTransparency = 0.4,

		SectionBox = C.Text,
		SectionBoxTransparency = 0.95,
		SectionBoxBorder = C.Text,
		SectionBoxBorderTransparency = 0.8,
		SectionBoxBackground = C.Text,
		SectionBoxBackgroundTransparency = 0.96,

		SearchBarBorder = C.Text,
		SearchBarBorderTransparency = 0.75,

		Notification = C.Background,
		NotificationTitle = C.Text,
		NotificationTitleTransparency = 0,
		NotificationContent = C.Text,
		NotificationContentTransparency = 0.4,
		NotificationDuration = C.Primary,
		NotificationDurationTransparency = 0.2,
		NotificationBorder = C.Text,
		NotificationBorderTransparency = 0.8,

		DropdownTabBorder = C.Text,

		LabelBackground = C.Text,
		LabelBackgroundTransparency = 0.95,
	})
end

local Themes = {
	Midnight = {
		Background = "#080B18",
		Primary = "#818CF8",
		Text = "#E0E7FF",
		Secondary = "#929BC0",
		ElementHover = "#252B45",
	},

	Crimson = {
		Background = "#100707",
		Primary = "#EF4444",
		Text = "#FEE2E2",
		Secondary = "#B99191",
		ElementHover = "#351313",
	},

	Cyberpunk = {
		Background = "#10051A",
		Primary = "#E879F9",
		Text = "#FAE8FF",
		Secondary = "#C084FC",
		ElementHover = "#351044",
	},

	Emerald = {
		Background = "#06110D",
		Primary = "#10B981",
		Text = "#D1FAE5",
		Secondary = "#86A99B",
		ElementHover = "#123629",
	},

	Dracula = {
		Background = "#191A21",
		Primary = "#BD93F9",
		Text = "#F8F8F2",
		Secondary = "#B6B6C5",
		ElementHover = "#343545",
	},

	Ocean = {
		Background = "#06121C",
		Primary = "#06B6D4",
		Text = "#CFFAFE",
		Secondary = "#8AAEBB",
		ElementHover = "#123344",
	},

	BloodMoon = {
		Background = "#100505",
		Primary = "#B91C1C",
		Text = "#FECACA",
		Secondary = "#B98B8B",
		ElementHover = "#351010",
	},
}

function Settings.Build(Tab, App, WindUI)
	App.ConfigFiles:BuildUI(Tab)

	local ThemeSection = Tab:Section({
		Title = "Appearance",
	})

	ThemeSection:Open()

	-- Register custom themes
	for Name, Colors in pairs(Themes) do
		local Converted = {}

		for Key, Value in pairs(Colors) do
			Converted[Key] = Color3.fromHex(Value)
		end

		AddCustomTheme(WindUI, Name, Converted)
	end

	-- Collect available themes
	local AvailableThemes = WindUI:GetThemes()
	local ThemeNames = {}

	for Name in pairs(AvailableThemes) do
		table.insert(ThemeNames, Name)
	end

	table.sort(ThemeNames)

	assert(#ThemeNames > 0, "WindUI returned no themes")

	local CurrentTheme = WindUI:GetCurrentTheme() or "Dark"

	if not table.find(ThemeNames, CurrentTheme) then
		CurrentTheme = ThemeNames[1]
	end

	local ThemeDropdown = ThemeSection:Dropdown({
		Title = "Theme",
		Values = ThemeNames,
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
