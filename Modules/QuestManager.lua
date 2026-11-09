-- App/Modules/QuestManager.lua
local QuestManager = {}

local Services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

local Player = Services.Players.LocalPlayer
local CommF = Services.ReplicatedStorage.Remotes.CommF_
local Quests = require(Services.ReplicatedStorage.Quests)

-- ============================================================
-- Boss blacklist — name-based
-- ============================================================
local BOSS_TARGETS = {
	-- First Sea
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
	-- Second Sea
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
	-- Third Sea
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
	-- Common variants
	["Swan Pirate"] = true,
	["Swan Pirates"] = true,
}

-- Multi-stage quests: only stage id 1 (the mob-kill stage) is farmable.
-- Higher stage ids target the boss. Skip them entirely.
local MULTI_STAGE_QUESTS = {
	BartiloQuest = true,
	CitizenQuest = true,
	DressrosaQuestProgress = true,
	ZouQuest = true,
	SwanQuest = true,
	MagmaQuest = true,
	FishmanQuest = true,
	ColosseumQuest = true,
	PrisonerQuest = true,
	ImpelQuest = true,
}

local function isBossQuest(questName, questId, def)
	if typeof(def.Task) ~= "table" then
		return false
	end

	-- Multi-stage: any id > 1 is the boss stage
	if MULTI_STAGE_QUESTS[questName] and type(questId) == "number" and questId > 1 then
		return true
	end

	-- Any boss name in Task → boss quest
	for enemy in pairs(def.Task) do
		if BOSS_TARGETS[enemy] then
			return true
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
	LastAcceptAttempt = 0,
	LastSwitchAttempt = 0,
	LastCompletionCheck = 0,
}

local Completed = {}

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

-- ============================================================
-- Picker — returns best non-boss quest
-- ============================================================
function QuestManager.FindBestQuestForLevel(level)
	local bestName, bestId, bestDef

	for questName, group in pairs(Quests) do
		for questId, def in pairs(group) do
			if
				level >= def.LevelReq
				and not isBossQuest(questName, questId, def)
				and not QuestManager.IsCompleted(questName, questId)
			then
				if not bestDef or def.LevelReq > bestDef.LevelReq then
					bestName, bestId, bestDef = questName, questId, def
				end
			end
		end
	end

	return bestName, bestId, bestDef
end

-- ============================================================
-- Accept
-- ============================================================
local function firstEnemy(def)
	if typeof(def.Task) ~= "table" then
		return nil
	end
	return next(def.Task)
end

function QuestManager.Accept(questName, questId, def)
	local r = CommF:InvokeServer("StartQuest", questName, questId)

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
-- EnsureQuest — accepts, switches on level-up, detects completion
-- ============================================================
function QuestManager.EnsureQuest()
	local now = tick()

	-- Throttle all StartQuest attempts to once per second (server safety)
	if now - State.LastAcceptAttempt < 1 then
		return "none", "throttled"
	end

	local level = Player.Data.Level.Value
	local bestName, bestId, bestDef = QuestManager.FindBestQuestForLevel(level)

	-- Verify current quest is still valid by re-attempting StartQuest periodically.
	-- If server returns 2, the quest is done → mark and pick next.
	if QuestManager.IsActive() and now - State.LastCompletionCheck > 2 then
		State.LastCompletionCheck = now
		State.LastAcceptAttempt = now

		local r = CommF:InvokeServer("StartQuest", State.QuestName, State.QuestId)
		if r == 2 then
			QuestManager.MarkCompleted(State.QuestName, State.QuestId)
			-- fall through to accept best
		elseif r == 0 then
			-- still active, server re-confirmed
			return "none", "still_active"
		else
			-- unknown state, keep going
			State.Accepted = false
		end
	end

	-- No best quest available
	if not bestName then
		return "none", "no_quest_available"
	end

	-- If we already have a quest and it's the same or better than best → keep it
	if QuestManager.IsActive() then
		local curDef = State.QuestDef
		if curDef and bestDef and bestDef.LevelReq <= curDef.LevelReq then
			return "none", "already_active"
		end
		-- else: fall through to switch
	end

	State.LastAcceptAttempt = now

	local ok, reason = QuestManager.Accept(bestName, bestId, bestDef)
	if ok then
		if State.QuestDef == bestDef then
			return "accepted", bestName .. ":" .. bestId
		end
		return "switched", bestName .. ":" .. bestId
	end

	if reason == "already_completed" then
		QuestManager.MarkCompleted(bestName, bestId)
	end
	return "failed", reason
end

-- ============================================================
-- Enemy lookup with CACHED scan (fixes lag)
-- ============================================================
local enemyCache = {}
local enemyCacheTime = 0
local CACHE_INTERVAL = 2 -- seconds

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
end

function QuestManager.FindNearestEnemy()
	if not QuestManager.IsActive() then
		return nil
	end

	local char = Player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	-- Refresh cache every 2s
	if tick() - enemyCacheTime > CACHE_INTERVAL then
		refreshEnemyCache()
		enemyCacheTime = tick()
	end

	local wanted = State.Enemy
	local list = enemyCache[wanted]
	if not list or #list == 0 then
		-- force refresh once, then bail
		refreshEnemyCache()
		enemyCacheTime = tick()
		list = enemyCache[wanted]
		if not list or #list == 0 then
			return nil
		end
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

return QuestManager
