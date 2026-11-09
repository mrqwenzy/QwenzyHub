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
-- Boss blacklist
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
}

local function isBossQuest(def)
	if typeof(def.Task) ~= "table" then
		return false
	end
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
}

local Completed = {} -- Completed[questName][questId] = true (session)

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
end

-- ============================================================
-- Picker
-- ============================================================
function QuestManager.FindBestQuestForLevel(level)
	local bestName, bestId, bestDef

	for questName, group in pairs(Quests) do
		for questId, def in pairs(group) do
			if level >= def.LevelReq and not isBossQuest(def) and not QuestManager.IsCompleted(questName, questId) then
				if not bestDef or def.LevelReq > bestDef.LevelReq then
					bestName, bestId, bestDef = questName, questId, def
				end
			end
		end
	end

	return bestName, bestId, bestDef
end

-- ============================================================
-- Accept / cancel
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

function QuestManager.Cancel()
	pcall(function()
		CommF:InvokeServer("AbandonQuest")
	end)
	QuestManager.Reset()
end

-- ============================================================
-- Ensure: accept or switch to a better quest
-- ============================================================
-- Returns: action, reason
--   action = "none"        nothing changed
--   action = "accepted"    accepted a new quest (was empty)
--   action = "switched"    switched to a higher-level quest
--   action = "completed"   current quest finished; will re-pick next call
--   action = "failed"
function QuestManager.EnsureQuest()
	if tick() - State.LastAcceptAttempt < 1 then
		return "none", "throttled"
	end
	State.LastAcceptAttempt = tick()

	local level = Player.Data.Level.Value
	local bestName, bestId, bestDef = QuestManager.FindBestQuestForLevel(level)

	-- No quest available at all
	if not bestName then
		return "none", "no_quest_available"
	end

	-- Already have a quest: is the best available higher-level than current?
	if QuestManager.IsActive() then
		local curDef = State.QuestDef
		if curDef and bestDef and bestDef.LevelReq > curDef.LevelReq then
			-- Try to accept the better one directly (StartQuest replaces in most cases)
			local ok, reason = QuestManager.Accept(bestName, bestId, bestDef)
			if ok then
				return "switched", bestName .. ":" .. bestId
			end
			if reason == "already_completed" then
				QuestManager.MarkCompleted(bestName, bestId)
			end
			-- fall through: keep current quest
			return "none", "switch_failed:" .. reason
		end

		return "none", "already_active"
	end

	-- No active quest → accept best
	local ok, reason = QuestManager.Accept(bestName, bestId, bestDef)
	if ok then
		return "accepted", bestName .. ":" .. bestId
	end

	if reason == "already_completed" then
		QuestManager.MarkCompleted(bestName, bestId)
	end
	return "failed", reason
end

-- ============================================================
-- Called by Combat when a kill is confirmed / quest should be re-checked
-- ============================================================
function QuestManager.NotifyProgress()
	if not QuestManager.IsActive() then
		return
	end
	-- Ask the server if the quest is done
	local ok, result = pcall(function()
		return CommF:InvokeServer("QuestProgress", "Check")
	end)
	if ok and result == 2 then
		-- Server reports completed
		QuestManager.MarkCompleted(State.QuestName, State.QuestId)
	end
end

-- ============================================================
-- Enemy lookup
-- ============================================================
function QuestManager.FindNearestEnemy()
	if not QuestManager.IsActive() then
		return nil
	end

	local char = Player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local wanted = State.Enemy
	local closest, closestDist = nil, math.huge
	local map = workspace:FindFirstChild("Map") or workspace

	for _, mob in ipairs(map:GetDescendants()) do
		if mob:IsA("Model") and mob.Name == wanted then
			local hum = mob:FindFirstChildOfClass("Humanoid")
			local mobRoot = mob:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and mobRoot then
				local dist = (mobRoot.Position - root.Position).Magnitude
				if dist < closestDist then
					closest, closestDist = mob, dist
				end
			end
		end
	end

	return closest, closestDist
end

return QuestManager
