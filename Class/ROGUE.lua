local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil

animalsTable.ROGUE = {
}

local energy = animalsTable.pp
local combo_points = animalsTable.cp

local shadowmeld = 58984
local blood_fury
local berserking
local arcane_torrent

local vanish = 1856
local kick = 1766

local the_dreadlords_deceit = 228224

local function vanishPartyCheck(target)
	if GetNumGroupMembers() < 2 then return false end
	if select(2, GetInstanceInfo()) ~= "none" and GetNumGroupMembers() > 1 then return true end
	if not target then target = "target" end
	local isTanking, status, scaledPercent, rawPercent, threatValue
	if GetNumGroupMembers() <= 5 then
		for i = 1, 4 do
			if UnitExists("party"..i) then
				isTanking, __, scaledPercent = UnitDetailedThreatSituation(("party"..i), target)
				if isTanking or scaledPercent > 0 then return true end
			end
		end
	elseif GetNumGroupMembers() > 5 then
		for i = 1, 40 do
			if UnitExists("raid"..i) then
				isTanking, __, scaledPercent = UnitDetailedThreatSituation(("raid"..i), target)
				if isTanking or scaledPercent > 0 then return true end
			end
		end
	end
end

-- do -- Assassination
-- 	local envenom_condition = false
-- 	local envenom_precheck = false
-- 	local rupture_pmultiplier = {}
-- 	-- talents=2110111

-- 	local mutilate = 1329
-- 	local garrote  = 703
-- 	local rupture = 1943
-- 	local envenom = 32645
-- 	local fan_of_knives = 51723
-- 	local deadly_poison = 2818

-- 	local vendetta = 79140

-- 	local elaborate_planning = 193641
-- 	local exsanguinate = 200806
-- 	local death_from_above = 152150
-- 	local hemorrhage = 16511
-- 	local agonizing_poison = 200803

-- 	local artifact = 128870
-- 	local kingsbane = 192759
-- 	local bag_of_tricks = 192657
-- 	local urge_to_kill = 192384

-- 	local function envenom_condition_new()
-- 		if animalsTable.spellCanAttack(rupture, "target") and animalsTable.auraRemaining("target", rupture, (animalsTable.talent31 and 6 or 7.2), "", "PLAYER") then return false end
-- 		if animalsTable.aoe then
-- 			for i = 1, animalsTable.animalsSize do
-- 				rotationUnitIterator = animalsTable.targetAnimals[i]
-- 				if animalsTable.spellCanAttack(rupture, rotationUnitIterator) and animalsTable.auraRemaining(rotationUnitIterator, rupture, (animalsTable.talent31 and 6 or 7.2), "", "PLAYER") then return false end
-- 			end
-- 		end
-- 		return true
-- 	end

-- 	local function cds()
-- 		if animalsTable.cds then
-- 			-- actions.cds=potion,name=old_war,if=buff.bloodlust.react|target.time_to_die<=25|debuff.vendetta.up
-- 			-- actions.cds+=/use_item,slot=trinket1,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
-- 			-- actions.cds+=/use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
-- 			-- actions.cds+=/blood_fury,if=debuff.vendetta.up
-- 			-- actions.cds+=/berserking,if=debuff.vendetta.up
-- 			-- actions.cds+=/arcane_torrent,if=debuff.vendetta.up&energy.deficit>50
-- 			-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|combo_points.deficit>=5
-- 			if animalsTable.spellCanAttack(vendetta) and animalsTable.talent63 and animalsTable.spellCDDuration(exsanguinate) < 5 and animalsTable.aura("target", rupture, "", "PLAYER") then animalsTable.cast(_, vendetta, false, false, false, "SpellToInterrupt", "Vendetta: Exsanguinate") return end
-- 			if animalsTable.spellCanAttack(vendetta) and not animalsTable.talent63 and (animalsTable.getTraitCurrentRank(artifact, urge_to_kill) == 0 or energy("deficit") >= 70) then animalsTable.cast(_, vendetta, false, false, false, "SpellToInterrupt", "Vendetta") return end
-- 			if animalsTable.spellIsReady(vanish) and vanishPartyCheck() then
-- 				if animalsTable.talent63 and animalsTable.talent21 and combo_points() >= (animalsTable.talent31 and 6 or 5) and animalsTable.spellCDDuration(exsanguinate) < 1 then animalsTable.cast(_, vanish, false, false, false, "SpellToInterrupt", "Vanish: Nightstalker Exsanguinate") return end
-- 				if (not animalsTable.talent63 and animalsTable.talent21 and combo_points() >= (animalsTable.talent31 and 6 or 5) and animalsTable.auraRemaining("target", rupture, (animalsTable.talent31 and 8.4 or 7.2), "", "PLAYER")) or (animalsTable.talent22 and animalsTable.auraRemaining("target", garrote, 5.4, "", "PLAYER")) then animalsTable.cast(_, vanish, false, false, false, "SpellToInterrupt", "Vanish") return end
-- 			end
-- 		end
-- 	end

