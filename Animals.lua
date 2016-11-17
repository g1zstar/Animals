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
	-- weaponPerks = {}
}

function animalsTable.createMainFrame()
	CreateFrame("Frame", "animalsMainFrame", nil)
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
		if not cacheTalentsQueued then C_Timer.After(3, animalsTable.cacheTalents); cacheTalentsQueued = true end
		if not cacheGearQueued then C_Timer.After(3, animalsTable.cacheGear); cacheGearQueued = true end
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
		if not cacheTalentsQueued then C_Timer.After(3, animalsTable.cacheTalents); cacheTalentsQueued = true end
	elseif originalEvent == "PLAYER_TALENT_UPDATE" then
		if not cacheTalentsQueued then C_Timer.After(3, animalsTable.cacheTalents); cacheTalentsQueued = true end
	elseif originalEvent == "PLAYER_EQUIPMENT_CHANGED" then
		if not cacheGearQueued then C_Timer.After(3, animalsTable.cacheGear); cacheGearQueued = true end
	end
end

local cacheTalentsQueued
function animalsTable.cacheTalents()
	for i = 1, 7 do
		for o = 1, 3 do
			animalsTable["talent"..i..o] = select(4, GetTalentInfo(i, o, 1))
		end
	end
	cacheTalentsQueued = false
end

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
local cacheGearQueued = false
function animalsTable.cacheGear()
	for k,v in pairs(gear) do
	   gear[k] = GetInventoryItemID("player", GetInventorySlotInfo(k.."Slot")) or 0
	end
	animalsTable.equippedGear = gear
	if HasArtifactEquipped() then
		if not animalsTable.artifactWeapon[gear.MainHand] then animalsTable.artifactWeapon[gear.MainHand] = {weaponPerks = {}} end
		local closeAfter = false
		if not ArtifactFrame or not ArtifactFrame:IsShown() then
			closeAfter = true
			SocketInventoryItem(16)
		end

		local item_id = C_ArtifactUI.GetArtifactInfo()
		if not item_id or item_id == 0 then if ArtifactFrame:IsShown() and closeAfter then HideUIPanel(ArtifactFrame) return end end
		local powers = C_ArtifactUI.GetPowers()
		if not powers then animalsTable.cacheGear() return end
		
		local spellID, perkCost, perkCurrentRank, perkMaxRank, perkBonusRanks, x, y, prereqsMet, isStart, isGoldMedal, isFinal
		for i = 1, #powers do
			local power_id = powers[i]
			spellID, perkCost, perkCurrentRank, perkMaxRank, perkBonusRanks, x, y, prereqsMet, isStart, isGoldMedal, isFinal = C_ArtifactUI.GetPowerInfo(power_id)
			animalsTable.artifactWeapon[gear.MainHand].weaponPerks[spellID] = {
				-- cost = perkCost,
				currentRank = perkCurrentRank,
				maxRank = perkMaxRank,
				bonusRanks = perkBonusRanks,
			}
		end
		if ArtifactFrame:IsShown() and closeAfter then HideUIPanel(ArtifactFrame) end
	end
	cacheGearQueued = false
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
	if tonumber(ReadFile(GetWoWDirectory().."\\Interface\\Addons\\Animals\\animalsVersion.txt")) < tonumber(revision) then print("Animals: Update Available. Latest Version: "..revision..", Current Version: "..ReadFile(GetWoWDirectory().."\\Interface\\Addons\\Animals\\animalsVersion.txt")) return end
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
	-- slayingInformationFrame:RegisterEvent("COMBAT_LOG_EVENT")
	slayingInformationFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	slayingInformationFrame:RegisterEvent("PLAYER_DEAD")
	slayingInformationFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	slayingInformationFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	slayingInformationFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
	slayingInformationFrame:RegisterEvent("UNIT_SpELLCAST_FAILED_QUIET")
	slayingInformationFrame:RegisterEvent("UNIT_SPELLCAST_START")
	slayingInformationFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
	slayingInformationFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	slayingInformationFrame:SetScript("OnEvent", animalsTable.respondSlayingInformationFrame)
	slayingInformationFrame:SetScript("OnUpdate", animalsTable.iterateSlayingInformationFrame)
end

