local Players = game:GetService("Players")

type ClosestEnemiesConfig = {
	Multi: boolean?,
	Players: boolean?,
	Mobs: boolean?,
	Distance: number?,
}
-- pls dont hak
local function GetClosestEnemies(Config: ClosestEnemiesConfig)
	Config = Config or {}

	local Multi = Config.Multi or false
	local IncludePlayers = Config.Players or false
	local IncludeMobs = Config.Mobs ~= false
	local Distance = Config.Distance or math.huge

	local Character = Players.LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not Root then
		return nil
	end

	local Enemies = {}

	local function Check(Model)
		if Model == Character then
			return
		end

		local Humanoid = Model:FindFirstChildOfClass("Humanoid")
		local TargetRoot = Model:FindFirstChild("HumanoidRootPart")

		if not Humanoid or not TargetRoot or Humanoid.Health <= 0 then
			return
		end

		local Dist = (Root.Position - TargetRoot.Position).Magnitude

		if Dist <= Distance then
			table.insert(Enemies, {
				Model = Model,
				Distance = Dist,
			})
		end
	end

	if IncludePlayers then
		for _, Player in ipairs(Players:GetPlayers()) do
			if Player ~= Players.LocalPlayer and Player.Character then
				Check(Player.Character)
			end
		end
	end

	if IncludeMobs then
		local Folder = workspace:FindFirstChild("Enemies")
		if Folder then
			for _, Mob in ipairs(Folder:GetChildren()) do
				Check(Mob)
			end
		end
	end

	table.sort(Enemies, function(a, b)
		return a.Distance < b.Distance
	end)

	if Multi then
		return Enemies
	end

	return Enemies[1] and Enemies[1].Model or nil
end

return GetClosestEnemies
