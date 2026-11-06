-- Script path: game:GetService("ReplicatedStorage").Modules.CombatUtil
-- Decompile time: 26.53 ms

local v1
game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

require(game.ReplicatedStorage.Modules.AnimationUtil)

local WeaponData = require(game.ReplicatedStorage.Modules.WeaponData)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Net = require(game.ReplicatedStorage.Modules.Net)
local GetBoundingBoxCustom = require(game.ReplicatedStorage.Modules.Part.GetBoundingBoxCustom)
local GetCornersOfPart = require(game.ReplicatedStorage.Modules.Part.GetCornersOfPart)
local u58 = {}
local LocalPlayer = game.Players.LocalPlayer
local Enemies = workspace.Enemies
local Characters = workspace.Characters
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local HighlightAdornee = require(game.ReplicatedStorage.Util.HighlightAdornee)
local u80 = RunService:IsServer()
local u81 = {}
local u85 = setmetatable({}, { __mode = "k" })
local u86 = nil
local u87 = nil

task.defer(function() -- Line: 23; upvalues: u86 (ref), u87 (ref), u81 (val), Net (val)
	u86 = require(game.ReplicatedStorage.Util)
	u87 = require(script.Particle)
	u81.RegisterHitEvent = Net:RemoteEvent("RegisterHit", true)
	u81.ReceivedHit = Net:RemoteEvent("ReceivedHit")
end)

function u58.GetPureWeaponName(a1, a2) -- Line: 30
	return string.lower(string.gsub(a2, "%s", ""))
end

function u58.GetComboPaddingTime(a1) -- Line: 41
	return 0.3
end

function u58.GetDefaultAOEDelay(a1) -- Line: 46
	return 0.35
end

function u58.GetAttackCancelMultiplier(a1) -- Line: 53
	return 0.8
end

local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)

function u58.HasRigEquipped(a1, a2) -- Line: 59; upvalues: IsTransformed (val)
	if a2:FindFirstChild("HumanoidRootPart") and a2.HumanoidRootPart:FindFirstChild("Buddha") then
		return false
	end

	if a2:FindFirstChild("DogHouseForm") then
		return false
	end

	return IsTransformed(a2, false, false)
end

function u58.CanAttack(a1, a2, a3) -- Line: 79; upvalues: u58 (val)
	local v1 = require(game.ReplicatedStorage.Global).tapCooldown or 0

	if os.clock() < v1 then
		return
	end

	local Humanoid = a2 and a2:FindFirstChildWhichIsA("Humanoid")

	if Humanoid and not (Humanoid.Health <= 0) then
		local Stun = a2:FindFirstChild("Stun")
		local Busy = a2:FindFirstChild("Busy")

		if not Humanoid.Sit then
			if Stun and 0 < Stun.Value then
				return
			end

			if Busy and Busy.Value then
				return
			end

			if u58:HasRigEquipped(a2) then
				return
			end

			return true
		end

		if a3 ~= "Sword" and a3 ~= "Melee" and a3 ~= "Gun" then
			if Stun and 0 < Stun.Value then
				return
			end

			if Busy and Busy.Value then
				return
			end

			if u58:HasRigEquipped(a2) then
				return
			end

			return true
		end
	end
end

function u58.IsVulnerable(a1, a2) -- Line: 94; upvalues: RunService (val), Players (val)
	if not a2 then
		return
	end

	local v1 = 0 < (a2 and a2:FindFirstChildWhichIsA("Humanoid")).Health

	if RunService:IsServer() then
		local v2 = require(game.ReplicatedStorage.Global).getWrappedPlayer(Players:GetPlayerFromCharacter(a2))

		if v2 and v2:dodging() then
			return false
		end
	end

	return v1
end

function u58.GetRigOfHitPart(a1, a2) -- Line: 110; upvalues: Enemies (val), Characters (val)
	local v1 = a2:FindFirstAncestorWhichIsA("Tool")

	if v1 then
		return v1.Parent
	end

	local v2 = { Enemies, Characters }
	local v3 = nil
	local v4 = nil

	for i, j in v2, v3, v4 do
		for k, n in j:GetChildren() do
			if v5:IsDescendantOf(n) then
				return n
			end
		end
	end
end

local u105 = false
local u106 = nil
local u124 = {}

for i, j in
	{
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"UpperTorso",
		"LowerTorso",
		"Head",
		"ModelHitbox",
	}
do
	u124[j] = true
end

function removeFromTableBackwards(a1, a2) -- Line: 140
	local v1
	local v2, v3 = a1, a2

	repeat
		v1 = table.find(v2, v3)

		if v1 then
			table.remove(v2, v1)
		end
	until not v1
end

function u58.GetHitDetectionParams(a1) -- Line: 159; upvalues: u105 (ref), u106 (ref)
	if u105 then
		return u106
	end

	u106 = OverlapParams.new()
	u105 = true

	return u106
end

local u140 = {}

function u58.ToggleLoadMovesetAnims(a1, a2, a3, a4) -- Line: 177; upvalues: u58 (val), u140 (val), u86 (ref)
	local Looped, v1, v2, v3
	local v4 = not (a3.WeaponType ~= "Gun") and a3.Moveset or a3.Moveset.Basic
	local v5 = nil
	local v6 = nil

	for i, j in v4, v5, v6 do
		v1 = if not a3.Moveset.Basic
			then (u58:GetPureWeaponName(a3.Name)) .. "-" .. i
			else (u58:GetPureWeaponName(a3.Name)) .. "-basic" .. i

		if a4 then
			if not u140[a2] then
				u140[a2] = {}
			end

			Looped = j.Looped
			v3 = u86.Anims:Get(a2.Parent, j.AnimationId)

			if v3 then
				v3._Object.Name = v1

				if not string.match(v1, "Idle") then
					v3._Object.Looped = Looped
					v3._Object.Priority = Enum.AnimationPriority.Action

					v3._Object:SetAttribute("SpeedMult", j.SpeedMult)
				else
					v3._Object.Looped = true
				end

				u140[a2][v1] = v3
			end
		elseif u140[a2] then
			v2 = u140[a2][v1]

			if v2 then
				v2:Stop()

				if typeof(v2) ~= "Instance" then
					v2.Animation:Destroy()
				else
					v2:Destroy()
				end
			end

			v3 = u140[a2]
			v3[v1] = nil

			if not next(u140[a2]) then
				u140[a2] = nil
			end
		end
	end
end

function u58.GetMovesetAnimCache(a1, a2) -- Line: 256; upvalues: u140 (val)
	return u140[a2]
end

