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

	App.ConfigFiles:Register("Combat.FastAttack", FastAttack, false)

	return {
		FastAttack = FastAttack,
	}
end

return Combat
