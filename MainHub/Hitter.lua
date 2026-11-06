local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RegisterAttack_RAM = {
	LastUse = 0,
	Combo = 1,
}

local _RAMRemotes = {
	["RE/RegisterHit"] = ReplicatedStorage.Modules.Net["RE/RegisterHit"],
	["RE/RegisterAttack"] = ReplicatedStorage.Modules.Net["RE/RegisterAttack"],
}

local hitThread = coroutine.create(function()
	local Event = _RAMRemotes["RE/RegisterHit"]
	local token = tostring(Players.LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)

	Event:FireServer(token)

	while true do
		local targetLimb, hitData = coroutine.yield()
		warn("FIRE INVOKED")
		Event:FireServer(targetLimb, hitData, nil, token)
	end
end)

local function RegisterAttack()
	local Now = tick()

	if Now - RegisterAttack_RAM.LastUse <= 0.5 then
		return false
	end

	RegisterAttack_RAM.Combo += 1

	if RegisterAttack_RAM.Combo > 5 then
		RegisterAttack_RAM.Combo = 1
	end

	RegisterAttack_RAM.LastUse = Now

	_RAMRemotes["RE/RegisterAttack"]:FireServer(0.5, RegisterAttack_RAM)

	print("Allowed reg")
	return true
end

local function resolveLimb(target)
	if typeof(target) ~= "Instance" then
		return nil
	end
	if target:IsA("BasePart") then
		return target
	end
	if target:IsA("Model") then
		return target:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function SendHit(target)
	local limbs = {}

	if typeof(target) == "Instance" then
		local limb = resolveLimb(target)
		if limb then
			table.insert(limbs, limb)
		end
	elseif typeof(target) == "table" then
		for _, item in ipairs(target) do
			local limb = resolveLimb(item)
			if limb then
				table.insert(limbs, limb)
			end
		end
	end

	if #limbs == 0 then
		return
	end

	local first = table.remove(limbs, 1)

	RegisterAttack()
	task.wait()
	coroutine.resume(hitThread, first, limbs)
end

coroutine.resume(hitThread)

return { SendHit = SendHit, RegisterAttack = RegisterAttack }