function u58.GetLoadedAnimsFor(a1, a2, a3) -- Line: 260; upvalues: u58 (val)
	local v1 = u58:GetPureWeaponName(a2)
	local v2 = {}
	local MovesetAnimCache = u58:GetMovesetAnimCache(a3)

	if MovesetAnimCache then
		local v3, v4

		for i, j in MovesetAnimCache do
			v3, v4 = string.match(i, "(.+)-(.+)")

			if v3 == v1 then
				v2[v4] = j
			end
		end
	end

	return v2
end

function u58.AttackStart(a1, a2, a3) -- Line: 279; upvalues: u58 (val), Enemies (val), LocalPlayer (val), u86 (ref)
	if a2 and a2.Parent then
		local Humanoid = a2.Parent:FindFirstChild("Humanoid")
		local RootPart = Humanoid

		if RootPart then
			RootPart = Humanoid.RootPart
		end

		local Parent = RootPart

		if Parent then
			Parent = RootPart.Parent
		end

		if not Parent then
			return
		end

		local Effect = require(game.ReplicatedStorage.Effect)
		local EquippedWeapon = Parent:FindFirstChild("EquippedWeapon")
		local WeaponName = u58:GetWeaponName(EquippedWeapon or a2)
		local PureWeaponName = u58:GetPureWeaponName(WeaponName)
		local WeaponData = u58:GetWeaponData(WeaponName)
		local Moveset = WeaponData.Moveset

		assert(Moveset.Basic, (("Couldn't find the 'Basic' moveset for %*"):format(WeaponName)))

		local u220 = Moveset.Basic[a3]
		local VFXDelay = WeaponData.VFXDelay or u220.VFXDelay
		local v1 = Parent:IsDescendantOf(Enemies)

		if EquippedWeapon then
			for i, j in EquippedWeapon:GetDescendants() do
				if not j:IsA("Trail") then
					if j.Name == "HitEffect" and j:IsA("ParticleEmitter") then
						task.delay(VFXDelay or 0.25, function() -- Line: 312; upvalues: j (val)
							j:Emit((j:GetAttribute("EmitCount")) or 1)
						end)
					end
				elseif PureWeaponName ~= "dragontalon" then
					j.Enabled = true
				elseif j.Name == "HitEffect" and j:IsA("ParticleEmitter") then
					task.delay(VFXDelay or 0.25, function() -- Line: 312; upvalues: j (val)
						j:Emit((j:GetAttribute("EmitCount")) or 1)
					end)
				end
			end

			local v2 = LocalPlayer and Parent ~= LocalPlayer.Character

			if v1 or v2 then
				task.delay(0.75, function() -- Line: 320; upvalues: EquippedWeapon (val)
					for i, j in EquippedWeapon:GetDescendants() do
						if j:IsA("Trail") then
							j.Enabled = false
						end
					end
				end)
			end
		end

		if PureWeaponName == "superhuman" or PureWeaponName == "godhuman" then
			task.delay(0.25, function() -- Line: 331; upvalues: Effect (val), Parent (val), PureWeaponName (val)
				(Effect.new("Chop.Punch")):play({ Character = Parent, God = PureWeaponName == "godhuman" })
			end)
		elseif PureWeaponName == "divineart" then
			task.defer(function() -- Line: 338; upvalues: Effect (val), RootPart (val), a3 (val)
				(Effect.new("Angel.M1")):play({ hrp = RootPart, index = a3 })
			end)
		elseif PureWeaponName == "flail" then
			task.delay(0.3, function() -- Line: 345; upvalues: Effect (val), Parent (val)
				(Effect.new("Chop.Punch")):play({ God = true, Character = Parent })
			end)
		elseif PureWeaponName == "dragontalon" then
			task.defer(function() -- Line: 352; upvalues: Effect (val), RootPart (val), a3 (val)
				task.delay(0.25, function() -- Line: 353; upvalues: Effect (upval), RootPart (upval), a3 (upval)
					(Effect.new("DragonTalon.M1")):play({ Root = RootPart, Index = a3 })
				end)
			end)
		elseif PureWeaponName == "sanguineart" then
			task.defer(function() -- Line: 361; upvalues: Effect (val), RootPart (val), a3 (val)
				(Effect.new("Ghoul.M1")):play({ Root = RootPart, Combo = a3 })
			end)
		elseif PureWeaponName == "sharkmankarate" then
			task.defer(function() -- Line: 368; upvalues: Effect (val), Parent (val), Humanoid (val), a3 (val)
				(Effect.new("Sharkman2.M1")):play({ Character = Parent, Humanoid = Humanoid, Combo = a3 })
			end)
		elseif PureWeaponName == "fishmankarate" then
			task.defer(function() -- Line: 376; upvalues: Effect (val), Parent (val), Humanoid (val), a3 (val)
				(Effect.new("WaterKungfu.M1")):play({ Character = Parent, Humanoid = Humanoid, Combo = a3 })
			end)
		elseif PureWeaponName == "anchor" then
			task.defer(function()
				-- Line: 384
				-- upvalues: EquippedWeapon (val), a3 (val), u86 (upval), Parent (val), LocalPlayer (upval)
				local Animation = Instance.new("Animation")
				Animation.AnimationId = "rbxassetid://14798724768"
				local Animation_2 = Instance.new("Animation")
				Animation_2.AnimationId = "rbxassetid://14798726082"
				local Animation_3 = Instance.new("Animation")
				Animation_3.AnimationId = "rbxassetid://14798728487"
				local Animation_4 = Instance.new("Animation")
				Animation_4.AnimationId = "rbxassetid://14798729807"
				local v1 = { Animation, Animation_2, Animation_3, Animation_4 }

				EquippedWeapon.Right.Anchor.AnimationController:LoadAnimation(v1[a3]):Play()

				task.delay(0.2, function() -- Line: 396; upvalues: u86 (upval), Parent (upval)
					u86.Sound:Play("SwordSwing", Parent.HumanoidRootPart)
				end)

				if a3 == 4 and Parent == LocalPlayer.Character then
					task.delay(0.2, function() -- Line: 402; upvalues: u86 (upval), Parent (upval)
						local v1 = Parent;
						(u86.BodyMover.new(v1)):Create("BodyVelocity", {
							Duration = 0.15,
							Velocity = Parent.HumanoidRootPart.CFrame.lookVector * 100,
						})
					end)
				end
			end)
		end

		local PushDelay = u220.PushDelay
		local PushForce = u220.PushForce

		if PushDelay or PushForce then
			task.delay(
				PushDelay or 0.2,
				function() -- Line: 413; upvalues: u86 (upval), Parent (val), RootPart (val), PushForce (val)
					(u86.BodyMover.new(Parent)):Create("BodyVelocity", {
						Duration = 0.15,
						Velocity = RootPart.CFrame.LookVector * PushForce,
					})
				end
			)
		end

		task.delay(PushDelay or 0.2, function() -- Line: 419; upvalues: u86 (upval), WeaponData (val), RootPart (val)
			u86.Sound:Play(WeaponData.SwingSound or "SwordSwing", RootPart)
		end)

		local AOEDelay = u220.AOEDelay
		local AOEDistanceFromCharacter = u220.AOEDistanceFromCharacter

		if AOEDelay then
			if not u220.CustomAOEVFX then
				task.delay(AOEDelay or u58:GetDefaultAOEDelay(), function()
					-- Line: 426
					-- upvalues: u86 (upval), RootPart (val), AOEDistanceFromCharacter (val), Enemies (upval)
					-- upvalues: u220 (val), Effect (val), Parent (val)
					local v1
					local Ray = u86.Ray
					local v2 = RootPart.CFrame * Vector3.new(0, 0, -(AOEDistanceFromCharacter or 7.5))
					local v3 = { workspace.Characters, Enemies }
					v1, v2 = Ray(v2, Vector3.new(0, -4, 0), v3)

					if v1 and not u220.CustomAOEEffect then
						(Effect.new("Rubber.Transformed.Axe")):play({ Character = Parent, Position = v2 })
					end
				end)
			end
		elseif AOEDistanceFromCharacter and not u220.CustomAOEVFX then
			task.delay(AOEDelay or u58:GetDefaultAOEDelay(), function()
				-- Line: 426
				-- upvalues: u86 (upval), RootPart (val), AOEDistanceFromCharacter (val), Enemies (upval)
				-- upvalues: u220 (val), Effect (val), Parent (val)
				local v1
				local Ray = u86.Ray
				local v2 = RootPart.CFrame * Vector3.new(0, 0, -(AOEDistanceFromCharacter or 7.5))
				local v3 = { workspace.Characters, Enemies }
				v1, v2 = Ray(v2, Vector3.new(0, -4, 0), v3)

				if v1 and not u220.CustomAOEEffect then
					(Effect.new("Rubber.Transformed.Axe")):play({ Character = Parent, Position = v2 })
				end
			end)
		end
	end
