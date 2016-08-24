local AC, ACD = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")

local animalsName, animalsTable = ...
local _ = nil
animalsTableGlobal = {}

animalsDataPerChar = animalsDataPerChar or {Log = false}
if not animalsDataPerChar.Class then animalsDataPerChar.Class = select(2, UnitClass("player")) end

animalsTable.preventExecution = false
animalsTable.throttleSlaying = 0
animalsTable.waitForCombatLog = false
animalsTable.iterationNumer = 0
animalsTable.toggleLog = true
animalsTable.animalsSize = 0
animalsTable.humansSize = 0
animalsTable.combatStart = math.huge
for i = 1, 7 do
	for o = 1, 3 do
		animalsTable["Talent"..i..o] = false
	end
end
animalsTable.artifactWeapon = {
	weaponPerks = {}
}

function animalsTable.createMainFrame()
	if not animalsMainFrame then
		CreateFrame("Frame", "animalsMainFrame", nil)
		animalsMainFrame:RegisterEvent("PLAYER_LOGIN")
		animalsMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		animalsMainFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
		animalsMainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		animalsMainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
		animalsMainFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		animalsMainFrame:SetScript("OnEvent", animalsTable.respondMainFrame)
	end
end

function animalsTable.respondMainFrame(self, originalEvent, ...) -- todo: player_entering_world and loading_screen_disabled
	if originalEvent == "PLAYER_ENTERING_WORLD" then
		-- GS.PreventExecution = true
		-- table.wipe(GS.MobTargets)
		-- table.wipe(GS.AllyTargets)
		-- GS.MonitorAnimationToggle("off")
	elseif originalEvent == "LOADING_SCREEN_DISABLED" then
		-- GS.PreventExecution = false
		-- GS.Start  = false
		-- GS.MonitorAnimationToggle("off")
	elseif originalEvent == "PLAYER_SPECIALIZATION_CHANGED" then
		animalsTable.currentSpec = GetSpecialization()
		animalsTable.cacheTalents()
	elseif originalEvent == "PLAYER_TALENT_UPDATE" then
		animalsTable.cacheTalents()
	elseif originalEvent == "PLAYER_EQUIPMENT_CHANGED" then
		animalsTable.cacheGear()
	end
end

function animalsTable.cacheTalents()
	for i = 1, 7 do
		for o = 1, 3 do
			animalsTable["Talent"..i..o] = select(4, GetTalentInfo(i, o, 1))
		end
	end
end

function animalsTable.cacheGear()
	local gear = {
		Ammo = 0,
		Back = 0,
		Chest = 0,
		Feet = 0,
		Finger0 = 0,
		Finger1 = 0,
		Hands = 0,
		Head = 0,
		Legs = 0,
		MainHand = 0,
		Neck = 0,
		SecondaryHand = 0,
		Shirt = 0,
		Shoulder = 0,
		Tabard = 0,
		Trinket0 = 0,
		Trinket1 = 0,
		Waist = 0,
		Wrist = 0,
	}
	for k,v in pairs(gear) do
	   v = GetInventoryItemID("player", GetInventorySlotInfo(k.."Slot")) or 0
	end
	animalsTable.equippedGear = gear
	if HasArtifactEquipped() then
		local closeAfter = false
		if not ArtifactFrame:IsShown() then
			closeAfter = true
			SocketInventoryItem(16)
		end
		for i, powerID in ipairs(C_ArtifactUI.GetPowers()) do
			local spellID, costS, currentRankS, maxRankS, bonusRanksS, x, y, prereqsMet, isStart, isGoldMedal, isFinal = C_ArtifactUI.GetPowerInfo(powerID)
			animalsTable.artifactWeapon.weaponPerks.spellID = {
				cost = costS,
				currentRank = currentRankS,
				maxRank = maxRankS,
				bonusRanks = bonusRanksS
			}
		end
		if ArtifactFrame:IsShown() and closeAfter then HideUIPanel(ArtifactFrame) end
	end
end

function animalsTable.slayingFrameCreation()
	if not animalsSlayingFrame then
		CreateFrame("Frame", "animalsSlayingFrame", animalsMainFrame)
		animalsSlayingFrame:SetScript("OnUpdate", animalsTable.startSlaying)
	end
end

function animalsTable.startSlaying()
	if not FireHack or not animalsTable.allowSlaying or UnitIsDeadOrGhost("player") then return end
	if not animalsTable.ranOnce then
		if not ReadFile(GetFireHackDirectory().."\\Scripts\\Animals\\animalsVersion.txt") then
			print("Animals: No animalsVersion.txt found.")
		    GS.CheckUpdateFailed("no local file")
		else
		    -- DownloadURL("raw.githubusercontent.com", "/g1zstar/GStar-Rotations/master/Revision.txt", true, GS.CheckUpdate, GS.DownloadURLFailed)
		end
		animalsTable.ranOnce = true
	end
end

