local Combat = {}

function Combat.Build(Tab, App)
	App.State.Autofarm = {
		Type = "Level",
		Active = false,
	}

	local FarmTab = Tab:Section({
		Title = "Autofamr",
	})

	local LevelAutofarm = FarmTab:Toggle({
		Title = "Level Autofarm",
		Value = App.State.FastAttack.Active,
		Callback = function(Enabled)
			App.State.Autofarm.Type = "Level"
			App.State.Autofarm.Active = true
		end,
	})

	return {
		LevelAutofarm = LevelAutofarm,
	}
end

return Combat
