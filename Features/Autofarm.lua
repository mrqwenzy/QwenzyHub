-- Combat.lua
local Combat = {}

function Combat.Build(Tab, App)
	-- Settings
	App.State.Autofarm = {
		Type = "Level",
		Active = false,
	}

	-- Runtime data (not saved)
	local RAM = {
		Target = nil,
		CurrentQuest = nil,
		RequiredEnemy = nil,
		Status = "Idle",
		LastKillCheck = 0,
		LastKnownHealth = nil,
	}

	-- Services / references
	local Services = {
		Players = game:GetService("Players"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		RunService = game:GetService("RunService"),
	}

	local Player = Services.Players.LocalPlayer

	-- QuestManager lives in App.Modules
	local QuestManager = App.Modules.QuestManager

	-- ============================================================
	-- Detection
	-- ============================================================
	local function GetCurrentQuest()
		if QuestManager.IsActive() then
			return QuestManager.GetState().QuestName
		end
		return nil
	end

	local function GetRequiredEnemy()
		return QuestManager.GetEnemy()
	end

	local function GetEnemies()
		local out = {}
		local map = workspace:FindFirstChild("Map") or workspace
		for _, mob in ipairs(map:GetDescendants()) do
			if mob:IsA("Model") then
				local hum = mob:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					table.insert(out, mob)
				end
			end
		end
		return out
	end

	local function GetSpawnPositions()
		-- Placeholder — extend if you have a way to detect spawn areas
		return {}
	end

	local function IsValidTarget(target, requiredEnemy)
		return target
			and target.Parent
			and target.Name == requiredEnemy
			and target:FindFirstChildOfClass("Humanoid")
			and target.Humanoid.Health > 0
	end

	local function GetTarget()
		local requiredEnemy = GetRequiredEnemy()
		if not requiredEnemy then
			return nil
		end

		if IsValidTarget(RAM.Target, requiredEnemy) then
			return RAM.Target
		end

		local enemy = QuestManager.FindNearestEnemy()
		if enemy then
			RAM.Target = enemy
			return enemy
		end

		RAM.Target = nil
		return nil
	end

	-- ============================================================
	-- Actions
	-- ============================================================
	local function MoveToTarget(Target)
		local char = Player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local mobRoot = Target and Target:FindFirstChild("HumanoidRootPart")
		if root and mobRoot then
			root.CFrame = CFrame.new(mobRoot.Position + Vector3.new(0, 3, 4))
		end
	end

	local function AttackTarget(Target)
		local char = Player.Character
		if not char then
			return
		end

		local tool = char:FindFirstChildOfClass("Tool")
		if not tool then
			for _, t in ipairs(Player.Backpack:GetChildren()) do
				if t:IsA("Tool") then
					t.Parent = char
					tool = t
					break
				end
			end
		end
		if tool then
			tool:Activate()
		end
	end

	-- ============================================================
	-- Progress detection
	-- ============================================================
	-- Detect a kill by watching the previous target's health go to 0 / despawn.
	local function CheckForKill()
		local target = RAM.Target
		if not target then
			return false
		end

		local hum = target:FindFirstChildOfClass("Humanoid")
		local dead = not target.Parent or not hum or hum.Health <= 0
		if dead then
			RAM.Target = nil
			return true
		end
		return false
	end

	local function Update()
		if not App.State.Autofarm.Active then
			RAM.Status = "Idle"
			return
		end

		local char = Player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			RAM.Status = "NoCharacter"
			return
		end

		-- 1. Ensure quest (handles accept, switch on level-up, completion detection)
		local action, reason = QuestManager.EnsureQuest()
		if action ~= "none" then
			RAM.Status = action .. ":" .. (reason or "")
			if action == "accepted" or action == "switched" then
				RAM.Target = nil
			end
		end

		RAM.CurrentQuest = QuestManager.GetState().QuestName
		RAM.RequiredEnemy = QuestManager.GetEnemy()

		if not RAM.CurrentQuest or not RAM.RequiredEnemy then
			RAM.Status = "NoQuest:" .. (reason or "")
			return
		end

		-- 2. Target
		if
			RAM.Target
			and (
				not RAM.Target.Parent
				or RAM.Target.Name ~= RAM.RequiredEnemy
				or not RAM.Target:FindFirstChildOfClass("Humanoid")
				or RAM.Target.Humanoid.Health <= 0
			)
		then
			RAM.Target = nil
		end

		if not RAM.Target then
			RAM.Target = QuestManager.FindNearestEnemy()
			if not RAM.Target then
				RAM.Status = "NoEnemy:" .. RAM.RequiredEnemy
				return
			end
		end

		-- 3. Move/attack
		local mobRoot = RAM.Target:FindFirstChild("HumanoidRootPart")
		if not mobRoot then
			RAM.Target = nil
			return
		end

		local dist = (mobRoot.Position - root.Position).Magnitude
		if dist > 8 then
			RAM.Status = "Moving"
			MoveToTarget(RAM.Target)
		else
			RAM.Status = "Attacking"
			AttackTarget(RAM.Target)
		end
	end

	-- ============================================================
	-- Heartbeat driver
	-- ============================================================
	local lastRun = 0
	Services.RunService.Heartbeat:Connect(function()
		if not App.State.Autofarm.Active then
			return
		end
		if tick() - lastRun < 0.1 then
			return
		end
		lastRun = tick()

		local ok, err = pcall(Update)
		if not ok then
			RAM.Status = "Error:" .. tostring(err)
		end
	end)

	-- ============================================================
	-- UI
	-- ============================================================
	local FarmTab = Tab:Section({
		Title = "Autofarm",
	})

	local LevelAutofarm = FarmTab:Toggle({
		Title = "Level Autofarm",
		Value = App.State.Autofarm.Active,
		Callback = function(Enabled)
			App.State.Autofarm.Active = Enabled
			App.State.Autofarm.Type = "Level"

			if not Enabled then
				RAM.Target = nil
				RAM.CurrentQuest = nil
				RAM.RequiredEnemy = nil
				RAM.Status = "Idle"
				QuestManager.Reset()
			else
				-- Force fresh pick on next Update
				RAM.Status = "Starting"
				RAM.LastKillCheck = 0
			end
		end,
	})

	return {
		LevelAutofarm = LevelAutofarm,
		RAM = RAM,
		Update = Update,
	}
end

return Combat
