local Combat = {}

function Combat.SetFastAttack(Config, SaveConfig, Enabled: boolean)
	local Previous = Config.FastAttack
	Config.FastAttack = {
		Active = Enabled,
		LastUse = Previous and Previous.LastUse or 0,
	}

	SaveConfig()
end

return Combat
