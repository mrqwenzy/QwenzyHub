local Combat = {}

function Combat.Build(ConfigTab, Config, SaveConfig)
	local AttackSection = ConfigTab:Section({
		Title = "Attack",
	})

	local FastAttack = AttackSection:Toggle({
		Title = "Fast Attack",
		Flag = "FastAttacket",
		Callback = function(Enabled)
			local Previous = Config.FastAttack
			Config.FastAttack = {
				Active = Enabled,
				LastUse = Previous and Previous.LastUse or 0,
			}

			SaveConfig()
		end,
	})

	return {
		FastAttack = FastAttack,
	}
end

return Combat
