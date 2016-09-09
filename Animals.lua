local AC, ACD = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")

local animalsName, animalsTable = ...
local _ = nil

animalsDataPerChar = animalsDataPerChar or {Log = false}
animalsGlobal = {}

animalsTable.debugTable = {}
animalsTable.preventSlaying = false
animalsTable.throttleSlaying = 0
animalsTable.waitForCombatLog = false
animalsTable.iterationNumer = 0
animalsTable.toggleLog = true
animalsTable.thokThrottle = 0

for i = 1, 7 do
	for o = 1, 3 do
		animalsTable["talent"..i..o] = false
	end
end
animalsTable.artifactWeapon = {
	weaponPerks = {}
}

function animalsTable.createMainFrame()
	CreateFrame("Frame", "animalsMainFrame", nil)
	animalsMainFrame:RegisterEvent("PLAYER_LOGIN")
	animalsMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	animalsMainFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
	animalsMainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	animalsMainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	animalsMainFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	animalsMainFrame:SetScript("OnEvent", animalsTable.respondMainFrame)
end

function animalsTable.respondMainFrame(self, originalEvent, ...) -- todo: player_entering_world and loading_screen_disabled
	if originalEvent == "PLAYER_ENTERING_WORLD" then
		if not animalsDataPerChar.class then animalsDataPerChar.class = select(2, UnitClass("player")) end
		animalsTable.currentSpec = animalsTable.currentSpec or GetSpecialization()
		animalsTable.cacheTalents()
		animalsTable.cacheGear()
		animalsTable.preventSlaying = true
		animalsTable.targetAnimals = {}
		animalsTable.targetHumans = {}
		animalsTable.monitorAnimationToggle("off")
	elseif originalEvent == "LOADING_SCREEN_DISABLED" then
		animalsTable.preventSlaying = false
		animalsTable.allowSlaying  = false
		animalsTable.monitorAnimationToggle("off")
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
			animalsTable["talent"..i..o] = select(4, GetTalentInfo(i, o, 1))
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
		if not ArtifactFrame or not ArtifactFrame:IsShown() then
			closeAfter = true
			SocketInventoryItem(16)
		end
		local spellID, perkCost, perkCurrentRank, perkMaxRank, perkBonusRanks, x, y, prereqsMet, isStart, isGoldMedal, isFinal
		for i, powerID in ipairs(C_ArtifactUI.GetPowers()) do
			spellID, perkCost, perkCurrentRank, perkMaxRank, perkBonusRanks, x, y, prereqsMet, isStart, isGoldMedal, isFinal = C_ArtifactUI.GetPowerInfo(powerID)
			animalsTable.artifactWeapon.weaponPerks[spellID] = {
				-- cost = perkCost,
				currentRank = perkCurrentRank,
				maxRank = perkMaxRank,
				bonusRanks = perkBonusRanks,
			}
		end
		if ArtifactFrame:IsShown() and closeAfter then HideUIPanel(ArtifactFrame) end
	end
end

function animalsTable.createSlayingFrame()
	CreateFrame("Frame", "animalsSlayingFrame", animalsMainFrame)
	animalsSlayingFrame:SetScript("OnUpdate", animalsTable.startSlaying)
end

function animalsTable.startSlaying()
	if not FireHack or not animalsTable.allowSlaying or not animalsDataPerChar.class or UnitIsDeadOrGhost("player") then return end
	if not animalsTable.ranOnce then
		if not ReadFile(GetWoWDirectory().."\\Interface\\Addons\\Animals\\animalsVersion.txt") then
			print("Animals: No animalsVersion.txt found.")
		else
		    DownloadURL("raw.githubusercontent.com", "/g1zstar/Animals/master/animalsVersion.txt", true, animalsTable.checkUpdate, animalsTable.revisionCheckFailed)
		end
		animalsTable.ranOnce = true
	end

	animalsTable.randomNumberGenerator = math.random(animalsDataPerChar.chaosMin, animalsDataPerChar.chaosMax)*.001

	if animalsTable.currentSpec and animalsTable[animalsDataPerChar.class..animalsTable.currentSpec] then
		animalsTable.iterationNumer = animalsTable.iterationNumer +1
		animalsTable[animalsDataPerChar.class..animalsTable.currentSpec]()
	elseif animalsTable[animalsDataPerChar.class..9] then
		animalsTable.iterationNumer = animalsTable.iterationNumer + 1
		animalsTable[animalsDataPerChar.class]()
	else
		print("Animals: No idea how to slay with this combination.\n"..animalsDataPerChar.class..animalsTable.currentSpec)
		animalsTable.allowSlaying = false
		animalsTable.monitorAnimationToggle("off")

	end
