local Combat = {}

function Combat.Build(ConfigTab, Config, ConfigFiles)
	local AttackSection = ConfigTab:Section({
		Title = "Attack",
	})

	local FastAttack = AttackSection:Toggle({
		Title = "Fast Attack",
		Value = false,
		Callback = function(Enabled)
			local Previous = Config.FastAttack
			Config.FastAttack = {
				Active = Enabled,
				LastUse = Previous and Previous.LastUse or 0,
			}
		end,
	})

	ConfigFiles:Register("Combat.FastAttack", FastAttack, false)

	return {
		FastAttack = FastAttack,
	}
end

return Combat