-- 	function animalsTable.ROGUE1()
-- 		if UnitAffectingCombat("player") then
-- 			animalsTable.multiDoT(GetSpellInfo(rupture), 40)
-- 			if animalsTable.validAnimal() then
-- 				if animalsTable.talent63 and animalsTable.spellCanAttack(exsanguinate) and (animalsTable.debugTable["ogSpell"] == rupture or animalsTable.debugTable["ogSpell"] == exsanguinate) and not animalsTable.auraRemaining("target", rupture, 4+4*(animalsTable.talent31 and 6 or 5), "", "PLAYER") then animalsTable.cast(_, exsanguinate, false, false, false, "SpellToInterrupt", "Exsanguinate") return end
-- 				if animalsTable.spellCanAttack(rupture) and animalsTable.talent21 and IsStealthed() then animalsTable.cast(_, rupture, false, false, false, "SpellToInterrupt", "Rupture: Stealthed") return end
-- 				-- actions+=/garrote,if=talent.subterfuge.enabled&stealthed
-- 				cds()
-- 				if animalsTable.spellCanAttack(rupture) and animalsTable.talent63 and combo_points() >= (animalsTable.talent31 and 6 or 5) and animalsTable.spellCDDuration(exsanguinate) < 1 then animalsTable.cast(_, rupture, false, false, false, "SpellToInterrupt", "Rupture: Exsanguinate Up") return end
-- 				if animalsTable.spellIsReady(rupture) and combo_points() >= (animalsTable.talent31 and 6 or 5)-1 then
-- 					if animalsTable.spellCanAttack(rupture) and animalsTable.auraRemaining("target", rupture, (animalsTable.talent31 and 6 or 7.2), "", "PLAYER") and (not animalsTable.talent63 or animalsTable.spellCDDuration(exsanguinate) <= 26 or animalsTable.auraRemaining("target", rupture, 1.5, "", "PLAYER")) and animalsTable.getTTD() < math.huge and animalsTable.getTTD() > 4 then animalsTable.cast(_, rupture, false, false, false, "SpellToInterrupt", "Rupture: AoE") return end
-- 					table.sort(animalsTable.targetAnimals, animalsTable.sortAnimalsByHighestTTD)
-- 					if animalsTable.aoe then
-- 						for i = 1, animalsTable.animalsSize do
-- 							rotationUnitIterator = animalsTable.targetAnimals[i]
-- 							if animalsTable.getTTD(rotationUnitIterator) < math.huge and animalsTable.getTTD(rotationUnitIterator) > 4 then
-- 								if animalsTable.spellCanAttack(rupture, rotationUnitIterator) and animalsTable.auraRemaining(rotationUnitIterator, rupture, (animalsTable.talent31 and 6 or 7.2), "", "PLAYER") and (not animalsTable.talent63 or animalsTable.spellCDDuration(exsanguinate) <= 26 or animalsTable.auraRemaining(rotationUnitIterator, rupture, 1.5, "", "PLAYER")) then animalsTable.cast(rotationUnitIterator, rupture, false, false, false, "SpellToInterrupt", "RUpture: AoE") return end
-- 							else
-- 								break
-- 							end
-- 						end
-- 					end
-- 				end
-- 				if animalsTable.getTraitCurrentRank(artifact, kingsbane) == 1 and animalsTable.spellCanAttack(kingsbane) and animalsTable.talent63 and animalsTable.aura("target", rupture, "", "PLAYER") and select(6, animalsTable.aura("target", rupture, "", "PLAYER")) < 24 and animalsTable.spellCDDuration(exsanguinate) > 26 then animalsTable.cast(_, kingsbane, false, false, false, "SpellToInterrupt", "Kingsbane: Exsanguinate") return end
-- 				if animalsTable.spellIsReady(garrote) or animalsTable.poolCheck(garrote) then
-- 					if animalsTable.auraRemaining("target", garrote, 5.4, "", "PLAYER") and (animalsTable.spellCDDuration(exsanguinate) < 33 or animalsTable.auraRemaining("target", garrote, 1.5, "", "PLAYER")) and animalsTable.getTTD() < math.huge and animalsTable.getTTD() > 4 then
-- 						if animalsTable.poolCheck(garrote) then return end
-- 						animalsTable.cast(_, garrote, false, false, false, "SpellToInterrupt", "Garrote")
-- 						return
-- 					end
-- 					for i = 1, animalsTable.animalsSize do
-- 						rotationUnitIterator = animalsTable.targetAnimals[i]
-- 						if animalsTable.auraRemaining(rotationUnitIterator, garrote, 5.4, "", "PLAYER") and (animalsTable.spellCDDuration(exsanguinate) < 33 or animalsTable.auraRemaining(rotationUnitIterator, garrote, 1.5, "", "PLAYER")) and animalsTable.getTTD(rotationUnitIterator) < math.huge and animalsTable.getTTD(rotationUnitIterator) > 4 then
-- 							if animalsTable.poolCheck(garrote) then return end
-- 							animalsTable.cast(rotationUnitIterator, garrote, false, false, false, "SpellToInterrupt", "Garrote")
-- 							return
-- 						end
-- 					end
-- 				end
-- 				if animalsTable.spellCanAttack(envenom) and (not animalsTable.talent63 or animalsTable.spellCDDuration(exsanguinate) > 2) and envenom_condition_new() --[[and (animalsTable.aoe and #animalsTable.tRupture >= animalsTable.playerCount(10)) ]]and ((not animalsTable.talent12 and combo_points() >= (animalsTable.talent31 and 6 or 5)) or (animalsTable.talent12 and combo_points() >= 3+(not animalsTable.talent63 and 1 or 0) and animalsTable.auraRemaining("player", elaborate_planning, 2))) then animalsTable.cast(_, envenom, false, false, false, "SpellToInterrupt", "Envenom") return end
-- 				if animalsTable.spellCanAttack(rupture) and animalsTable.talent63 and not animalsTable.aura("target", rupture, "", "PLAYER") and ((GetTime()-animalsTable.combatStartTime) > 10 or combo_points() >= 2+(animalsTable.getTraitCurrentRank(artifact, urge_to_kill) == 1 and 2 or 0)) then animalsTable.cast(_, rupture, false, false, false, "SpellToInterrupt", "Rupture: Exsanguinate Keep Up") return end
-- 				-- actions+=/hemorrhage,if=refreshable
-- 				-- actions+=/hemorrhage,target_if=max:dot.rupture.duration,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<=3
-- 				if animalsTable.getTraitCurrentRank(artifact, kingsbane) == 1 and animalsTable.spellCanAttack(kingsbane) and not animalsTable.talent63 and (animalsTable.aura("target", vendetta, "", "PLAYER") or animalsTable.spellCDDuration(vendetta) > 10) then animalsTable.cast(_, kingsbane, false, false, false, "SpellToInterrupt", "Kingsbane: Non Exsanguinate") return end
-- 				if animalsTable.spellIsReady(fan_of_knives) then
-- 					if animalsTable.aoe and animalsTable.playerCount(10, _, 3, ">=") then animalsTable.cast(_, fan_of_knives, false, false, false, "SpellToInterrupt", "Fan of Knives: AoE") return end
-- 					-- actions+=/fan_of_knives,if=buff.the_dreadlords_deceit.stack>=29
-- 				end
-- 				if animalsTable.spellIsReady(mutilate) then
-- 					if animalsTable.spellCanAttack(mutilate) and (not animalsTable.talent61 and animalsTable.auraRemaining("target", deadly_poison, 3.6, "", "PLAYER") or animalsTable.talent61 and animalsTable.auraRemaining("target", agonizing_poison, 3.6, "", "PLAYER")) then animalsTable.cast(_, mutilate, false, false, false, "SpellToInterrupt", "Mutilate: Poisons") return end
-- 					if animalsTable.aoe then
-- 						for i = 1, animalsTable.animalsSize do
-- 							rotationUnitIterator = animalsTable.targetAnimals[i]
-- 							if animalsTable.spellCanAttack(mutilate, rotationUnitIterator) and (not animalsTable.talent61 and animalsTable.auraRemaining(rotationUnitIterator, deadly_poison, 3.6, "", "PLAYER") or animalsTable.talent61 and animalsTable.auraRemaining(rotationUnitIterator, agonizing_poison, 3.6, "", "PLAYER")) then animalsTable.cast(rotationUnitIterator, mutilate, false, false, false, "SpellToInterrupt", "Mutilate: AoE Poisons") return end
-- 						end
-- 					end
-- 					if animalsTable.spellCanAttack(mutilate) then animalsTable.cast(_, mutilate, false, false, false, "SpellToInterrupt", "Mutilate") return end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- 33

do -- Assassination
-- 	--[[update to this
-- 	actions=exsanguinate,if=prev_gcd.rupture&dot.rupture.remains>4+4*cp_max_spend
-- 	actions+=/rupture,if=talent.nightstalker.enabled&stealthed
-- 	actions+=/garrote,if=talent.subterfuge.enabled&stealthed
-- 	actions+=/call_action_list,name=cds
-- 	actions+=/rupture,if=talent.exsanguinate.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1
-- 	actions+=/rupture,cycle_targets=1,if=combo_points>=cp_max_spend-talent.exsanguinate.enabled&refreshable&(!exsanguinated|remains<=1.5)&target.time_to_die-remains>4
-- 	actions+=/kingsbane,if=talent.exsanguinate.enabled&dot.rupture.exsanguinated
-- 	actions+=/pool_resource,for_next=1
-- 	actions+=/garrote,cycle_targets=1,if=refreshable&(!exsanguinated|remains<=1.5)&target.time_to_die-remains>4
-- 	# active_dot.rupture>=spell_targets.fan_of_knives meant that we don't want to envenom as long as we can multi-rupture
-- 	actions+=/envenom,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&!dot.rupture.refreshable&active_dot.rupture>=spell_targets.fan_of_knives&((!talent.elaborate_planning.enabled&combo_points>=cp_max_spend)|(talent.elaborate_planning.enabled&combo_points>=3+!talent.exsanguinate.enabled&buff.elaborate_planning.remains<2))
-- 	actions+=/rupture,if=talent.exsanguinate.enabled&!ticking&(time>10|combo_points>=2+artifact.urge_to_kill.enabled*2)
-- 	actions+=/hemorrhage,if=refreshable
-- 	actions+=/hemorrhage,target_if=max:dot.rupture.duration,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<=3
-- 	actions+=/kingsbane,if=!talent.exsanguinate.enabled&(debuff.vendetta.up|cooldown.vendetta.remains>10)
-- 	actions+=/fan_of_knives,if=spell_targets>=3|buff.the_dreadlords_deceit.stack>=29
-- 	actions+=/mutilate,cycle_targets=1,if=(!talent.agonizing_poison.enabled&dot.deadly_poison_dot.refreshable)|(talent.agonizing_poison.enabled&debuff.agonizing_poison.remains<debuff.agonizing_poison.duration*0.3)
-- 	actions+=/mutilate]]
	local envenom_condition = false
	local envenom_precheck = false
	local rupture_pmultiplier = {}
	-- talents=2110111

	local mutilate = 1329
	local garrote  = 703
	local rupture = 1943
	local envenom = 32645
	local fan_of_knives = 51723
	local deadly_poison = 2818

	local vendetta = 79140

	local elaborate_planning = 193641
	local exsanguinate = 200806
	local death_from_above = 152150
	local hemorrhage = 16511
	local agonizing_poison = 200803

	local artifact = 128870
	local kingsbane = 192759
	local bag_of_tricks = 192657
	local urge_to_kill = 192384

	local function cds()
		-- actions.cds=marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|combo_points.deficit>=5
		if animalsTable.cds then
			if animalsTable.spellCanAttack(vendetta) then
				-- actions.cds+=/vendetta,if=target.time_to_die<20
				if animalsTable.aura("target", rupture, "", "PLAYER") and (not animalsTable.talent63 or animalsTable.spellCDDuration(exsanguinate) < 1+4*(animalsTable.getTraitCurrentRank(artifact, urge_to_kill) == 0 and 1 or 0)) and (energy() < 55 or (GetTime()-animalsTable.combatStartTime) < 10 or animalsTable.aoe and animalsTable.playerCount(10, _, 2, ">=") or animalsTable.getTraitCurrentRank(artifact, urge_to_kill) == 0) then animalsTable.cast(_, vendetta, false, false, false, "SpellToInterrupt", "Vendetta") return end
			end
		end
		if animalsTable.spellIsReady(vanish) and vanishPartyCheck() then
			-- actions.cds+=/vanish,if=!dot.rupture.exsanguinated&((talent.subterfuge.enabled&combo_points<=2)|(talent.shadow_focus.enabled&combo_points.deficit>=2))
			if not animalsTable.talent63 and animalsTable.talent21 and combo_points() >= (animalsTable.talent31 and 6 or 5) and animalsTable.spellCDDuration(61304) == 0 and energy() >= 25 then animalsTable.cast(_, vanish, false, false, false, "SpellToInterrupt", "Vanish") return end
		end
	end

	local function garrote_apl()
		if not animalsTable.spellIsReady(garrote) and not animalsTable.poolCheck(garrote) then return false end
		if animalsTable.talent22 and combo_points("deficit") >= 1 and animalsTable.aoe and animalsTable.playerCount(10, _, 2, ">=") then
			if animalsTable.poolCheck(garrote) then return end
			if animalsTable.spellCanAttack(garrote) and not animalsTable.aura("target", garrote, "", "PLAYER") then animalsTable.cast(_, garrote, false, false, false, "SpellToInterrupt", "Garrote: Cleave") return end
			for i = 1, animalsTable.animalsSize do
				rotationUnitIterator = animalsTable.targetAnimals[i]
				if animalsTable.spellCanAttack(garrote, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, garrote, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, garrote, false, false, false, "SpellToInterrupt") return end
			end
		end
		if combo_points("deficit") >= 1 and (not animalsTable.aura("target", garrote, "", "PLAYER") or select(6, animalsTable.aura("target", garrote, "", "PLAYER")) >= 18) and animalsTable.auraRemaining("target", garrote, 5.4, "", "PLAYER") then
			if animalsTable.poolCheck(garrote) then return end
			if animalsTable.spellCanAttack(garrote) then animalsTable.cast(_, garrote, false, false, false, "SpellToInterrupt", "Garrote") return end
		end
	end

	local function getRupturePMult(unit)
		if not animalsTable.aura(unit, rupture, "", "PLAYER") then return 0 end
		return rupture_pmultiplier[UnitGUID(unit)]
	end

	local function envenom_condition()
		envenom_precheck = (not animalsTable.talent21 or animalsTable.spellCDDuration(vanish) >= 6 or not vanishPartyCheck()) and animalsTable.auraRemaining("player", elaborate_planning, 1.5) and (animalsTable.getTraitCurrentRank(artifact, bag_of_tricks) == 1 or not animalsTable.aoe or animalsTable.playerCount(10, _, 6, "<="))
		if not envenom_precheck then return false end
		if animalsTable.spellCanAttack(rupture, "target") and ((animalsTable.auraRemaining("target", rupture, 7.2, "", "PLAYER") and getRupturePMult("target") < 1.5) or animalsTable.auraRemaining("target", rupture, 6, "", "PLAYER")) then return false end
		if animalsTable.aoe then
			for i = 1, animalsTable.animalsSize do
				rotationUnitIterator = animalsTable.targetAnimals[i]
				if animalsTable.spellCanAttack(rupture, rotationUnitIterator) and ((animalsTable.auraRemaining(rotationUnitIterator, rupture, 7.2, "", "PLAYER") and getRupturePMult(rotationUnitIterator) < 1.5) or animalsTable.auraRemaining(rotationUnitIterator, rupture, 6, "", "PLAYER")) then return false end
			end
		end
		-- envenom_condition,value=!(dot.rupture.refreshable&dot.rupture.pmultiplier<1.5)&(!talent.nightstalker.enabled|cooldown.vanish.remains>=6)&dot.rupture.remains>=6&buff.elaborate_planning.remains<1.5&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
		return true
	end

	local function finish_noex()
		if animalsTable.spellIsReady(rupture) and combo_points() >= (animalsTable.talent31 and 6 or 5) then
			if animalsTable.aoe and #animalsTable.tRupture < 14 - 2 * animalsTable.getTraitCurrentRank(artifact, bag_of_tricks) and animalsTable.playerCount(10, _, 1, ">") then
				if animalsTable.spellCanAttack(rupture) and not animalsTable.aura("target", rupture, "", "PLAYER") and animalsTable.getTTD() > 6 then animalsTable.cast(_, rupture, false, false, false, "SpellToInterrupt", "Rupture: AoE"); rupture_pmultiplier[UnitGUID("target")] = (animalsTable.talent21 and IsStealthed() and 1.5 or 1) return end
				table.sort(animalsTable.targetAnimals, animalsTable.sortAnimalsByHighestTTD)
				for i = 1, animalsTable.animalsSize do
					rotationUnitIterator = animalsTable.targetAnimals[i]
					if animalsTable.getTTD(rotationUnitIterator) > 6 and animalsTable.getTTD(rotationUnitIterator) < math.huge then
						if animalsTable.spellCanAttack(rupture, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, rupture, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, rupture, false, false, false, "SpellToInterrupt"); rupture_pmultiplier[UnitGUID(rotationUnitIterator)] = (animalsTable.talent21 and IsStealthed() and 1.5 or 1) return end
					else
						break
					end
				end
			end
			if animalsTable.auraRemaining("target", rupture, 7.2, "", "PLAYER") or animalsTable.talent21 and animalsTable.aura("player", vanish) then animalsTable.cast(_, rupture, false, false, false, "SpellToInterrupt", "Rupture") rupture_pmultiplier[UnitGUID("target")] = (animalsTable.talent21 and IsStealthed() and 1.5 or 1) return end
		end
		if envenom_condition() and combo_points() >= (animalsTable.talent31 and 6 or 5)-2*(animalsTable.talent12 and 1 or 0) and (animalsTable.auraRemaining("player", envenom, (combo_points()+1)*.3) or animalsTable.talent12 and not animalsTable.aura("player", elaborate_planning) or animalsTable.spellCDDuration(garrote) < 1) then
			if animalsTable.talent73 and animalsTable.spellCanAttack(death_from_above) then animalsTable.cast(_, death_from_above, false, false, false, "SpellToInterrupt", "Death from Above") return end
			if animalsTable.spellCanAttack(envenom) then animalsTable.cast(_, envenom, false, false, false, "SpellToInterrupt", "Envenom") return end
		end
	end

	local function build_noex()
		-- actions.build_noex=hemorrhage,cycle_targets=1,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives<=4
		-- actions.build_noex+=/hemorrhage,cycle_targets=1,max_cycle_targets=3,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives=5
		if animalsTable.spellIsReady(fan_of_knives) then
			if animalsTable.aoe and ((animalsTable.playerCount(10, _, 2+(animalsTable.aura("target", vendetta, "", "PLAYER") and 1 or 0), ">=") and (combo_points("deficit") >= 1 or energy("deficit") <= 30)) or (animalsTable.getTraitCurrentRank(artifact, bag_of_tricks) == 0 and animalsTable.playerCount(10, _, 7+2*(animalsTable.aura("target", vendetta, "", "PLAYER") and 1 or 0), ">="))) then animalsTable.cast(_, fan_of_knives, false, false, false, "SpellToInterrupt", "Fan of Knives") return end
			-- actions.build_noex+=/fan_of_knives,if=(debuff.vendetta.up&buff.the_dreadlords_deceit.stack>=29-(debuff.vendetta.remains<=3)*14)|(cooldown.vendetta.remains>60&cooldown.vendetta.remains<65&buff.the_dreadlords_deceit.stack>=5)
		end
		-- actions.build_noex+=/hemorrhage,if=combo_points.deficit>=1&refreshable
		if animalsTable.spellCanAttack(mutilate) and combo_points("deficit") >= 1 and animalsTable.spellCDDuration(garrote) > 2 then animalsTable.cast(_, mutilate, false, false, false, "SpellToInterrupt", "Mutilate") return end
	end

	function animalsTable.ROGUE1()
		if UnitAffectingCombat("player") then
			animalsTable.multiDoT(GetSpellInfo(rupture), 40)
			if animalsTable.validAnimal() then
				if animalsDataPerChar.interrupt then if animalsTable.spellCanAttack(kick) then animalsTable.interruptFunction(nil, kick) else animalsTable.interruptFunction() end end
				if animalsTable.cds then
					-- actions=potion,name=old_war,if=buff.bloodlust.react|target.time_to_die<=25|debuff.vendetta.up
					-- actions+=/blood_fury,if=debuff.vendetta.up
					-- actions+=/berserking,if=debuff.vendetta.up
					-- actions+=/arcane_torrent,if=debuff.vendetta.up&energy.deficit>50
				end
				cds()
				-- actions+=/rupture,if=talent.exsanguinate.enabled&combo_points>=2+artifact.urge_to_kill.enabled*2&!ticking&(artifact.urge_to_kill.enabled|time<10)
				if animalsTable.getTraitCurrentRank(artifact, kingsbane) == 1 and (not animalsTable.talent63 and (animalsTable.aura("target", vendetta, "", "PLAYER") or animalsTable.spellCDDuration(vendetta) > 10) or (animalsTable.talent63 and dot.rupture.exsanguinated)) then
					if animalsTable.poolCheck(kingsbane) then return end
					if animalsTable.spellCanAttack(kingsbane) then animalsTable.cast(_, kingsbane, false, false, false, "SpellToInterrupt", "Kingsbane") return end
				end
				-- actions+=/run_action_list,name=exsang_combo,if=talent.exsanguinate.enabled&cooldown.exsanguinate.remains<3&(debuff.vendetta.up|cooldown.vendetta.remains>25)
				if not animalsTable.aoe or animalsTable.playerCount(10, _, (8-animalsTable.getTraitCurrentRank(artifact, bag_of_tricks)), "<=") then
					garrote_apl()
				end
				-- actions+=/call_action_list,name=exsang,if=dot.rupture.exsanguinated
				-- actions+=/rupture,if=talent.exsanguinate.enabled&remains-cooldown.exsanguinate.remains<(4+cp_max_spend*4)*0.3&new_duration-cooldown.exsanguinate.remains>=(4+cp_max_spend*4)*0.3+3
				if animalsTable.talent63 then
					finish_ex()
					build_ex()
				else
					finish_noex()
					build_noex()
				end
			end
		else
		end
	end
end

do -- Outlaw
	local rtb_reroll               = false
	local ss_useable               = false
	local ss_useable_noreroll      = false
	local stealth_condition        = false

	-- talents=1310022

	local ambush                   = 8676
	local blade_flurry             = 13877
	local opportunity              = 195627
	local pistol_shot              = 185763
	local run_through              = 2098
	local saber_slash              = 193315
	
	local roll_the_bones           = 193316
	local broadsides               = 193356
	local buried_treasure          = 199600
	local grand_melee              = 193358
	local jolly_roger              = 199603
	local shark_infested_waters    = 193357
	local true_bearing             = 193359

	local adrenaline_rush          = 13750

	local alacrity                 = 193538
	local cannonball_barrage       = 185767
	local death_from_above         = 152150
	local ghostly_strike           = 196937
	local killing_spree            = 51690
	local marked_for_death         = 137619
	local slice_and_dice           = 5171

	local artifact                 = 128872
	local curse_of_the_dreadblades = 202665
	local blunderbuss = 0

	local greenskins_waterlogged_wristcuffs = 0
	local shivarran_symmetry       = 141321


	local bf_cd = 0
	function setBF_CD(value)
		bf_cd = value
	end

	local function bf()
		if bf_cd > 0 then return end
		if animalsTable.aura("player", blade_flurry) then
			if not animalsTable.aoe or animalsTable.equippedGear.Hands == shivarran_symmetry and animalsTable.spellCDDuration(blade_flurry) == 0 and animalsTable.playerCount(8, _, 1, ">") or #animalsTable.smartAoE(40, 8, true, true) < 2 then
				bf_cd = 1
				CancelUnitBuff("player", "Blade Flurry")
				return
			end
		else
			if animalsTable.aoe and animalsTable.spellIsReady(blade_flurry) and animalsTable.playerCount(8, _, 1, ">") and not animalsTable.aura("player", blade_flurry) then
				bf_cd = 1
				animalsTable.cast(_, blade_flurry, false, false, false, "SpellToInterrupt", "Blade Flurry")
				return
			end
		end
	end

	local function build()
		if animalsTable.talent11 and animalsTable.spellCanAttack(ghostly_strike) and combo_points("deficit") >= 1 + (animalsTable.aura("player", broadsides) and 1 or 0) and not animalsTable.aura("player", curse_of_the_dreadblades) and (animalsTable.auraRemaining("target", ghostly_strike, 4.5, "", "PLAYER") or (animalsTable.spellCDDuration(curse_of_the_dreadblades) < 3 and animalsTable.auraRemaining("target", ghostly_strike, 14, "", "PLAYER"))) and (combo_points() >= 3 or (rtb_reroll and (GetTime()-animalsTable.combatStartTime) >=10)) then animalsTable.cast(_, ghostly_strike, _, _, _, _, "Ghostly Strike") return end
		if animalsTable.spellCanAttack(pistol_shot) and combo_points("deficit") >= 1 + (animalsTable.aura("player", broadsides) and 1 or 0) and animalsTable.aura("player", opportunity) and (energy("tomax") > 2-(animalsTable.talent13 and 1 or 0) or animalsTable.aura("player", blunderbuss) and animalsTable.aura("player", greenskins_waterlogged_wristcuffs)) then animalsTable.cast(_, pistol_shot, _, _, _, _, "Pistol Shot") return end
		if animalsTable.spellCanAttack(saber_slash) and ss_useable then animalsTable.cast(_, saber_slash, _, _, _, _, "Saber Slash") return end
	end

	local function cds()
		if animalsTable.cds then
			-- actions.cds=potion,name=old_war,if=buff.bloodlust.react|target.time_to_die<=25|buff.adrenaline_rush.up
			-- actions.cds+=/use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|combo_points.deficit<=2
			-- actions.cds+=/blood_fury
			-- actions.cds+=/berserking
			-- actions.cds+=/arcane_torrent,if=energy.deficit>40
		end
		-- actions.cds+=/cannonball_barrage,if=spell_targets.cannonball_barrage>=1
		if animalsTable.cds then
			if animalsTable.spellIsReady(adrenaline_rush) and not animalsTable.aura("player", adrenaline_rush) and energy("deficit") > 0 then animalsTable.cast("target", adrenaline_rush, false, false, false, "SpellToInterrupt", "Adrenaline Rush") return end
		end
		if (not animalsDataPerChar.markedForDeath or animalsTable.cds) and animalsTable.talent72 and animalsTable.spellIsReady(marked_for_death) then
			table.sort(animalsTable.targetAnimals, animalsTable.sortAnimalsByLowestTTD)
            check = combo_points("deficit") >= 4+((animalsTable.talent31 or animalsTable.talent32) and 1 or 0)
            for i = 1, animalsTable.animalsSize do
            	rotationUnitIterator = animalsTable.targetAnimals[i]
            	if animalsTable.getTTD(rotationUnitIterator) == math.huge then break end
            	if animalsTable.spellCanAttack(marked_for_death, rotationUnitIterator) and (check and (select(2, GetInstanceInfo()) ~= "none" or 

            		--[[raid_event.adds.in>40 or ]]not animalsTable.auraRemaining("player", true_bearing, 15)) or animalsTable.getTTD(rotationUnitIterator) < combo_points("deficit")) then animalsTable.cast(rotationUnitIterator, marked_for_death, false, false, false, "SpellToInterrupt", "Marked for Death") return end
            end
		end
		-- actions.cds+=/sprint,if=equipped.thraxis_tricksy_treads&!variable.ss_useable
		if animalsTable.cds and animalsTable.getTraitCurrentRank(artifact, curse_of_the_dreadblades) > 0 and animalsTable.spellIsReady(curse_of_the_dreadblades) and combo_points("deficit") >= 4 and (not animalsTable.talent11 or animalsTable.aura("target", ghostly_strike, "", "PLAYER")) then animalsTable.cast(_, curse_of_the_dreadblades, false, false, false, "SpellToInterrupt", "Curse of the Dreadblades") return end
	end

	local function finish()
		-- actions.finish=between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up
		if animalsTable.spellCanAttack(run_through) and (not animalsTable.talent73 or energy("tomax") < animalsTable.spellCDDuration(death_from_above)+3.5) then animalsTable.cast(_, run_through, _, _, _, _, "Run Through") return end
	end

	local function stealth()
		-- actions.stealth=variable,name=stealth_condition,value=(combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up&!buff.curse_of_the_dreadblades.up)
		if animalsTable.spellCanAttack(ambush) then animalsTable.cast(_, ambush, _, _, _, _, "Ambush") return end
		-- actions.stealth+=/vanish,if=variable.stealth_condition
		-- actions.stealth+=/shadowmeld,if=variable.stealth_condition
	end

	local function roll_the_bones_remains()
		if     animalsTable.aura("player", broadsides)            then return (select(7, animalsTable.aura("player", broadsides))-GetTime())
		elseif animalsTable.aura("player", buried_treasure)       then return (select(7, animalsTable.aura("player", buried_treasure))-GetTime())
		elseif animalsTable.aura("player", grand_melee)           then return (select(7, animalsTable.aura("player", grand_melee))-GetTime())
		elseif animalsTable.aura("player", jolly_roger)           then return (select(7, animalsTable.aura("player", jolly_roger))-GetTime())
		elseif animalsTable.aura("player", shark_infested_waters) then return (select(7, animalsTable.aura("player", shark_infested_waters))-GetTime())
		elseif animalsTable.aura("player", true_bearing)          then return (select(7, animalsTable.aura("player", true_bearing))-GetTime())
		else return 0
		end
	end

	local function rtb_buffs()
		local a = 0
		if animalsTable.aura("player", broadsides)            then a = a + 1 end
		if animalsTable.aura("player", buried_treasure)       then a = a + 1 end
		if animalsTable.aura("player", grand_melee)           then a = a + 1 end
		if animalsTable.aura("player", jolly_roger)           then a = a + 1 end
		if animalsTable.aura("player", shark_infested_waters) then a = a + 1 end
		if animalsTable.aura("player", true_bearing)          then a = a + 1 end
		return a
	end

	function animalsTable.ROGUE2()
		if UnitAffectingCombat("player") then
			if animalsTable.validAnimal() then
				if animalsDataPerChar.interrupt then if animalsTable.spellCanAttack(kick) then animalsTable.interruptFunction(nil, kick) else animalsTable.interruptFunction() end end
				rtb_reroll = not animalsTable.talent71 and (rtb_buffs() <= 1 and not animalsTable.aura("player", true_bearing) and ((not animalsTable.aura("player", curse_of_the_dreadblades) and not animalsTable.aura("player", adrenaline_rush)) or not animalsTable.aura("player", shark_infested_waters)))
				ss_useable_noreroll = (combo_points() < 5 + (animalsTable.talent31 and 1 or 0) - (animalsTable.aura("player", broadsides) and 1 or animalsTable.aura("player", jolly_roger) and 1 or 0) - (animalsTable.talent62 and not animalsTable.auraStacks("player", alacrity, 5) and 1 or 0))
				ss_useable = (animalsTable.talent32 and combo_points() < 4) or (not animalsTable.talent32 and ((rtb_reroll and combo_points() < 4 + (animalsTable.talent31 and 1 or 0))  or (not rtb_reroll and ss_useable_noreroll)))
				-- bf()
				cds()
				if IsStealthed() or animalsTable.spellIsReady(vanish) or animalsTable.spellIsReady(shadowmeld) then stealth() end
				if animalsTable.talent73 and animalsTable.spellCanAttack(death_from_above) and energy("tomax") > 2 and not ss_useable_noreroll then animalsTable.cast(_, death_from_above, _, _, _, _, "Death from Above") return end
				if animalsTable.talent71 and not ss_usable and animalsTable.spellIsReady(slice_and_dice) and animalsTable.auraRemaining("player", slice_and_dice, animalsTable.getTTD()) and animalsTable.auraRemaining("player", slice_and_dice, (1+combo_points())*1.8) then animalsTable.cast(_, slice_and_dice, _, _, _, _, "Slice and Dice") return end
				if not animalsTable.talent71 and not ss_usable and animalsTable.spellIsReady(roll_the_bones) and roll_the_bones_remains() < animalsTable.getTTD() and (roll_the_bones_remains() <= 3 or rtb_reroll) then animalsTable.cast(_, roll_the_bones, _, _, _, _, "Roll the Bones") return end
				-- actions+=/killing_spree,if=energy.time_to_max>5|energy<15
				build()
				if not ss_useable then finish() end
				-- # Gouge is used as a CP Generator while nothing else is available and you have Dirty Tricks talent. It's unlikely that you'll be able to do this optimally in-game since it requires to move in front of the target, but it's here so you can quantifiy its value.
				-- actions+=/gouge,if=talent.dirty_tricks.enabled&combo_points.deficit>=1
			end
		else
			rtb_reroll          = false
			ss_useable          = false
			ss_useable_noreroll = false
			stealth_condition   = false
		end
	end
end

do -- Subtlety
	local ssw_er
	local ed_threshold
	-- talents=2210011

	local backstab            = 53
	local eviscerate          = 196819
	local nightblade          = 195452
	local shadow_dance        = {spell = 185313, buff = 185422}
	local shadowstrike        = 185438
	local shuriken_storm      = 197835
	local symbols_of_death    = 212283

	local shadow_blades       = 121471
	
	local death_from_above    = 152150
	local enveloping_shadows  = 206237
	local gloomblade          = 200758
	local marked_for_death    = 137619
	local subterfuge          = 115192

	local artifact = 128476
	local goremaws_bite       = 209782
	local finality            = 197406
	local finality_nightblade = 197498
	local finality_eviscerate = 197496

	local shadow_satyrs_walk  = 137032

	local function build()
		if animalsTable.aoe and animalsTable.spellIsReady(shuriken_storm) and animalsTable.playerCount(10, _, 2, ">=") then animalsTable.cast(_, shuriken_storm, _, _, _, _, "Shuriken Storm") return end
		if animalsTable.talent13 and animalsTable.spellCanAttack(gloomblade) then animalsTable.cast(_, gloomblade, _, _, _, _, "Gloomlade") return end
		if not animalsTable.talent13 and animalsTable.spellCanAttack(backstab) then animalsTable.cast(_, backstab, _, _, _, _, "Backstab") return end
	end

	local function cds()
		if animalsTable.cds then
			-- actions.cds=potion,name=old_war,if=buff.bloodlust.react|target.time_to_die<=25|buff.shadow_blades.up
			if IsStealthed() or animalsTable.aura("player", subterfuge) or animalsTable.aura("player", shadow_dance.buff) then
				-- actions.cds+=/blood_fury,if=stealthed
				-- actions.cds+=/berserking,if=stealthed
				-- actions.cds+=/arcane_torrent,if=stealthed&energy.deficit>70
			end
			if animalsTable.spellIsReady(shadow_blades) and not IsStealthed() and not animalsTable.aura("player", shadow_dance.buff) and not animalsTable.aura("player", subterfuge) and not animalsTable.aura("player", shadowmeld) then animalsTable.cast(_, shadow_blades, _, _, _, _, "Shadow Blades") return end
		end
		if animalsTable.getTraitCurrentRank(artifact, goremaws_bite) > 0 and animalsTable.spellCanAttack(goremaws_bite) and not animalsTable.aura("player", shadow_dance.buff) and ((combo_points("deficit") >= 4-((GetTime()-animalsTable.combatStartTime) < 10 and 2 or 0) and energy("deficit") > 50+(animalsTable.talent33 and 25 or 0)-((GetTime()-animalsTable.combatStartTime) >= 10 and 15 or 0)) or animalsTable.animalIsBoss() and animalsTable.getTTD() < 8) then animalsTable.cast(_, goremaws_bite, _, _, _, _, "Goremaw's Bite") return end
		if (not animalsDataPerChar.markedForDeath or animalsTable.cds) and animalsTable.talent72 and animalsTable.spellIsReady(marked_for_death) then
			table.sort(animalsTable.targetAnimals, animalsTable.sortAnimalsByLowestTTD)
            check = combo_points("deficit") >= 4+((animalsTable.talent31 or animalsTable.talent32) and 1 or 0)
            for i = 1, animalsTable.animalsSize do
            	rotationUnitIterator = animalsTable.targetAnimals[i]
            	if animalsTable.getTTD(rotationUnitIterator) == math.huge then break end
            	if animalsTable.spellCanAttack(marked_for_death, rotationUnitIterator) and (check and (--[[raid_event.adds.in>40 or ]]true) or animalsTable.getTTD(rotationUnitIterator) < combo_points("deficit")) then animalsTable.cast(rotationUnitIterator, marked_for_death, false, false, false, "SpellToInterrupt", "Marked for Death") return end
            end
		end
	end

	local function nightblade_check()
		if #animalsTable.tNightblade == 0 then return true elseif #animalsTable.tNightblade > 1 then return false end
		local unit = animalsTable.tNightblade[1]
		if animalsTable.auraRemaining(unit, nightblade, 4.8, "", "PLAYER") and (animalsTable.getTraitCurrentRank(artifact, finality) == 0 or animalsTable.aura("player", finality_nightblade)) or animalsTable.auraRemaining(unit, nightblade, 2, "", "PLAYER") then return true end
		return false
	end

	local function finish()
		if animalsTable.talent63 and animalsTable.spellIsReady(enveloping_shadows) and animalsTable.auraRemaining("player", enveloping_shadows, animalsTable.getTTD()) and animalsTable.auraRemaining("player", enveloping_shadows, combo_points()*1.8) then animalsTable.cast(_, enveloping_shadows, false, false, false, "SpellToInterrupt", "Enveloping Shadows") return end
		if animalsTable.aoe and animalsTable.talent73 and animalsTable.spellCanAttack(death_from_above) and animalsTable.targetCount(_, 8) >= 6 then animalsTable.cast(_, death_from_above, _, _, _, _, "Death from Above") return end
		if animalsTable.spellIsReady(nightblade) and nightblade_check() then
			if animalsTable.spellCanAttack(nightblade) and animalsTable.getTTD() > 8 and animalsTable.getTTD() < math.huge then animalsTable.cast(_, nightblade, _, _, _, _, "Nightblade") return end
			if animalsTable.aoe then
				table.sort(animalsTable.targetAnimals, animalsTable.sortAnimalsByHighestTTD)
				for i = 1, animalsTable.animalsSize do
					rotationUnitIterator = animalsTable.targetAnimals[i]
					if animalsTable.getTTD(rotationUnitIterator) > 8 and animalsTable.getTTD(rotationUnitIterator) < math.huge then
						if animalsTable.spellCanAttack(nightblade, rotationUnitIterator) then animalsTable.cast(rotationUnitIterator, nightblade, _, _, _, _, "Nightblade") return end
					else
						break
					end
				end
			end
		end
		if animalsTable.talent73 and animalsTable.spellCanAttack(death_from_above) then animalsTable.cast(_, death_from_above, _, _, _, _, "Death from Above") return end
		if animalsTable.spellCanAttack(eviscerate) then animalsTable.cast(_, eviscerate, _, _, _, _, "Eviscerate") return end
	end

	local function stealth_cds()
		if animalsTable.spellIsReady(shadow_dance.spell) and animalsTable.fracCalc("spell", shadow_dance.spell) >= 2.65 then animalsTable.cast(_, shadow_dance.spell, _, _, _, _, "Shadow Dance: Capped Charges") return true end
		if animalsTable.spellIsReady(vanish) and vanishPartyCheck() then animalsTable.cast(_, vanish, false, false, false, "SpellToInterrupt", "Vanish") return end
		if animalsTable.spellIsReady(shadow_dance.spell) and GetSpellCharges(shadow_dance.spell) >= 2 and combo_points() <= 1 then animalsTable.cast(_, shadow_dance.spell, _, _, _, _, "Shadow Dance: Two Charges No CP") return true end
		if animalsTable.spellIsReady(shadowmeld) and GetNumGroupMembers() > 1 then
			if vanishPartyCheck() then
				if energy() < 40-ssw_er then return true end
				animalsTable.cast(_, shadowmeld, _, _, _, _, "Shadowmeld")
			end
		end
		if animalsTable.spellIsReady(shadow_dance.spell) and combo_points() <= 1 then animalsTable.cast(_, shadow_dance.spell, _, _, _, _, "Shadow Dance") return true end
	end

	local function stealthed()
		if animalsTable.spellIsReady(symbols_of_death) and not animalsTable.aura("player", shadowmeld) and ((animalsTable.auraRemaining("player", symbols_of_death, animalsTable.getTTD()-4) and animalsTable.auraRemaining("player", symbols_of_death, 10.5)) or (animalsTable.equippedGear.Feet == shadow_satyrs_walk and energy("tomax") < 0.25)) then animalsTable.cast(_, symbols_of_death, _, _, _, _, "Symbols of Death") return end
		if combo_points() >= 5 then finish() end
		if animalsTable.spellIsReady(shuriken_storm) and not animalsTable.aura("player", shadowmeld) and ((animalsTable.aoe and combo_points("deficit") >= 3 and animalsTable.playerCount(10, _, 2+(animalsTable.talent61 and 1 or 0)+(animalsTable.equippedGear.Feet == shadow_satyrs_walk and 1 or 0), ">=")) or animalsTable.auraStacks("player", the_dreadlords_deceit, 29)) then animalsTable.cast(_, shuriken_storm, _, _, _, _, "Shuriken Storm: Stealthed") return end
		if animalsTable.spellCanAttack(shadowstrike) then animalsTable.cast(_, shadowstrike, _, _, _, _, "Shadowstrike") return end
	end

	function animalsTable.ROGUE3()
		if UnitAffectingCombat("player") or UnitExists("focus") and UnitAffectingCombat("focus") then
			animalsTable.multiDoT(GetSpellInfo(nightblade), 40)
			if animalsTable.validAnimal() then
				if animalsDataPerChar.interrupt then if animalsTable.spellCanAttack(kick) then animalsTable.interruptFunction(nil, kick) else animalsTable.interruptFunction() end end
				ssw_er = animalsTable.equippedGear.Feet ~= shadow_satyrs_walk and 0 or (10 + math.floor(animalsTable.distanceBetween()*0.5))
				ed_threshold = energy("deficit") <= (20 + (animalsTable.talent33 and 1 or 0) * 35 + (animalsTable.talent71 and 1 or 0) * 25 + ssw_er)
				cds()
				if IsStealthed() or animalsTable.aura("player", subterfuge) or animalsTable.aura("player", shadow_dance.buff) or animalsTable.aura("player", shadowmeld) then stealthed() return end
				if combo_points() >= 5 or animalsTable.aoe and combo_points() >= 4 and animalsTable.playerCount(10, _, 3, "inclusive", 4) then finish() end
				if combo_points("deficit") >= 2 + (animalsTable.talent61 and 1 or 0) and (ed_threshold or (animalsTable.spellIsReady(shadowmeld) and not animalsTable.spellIsReady(vanish) and animalsTable.spellCDDuration(shadow_dance.spell) <= 1) or animalsTable.animalIsBoss() and animalsTable.getTTD() < 12) then if stealth_cds() then return end end
				if ed_threshold then build() end
			end
		end
	end
end