end

function animalsTable.checkUpdate(revision)
	if ReadFile(GetWoWDirectory().."\\Interface\\Addons\\Animals\\animalsVersion.txt") < revision then print("Animals: Update Available") return end
end

function animalsTable.revisionCheckFailed()
	print("Animals: Could not check for updates.")
end

function animalsTable.createSlayingInformationFrame()
	animalsTable.animalsSize = 0
	animalsTable.humansSize = 0
	animalsTable.targetAnimals = {}
	animalsTable.targetHumans = {}
	animalsTable.TTDM, animalsTable.TTD = {}, {}

	animalsTable.combatStartTime = math.huge
	
	CreateFrame("Frame", "slayingInformationFrame", animalsMainFrame)
	slayingInformationFrame:RegisterEvent("PLAYER_DEAD")
	slayingInformationFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	slayingInformationFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	slayingInformationFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	slayingInformationFrame:RegisterEvent("COMBAT_LOG_EVENT")
	slayingInformationFrame:SetScript("OnEvent", animalsTable.respondSlayingInformationFrame)
	slayingInformationFrame:SetScript("OnUpdate", animalsTable.iterateSlayingInformationFrame)
end

function animalsTable.iterateSlayingInformationFrame()
	if not FireHack or animalsTable.preventSlaying or UnitIsDeadOrGhost("player") then return end

	if not animalsDataPerChar.animals and animalsTable.animalsSize > 0 then animalsTable.targetAnimals = {} end
	if not animalsDataPerChar.humans and animalsTable.humansSize > 0 then animalsTable.targetHumans = {} end

	animalsTable.animalsSize = #animalsTable.targetAnimals
	animalsTable.humansSize = #animalsTable.targetHumans

	local unitPlaceholder = nil
	for i = 1, ObjectCount() do
	    unitPlaceholder = ObjectWithIndex(i)
	    if (not animalsDataPerChar.animals or not tContains(animalsTable.targetAnimals, unitPlaceholder)) and (not animalsDataPerChar.humans or animalsTable.humanNotDuplicate(unitPlaceholder))
	    and ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder)
	    and bit.band(ObjectType(unitPlaceholder), 0x8) > 0
	    then
	        if bit.band(ObjectType(unitPlaceholder), 0x8) > 0 and bit.band(ObjectType(unitPlaceholder), 0x10) == 0 then -- mobs
	            if animalsDataPerChar.humans and UnitInParty(unitPlaceholder) then -- friendly mobs
	                if animalsTable.humansAuraBlacklist(unitPlaceholder) then
	                    animalsTable.targetHumans[animalsTable.humansSize+1] = {Player = unitPlaceholder, Stats = {Position = {true,true,true}}, Role = UnitGroupRolesAssigned(unitPlaceholder)}
	                    animalsTable.humansSize = animalsTable.humansSize + 1
	                end
	            elseif animalsDataPerChar.animals and not UnitInParty(unitPlaceholder) and animalsTable.health(unitPlaceholder) > 0 and UnitCanAttack("player", unitPlaceholder) then -- hostile mobs
	                if not tContains(animalsTable.animalNamesToIgnore, UnitName(unitPlaceholder)) and not tContains(animalsTable.animalTypesToIgnore, UnitCreatureType(unitPlaceholder)) and animalsTable.animalsAuraBlacklist(unitPlaceholder) then
	                    animalsTable.targetAnimals[animalsTable.animalsSize+1] = unitPlaceholder
	                    animalsTable.animalsSize = animalsTable.animalsSize + 1
	                end
	            end
	        elseif animalsDataPerChar.humans and bit.band(ObjectType(unitPlaceholder), 0x10) > 0 and UnitInParty(unitPlaceholder) then -- friendly players
	            if animalsTable.humansAuraBlacklist(unitPlaceholder) then
	                animalsTable.targetHumans[animalsTable.humansSize+1] = {Player = unitPlaceholder, Stats = {Position = {true,true,true}}, Role = UnitGroupRolesAssigned(unitPlaceholder)}
	                animalsTable.humansSize = animalsTable.humansSize + 1
	            end
	        end
	    end
	end

	for i = 1, animalsTable.animalsSize do
	    unitPlaceholder = animalsTable.targetAnimals[i]
	    if not animalsDataPerChar.animals or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or animalsTable.health(unitPlaceholder) == 0 or not UnitCanAttack("player", unitPlaceholder) or not animalsTable.animalsAuraBlacklist(unitPlaceholder) then _G["removeTargetAnimals"..i] = true end
	end
	for i = animalsTable.animalsSize, 1, -1 do
	    if _G["removeTargetAnimals"..i] then
	        table.remove(animalsTable.targetAnimals, i)
	        _G["removeTargetAnimals"..i] = false
	    end
	end
	for i = 1, animalsTable.humansSize do
		unitPlaceholder = animalsTable.targetHumans[i].Player
		if not animalsDataPerChar.humans or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or UnitName(unitPlaceholder) == "Unknown" then _G["removeTargetHumans"..i] = true end
	end
	for i = animalsTable.humansSize, 1, -1 do
		if _G["removeTargetHumans"..i] then
			table.remove(animalsTable.targetHumans, i)
			_G["removeTargetHumans"..i] = false
		end
	end

	animalsTable.animalsSize = #animalsTable.targetAnimals
	animalsTable.humansSize = #animalsTable.targetHumans

	for i = 1, animalsTable.animalsSize do
	    unitPlaceholder = animalsTable.targetAnimals[i]
	    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and (UnitAffectingCombat(unitPlaceholder) or tContains(animalsTable.dummiesID, animalsTable.getUnitID(unitPlaceholder))) then
	        animalsTable.TTDF(unitPlaceholder)
	    end
	end

	for k,v in pairs(animalsTable.TTD) do if not ObjectExists(k) or not UnitExists(k) or animalsTable.health(k) == 0 or not UnitCanAttack("player", k) or not animalsTable.animalsAuraBlacklist(k) then animalsTable.TTD[k] = nil end end
