local Combat = {}

function Combat.Build(Tab, App)
	local AttackSection = Tab:Section({
		Title = "Attack",
	})

	local FastAttack = AttackSection:Toggle({
		Title = "Fast Attack",
		Value = false,
		Callback = function(Enabled)
			local Previous = App.State.FastAttack
			App.State.FastAttack = {
				Active = Enabled,
				LastUse = Previous and Previous.LastUse or 0,
			}
		end,
	})

	local AttackDelay = AttackSection:Slider({
		Title = "Fast attack interval",
		Value = {
			Min = 0.1, -- minimum value
			Max = 1, -- maximum value
			Default = 0.4, -- initial value
		},
		Step = 0.01, -- increment step (use 0.1 for floats). optional
		Locked = false, -- disable slider. optional
		Flag = "fastattack", -- for config saving. optional
		Callback = function(value)
			App.State.FastAttack.Interval = value
		end,
	})
	App.ConfigFiles:Register("Combat.FastAttack", FastAttack, false)
	App.ConfigFiles:Register("Combat.AttackDelay", AttackDelay, 0.4)

	return {
		FastAttack = FastAttack,
		AttackDelay = AttackDelay,
	}
end

return Combat