end

function u58.CanCharacterMeleeAoe(a1, a2) -- Line: 439
	local HumanoidRootPart = a2 and a2:FindFirstChild("HumanoidRootPart")

	if HumanoidRootPart and HumanoidRootPart:FindFirstChild("Buddha") then
		return 10
	end

	return 1
end

local u152 = coroutine.create(function() -- Line: 454; upvalues: u81 (val)
	local success, err = pcall(function() -- Line: 455; upvalues: u81 (upval)
		local v1, v2

		repeat
			task.wait()
		until u81.RegisterHitEvent

		local v3 = (tostring(game.Players.LocalPlayer.UserId):sub(2, 4))
			.. (tostring((coroutine.running())):sub(11, 15))
		u81.RegisterHitEvent:FireServer(v3)

		while true do
			v1, v2 = coroutine.yield()
			u81.RegisterHitEvent:FireServer(v1, v2, nil, v3)
		end
	end)

	if not success then
		warn(err)
	end
end)

if not u80 then
	local Global = require(game.ReplicatedStorage.Global)

	function Global.checkHits() -- Line: 472
	end

	local Global_2 = require(game.ReplicatedStorage.Global)

	function Global_2.SendHitsToServer(...) -- Line: 475; upvalues: u152 (val)
		require(game.ReplicatedStorage.Global).checkHits(...)
		coroutine.resume(u152, ...)
	end

	coroutine.resume(u152)
end

local u169 = {}

local function registerHit(a1, a2, a3, a4, a5)
	-- Line: 483
	-- upvalues: u80 (val), u169 (val), Flags (val), u152 (val), u81 (val), u58 (val)
	if u80 then
		require(game.ServerScriptService.Services.CombatService):RegisterHit(a1, a3)
		return
	end

	if a5 then
		for k, v in pairs(a5) do
			table.insert(u169, v)
		end

		table.insert(u169, { a2, a3 })
	end

	if a1 == true then
		if #u169 > 0 then
			if not Flags.COMBAT_REMOTE_THREAD then
				u81.RegisterHitEvent:FireServer(table.remove(u169, 1)[2], u169)
			else
				coroutine.resume(u152, table.remove(u169, 1)[2], u169)
			end
		end

		table.clear(u169)
	end

	if a1 ~= true then
		u58:ApplyDamageHighlight(a2, a1, a4.Name, a4.WeaponType, a3)
	end
end

function u58.GetAttackAngle(a1, a2, a3) -- Line: 516
	return (
		math.acos(
			(
				a2.HumanoidRootPart.CFrame.LookVector:Dot(
					(a3.HumanoidRootPart.Position - a2.HumanoidRootPart.Position).unit
				)
			)
		)
	)
end