end

function animalsTable.respondSlayingInformationFrame(self, registeredEvent, ...)
	if not FireHack or animalsTable.preventSlaying then return end
	if registeredEvent == "PLAYER_DEAD" then
	elseif registeredEvent == "PLAYER_REGEN_DISABLED" then
	    animalsTable.combatStartTime = GetTime()
	    animalsTable.cacheTalents()
	    animalsTable.cacheGear()
	elseif registeredEvent == "PLAYER_REGEN_ENABLED" then
	    -- animalsTable.MONK.lastCast = 0
	elseif registeredEvent == "COMBAT_LOG_EVENT_UNFILTERED" then
	    local timeNow = GetTime()
	    local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, failedType = ...

	    if tContains(animalsTable.animalsThatInterrupt, sourceName) then
	    	if event == "SPELL_CAST_START" then
	    	elseif event == "SPELL_CAST_FAILED" then
	    	end
	    	return
	    end

	    if sourceName ~= UnitName("player") then return end
        animalsTable.waitForCombatLog = false

	    if event == "SPELL_CAST_START" then
	    elseif event == "SPELL_CAST_FAILED" then
	        -- animalsTable.throttleSlaying = 0
	        animalsTable.logToFile(spellName..": Unthrottling "..failedType)

	        -- Demon Hunter
	        	if spellID == 198793 then -- Vengeful Retreat
	        		SetHackEnabled("Fly", false)
	        		return
	        	end
	        return
	    elseif event == "SPELL_CAST_SUCCESS" then 
	        -- animalsTable.throttleSlaying = (GetTime()+math.random(animalsDataPerChar.chaosMin, animalsDataPerChar.chaosMax)*.001)+animalsTable.spellCDDuration(61304)

	        -- Monk
	            if animalsDataPerChar.class == "MONK" and animalsTable.currentSpec == 3 and tContains(animalsTable.MONK.hitComboTable, spellID) then
	                animalsTable.MONK.lastCast = spellID
	                return
	            end
	    elseif event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
	    elseif event == "SPELL_AURA_APPLIED_DOSE" then -- Never seen this before. it's used for buffs that gain stacks without refreshing duration aka void form (mongoose bite?)
	    elseif event == "SPELL_AURA_REMOVED" then
	    elseif event == "SPELL_DAMAGE" then -- projectile unthrottles would go in here
	    	-- Demon Hunter
		    	if spellID == 192611 then
		    		animalsTable.DEMONHUNTER.castFelRush = false
		    		StopMoving()
		    		return
		    	end
	    		if spellID == 198813 then -- Vengeful Retreat
	    			animalsTable.DEMONHUNTER.castVengefulRetreat = false
	    			return
	    		end
	    elseif event == "SPELL_PERIODIC_DAMAGE" then
	    end
	end
