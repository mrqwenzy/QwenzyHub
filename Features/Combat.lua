local Combat = {}

function Combat.Build(Tab, App)
	App.State.FastAttack = App.State.FastAttack or {
		Active = false,
		LastUse = 0,
		Interval = 0.4,
	}

	local AttackSection = Tab:Section({
		Title = "Attack",
	})
	AttackSection:Open()

	local FastAttack = AttackSection:Toggle({
		Title = "Fast Attack",
		Value = App.State.FastAttack.Active,
		Callback = function(Enabled)
			local Previous = App.State.FastAttack

			App.State.FastAttack = {
				Active = Enabled,
				LastUse = Previous.LastUse or 0,
				Interval = Previous.Interval or 0.4,
			}
		end,
	})

	local AttackDelay = AttackSection:Slider({
		Title = "Fast attack interval",
		Value = {
			Min = 0.1,
			Max = 1,
			Default = App.State.FastAttack.Interval,
		},
		Step = 0.01,
		Locked = false,
		Flag = "dointerval",
		Callback = function(Value)
			App.State.FastAttack.Interval = Value
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
