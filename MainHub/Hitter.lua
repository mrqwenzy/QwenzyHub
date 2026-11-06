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

local function SendHit(targetLimb)
	if typeof(targetLimb) ~= "Instance" or not targetLimb:IsA("BasePart") then
		return
	end
	RegisterAttack()
	task.wait()
	coroutine.resume(hitThread, targetLimb, {})
end

coroutine.resume(hitThread)

return { SendHit = SendHit, RegisterAttack = RegisterAttack }