end

-- Ace Stuff
    local options = {
        type = "group",
        name = "Animals Settings",
        args = {
            General = {
                name = "General Settings",
                type = "group",
                order = 1,
                args = {
                    interrupt = {
                        order = 2,
                        type = "toggle",
                        name = "Interrupt",
                        desc = "Use interrupt?",
                        descStyle = "inline",
                        get = function() return animalsDataPerChar.interrupt end,
                        set = function(i, v) animalsDataPerChar.interrupt = v end
                    },
                    TauntTrainer = {
                        order = 1,
                        type = "toggle",
                        name = "Taunt",
                        desc = "Use taunt?\n(Set other tank as focus.)",
                        descStyle = "inline",
                        get = function() return animalsDataPerChar.taunt end,
                        set = function(i,v) animalsDataPerChar.taunt = v end
                    },
                    ThokThrottle = {
                        order = 3,
                        type = "toggle",
                        name = "Thok",
                        desc = "Use stop casting? (Not 100% success rate.)",
                        descStyle = "inline",
                        get = function() return animalsDataPerChar.thok end,
                        set = function(i,v) animalsDataPerChar.thok = v end
                    },
                    LOS = {
                        order = 5,
                        type = "toggle",
                        name = "LoS",
                        desc = "blargh",
                        get = function() return animalsDataPerChar.los end,
                        set = function(i,v) animalsDataPerChar.los = v end
                    },
                    CC = {
                        order = 6,
                        type = "toggle",
                        name = "Check CC?",
                        get = function() return animalsDataPerChar.cced end,
                        set = function(i,v) animalsDataPerChar.cced = v end
                    },
                    Dummy = {
                        order = 7,
                        type = "select",
                        name = "Dummy TTD",
                        values = {"Mixed Mode", "Execute", "Healthy"},
                        get = function() return animalsDataPerChar.dummyTTDMode or 1 end,
                        set = function(i,v) animalsDataPerChar.dummyTTDMode = v end
                    },
                    Newline2 = {
                        order = 8,
                        type = "header",
                        name = ""
                    },
                    DAMAGING = {
                        order = 10,
                        type = "toggle",
                        name = "Slaying",
                        desc = "Enable this if you're using this addon to slay animals.",
                        descStyle = "inline",
                        get = function() return animalsDataPerChar.animals end,
                        set = function(i,v) animalsDataPerChar.animals = v end
                    },
                    Healing = {
                        order = 9,
                        type = "toggle",
                        name = "Healing",
                        desc = "Enable this if you're using this addon to heal humans.",
                        descStyle = "inline",
                        get = function() return animalsDataPerChar.humans end,
                        set = function(i,v) animalsDataPerChar.humans = v end
                    },
                }
            },
            Monk = {
                name = "Monk Settings",
                type = "group",
                order = 2,
                hidden = function() return animalsDataPerChar.class ~= "MONK" end,
                args = {
                },
            },
            Debug = {
                name = "Debug Settings",
                type = "group",
                order = math.huge,
                hidden = function() return false end,
                args = {
                    Log = {
                        order = 1,
                        type = "toggle",
                        name = "Log",
                        get = function() return animalsDataPerChar.log end,
                        set = function(i,v) animalsDataPerChar.log = v end
                    },
                }
            }
        }
    }

    AC:RegisterOptionsTable("Animals_Settings", options)