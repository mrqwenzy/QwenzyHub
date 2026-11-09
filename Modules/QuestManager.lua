local QuestManager = {}

local Services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

local Player = Services.Players.LocalPlayer
local CommF = Services.ReplicatedStorage.Remotes.CommF_
local Quests = require(Services.ReplicatedStorage.Quests)

-- ============================================================
-- Boss blacklists
-- ============================================================
local BOSS_TARGETS = {
	["Gorilla King"] = true,
	["Bobby"] = true,
	["Chef"] = true,
	["The Saw"] = true,
	["Yeti"] = true,
	["Mob Leader"] = true,
	["Vice Admiral"] = true,
	["Saber Expert"] = true,
	["Warden"] = true,
	["Chief Warden"] = true,
	["Swan"] = true,
	["Magma Admiral"] = true,
	["Magma General"] = true,
	["Fishman Lord"] = true,
	["Wysper"] = true,
	["Sky Warlord"] = true,
	["Thunder God"] = true,
	["Lightning God"] = true,
	["Cyborg"] = true,
	["Ice Admiral"] = true,
	["Diamond"] = true,
	["Jeremy"] = true,
	["Orbitus"] = true,
	["Fajita"] = true,
	["Don Swan"] = true,
	["Smoke Admiral"] = true,
	["Awakened Ice Admiral"] = true,
	["Tide Keeper"] = true,
	["Darkbeard"] = true,
	["Cursed Captain"] = true,
	["Stone"] = true,
	["Hydra Leader"] = true,
	["Island Empress"] = true,
	["Kilo Admiral"] = true,
	["Captain Elephant"] = true,
	["Beautiful Pirate"] = true,
	["Longma"] = true,
	["Cursed Skeleton Boss"] = true,
	["Cake Queen"] = true,
	["Heaven's Guardian"] = true,
	["Hell's Messenger"] = true,
	["Dough King"] = true,
	["Soul Reaper"] = true,
	["rip_indra"] = true,
	["Rip_Return"] = true,
	["Swan Pirate"] = true,
	["Swan Pirates"] = true,
}

local BOSS_QUEST_GROUPS = {
	ColosseumQuest = true,
	PrisonerQuest = true,
	ImpelQuest = true,
	MagmaQuest = true,
	FishmanQuest = true,
	SwanQuest = true,
	BartiloQuest = true,
	CitizenQuest = true,
	DressrosaQuestProgress = true,
	ZouQuest = true,
	HauntedQuest1 = true,
	HauntedQuest2 = true,
	IceCreamIslandQuest = true,
	CakeQuest1 = true,
	CakeQuest2 = true,
	TikiQuest3 = true,
	SubmergedQuest3 = true,
}

local function isBossQuest(questName, questId, def)
	if BOSS_QUEST_GROUPS[questName] then
		return true
	end
	if typeof(def.Task) == "table" then
		for enemy in pairs(def.Task) do
			if BOSS_TARGETS[enemy] then
				return true
			end
		end
	end
	return false
end

QuestManager.IsBossQuest = isBossQuest

-- ============================================================
-- State
-- ============================================================
local State = {
	QuestName = nil,
	QuestId = nil,
	QuestDef = nil,
	Enemy = nil,
	Accepted = false,
	Disabled = true,
	LastAcceptAttempt = 0,
	LastPickerRun = 0,
	CachedBestName = nil,
	CachedBestId = nil,
	CachedBestDef = nil,
	CachedLevel = -1,
}

local Completed = {}
local Failed = {}

function QuestManager.GetState()
	return State
end
function QuestManager.GetEnemy()
	return State.Enemy
end
function QuestManager.IsActive()
	return State.Accepted and State.Enemy ~= nil
end

function QuestManager.Reset()
	State.QuestName = nil
	State.QuestId = nil
	State.QuestDef = nil
	State.Enemy = nil
	State.Accepted = false
	State.LastAcceptAttempt = 0
	State.LastPickerRun = 0
	State.CachedBestName = nil
	State.CachedBestId = nil
	State.CachedBestDef = nil
	State.CachedLevel = -1
end

function QuestManager.SetEnabled(enabled)
	State.Disabled = not enabled
	if not enabled then
		QuestManager.Reset()
	end
end

function QuestManager.IsCompleted(name, id)
	return Completed[name] and Completed[name][id] == true
end

function QuestManager.MarkCompleted(name, id)
	Completed[name] = Completed[name] or {}
	Completed[name][id] = true
	State.Accepted = false
	State.QuestName = nil
	State.QuestId = nil
	State.QuestDef = nil
	State.Enemy = nil
end

local function markFailed(name, id)
	Failed[name] = Failed[name] or {}
	Failed[name][id] = true
end

local function isFailed(name, id)
	return Failed[name] and Failed[name][id] == true
end

-- ============================================================
-- Picker (cached)
-- ============================================================
local function refreshPickerCache(level)
	State.CachedLevel = level
	State.LastPickerRun = tick()

	local bestName, bestId, bestDef
	for questName, group in pairs(Quests) do
		for questId, def in pairs(group) do
			if
				level >= def.LevelReq
				and not isBossQuest(questName, questId, def)
				and not QuestManager.IsCompleted(questName, questId)
				and not isFailed(questName, questId)
			then
				if not bestDef or def.LevelReq > bestDef.LevelReq then
					bestName, bestId, bestDef = questName, questId, def
				end
			end
		end
	end

	State.CachedBestName = bestName
	State.CachedBestId = bestId
	State.CachedBestDef = bestDef
