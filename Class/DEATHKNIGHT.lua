local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil
local variableX, variableY, variableZ

animalsTable.DEATHKNIGHT = {}

local runic_power = animalsTable.pp

do -- Blood
	local heart_strike    = 206930
	local death_strike    = 49998
	local marrowrend      = 195182
	local blood_boil      = 50842
	local death_and_decay = 43265
	local bone_shield = 195181
	local crimson_scourge = 0

	local artifact = 0
	local consumption     = 0

	function animalsTable.DEATHKNIGHT1()
		if UnitAffectingCombat("player") then
			if animalsTable.validAnimal() then
				-- if consumption and animalsTable.health("player", _, true) < 75 then animalsTable.cast(_, consumption, false, false, false, "SpellToInterrupt") return end
				if animalsTable.spellCanAttack(death_strike) and (animalsTable.health("player", _, true) < 75 or runic_power("deficit") <= 20) then animalsTable.cast(_, death_strike, false, false, false, "SpellToInterrupt") return end
				if animalsTable.spellCanAttack(marrowrend) and ((not animalsTable.auraStacks("player", bone_shield, 8) and (animalsTable.getTraitCurrentRank(artifact, mouth_of_hell) == 0 or not animalsTable.aura("player", dancing_rune_weapon))) or (not animalsTable.auraStacks("player", bone_shield, 7) and animalsTable.getTraitCurrentRank(artifact, mouth_of_hell) > 0 and animalsTable.aura("player", dancing_rune_weapon))) then animalsTable.cast(_, marrowrend, false, false, false, "SpellToInterrupt") return end
				if animalsTable.spellIsReady(blood_boil) and animalsTable.playerCount(8, _, 0, ">") then animalsTable.cast(_, blood_boil, false, false, false, "SpellToInterrupt") return end
				if animalsTable.spellIsReady(death_and_decay) and (animalsTable.aura("player", crimson_scourge) or animalsTable.talent21) then
					if not animalsTable.aoe then animalsTable.cast("target", death_and_decay, false, false, false, "SpellToInterrupt") return end
					variableX, variableY, variableZ = animalsTable.smartAoE(30, 8, true)
					animalsTable.cast(_, death_and_decay, variableX, variableY, variableZ, _)
					return
				end
				if animalsTable.spellCanAttack(heart_strike) then animalsTable.cast(_, heart_strike, false, false, false, "SpellToInterrupt") return end
			end
		end
	end
end