function u58.RunHitDetection(a1, a2, a3, a4)
	-- Line: 522
	-- upvalues: Players (val), u58 (val), Enemies (val), Characters (val), u106 (ref), RunService (val), u81 (val)
	-- upvalues: u85 (val), u124 (val), registerHit (val), Flags (val), GetBoundingBoxCustom (val)
	-- upvalues: GetCornersOfPart (val), u80 (val)
	local CFrame_2, Character, Character_2, HitboxMagnitude, HitboxMagnitude_2, HitboxMagnitude_3, PlayerFromCharacter_2, Position, Position_3, Position_4, Size_3, _workspace_4, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17
	local Parent = a2.Parent
	local PlayerFromCharacter = Players:GetPlayerFromCharacter(Parent)
	local HumanoidRootPart = Parent.HumanoidRootPart
	local UpperTorso = Parent.UpperTorso
	local RightFoot = Parent.RightFoot
	local Humanoid = Parent.Humanoid
	local EquippedWeapon = Parent:FindFirstChild("EquippedWeapon") or u58:GetEquippedWeaponTool(Parent)
	local WeaponName = u58:GetWeaponName(EquippedWeapon)
	local WeaponData = u58:GetWeaponData(WeaponName)
	local v18 = WeaponData.WeaponType == "Melee"
	local u1480 = EquippedWeapon:IsDescendantOf(Enemies)

	if u1480 then
		u1480 = not Parent:FindFirstChild("Summoner")
	end

	local Summoner = Parent:FindFirstChild("Summoner")
	local Basic = WeaponData.Moveset.Basic

	assert(Basic, (("Couldn't find the 'Basic' moveset for %*"):format(WeaponName)))

	if Basic[a3].AOEDelay ~= nil then
		return
	end

	local v19 = {}

	if not v18 then
		v1 = a4
	else
		v1 = a4

		for i, j in Parent:GetChildren() do
			if j:HasTag("WeaponHitbox") or j:HasTag("Blade") then
				table.insert(v19, j)
			end
		end
	end

	for k, n in EquippedWeapon:GetDescendants() do
		if n:HasTag("WeaponHitbox") or n:HasTag("Blade") then
			table.insert(v19, n)
		end
	end

	if not PlayerFromCharacter then
		u106.IncludeInstances = { Characters, Enemies }
	else
		local v20 = game.CollectionService:GetTagged("M1HitRegistry")
		table.insert(v20, Characters)
		table.insert(v20, Enemies)

		u106.IncludeInstances = v20
	end

	local u149 = {}
	local u150 = {}
	local u151 = {}
	local u158 = u58:CanCharacterMeleeAoe(Parent)

	local function tryToRegisterHit(a1)
		-- Line: 579
		-- upvalues: u58 (upval), RunService (upval), u151 (val), u81 (upval), u85 (upval), u124 (upval), Parent (val)
		-- upvalues: PlayerFromCharacter (val), WeaponData (val), HumanoidRootPart (val), u1480 (val), u150 (val)
		-- upvalues: u158 (val), u149 (val), registerHit (upval)
		local Position, Position_2, RigOfHitPart, Summoner, Summoner_2, v1, v2, v3, v4, v5
		local dispatch = 0

		while true do
			if not (dispatch < 30) then
				if not (dispatch < 31) then
					return v1, v2
				end

				registerHit(Parent, v1, v2, WeaponData, u149)

				dispatch = 31
			elseif dispatch < 29 then
				v1 = nil
				v2 = nil
				v3 = a1
				v4 = nil
				v5 = nil
				local dispatchExit = nil

				for k, n in v3, v4, v5 do
					local dispatch2 = 1

					while true do
						if dispatch2 < 14 then
							if dispatch2 < 7 then
								if dispatch2 < 4 then
									if dispatch2 < 2 then
										RigOfHitPart = u58:GetRigOfHitPart(n)
										dispatch2 = if RigOfHitPart then 8 else 2
									else
										dispatch2 = if dispatch2 < 3
											then if not n:HasTag("M1HitRegistry") then 6 else 3
											else if not RunService:IsClient() then 6 else 4
									end
								elseif dispatch2 < 5 then
									if u151[n] then
										break
									else
										dispatch2 = 5
									end
								elseif dispatch2 < 6 then
									u151[n] = true
									u81.RegisterHitEvent:FireServer(n)
									break
								elseif u85[n] then
									break
								else
									dispatch2 = 7
								end
							elseif dispatch2 < 10 then
								if dispatch2 < 8 then
									u85[n] = true
									warn("No rig found for hit part:", n)
									break
								elseif not (dispatch2 < 9) then
									Summoner = RigOfHitPart:FindFirstChild("Summoner")
									Summoner_2 = Parent:FindFirstChild("Summoner")
									dispatch2 = if not Summoner_2 then 11 else 10
								elseif not u124[n.Name] then
									break
								else
									dispatch2 = 9
								end
							elseif dispatch2 < 12 then
								if not (dispatch2 < 11) then
									dispatch2 = if not PlayerFromCharacter then 14 else 12
								elseif RigOfHitPart == Summoner_2.Value.Character then
									break
								else
									dispatch2 = 11
								end
							elseif dispatch2 < 13 then
								dispatch2 = if not Summoner then 14 else 13
							elseif Summoner.Value == PlayerFromCharacter then
								break
							else
								dispatch2 = 14
							end
						elseif dispatch2 < 21 then
							if dispatch2 < 17 then
								if dispatch2 < 15 then
									dispatch2 = if not WeaponData.ValidateFrontHits then 16 else 15
								elseif dispatch2 < 16 then
									Position = HumanoidRootPart.CFrame.Position
									Position_2 = RigOfHitPart.PrimaryPart.CFrame.Position

									if 1.3 < (u58:GetAttackAngle(Parent, RigOfHitPart)) then
										break
									else
										dispatch2 = 16
									end
								else
									dispatch2 = if not u1480 then 20 else 17
								end
							elseif dispatch2 < 19 then
								dispatch2 = if dispatch2 < 18
									then if not RigOfHitPart:IsDescendantOf(workspace.Enemies) then 20 else 18
									else if Summoner_2 then 20 else 19
							elseif dispatch2 < 20 then
								if not Summoner then
									break
								else
									dispatch2 = 20
								end
							elseif RigOfHitPart == Parent then
								break
							else
								dispatch2 = 21
							end
						elseif dispatch2 < 24 then
							if not (dispatch2 < 22) then
								if not (dispatch2 < 23) then
									table.insert(u150, RigOfHitPart)

									v1 = RigOfHitPart
									v2 = n
									break
								end

								dispatch2 = if v1 then 24 else 23
							elseif not u58:IsVulnerable(RigOfHitPart) then
								break
							else
								dispatch2 = 22
							end
						elseif not (dispatch2 < 26) then
							if not (dispatch2 < 27) then
								table.insert(u149, { RigOfHitPart, n })

								table.insert(u150, RigOfHitPart)
								break
							end

							if table.find(u150, n.Parent) then
								break
							else
								dispatch2 = 27
							end
						elseif dispatch2 < 25 then
							if not (#u150 < u158) then
								break
							else
								dispatch2 = 25
							end
						elseif n.Parent == v1 then
							break
						else
							dispatch2 = 26
						end
					end

					if dispatchExit then
						break
					end
				end

				dispatch = 29
			else
				dispatch = if not v1 then 31 else 30
			end
		end
	end

	local u1391 = nil
	local u1395 = nil

	if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
		u1391 = Instance.new("Part")
		u1391.Name = "BroadphaseHitboxPart"
		u1391.BrickColor = BrickColor.new("Bright red")
		u1391.Transparency = 0.8
		u1391.CanCollide = false
		u1391.CanTouch = false
		u1391.CanQuery = false
		u1391.Anchored = true
		u1391.Parent = workspace
	end

	local v21 = false
	local Buddha2 = Parent.HumanoidRootPart:FindFirstChild("Buddha2")

	if Buddha2 or Parent.HumanoidRootPart:FindFirstChild("Buddha") then
		v21 = true
	end

	local v22 = HumanoidRootPart.Size.Y * 0.5 + Humanoid.HipHeight + 0.5
	local v23 = nil
	local v24 = {}
	local Length = v1._Object.Length
	local v25 = 0

	while v25 < Length do
		if not v1._Object.IsPlaying or v23 then
			break
		end

		v25 = v25 + task.wait()

		if EquippedWeapon and not EquippedWeapon:IsDescendantOf(workspace) then
			break
		end

		if not (v25 < 0.13) then
			CFrame_2 = HumanoidRootPart.CFrame
			Position = CFrame_2.Position
			v3 = CFrame_2 * Vector3.new(UpperTorso.Size.X, 0, 0)
			v4 = math.clamp(v25 / Length, 0, 1)
			v5 = v4 * v22
			v5 = v3:Lerp(
				Vector3.new(Position.X, (RightFoot.Position - Vector3.new(0, RightFoot.Size.Y * 0.5, 0)).Y, Position.Z),
				v4
			)
			v7, v8 = GetBoundingBoxCustom(v19)
			v6 = { CFrame = v7, Size = v8 }
			v8 = GetCornersOfPart(v6)
			v7 = { v3, v5, unpack(v8) }
			v11 = #v24
			v9 = #v24 + 1 - 30

			for m = v11, v9, -1 do
				v6 = v24[m]

				if v6 then
					for i5, i6 in v6 do
						table.insert(v7, CFrame_2 * i6)
					end
				end
			end

			v5 = {}

			for i7, i8 in v8 do
				table.insert(v5, (CFrame_2:ToObjectSpace(i8)))
			end

			table.insert(v24, v5)

			v9, v10 = GetBoundingBoxCustom(v7)
			v9 = v9 * (CFrame_2 - Position)
			v10 = v10 * (1 / math.clamp(HumanoidRootPart:GetAttribute("CharacterSizeScaleNumber") or 1, 1, 999))
			v8 = u1480 and not Summoner

			if v8 then
				v10 = v10 * 0.5
			end

			v7 = HumanoidRootPart.Size * (HumanoidRootPart:GetAttribute("HrpSizeScale") or 1)

			if v21 then
				if not v18 then
					v10 = Vector3.new(v10.X, math.max(v7.Y * 4, v10.Y), v10.Z)
				else
					v10 = Vector3.new(10.625, 7.5, 10) * v7.Y / 2
					HitboxMagnitude = WeaponData.HitboxMagnitude

					if HitboxMagnitude then
						v10 = v10 * (1 + (HitboxMagnitude - 2) * 0.1)
					end

					if Buddha2 then
						v10 = v10 * Vector3.new(1, 1, 0.875)
					end

					v9 = HumanoidRootPart.CFrame * CFrame.new(0, -v10.Y * 0.125, -v10.Z / 3.25)
				end
			end

			if u1391 then
				u1391.CFrame = v9
				u1391.Size = v10
			end

			v4 = workspace:GetPartBoundsInBox(v9, v10, u106)

			if v21 and v18 == false then
				v10 = Vector3.new(10.625, 7.5, 10) * v7.Y / 2
				HitboxMagnitude_2 = WeaponData.HitboxMagnitude

				if HitboxMagnitude_2 then
					v10 = v10 * (1 + (HitboxMagnitude_2 - 2) * 0.1)
				end

				if Buddha2 then
					v10 = v10 * Vector3.new(1, 1, 0.875)
				end

				v9 = HumanoidRootPart.CFrame * CFrame.new(0, -v10.Y * 0.125, -v10.Z / 3.25)

				if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES and not u1395 then
					u1395 = Instance.new("Part")
					u1395.Name = "BroadphaseHitboxPart"
					u1395.BrickColor = BrickColor.new("Bright red")
					u1395.Transparency = 0.8
					u1395.CanCollide = false
					u1395.CanTouch = false
					u1395.CanQuery = false
					u1395.Anchored = true
					u1395.CFrame = v9
					u1395.Size = v10
					u1395.Parent = workspace
				end

				if u1395 then
					u1395.CFrame = v9
					u1395.Size = v10
				end

				for k2, v in pairs(workspace:GetPartBoundsInBox(v9, v10, u106)) do
					table.insert(v4, v)
				end
			end

			v12, v13 = tryToRegisterHit(v4)
			v23 = v12
			v11 = v13

			if v23 then
				v7 = Players:GetPlayerFromCharacter(v23)

				if not u80 or not v7 then
					break
				end

				Position_3 = v11.Position

				for i17, i18 in Players:GetPlayers() do
					Character = i18.Character

					if
						i18 ~= PlayerFromCharacter
						and Character
						and (Character:GetPivot().Position - Position_3).Magnitude <= 300
					then
						u81.ReceivedHit:FireClient(v7, v23, Character, WeaponData.Name, WeaponData.WeaponType, v11)
					end
				end

				break
			end

			if not v21 then
				v13 = nil
				v14 = nil

				for i9, i10 in v19, v13, v14 do
					Size_3 = i10.Size

					if not v8 then
						HitboxMagnitude_3 = WeaponData.HitboxMagnitude

						if HitboxMagnitude_3 then
							Size_3 = Size_3 + Vector3.new(1, 1, 1) * HitboxMagnitude_3
						end

						if v18 then
							Size_3 = Size_3 + Vector3.new(2, 2, 2)
						end

						if Parent.HumanoidRootPart:FindFirstChild("Buddha2") then
							Size_3 = Size_3 * 1.5
						elseif Parent.HumanoidRootPart:FindFirstChild("Buddha") then
							Size_3 = Size_3 * 1.2
						end

						v2 = Vector3.new(math.max(3, Size_3.X), math.max(3, Size_3.Y), (math.max(3, Size_3.Z)))
					else
						v2 = Size_3 * 0.5
					end

					if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
						local Part = Instance.new("Part")
						Part.BrickColor = BrickColor.new("Bright red")
						Part.Transparency = 0.5
						Part.CanCollide = false
						Part.CanTouch = false
						Part.CanQuery = false
						Part.Anchored = true
						Part.CFrame = i10.CFrame
						Part.Size = v2
						Part.Parent = workspace

						task.delay(0, function() -- Line: 865; upvalues: Part (val)
							Part:Destroy()
						end)
					end

					_workspace_4 = workspace
					v17 = u106
					v15, v16 = tryToRegisterHit((_workspace_4:GetPartBoundsInBox(i10.CFrame, v2, v17)))
					v23 = v15
					v11 = v16

					if v23 then
						PlayerFromCharacter_2 = Players:GetPlayerFromCharacter(v23)

						if not u80 or not PlayerFromCharacter_2 then
							break
						end

						Position_4 = v11.Position

						for i11, i12 in Players:GetPlayers() do
							Character_2 = i12.Character

							if
								i12 ~= PlayerFromCharacter
								and Character_2
								and (Character_2:GetPivot().Position - Position_4).Magnitude <= 300
							then
								u81.ReceivedHit:FireClient(
									PlayerFromCharacter_2,
									v23,
									Character_2,
									WeaponData.Name,
									WeaponData.WeaponType,
									v11
								)
							end
						end

						break
					end
				end
			elseif v18 == false then
				v13 = nil
				v14 = nil

				for i13, i14 in v19, v13, v14 do
					Size_3 = i14.Size

					if not v8 then
						HitboxMagnitude_3 = WeaponData.HitboxMagnitude

						if HitboxMagnitude_3 then
							Size_3 = Size_3 + Vector3.new(1, 1, 1) * HitboxMagnitude_3
						end

						if v18 then
							Size_3 = Size_3 + Vector3.new(2, 2, 2)
						end

						if Parent.HumanoidRootPart:FindFirstChild("Buddha2") then
							Size_3 = Size_3 * 1.5
						elseif Parent.HumanoidRootPart:FindFirstChild("Buddha") then
							Size_3 = Size_3 * 1.2
						end

						v2 = Vector3.new(math.max(3, Size_3.X), math.max(3, Size_3.Y), (math.max(3, Size_3.Z)))
					else
						v2 = Size_3 * 0.5
					end

					if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
						local Part = Instance.new("Part")
						Part.BrickColor = BrickColor.new("Bright red")
						Part.Transparency = 0.5
						Part.CanCollide = false
						Part.CanTouch = false
						Part.CanQuery = false
						Part.Anchored = true
						Part.CFrame = i14.CFrame
						Part.Size = v2
						Part.Parent = workspace

						task.delay(0, function() -- Line: 865; upvalues: Part (val)
							Part:Destroy()
						end)
					end

					_workspace_4 = workspace
					v17 = u106
					v15, v16 = tryToRegisterHit((_workspace_4:GetPartBoundsInBox(i14.CFrame, v2, v17)))
					v23 = v15
					v11 = v16

					if v23 then
						PlayerFromCharacter_2 = Players:GetPlayerFromCharacter(v23)

						if not u80 or not PlayerFromCharacter_2 then
							break
						end

						Position_4 = v11.Position

						for i15, i16 in Players:GetPlayers() do
							Character_2 = i16.Character

							if
								i16 ~= PlayerFromCharacter
								and Character_2
								and (Character_2:GetPivot().Position - Position_4).Magnitude <= 300
							then
								u81.ReceivedHit:FireClient(
									PlayerFromCharacter_2,
									v23,
									Character_2,
									WeaponData.Name,
									WeaponData.WeaponType,
									v11
								)
							end
						end

						break
					end
				end
			end
		end
	end

	if PlayerFromCharacter == game.Players.LocalPlayer then
		registerHit(true)
	end

	if Flags.NEW_COMBAT_SYSTEM_VISUALIZE_HITBOXES then
		task.delay(0.1, function() -- Line: 900; upvalues: u1391 (ref)
			u1391:Destroy()
		end)

		if u1395 then
			task.delay(0.1, function() -- Line: 904; upvalues: u1395 (ref)
				u1395:Destroy()
			end)
		end
	end
end

local function toCamelCase(a1) -- Line: 916
	return (string.lower(a1:sub(1, 1))) .. a1:sub(2, #a1)
end

local function toPascalCase(a1) -- Line: 920
	return (string.upper(a1:sub(1, 1))) .. a1:sub(2, #a1)
end

local function removeSpaces(a1) -- Line: 924
	return string.gsub(a1, "%s", "")
end

function u58.GetWeaponData(a1, a2) -- Line: 928; upvalues: u58 (val), WeaponData (val)
	local v1
	local v2 = {}
	local PureWeaponName = u58:GetPureWeaponName(a2)
	local v3 = string.gsub(a2, "%s", "")
	local v4 = string.lower(a2)
	local v5 = (string.lower(a2:sub(1, 1))) .. a2:sub(2, #a2)
	local v6 = string.upper(a2:sub(1, 1))
	local v7 = #a2
	v2[1] = a2
	v2[2] = PureWeaponName
	v2[3] = v3
	v2[4] = v4
	v2[5] = v5
	v2[6] = v6 .. a2:sub(2, v7)

	for i, j in v2 do
		v1 = WeaponData[j]

		if v1 then
			return v1
		end
	end
end

function u58.GetWeaponName(a1, a2) -- Line: 946; types: a1: table, a2: userdata
	return a2:GetAttribute("WeaponName") or a2.Name
end

function u58.GetWeaponModel(a1, a2, a3) -- Line: 950; upvalues: u58 (val)
	local PureWeaponName = u58:GetPureWeaponName(a3)

	for i, j in a2:GetChildren() do
		if u58:GetPureWeaponName(j.Name) == PureWeaponName then
			return j
		end
	end
end

function u58.GetEquippedWeaponTool(a1, a2) -- Line: 959
	for i, j in a2:GetChildren() do
		if j:IsA("Tool") then
			if not j:HasTag("MeleeTool") and not j:HasTag("GunTool") then
				continue
			end

			return j
		end
	end
end

function u58.CreateShootAngles(a1, a2) -- Line: 967
	if a2.NoSpread then
		return { { Angle = CFrame.Angles(0, 0, 0) } }
	end

	local u10 = {}
	local u13 = Random.new(a2.Seed)
	local v1 = a2.BulletSpreadCount or 7
	local u17 = a2.BulletSpreadDegree or 12

	local function addAngle() -- Line: 978; upvalues: u13 (val), u17 (val), u10 (val)
		table.insert(u10, {
			Angle = CFrame.Angles(
				math.rad((u13:NextNumber(-u17 / 2, u17 / 2))),
				math.rad((u13:NextNumber(-u17 / 2, u17 / 2))),
				(math.rad((u13:NextNumber(-u17 / 2, u17 / 2))))
			),
		})
	end

	if a2.BulletSpreadCount == 1 then
		addAngle()
		return u10
	end

	table.insert(u10, { Angle = CFrame.Angles(0, 0, 0) })

	local v2 = v1 - 1

	for i = 1, v2 do
		addAngle()
	end

	return u10
end

function u58.GetToolOfWeaponType(a1, a2, a3) -- Line: 1001; upvalues: Players (val)
	local PlayerFromCharacter = Players:GetPlayerFromCharacter(a2)

	if PlayerFromCharacter then
		for i, j in PlayerFromCharacter.Backpack:GetChildren() do
			if j:IsA("Tool") and j:GetAttribute("WeaponType") == a3 then
				return j
			end
		end
	end

	local Tool = a2:FindFirstChildWhichIsA("Tool")

	if Tool and Tool:GetAttribute("WeaponType") == a3 then
		return Tool
	end
end

function u58.PlayMeleeHitParticles(a1, a2, a3, a4) -- Line: 1018; upvalues: u58 (val), u87 (ref)
	task.defer(function() -- Line: 1019; upvalues: a3 (val), a2 (val), u58 (upval), a4 (val), u87 (upval)
		local Position = a3 and a3.Position or a2:GetPivot().Position
		local WeaponData = u58:GetWeaponData(a4)

		u87.play("Hit", Position, WeaponData)
	end)
end

function u58.ApplyDamageHighlight(a1, a2, a3, a4, a5, a6, a7)
	-- Line: 1027
	-- upvalues: u58 (val), Players (val), Enemies (val), TweenService (val), WrapHighlight (val)
	-- upvalues: HighlightAdornee (val)
	local Attribute, Attribute_2, Attribute_3, Data, Data_2, Highlight, PlayerFromCharacter, PlayerFromCharacter_2, Value, Value_2, u463, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12
	local dispatch = 0

	while true do
		if dispatch < 54 then
			if dispatch < 27 then
				if dispatch < 13 then
					if dispatch < 6 then
						if dispatch < 3 then
							if dispatch < 1 then
								dispatch = if not u58:HasRigEquipped(a2) then 2 else 1
							elseif dispatch < 2 then
								return
							else
								PlayerFromCharacter = Players:GetPlayerFromCharacter(a2)
								PlayerFromCharacter_2 = Players:GetPlayerFromCharacter(a3)
								dispatch = if PlayerFromCharacter then 5 else 3
							end
						elseif dispatch < 4 then
							dispatch = if PlayerFromCharacter_2 then 5 else 4
						elseif dispatch < 5 then
							return
						else
							dispatch = if not PlayerFromCharacter then 9 else 6
						end
					elseif dispatch < 9 then
						if dispatch < 7 then
							dispatch = if not PlayerFromCharacter_2 then 9 else 7
						else
							if not (dispatch < 8) then
								return
							end

							dispatch = if not require(game.ReplicatedStorage.Global).InSafeZone then 9 else 8
						end
					elseif dispatch < 11 then
						dispatch = if dispatch < 10
							then if not PlayerFromCharacter then 19 else 10
							else if not PlayerFromCharacter:GetAttribute("PvpDisabled") then 12 else 11
					elseif dispatch < 12 then
						return
					else
						dispatch = if not PlayerFromCharacter:GetAttribute("KenActive") then 19 else 13
					end
				elseif dispatch < 20 then
					if dispatch < 16 then
						if dispatch < 14 then
							v12 = PlayerFromCharacter:GetAttribute("KenDodgesLeft") or 0
							Attribute = PlayerFromCharacter:GetAttribute("LastKenDodge")
							dispatch = if tick() - (Attribute or 0) <= 0.4 then 15 else 14
						else
							v3 = not (dispatch < 15)
							dispatch = 16
						end
					elseif dispatch < 18 then
						dispatch = if dispatch < 17 then if v12 > 0 then 18 else 17 else if not v3 then 19 else 18
					elseif dispatch < 19 then
						return
					else
						dispatch = if not a3 then 22 else 20
					end
				elseif dispatch < 23 then
					if dispatch < 21 then
						dispatch = if not a3:IsDescendantOf(Enemies) then 22 else 21
					else
						v12 = if dispatch < 22 then a3 else nil
						dispatch = 23
					end
				elseif dispatch < 25 then
					dispatch = if dispatch < 24
						then if not a2 then 26 else 24
						else if not a2:IsDescendantOf(Enemies) then 26 else 25
				else
					v2 = if dispatch < 26 then a2 else nil
					dispatch = 27
				end
			elseif dispatch < 40 then
				if dispatch < 33 then
					if dispatch < 30 then
						if dispatch < 28 then
							dispatch = if not v12 then 29 else 28
						elseif dispatch < 29 then
							Attribute_2 = v12:GetAttribute("Level")
							dispatch = if Attribute_2 then 31 else 29
						else
							Attribute_2 = v2
							dispatch = if not Attribute_2 then 31 else 30
						end
					elseif dispatch < 31 then
						Attribute_2 = v2:GetAttribute("Level")
						dispatch = 31
					elseif dispatch < 32 then
						dispatch = if not v12 then 33 else 32
					else
						Attribute_3 = v12:GetAttribute("IsBoss")
						dispatch = if Attribute_3 then 35 else 33
					end
				elseif dispatch < 36 then
					if dispatch < 34 then
						Attribute_3 = v2
						dispatch = if not Attribute_3 then 35 else 34
					elseif dispatch < 35 then
						Attribute_3 = v2:GetAttribute("IsBoss")
						dispatch = 35
					else
						Data = PlayerFromCharacter_2
						dispatch = if not Data then 37 else 36
					end
				elseif dispatch < 38 then
					if dispatch < 37 then
						Data = PlayerFromCharacter_2:FindFirstChild("Data")
						dispatch = 37
					else
						Data_2 = PlayerFromCharacter
						dispatch = if not Data_2 then 39 else 38
					end
				elseif dispatch < 39 then
					Data_2 = PlayerFromCharacter:FindFirstChild("Data")
					dispatch = 39
				else
					dispatch = if not Data then 41 else 40
				end
			elseif dispatch < 47 then
				if dispatch < 43 then
					if dispatch < 41 then
						Value = Data.Level.Value
						dispatch = if Value then 44 else 41
					elseif dispatch < 42 then
						dispatch = if not v12 then 43 else 42
					else
						Value = Attribute_2
						dispatch = if Value then 44 else 43
					end
				elseif dispatch < 45 then
					if dispatch < 44 then
						Value = 1
						dispatch = 44
					else
						dispatch = if not Data_2 then 46 else 45
					end
				elseif dispatch < 46 then
					Value_2 = Data_2.Level.Value
					dispatch = if Value_2 then 47 else 46
				else
					Value_2 = v2 and Attribute_2
					dispatch = 47
				end
			elseif dispatch < 50 then
				if dispatch < 48 then
					v4 = math.floor((Value / 175) ^ 1.5) * 2
					v6 = nil
					dispatch = if not PlayerFromCharacter_2 then 50 else 48
				elseif dispatch < 49 then
					v5 = u58:GetToolOfWeaponType(a3, "Melee")
					dispatch = if not v5 then 52 else 49
				else
					v6 = v5:GetAttribute("WeaponName")
					dispatch = 52
				end
			elseif dispatch < 52 then
				if dispatch < 51 then
					dispatch = if not v12 then 52 else 51
				else
					v6 = v12:GetAttribute("WeaponName")
					dispatch = 52
				end
			elseif dispatch < 53 then
				v2 = u58:GetToolOfWeaponType(a2, "Demon Fruit")
				dispatch = if a5 == "Melee" then 55 else 53
			else
				dispatch = if a5 == "Sword" then 55 else 54
			end
		elseif dispatch < 83 then
			if dispatch < 67 then
				if dispatch < 60 then
					if not (dispatch < 57) then
						dispatch = if dispatch < 58
							then if a5 ~= "Melee" then 61 else 58
							else if dispatch < 59
								then if not Data then 61 else 59
								else if v6 ~= "Electro" then 61 else 60
					elseif not (dispatch < 55) then
						dispatch = if dispatch < 56
							then if not v2 then 61 else 56
							else if v2.Name ~= "Rubber-Rubber" then 61 else 57
					elseif a5 ~= "Gun" then
						v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
						dispatch = 100
					else
						dispatch = 55
					end
				elseif not (dispatch < 63) then
					dispatch = if dispatch < 65
						then if dispatch < 64 then if a5 ~= "Sword" then 72 else 64 else if not v12 then 66 else 65
						else if dispatch < 66 then if not Attribute_3 then 67 else 66 else if v12 then 72 else 67
				elseif dispatch < 61 then
					return
				else
					dispatch = if dispatch < 62
						then if not v2 then 72 else 62
						else if v2.Name ~= "Blade-Blade" then 72 else 63
				end
			elseif dispatch < 75 then
				if dispatch < 70 then
					if dispatch < 68 then
						dispatch = if not v12 then 69 else 68
					elseif dispatch < 69 then
						dispatch = if Attribute_2 <= Value_2 - v4 then 70 else 69
					elseif v12 then
						v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
						dispatch = 100
					else
						dispatch = 70
					end
				elseif not (dispatch < 73) then
					dispatch = if dispatch < 74
						then if v2.Name ~= "Rubber-Rubber" then 83 else 74
						else if a5 ~= "Gun" then 83 else 75
				elseif dispatch < 72 then
					return
				else
					dispatch = if not v2 then 83 else 73
				end
			elseif dispatch < 78 then
				dispatch = if dispatch < 76
					then if not v12 then 77 else 76
					else if dispatch < 77 then if not Attribute_3 then 78 else 77 else if v12 then 83 else 78
			elseif dispatch < 80 then
				dispatch = if dispatch < 79
					then if not v12 then 80 else 79
					else if Attribute_2 <= Value_2 - v4 then 81 else 80
			else
				if not (dispatch < 81) then
					return
				end

				if v12 then
					v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
					dispatch = 100
				else
					dispatch = 81
				end
			end
		elseif dispatch < 97 then
			if dispatch < 89 then
				if dispatch < 86 then
					dispatch = if dispatch < 84
						then if not v2 then 91 else 84
						else if dispatch < 85
							then if not v2:FindFirstChild("Logia") then 91 else 85
							else if a3:GetAttribute("BusoEnabled") then 91 else 86
				elseif dispatch < 87 then
					dispatch = if not v12 then 88 else 87
				elseif dispatch < 88 then
					dispatch = if Attribute_2 <= Value_2 - v4 then 89 else 88
				elseif v12 then
					v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
					dispatch = 100
				else
					dispatch = 89
				end
			elseif dispatch < 93 then
				if dispatch < 91 then
					return
				elseif dispatch < 92 then
					if not v2 then
						v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
						dispatch = 100
					else
						dispatch = 92
					end
				elseif not v2:FindFirstChild("LogiaDough") then
					v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
					dispatch = 100
				else
					dispatch = 93
				end
			elseif dispatch < 95 then
				if dispatch < 94 then
					if not PlayerFromCharacter then
						v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
						dispatch = 100
					else
						dispatch = 94
					end
				elseif not PlayerFromCharacter:GetAttribute("KenActive") then
					v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
					dispatch = 100
				else
					dispatch = 95
				end
			elseif not (dispatch < 96) then
				dispatch = if not v12 then 98 else 97
			elseif a3:GetAttribute("BusoEnabled") then
				v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
				dispatch = 100
			else
				dispatch = 96
			end
		elseif dispatch < 104 then
			if dispatch < 100 then
				if dispatch < 98 then
					dispatch = if Attribute_2 <= Value_2 - v4 then 99 else 98
				else
					if not (dispatch < 99) then
						return
					end

					if v12 then
						v1, v7, v9, v10, v8, v11 = a2, a3, a5, a6, a4, a7
						dispatch = 100
					else
						dispatch = 99
					end
				end
			elseif dispatch < 102 then
				dispatch = if dispatch < 101
					then if PlayerFromCharacter then 104 else 101
					else if v1:GetAttribute("FruitType") ~= "Logia" then 104 else 102
			else
				if not (dispatch < 103) then
					return
				end

				dispatch = if v7:GetAttribute("BusoEnabled") then 104 else 103
			end
		elseif not (dispatch < 107) then
			if not (dispatch < 109) then
				if dispatch < 110 then
					return true
				end

				u463 = WrapHighlight(script.DamageHighlight):Clone()
				u463.Adornee = HighlightAdornee(v1)
				u463.Parent = v1

				TweenService:Create(u463, TweenInfo.new(0.2), { FillTransparency = 0.5 }):Play()

				task.delay(0.2, function() -- Line: 1138; upvalues: TweenService (upval), u463 (val)
					TweenService:Create(u463, TweenInfo.new(0.2), { FillTransparency = 1 }):Play()

					task.wait(0.2)
					u463:Destroy()
				end)

				return true
			end

			if dispatch < 108 then
				dispatch = if not Highlight:GetAttribute("__FillColor") then 109 else 108
			else
				v4 = Color3.fromRGB(138, 0, 0)
				TweenService:Create(Highlight, TweenInfo.new(0.2), { FillColor = v4 }):Play()

				task.delay(0.2, function() -- Line: 1124; upvalues: TweenService (upval), Highlight (val)
					TweenService
						:Create(Highlight, TweenInfo.new(0.2), { FillColor = Highlight:GetAttribute("__FillColor") })
						:Play()
				end)

				dispatch = 109
			end
		elseif dispatch < 105 then
			dispatch = if v9 == "Gun" then 106 else 105
		elseif dispatch < 106 then
			u58:PlayMeleeHitParticles(v1, v10, v8)

			dispatch = 106
		else
			Highlight = v1:FindFirstChildOfClass("Highlight")
			dispatch = if not Highlight then 110 else 107
		end
	end
end

function u58.IsGunReloading(a1, a2) -- Line: 1147; upvalues: u80 (val)
	if u80 then
		return not a2.Enabled or a2:GetAttribute("IsReloading") or a2:GetAttribute("UnequipAutoReloading")
	end

	return not a2.Enabled or a2:GetAttribute("IsReloading_Client") or a2:GetAttribute("UnequipAutoReloading")
end

local u218 = RaycastParams.new()
u218.FilterType = Enum.RaycastFilterType.Exclude
u218.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, Enemies }
local u227 = RaycastParams.new()
u227.FilterType = Enum.RaycastFilterType.Exclude

function u58.GetTargetPosition(a1, a2, a3, a4, a5) -- Line: 1163; upvalues: u227 (val), u218 (val)
	debug.profilebegin("GetTargetPosition")

	local v1 = a4 or (1 / 0)
	local v2 = a3 - a2

	if v1 < v2.Magnitude then
		a3 = a2 + v2.Unit * v1
	end

	if a5 then
		u227.FilterDescendantsInstances = { workspace._WorldOrigin, a5 }
	end

	local _workspace = workspace
	local v3 = a5 and u227 or u218
	v2 = _workspace:Raycast(a2, a3 - a2, v3)

	if v2 then
		a3 = v2.Position
	end

	debug.profileend()

	return a3
end

return u58
