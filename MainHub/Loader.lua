local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _RAMRemotes = {
	["RE/RegisterHit"] = ReplicatedStorage.Modules.Net["RE/RegisterHit"],
	["RE/RegisterAttack"] = ReplicatedStorage.Modules.Net["RE/RegisterAttack"],
}

local Players = game:GetService("Players")

type ClosestEnemiesConfig = {
	Multi: boolean?,
	Players: boolean?,
	Mobs: boolean?,
	Distance: number?,
}

local function GetClosestEnemies(Config: ClosestEnemiesConfig?)
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
local hitThread = coroutine.create(function()
	local Event = _RAMRemotes["RE/RegisterHit"]
	local token = tostring(Players.LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)

	Event:FireServer(token)

	while true do
		local targetLimb, hitData = coroutine.yield()
		Event:FireServer(targetLimb, hitData, nil, token)
	end
end)

coroutine.resume(hitThread)

local function RegisterAttack()
	_RAMRemotes["RE/RegisterAttack"]:FireServer(0.5, 1)
end
local function SendHit(targetLimb)
	if typeof(targetLimb) ~= "Instance" or not targetLimb:IsA("BasePart") then
		return
	end
	RegisterAttack()
	coroutine.resume(hitThread, targetLimb, {})
end

SendHit(workspace.Enemies:GetChildren()[9].LeftLowerLeg)