end

function QuestManager.FindBestQuestForLevel(level)
	local now = tick()
	if level ~= State.CachedLevel or now - State.LastPickerRun > 5 then
		refreshPickerCache(level)
	end
	return State.CachedBestName, State.CachedBestId, State.CachedBestDef
end

-- ============================================================
-- Accept — the ONLY place StartQuest is called
-- ============================================================
local function firstEnemy(def)
	if typeof(def.Task) ~= "table" then
		return nil
	end
	return next(def.Task)
end

function QuestManager.Accept(questName, questId, def)
	print("[QM] StartQuest", questName, questId, "activeBefore:", State.Accepted)
	local r = CommF:InvokeServer("StartQuest", questName, questId)
	print("[QM]   result:", r)

	if r == 0 then
		State.QuestName = questName
		State.QuestId = questId
		State.QuestDef = def
		State.Enemy = firstEnemy(def)
		State.Accepted = true
		return true, "accepted"
	end

	State.Accepted = false

	if r == 2 then
		return false, "already_completed"
	elseif r == 1 then
		return false, "error"
	elseif type(r) == "number" then
		return false, "level_lock:" .. r
	end
	return false, "unknown:" .. tostring(r)
end

-- ============================================================
-- ForceRePick — called when Combat detects "no targets for a while"
-- ============================================================
function QuestManager.ForceRePick()
	if QuestManager.IsActive() then
		QuestManager.MarkCompleted(State.QuestName, State.QuestId)
	end
	State.LastAcceptAttempt = 0
end

-- ============================================================
-- EnsureQuest — accepts only when nothing active. No polling.
-- ============================================================
function QuestManager.EnsureQuest()
	if State.Disabled then
		return "none", "disabled"
	end

	local now = tick()

	-- Self-heal boss
	if QuestManager.IsActive() and isBossQuest(State.QuestName, State.QuestId, State.QuestDef) then
		pcall(function()
			CommF:InvokeServer("AbandonQuest")
		end)
		QuestManager.MarkCompleted(State.QuestName, State.QuestId)
		State.LastAcceptAttempt = now
		return "abandoned_boss", "boss_detected"
	end

	-- Already have an active quest → do nothing. Completion is detected by Combat.
	if QuestManager.IsActive() then
		return "none", "active"
	end

	-- Throttle
	if now - State.LastAcceptAttempt < 1 then
		return "none", "throttled"
	end

	local level = Player.Data.Level.Value
	local bestName, bestId, bestDef = QuestManager.FindBestQuestForLevel(level)
	if not bestName then
		return "none", "no_quest_available"
	end

	State.LastAcceptAttempt = now
	local ok, reason = QuestManager.Accept(bestName, bestId, bestDef)
	if ok then
		return "accepted", bestName .. ":" .. bestId
	end

	if reason == "already_completed" then
		QuestManager.MarkCompleted(bestName, bestId)
		return "completed", bestName .. ":" .. bestId
	end

	markFailed(bestName, bestId)
	State.CachedLevel = -1
	return "failed", reason
end

-- ============================================================
-- Enemy lookup (cached, one refresh per stale window)
-- ============================================================
local enemyCache = {}
local enemyCacheTime = 0
local CACHE_INTERVAL = 2

local function refreshEnemyCache()
	enemyCache = {}
	local map = workspace:FindFirstChild("Map") or workspace
	for _, mob in ipairs(map:GetChildren()) do
		if mob:IsA("Model") then
			local hum = mob:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				enemyCache[mob.Name] = enemyCache[mob.Name] or {}
				table.insert(enemyCache[mob.Name], mob)
			end
		end
	end
	enemyCacheTime = tick()
end

function QuestManager.FindNearestEnemy()
	if State.Disabled then
		return nil
	end
	if not QuestManager.IsActive() then
		return nil
	end

	local char = Player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local wanted = State.Enemy
	local list = enemyCache[wanted]

	if not list or #list == 0 or tick() - enemyCacheTime > CACHE_INTERVAL then
		refreshEnemyCache()
		list = enemyCache[wanted]
	end

	if not list then
		return nil
	end

	local closest, closestDist = nil, math.huge
	for _, mob in ipairs(list) do
		if mob.Parent then
			local hum = mob:FindFirstChildOfClass("Humanoid")
			local mobRoot = mob:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and mobRoot then
				local d = (mobRoot.Position - root.Position).Magnitude
				if d < closestDist then
					closest, closestDist = mob, d
				end
			end
		end
	end

	return closest, closestDist
end

function QuestManager.DebugDump()
	warn("===== QuestManager Debug Dump =====")
	for qName, group in pairs(Quests) do
		for qId, def in pairs(group) do
			print(
				isBossQuest(qName, qId, def) and "SKIP" or "USE ",
				qName,
				qId,
				next(def.Task or {}),
				"Lvl" .. tostring(def.LevelReq)
			)
		end
	end
	warn("Active:", State.QuestName, State.QuestId, "Enemy:", State.Enemy)
	warn("===================================")
end

return QuestManager