do -- Frost
	local artifact = 128292
	-- talents=2230021
	local breath_of_sindragosa  = 0
	local empower_rune_weapon   = 47568
	local frost_fever           = 55095
	local frost_strike          = 49143
	local frostscythe           = 207230
	local frozen_soul           = 189184
	local glacial_advance       = 194913
	local horn_of_winter        = 57330
	local howling_blast         = 49184
	local hungering_rune_weapon = 207127
	local icy_talons            = 194879
	local killing_machine       = 51124
	local obliterate            = 49020
	local obliteration          = 207256
	local pillar_of_frost       = 51271
	local razorice              = 51714
	local remorseless_winter    = 196770
	local rime                  = 59052
	local sindragosas_fury      = 190778


	local function bos()
		if animalsTable.spellCanAttack(howling_blast) and not animalsTable.aura("target", frost_fever, "", "PLAYER") then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Frost Fever") return end
		core()
		if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
		if animalsTable.cds and not animalsTable.talent32 and animalsTable.spellIsReady(empower_rune_weapon) and runic_power() <= 70 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
		if animalsTablecds and animalsTable.talent32 and animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Hungering Rune Weapon") return end
		if animalsTable.spellCanAttack(howling_blast) and animalsTable.aura("player", rime) then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Rime") return end
	end


	local function core()
		if animalsTable.spellIsReady(remorseless_winter) and animalsTable.getTraitCurrentRank(artifact, frozen_soul) then animalsTable.cast(_, remorseless_winter, _, _, _, _, "Remorseless Winter: Frozen Soul") return end
		if animalsTable.talent73 and animalsTable.spellIsReady(glacial_advance) then animalsTable.cast(_, glacial_advance, _, _, _, _, "Glacial Advance") return end
		if animalsTable.spellCanAttack(frost_strike) and animalsTable.aura("player", obliteration) and not animalsTable.aura("player", killing_machine) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike: Obliteration") return end
		if animalsTable.aoe and animalsTable.spellIsReady(remorseless_winter) and (animalsTable.aoe and animalsTable.playerCount(8, _, 2, ">=") or animalsTable.talent63) then animalsTable.cast(_, remorseless_winter, _, _, _, _, "Remorseless Winter: Cleave") return end
		if animalsTable.talent61 and animalsTable.spellCanAttack(frostscythe) and not animalsTable.talent72 and (animalsTable.aura("player", killing_machine) or animalsTable.aoe and animalsTable.targetCount(_, 8) >= 4) then animalsTable.cast(_, frostscythe, _, _, _, _, "Frost Scythe") return end
		if animalsTable.spellCanAttack(obliterate) then animalsTable.cast(_, obliterate, _, _, _, _, "Obliterate") return end
		if animalsTable.spellIsReady(remorseless_winter) then animalsTable.cast(_, remorseless_winter, _, _, _, _, "Remorseless Winter") return end
		if animalsTable.talent22 then
			if animalsTable.talent61 and animalsTable.spellCanAttack(frostscythe) then animalsTable.cast(_, frostscythe, _, _, _, _, "Frostscythe: Frozen Pulse Dump Runes") return end
			if animalsTable.spellCanAttack(howling_blast) then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Frozen Pulse Dump Runes") return end
		end
	end


	local function generic()
		if animalsTable.spellCanAttack(howling_blast) and not animalsTable.aura("target", frost_fever, "", "PLAYER") then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Frost Fever") return end
		if animalsTable.spellCanAttack(howling_blast) and animalsTable.aura("player", rime) then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Rime") return end
		if animalsTable.spellCanAttack(frost_strike) and runic_power() >= 80 then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike: Dump RP") return end
		core()
		if animalsTable.talent72 then
			if animalsTable.spellCDDuration(breath_of_sindragosa) > 15 then
				if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
				if animalsTable.spellCanAttack(frost_strike) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
				if not animalsTable.talent32 then
					if animalsTable.spellIsReady(empower_rune_weapon) and animalsTable.spellCDDuration(61304) == 0 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
				else
					if animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
				end
			end
		else
			if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
			if animalsTable.spellCanAttack(frost_strike) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
			if not animalsTable.talent32 then
				if animalsTable.spellIsReady(empower_rune_weapon) and animalsTable.spellCDDuration(61304) == 0 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
			else
				if animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
			end
		end
	end

	local function icytalons()
		if animalsTable.spellCanAttack(frost_strike) and animalsTable.auraRemaining("player", icy_talons, 1.5) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike: Icy Talons") return end
		if animalsTable.spellCanAttack(howling_blast) and not animalsTable.aura("target", frost_fever, "", "PLAYER") then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Frost Fever") return end
		if animalsTable.spellCanAttack(howling_blast) and animalsTable.aura("player", rime) then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Rime") return end
		if animalsTable.spellCanAttack(frost_strike) and (runic_power() >= 80 or not animalsTable.auraStacks("player", icy_talons, 3)) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike: Dump or Build Icy Talons") return end
		core()
		if animalsTable.talent72 then
			if animalsTable.spellCDDuration(breath_of_sindragosa) > 15 then
				if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
				if animalsTable.spellCanAttack(frost_strike) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
				if not animalsTable.talent32 then
					if animalsTable.spellIsReady(empower_rune_weapon) and animalsTable.spellCDDuration(61304) == 0 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
				else
					if animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
				end
			end
		else
			if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
			if animalsTable.spellCanAttack(frost_strike) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
			if not animalsTable.talent32 then
				if animalsTable.spellIsReady(empower_rune_weapon) and animalsTable.spellCDDuration(61304) == 0 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
			else
				if animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
			end
		end
	end


	local function shatter()
		if animalsTable.spellCanAttack(frost_strike) and animalsTable.auraStacks("target", razorice, 5, "", "PLAYER") then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike: Razorice Stacks") return end
		if animalsTable.spellCanAttack(howling_blast) and not animalsTable.aura("player", frost_fever) then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Frost Fever") return end
		if animalsTable.spellCanAttack(howling_blast) and animalsTable.aura("player", rime) then animalsTable.cast(_, howling_blast, _, _, _, _, "Howling Blast: Rime") return end
		if animalsTable.spellCanAttack(frost_strike) and runic_power() >= 80 then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike: Dump RP") return end
		core()
		if animalsTable.talent72 then
			if animalsTable.spellCDDuration(breath_of_sindragosa) > 15 then
				if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
				if animalsTable.spellCanAttack(frost_strike) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
				if not animalsTable.talent32 then
					if animalsTable.spellIsReady(empower_rune_weapon) and animalsTable.spellCDDuration(61304) == 0 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
				else
					if animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
				end
			end
		else
			if animalsTable.talent23 and animalsTable.spellIsReady(horn_of_winter) then animalsTable.cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
			if animalsTable.spellCanAttack(frost_strike) then animalsTable.cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
			if not animalsTable.talent32 then
				if animalsTable.spellIsReady(empower_rune_weapon) and animalsTable.spellCDDuration(61304) == 0 then animalsTable.cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
			else
				if animalsTable.spellIsReady(hungering_rune_weapon) then animalsTable.cast(_, hungering_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
			end
		end
	end

	function animalsTable.DEATHKNIGHT2()
		if UnitAffectingCombat("player") then
		    if animalsTable.validAnimal() and GetTime() > animalsTable.throttleSlaying then
				-- actions=auto_attack
				if animalsTable.spellIsReady(pillar_of_frost) then animalsTable.cast(_, pillar_of_frost, _, _, _, _, "Pillar of Frost") return end
				if animalsTable.cds then
					-- actions+=/arcane_torrent,if=runic_power.deficit>20
					-- actions+=/blood_fury,if=!talent.breath_of_sindragosa.enabled|dot.breath_of_sindragosa.ticking
					-- actions+=/berserking,if=buff.pillar_of_frost.up
					-- actions+=/use_item,slot=finger2
					-- actions+=/use_item,slot=trinket1
					-- actions+=/potion,name=old_war
					if animalsTable.getTraitCurrentRank(artifact, sindragosas_fury) > 0 and animalsTable.spellIsReady(sindragosas_fury) and animalsTable.aura("player", pillar_of_frost) then animalsTable.cast(_, sindragosas_fury, _, _, _, _, "Sindragosa's Fury") return end
					if animalsTable.talent71 and animalsTable.spellIsReady(obliteration) then animalsTable.cast(_, obliteration, _, _, _, _, "Obliteration") return end
					if animalsTable.talent72 and animalsTable.spellIsReady(breath_of_sindragosa) and runic_power() >= 50 then animalsTable.cast(_, breath_of_sindragosa, _, _, _, _, "Breath of Sindragosa") return end
				end
				if animalsTable.aura("player", breath_of_sindragosa) then bos() return end
				-- actions+=/run_action_list,name=bos,if=dot.breath_of_sindragosa.ticking
				if animalsTable.talent11 then
					shatter()
				elseif animalsTable.talent12 then
					icytalons()
				else
					generic()
				end
		    end
		end
	end
	
end

do -- Unholy
	-- actions=auto_attack
	-- actions+=/arcane_torrent,if=runic_power.deficit>20
	-- actions+=/blood_fury
	-- actions+=/berserking
	-- actions+=/use_item,slot=trinket1
	-- actions+=/potion,name=old_war,if=buff.unholy_strength.react
	-- actions+=/outbreak,target_if=!dot.virulent_plague.ticking
	-- actions+=/dark_transformation,if=equipped.137075&cooldown.dark_arbiter.remains>165
	-- actions+=/dark_transformation,if=equipped.137075&!talent.shadow_infusion.enabled&cooldown.dark_arbiter.remains>55
	-- actions+=/dark_transformation,if=equipped.137075&talent.shadow_infusion.enabled&cooldown.dark_arbiter.remains>35
	-- actions+=/dark_transformation,if=equipped.137075&target.time_to_die<cooldown.dark_arbiter.remains-8
	-- actions+=/dark_transformation,if=equipped.137075&cooldown.summon_gargoyle.remains>160
	-- actions+=/dark_transformation,if=equipped.137075&!talent.shadow_infusion.enabled&cooldown.summon_gargoyle.remains>55
	-- actions+=/dark_transformation,if=equipped.137075&talent.shadow_infusion.enabled&cooldown.summon_gargoyle.remains>35
	-- actions+=/dark_transformation,if=equipped.137075&target.time_to_die<cooldown.summon_gargoyle.remains-8
	-- actions+=/dark_transformation,if=!equipped.137075&rune<=3
	-- actions+=/blighted_rune_weapon,if=rune<=3
	-- actions+=/run_action_list,name=valkyr,if=talent.dark_arbiter.enabled&pet.valkyr_battlemaiden.active
	-- actions+=/call_action_list,name=generic

	-- actions.aoe=death_and_decay,if=spell_targets.death_and_decay>=2
	-- actions.aoe+=/epidemic,if=spell_targets.epidemic>4
	-- actions.aoe+=/scourge_strike,if=spell_targets.scourge_strike>=2&(dot.death_and_decay.ticking|dot.defile.ticking)
	-- actions.aoe+=/clawing_shadows,if=spell_targets.clawing_shadows>=2&(dot.death_and_decay.ticking|dot.defile.ticking)
	-- actions.aoe+=/epidemic,if=spell_targets.epidemic>2

	-- actions.castigator=festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
	-- actions.castigator+=/death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
	-- actions.castigator+=/scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=3&runic_power.deficit>23
	-- actions.castigator+=/scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=3&runic_power.deficit>23
	-- actions.castigator+=/scourge_strike,if=rune>=2&debuff.festering_wound.stack>=3&runic_power.deficit>23
	-- actions.castigator+=/death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
	-- actions.castigator+=/death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
	-- actions.castigator+=/death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
	-- actions.castigator+=/death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled

	-- actions.generic=dark_arbiter,if=!equipped.137075&runic_power.deficit<30
	-- actions.generic+=/dark_arbiter,if=equipped.137075&runic_power.deficit<30&cooldown.dark_transformation.remains<2
	-- actions.generic+=/summon_gargoyle,if=!equipped.137075,if=rune<=3
	-- actions.generic+=/summon_gargoyle,if=equipped.137075&cooldown.dark_transformation.remains<10&rune<=3
	-- actions.generic+=/soul_reaper,if=debuff.festering_wound.stack>=7&cooldown.apocalypse.remains<2
	-- actions.generic+=/apocalypse,if=debuff.festering_wound.stack>=7
	-- actions.generic+=/death_coil,if=runic_power.deficit<30
	-- actions.generic+=/death_coil,if=!talent.dark_arbiter.enabled&buff.sudden_doom.up&!buff.necrosis.up&rune<=3
	-- actions.generic+=/death_coil,if=talent.dark_arbiter.enabled&buff.sudden_doom.up&cooldown.dark_arbiter.remains>5&rune<=3
	-- actions.generic+=/festering_strike,if=debuff.festering_wound.stack<7&cooldown.apocalypse.remains<5
	-- actions.generic+=/wait,sec=cooldown.apocalypse.remains,if=cooldown.apocalypse.remains<=1&cooldown.apocalypse.remains
	-- actions.generic+=/soul_reaper,if=debuff.festering_wound.stack>=3
	-- actions.generic+=/festering_strike,if=debuff.soul_reaper.up&!debuff.festering_wound.up
	-- actions.generic+=/scourge_strike,if=debuff.soul_reaper.up&debuff.festering_wound.stack>=1
	-- actions.generic+=/clawing_shadows,if=debuff.soul_reaper.up&debuff.festering_wound.stack>=1
	-- actions.generic+=/defile
	-- actions.generic+=/call_action_list,name=aoe,if=active_enemies>=2
	-- actions.generic+=/call_action_list,name=instructors,if=equipped.132448
	-- actions.generic+=/call_action_list,name=standard,if=!talent.castigator.enabled&!equipped.132448
	-- actions.generic+=/call_action_list,name=castigator,if=talent.castigator.enabled&!equipped.132448

	-- actions.instructors=festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
	-- actions.instructors+=/death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
	-- actions.instructors+=/scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
	-- actions.instructors+=/clawing_shadows,if=buff.necrosis.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
	-- actions.instructors+=/scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
	-- actions.instructors+=/clawing_shadows,if=buff.unholy_strength.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
	-- actions.instructors+=/scourge_strike,if=rune>=2&debuff.festering_wound.stack>=5&runic_power.deficit>29
	-- actions.instructors+=/clawing_shadows,if=rune>=2&debuff.festering_wound.stack>=5&runic_power.deficit>29
	-- actions.instructors+=/death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
	-- actions.instructors+=/death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
	-- actions.instructors+=/death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
	-- actions.instructors+=/death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled

	-- actions.standard=festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
	-- actions.standard+=/death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
	-- actions.standard+=/scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
	-- actions.standard+=/clawing_shadows,if=buff.necrosis.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
	-- actions.standard+=/scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
	-- actions.standard+=/clawing_shadows,if=buff.unholy_strength.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
	-- actions.standard+=/scourge_strike,if=rune>=2&debuff.festering_wound.stack>=1&runic_power.deficit>15
	-- actions.standard+=/clawing_shadows,if=rune>=2&debuff.festering_wound.stack>=1&runic_power.deficit>15
	-- actions.standard+=/death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
	-- actions.standard+=/death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
	-- actions.standard+=/death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
	-- actions.standard+=/death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled

	-- actions.valkyr=death_coil
	-- actions.valkyr+=/apocalypse,if=debuff.festering_wound.stack=8
	-- actions.valkyr+=/festering_strike,if=debuff.festering_wound.stack<8&cooldown.apocalypse.remains<5
	-- actions.valkyr+=/call_action_list,name=aoe,if=active_enemies>=2
	-- actions.valkyr+=/festering_strike,if=debuff.festering_wound.stack<=3
	-- actions.valkyr+=/scourge_strike,if=debuff.festering_wound.up
	-- actions.valkyr+=/clawing_shadows,if=debuff.festering_wound.up
end