local elapsedTime = 0
function animalsTable.iterateSlayingInformationFrame(self, elapsed)
	if not FireHack or animalsTable.preventSlaying or UnitIsDeadOrGhost("player") then return end

	if not animalsDataPerChar.animals and animalsTable.animalsSize > 0 then animalsTable.targetAnimals = {} end
	if not animalsDataPerChar.humans and animalsTable.humansSize > 0 then animalsTable.targetHumans = {} end

	local zone = GetCurrentMapAreaID()

	animalsTable.animalsSize = #animalsTable.targetAnimals
	animalsTable.humansSize = #animalsTable.targetHumans

	elapsedTime = elapsedTime + elapsed
	if elapsedTime >= 1 or zone ~= 1115 then
		elapsedTime = 0

		local unitPlaceholder = nil
		for i = 1, ObjectCount() do
		    unitPlaceholder = ObjectWithIndex(i)
		    if (not animalsDataPerChar.animals or not tContains(animalsTable.targetAnimals, unitPlaceholder)) and (not animalsDataPerChar.humans or animalsTable.humanNotDuplicate(unitPlaceholder))
		    and ObjectIsType(unitPlaceholder, ObjectTypes.Unit)
		    and UnitExists(unitPlaceholder) and UnitIsVisible(unitPlaceholder)
		    then
		        if ObjectIsType(unitPlaceholder, ObjectTypes.Unit) and not ObjectIsType(unitPlaceholder, ObjectTypes.Player) then -- mobs
		            if animalsDataPerChar.humans and UnitInParty(unitPlaceholder) then -- friendly mobs
		                if animalsTable.animalsAuraBlacklist(unitPlaceholder) then
		                    animalsTable.targetHumans[animalsTable.humansSize+1] = {Player = unitPlaceholder, Role = (ObjectName(unitPlaceholder) == "Oto the Protector" and "TANK" or UnitGroupRolesAssigned(unitPlaceholder))}
		                    animalsTable.humansSize = animalsTable.humansSize + 1
		                end
		            elseif animalsDataPerChar.animals and not UnitInParty(unitPlaceholder) and animalsTable.health(unitPlaceholder) > 0 and UnitCanAttack("player", unitPlaceholder) then -- hostile mobs
		                if (zone ~= 1115 or animalsTable.animalIsTappedByPlayer(unitPlaceholder)) and not tContains(animalsTable.animalNamesToIgnore, UnitName(unitPlaceholder)) and not tContains(animalsTable.animalTypesToIgnore, UnitCreatureType(unitPlaceholder)) and animalsTable.animalsAuraBlacklist(unitPlaceholder) then
		                    animalsTable.targetAnimals[animalsTable.animalsSize+1] = unitPlaceholder
		                    animalsTable.animalsSize = animalsTable.animalsSize + 1
		                end
		            end
		        elseif animalsDataPerChar.humans and ObjectIsType(unitPlaceholder, ObjectTypes.Player) and (UnitIsUnit("player", unitPlaceholder) or UnitInParty(unitPlaceholder)) and animalsTable.humanNotDuplicate(unitPlaceholder) then -- friendly players
		            if animalsTable.humansAuraBlacklist(unitPlaceholder) then
		                animalsTable.targetHumans[animalsTable.humansSize+1] = {Player = unitPlaceholder, Role = UnitGroupRolesAssigned(unitPlaceholder)}
		                animalsTable.humansSize = animalsTable.humansSize + 1
		            end
		        end
		    end
		end
	end

	for i = 1, animalsTable.animalsSize do
	    unitPlaceholder = animalsTable.targetAnimals[i]
	    if not animalsDataPerChar.animals or not ObjectExists(unitPlaceholder) or UnitIsDeadOrGhost(unitPlaceholder) or not UnitCanAttack("player", unitPlaceholder) or not animalsTable.animalsAuraBlacklist(unitPlaceholder) then _G["removeTargetAnimals"..i] = true end
	end
	for i = animalsTable.animalsSize, 1, -1 do
	    if _G["removeTargetAnimals"..i] then
	        table.remove(animalsTable.targetAnimals, i)
	        _G["removeTargetAnimals"..i] = false
	    end
	end
	for i = 1, animalsTable.humansSize do
		unitPlaceholder = animalsTable.targetHumans[i].Player
		if not animalsDataPerChar.humans or not ObjectExists(unitPlaceholder) or UnitName(unitPlaceholder) == "Unknown" or (not UnitInParty(unitPlaceholder) and not UnitIsUnit("player", unitPlaceholder)) then _G["removeTargetHumans"..i] = true end
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
	    if ObjectExists(unitPlaceholder) and (UnitAffectingCombat(unitPlaceholder) or tContains(animalsTable.dummiesID, ObjectID(unitPlaceholder))) then
	        animalsTable.TTDF(unitPlaceholder)
	    end
	end

	for k,v in pairs(animalsTable.TTD) do if not ObjectExists(k) or UnitIsDeadOrGhost(k) == 0 or not animalsTable.animalsAuraBlacklist(k) then animalsTable.TTD[k] = nil end end
