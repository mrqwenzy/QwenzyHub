local Combat = {}

function Combat.Build(Tab, App)
	if App._CombatBuilt then
		return App._CombatBuilt
	end

	App.State.Autofarm = {
		Type = "Level",
		Active = false,
	}

	local RAM = {
		Target = nil,
		CurrentQuest = nil,
		RequiredEnemy = nil,
		Status = "Idle",
	}

	local Services = {
		Players = game:GetService("Players"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		RunService = game:GetService("RunService"),
	}

	local Player = Services.Players.LocalPlayer
	local QuestManager = App.Modules.QuestManager

	-- ============================================================
	-- Detection
	-- ============================================================
	local function GetCurrentQuest()
		return QuestManager.IsActive() and QuestManager.GetState().QuestName or nil
	end

	local function GetRequiredEnemy()
		return QuestManager.GetEnemy()
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
		RAM.Target = enemy
		return enemy
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
	-- Main logic
	-- ============================================================
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

		-- 1. Ensure quest (accept or switch on level-up)
		local action, reason = QuestManager.EnsureQuest()
		if action ~= "none" then
			RAM.Status = action .. ":" .. (reason or "")
			if
				action == "accepted"
				or action == "switched"
				or action == "abandoned_boss"
				or action == "abandoned_for_better"
			then
				RAM.Target = nil
			end
		end

		RAM.CurrentQuest = GetCurrentQuest()
		RAM.RequiredEnemy = GetRequiredEnemy()

		if not RAM.CurrentQuest or not RAM.RequiredEnemy then
			RAM.Status = "NoQuest:" .. (reason or "")
			return
		end

		-- 2. Target
		local target = GetTarget()
		if not target then
			RAM.Status = "NoEnemy:" .. RAM.RequiredEnemy
			return
		end

		-- 3. Move / attack
		local mobRoot = target:FindFirstChild("HumanoidRootPart")
		if not mobRoot then
			RAM.Target = nil
			return
		end

		local dist = (mobRoot.Position - root.Position).Magnitude
		if dist > 8 then
			RAM.Status = "Moving"
			MoveToTarget(target)
		else
			RAM.Status = "Attacking"
			AttackTarget(target)
		end
	end

	-- ============================================================
	-- Heartbeat loop (start/stop via toggle)
	-- ============================================================
	local heartbeatConn = nil
	local lastRun = 0

	local function startLoop()
		if heartbeatConn then
			return
		end
		heartbeatConn = Services.RunService.Heartbeat:Connect(function()
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
	end

	local function stopLoop()
		if heartbeatConn then
			heartbeatConn:Disconnect()
			heartbeatConn = nil
		end
	end

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

			if QuestManager.SetEnabled then
				QuestManager.SetEnabled(Enabled)
			end

			if not Enabled then
				RAM.Target = nil
				RAM.CurrentQuest = nil
				RAM.RequiredEnemy = nil
				RAM.Status = "Idle"
				QuestManager.Reset()
				stopLoop()
			else
				RAM.Status = "Starting"
				startLoop()
			end
		end,
	})

	local result = {
		LevelAutofarm = LevelAutofarm,
		RAM = RAM,
		Update = Update,
	}

	App._CombatBuilt = result
	return result
end

return Combat