end

function animalsTable.respondSlayingInformationFrame(self, registeredEvent, ...)
	if not FireHack or animalsTable.preventSlaying then return end
	if registeredEvent == "PLAYER_DEAD" then
	elseif registeredEvent == "PLAYER_REGEN_DISABLED" then
	    animalsTable.combatStartTime = GetTime()
	    if not cacheTalentsQueued then C_Timer.After(1, animalsTable.cacheTalents); cacheTalentsQueued = true end
	    if not cacheGearQueued then C_Timer.After(1, animalsTable.cacheGear); cacheGearQueued = true end
	elseif registeredEvent == "PLAYER_REGEN_ENABLED" then
	    -- animalsTable.MONK.lastCast = 0
	elseif registeredEvent == "UNIT_SPELLCAST_START" or registeredEvent == "UNIT_SPELLCAST_CHANNEL_START" then
		local unitID, __, __, __, spellID = ...
		if not UnitIsUnit(unitID, "player") then return end
		animalsTable.throttleSlaying = 1
	elseif registeredEvent == "UNIT_SPELLCAST_STOP" or registeredEvent == "UNIT_SPELLCAST_CHANNEL_STOP" then
		local unitID, __, __, __, spellID = ...
		if not UnitIsUnit(unitID, "player") then return end
		animalsTable.throttleSlaying = 0
	elseif registeredEvent == "UNIT_SPELLCAST_SUCCEEDED" then
		local unitID, __, __, __, spellID = ...
		if not UnitIsUnit(unitID, "player") then return end
		animalsTable.throttleSlaying = 0
		if animalsDataPerChar.class == "MONK" and animalsTable.currentSpec == 3 and tContains(animalsTable.MONK.hitComboTable, spellID) then
			animalsTable.MONK.lastCast = spellID
			return
		end
	elseif registeredEvent == "UNIT_SPELLCAST_FAILED" then
		local unitID, __, __, __, spellID = ...
		if not UnitIsUnit(unitID, "player") then return end
		-- animalsTable.logToFile(spellName..": Unthrottling "..failedType)

        -- Demon Hunter
        	if spellID == 198793 then -- Vengeful Retreat
        		SetHackEnabled("Fly", false)
        		return
        	end
	elseif registeredEvent == "UNIT_SPELLCAST_FAILED_QUIET" then
		local unitID, __, __, __, spellID = ...
		if not UnitIsUnit(unitID, "player") then return end
		-- animalsTable.logToFile(spellName..": Unthrottling "..failedType)

        -- Demon Hunter
        	if spellID == 198793 then -- Vengeful Retreat
        		SetHackEnabled("Fly", false)
        		return
        	end
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

	    if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
	    	-- Priest
		    	if spellID == 194384 then
		    		animalsTable.setWaitForAura(false)
		    		return
		    	end

	    	-- Rogue
	    		if spellID == 13877 then
	    			setBF_CD(0)
	    			return
	    		end
	    elseif event == "SPELL_AURA_APPLIED_DOSE" then -- Never seen this before. it's used for buffs that gain stacks without refreshing duration aka void form (mongoose bite?)
	    elseif event == "SPELL_AURA_REMOVED" then
	    	-- Rogue
	    		if spellID == 13877 then
	    			setBF_CD(0)
	    			return
	    		end
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
            Rogue = {
            	name = "Rogue Settings",
            	type = "group",
            	order = 2,
            	hidden = function() return animalsDataPerChar.class ~= "ROGUE" end,
            	args = {
            		MarkedForDeath = {
            			order = 1,
            			type = "toggle",
            			name = "MFD",
            			desc = "Tie Marked for Death to CDs?",
            			descStyle = "inline",
            			get = function() return animalsDataPerChar.markedForDeath end,
            			set = function(i,v) animalsDataPerChar.markedForDeath = v end
            		}
            	}
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