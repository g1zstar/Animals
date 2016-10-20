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

local the_dreadlords_deceit = 228224

local function vanishPartyCheck(target)
	if GetNumGroupMembers() < 2 then return false end
	if select(2, GetInstanceInfo()) ~= "none" and GetNumGroupMembers() > 1 then return true end
	if not target then target = "target" end
	local isTanking, status, scaledPercent, rawPercent, threatValue
	if tContains({1, 2, 19, 23, 24}, select(3, GetInstanceInfo())) then
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

do -- Assassination
	-- talents=2110111

	local mutilate = 0
	local garrote = 0

	local function build_ex()
		-- # Builders Exsanguinate
		-- actions.build_ex=hemorrhage,cycle_targets=1,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives<=4
		-- actions.build_ex+=/hemorrhage,cycle_targets=1,max_cycle_targets=3,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives=5
		-- actions.build_ex+=/fan_of_knives,if=(spell_targets>=2+debuff.vendetta.up&(combo_points.deficit>=1|energy.deficit<=30))|(!artifact.bag_of_tricks.enabled&spell_targets>=7+2*debuff.vendetta.up)
		-- actions.build_ex+=/fan_of_knives,if=equipped.the_dreadlords_deceit&((buff.the_dreadlords_deceit.stack>=29|buff.the_dreadlords_deceit.stack>=15&debuff.vendetta.remains<=3)&debuff.vendetta.up|buff.the_dreadlords_deceit.stack>=5&cooldown.vendetta.remains>60&cooldown.vendetta.remains<65)
		-- actions.build_ex+=/hemorrhage,if=(combo_points.deficit>=1&refreshable)|(combo_points.deficit=1&(dot.rupture.exsanguinated&dot.rupture.remains<=2|cooldown.exsanguinate.remains<=2))
		if animalsTable.spellCanAttack(mutilate) then
			if combo_points("deficit") <= 1 and energy("deficit") <= 30 then animalsTable.cast(_, mutilate, false, false, false, "SpellToInterrupt", "Mutilate: Prevent Energy Cap") return end
			if combo_points("deficit") >= 2 and animalsTable.spellCDDuration(garrote) > 2 then animalsTable.cast(_, mutilate, false, false, false, "SpellToInterrupt", "Mutilate: Garrote CD > 2") return end
		end
	end

	local function build_noex()
		-- # Builders no Exsanguinate
		-- actions.build_noex=hemorrhage,cycle_targets=1,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives<=4
		-- actions.build_noex+=/hemorrhage,cycle_targets=1,max_cycle_targets=3,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives=5
		-- actions.build_noex+=/fan_of_knives,if=(spell_targets>=2+debuff.vendetta.up&(combo_points.deficit>=1|energy.deficit<=30))|(!artifact.bag_of_tricks.enabled&spell_targets>=7+2*debuff.vendetta.up)
		-- actions.build_noex+=/fan_of_knives,if=equipped.the_dreadlords_deceit&((buff.the_dreadlords_deceit.stack>=29|buff.the_dreadlords_deceit.stack>=15&debuff.vendetta.remains<=3)&debuff.vendetta.up|buff.the_dreadlords_deceit.stack>=5&cooldown.vendetta.remains>60&cooldown.vendetta.remains<65)
		-- actions.build_noex+=/hemorrhage,if=combo_points.deficit>=1&refreshable
		if animalsTable.spellCanAttack(mutilate) and combo_points("deficit") >= 1 and animalsTable.spellCDDuration(garrote) > 2 then animalsTable.cast(_, mutilate, false, false, false, "SpellToInterrupt", "Mutilate: Garrote CD > 2") return end
	end

	local function cds()
		-- # Cooldowns
		-- actions.cds=marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|combo_points.deficit>=5
		-- actions.cds+=/vendetta,if=target.time_to_die<20
		-- actions.cds+=/vendetta,if=artifact.urge_to_kill.enabled&dot.rupture.ticking&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains<5)&(energy<55|time<10|spell_targets.fan_of_knives>=2)
		-- actions.cds+=/vendetta,if=!artifact.urge_to_kill.enabled&dot.rupture.ticking&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains<1)
		-- actions.cds+=/vanish,if=talent.subterfuge.enabled&combo_points<=2&!dot.rupture.exsanguinated|talent.shadow_focus.enabled&!dot.rupture.exsanguinated&combo_points.deficit>=2
		-- actions.cds+=/vanish,if=!talent.exsanguinate.enabled&talent.nightstalker.enabled&combo_points>=5+talent.deeper_stratagem.enabled&energy>=25&gcd.remains=0
	end

	local function exsang()
		-- # Exsanguinated Finishers
		-- actions.exsang=rupture,cycle_targets=1,max_cycle_targets=14-2*artifact.bag_of_tricks.enabled,if=!ticking&combo_points>=cp_max_spend-1&spell_targets.fan_of_knives>1&target.time_to_die-remains>6
		-- actions.exsang+=/rupture,if=combo_points>=cp_max_spend&ticks_remain<2
		-- actions.exsang+=/death_from_above,if=combo_points>=cp_max_spend-1&(dot.rupture.remains>3|dot.rupture.remains>2&spell_targets.fan_of_knives>=3)&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6+2*debuff.vendetta.up)
		-- actions.exsang+=/envenom,if=combo_points>=cp_max_spend-1&(dot.rupture.remains>3|dot.rupture.remains>2&spell_targets.fan_of_knives>=3)&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6+2*debuff.vendetta.up)
	end

	local function exsang_combo()
		-- # Exsanguinate Combo
		-- actions.exsang_combo=vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1&gcd.remains=0&energy>=25
		-- actions.exsang_combo+=/rupture,if=combo_points>=cp_max_spend&(!talent.nightstalker.enabled|buff.vanish.up|cooldown.vanish.remains>15)&cooldown.exsanguinate.remains<1
		-- actions.exsang_combo+=/exsanguinate,if=prev_gcd.rupture&dot.rupture.remains>22+4*talent.deeper_stratagem.enabled&cooldown.vanish.remains>10
		-- actions.exsang_combo+=/call_action_list,name=garrote,if=spell_targets.fan_of_knives<=8-artifact.bag_of_tricks.enabled
		-- actions.exsang_combo+=/hemorrhage,if=spell_targets.fan_of_knives>=2&!ticking
		-- actions.exsang_combo+=/call_action_list,name=build_ex
	end

	local function finish_ex()
		-- # Finishers Exsanguinate
		-- actions.finish_ex=rupture,cycle_targets=1,max_cycle_targets=14-2*artifact.bag_of_tricks.enabled,if=!ticking&combo_points>=cp_max_spend-1&spell_targets.fan_of_knives>1&target.time_to_die-remains>6
		-- actions.finish_ex+=/rupture,if=combo_points>=cp_max_spend-1&refreshable&!exsanguinated
		-- actions.finish_ex+=/death_from_above,if=combo_points>=cp_max_spend-1&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
		-- actions.finish_ex+=/envenom,if=combo_points>=cp_max_spend-1&!dot.rupture.refreshable&buff.elaborate_planning.remains<2&energy.deficit<40&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
		-- actions.finish_ex+=/envenom,if=combo_points>=cp_max_spend&!dot.rupture.refreshable&buff.elaborate_planning.remains<2&cooldown.garrote.remains<1&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
	end

	local function finish_noex()
		-- # Finishers no Exsanguinate
		-- actions.finish_noex=variable,name=envenom_condition,value=!(dot.rupture.refreshable&dot.rupture.pmultiplier<1.5)&(!talent.nightstalker.enabled|cooldown.vanish.remains>=6)&dot.rupture.remains>=6&buff.elaborate_planning.remains<1.5&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
		-- actions.finish_noex+=/rupture,cycle_targets=1,max_cycle_targets=14-2*artifact.bag_of_tricks.enabled,if=!ticking&combo_points>=cp_max_spend&spell_targets.fan_of_knives>1&target.time_to_die-remains>6
		-- actions.finish_noex+=/rupture,if=combo_points>=cp_max_spend&(((dot.rupture.refreshable)|dot.rupture.ticks_remain<=1)|(talent.nightstalker.enabled&buff.vanish.up))
		-- actions.finish_noex+=/death_from_above,if=(combo_points>=5+talent.deeper_stratagem.enabled-2*talent.elaborate_planning.enabled)&variable.envenom_condition&(refreshable|talent.elaborate_planning.enabled&!buff.elaborate_planning.up|cooldown.garrote.remains<1)
		-- actions.finish_noex+=/envenom,if=(combo_points>=5+talent.deeper_stratagem.enabled-2*talent.elaborate_planning.enabled)&variable.envenom_condition&(refreshable|talent.elaborate_planning.enabled&!buff.elaborate_planning.up|cooldown.garrote.remains<1)
	end

	local function garrote()
		-- # Garrote
		-- actions.garrote=pool_resource,for_next=1
		-- actions.garrote+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&!ticking&combo_points.deficit>=1&spell_targets.fan_of_knives>=2
		-- actions.garrote+=/pool_resource,for_next=1
		-- actions.garrote+=/garrote,if=combo_points.deficit>=1&!exsanguinated
	end

	-- # Executed every time the actor is available.
	-- actions=potion,name=old_war,if=buff.bloodlust.react|target.time_to_die<=25|debuff.vendetta.up
	-- actions+=/use_item,slot=trinket1,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
	-- actions+=/use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
	-- actions+=/blood_fury,if=debuff.vendetta.up
	-- actions+=/berserking,if=debuff.vendetta.up
	-- actions+=/arcane_torrent,if=debuff.vendetta.up&energy.deficit>50
	-- actions+=/call_action_list,name=cds
	-- actions+=/rupture,if=combo_points>=2&!ticking&time<10&!artifact.urge_to_kill.enabled&talent.exsanguinate.enabled
	-- actions+=/rupture,if=combo_points>=4&!ticking&talent.exsanguinate.enabled
	-- actions+=/pool_resource,for_next=1
	-- actions+=/kingsbane,if=!talent.exsanguinate.enabled&(buff.vendetta.up|cooldown.vendetta.remains>10)|talent.exsanguinate.enabled&dot.rupture.exsanguinated
	-- actions+=/run_action_list,name=exsang_combo,if=cooldown.exsanguinate.remains<3&talent.exsanguinate.enabled&(buff.vendetta.up|cooldown.vendetta.remains>25)
	-- actions+=/call_action_list,name=garrote,if=spell_targets.fan_of_knives<=8-artifact.bag_of_tricks.enabled
	-- actions+=/call_action_list,name=exsang,if=dot.rupture.exsanguinated
	-- actions+=/rupture,if=talent.exsanguinate.enabled&remains-cooldown.exsanguinate.remains<(4+cp_max_spend*4)*0.3&new_duration-cooldown.exsanguinate.remains>=(4+cp_max_spend*4)*0.3+3
	-- actions+=/call_action_list,name=finish_ex,if=talent.exsanguinate.enabled
	-- actions+=/call_action_list,name=finish_noex,if=!talent.exsanguinate.enabled
	-- actions+=/call_action_list,name=build_ex,if=talent.exsanguinate.enabled
	-- actions+=/call_action_list,name=build_noex,if=!talent.exsanguinate.enabled
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

	local shivarran_symmetry       = 141321


	local function bf()
		-- if animalsTable.aura("player", blade_flurry) then
		-- 	if not animalsTable.aoe or animalsTable.equippedGear.Hands == shivarran_symmetry and animalsTable.spellCDDuration(blade_flurry) == 0 and animalsTable.playerCount(8, _, 1, ">") or #animalsTable.smartAoE(40, 8, true, true) < 2 then CancelUnitBuff("player", "Blade Flurry") return end
		-- else
		-- 	if animalsTable.aoe and animalsTable.spellIsReady(blade_flurry) and animalsTable.playerCount(8, _, 1, ">") and not animalsTable.aura("player", blade_flurry) then animalsTable.cast(_, blade_flurry, false, false, false, "SpellToInterrupt", "Blade Flurry") return end
		-- end
	end

	local function build()
		if animalsTable.talent11 and animalsTable.spellCanAttack(ghostly_strike) and combo_points("deficit") >= 1 + (animalsTable.aura("player", broadsides) and 1 or 0) and not animalsTable.aura("player", curse_of_the_dreadblades) and (animalsTable.auraRemaining("target", ghostly_strike, 4.5, "", "PLAYER") or (animalsTable.spellCDDuration(curse_of_the_dreadblades) < 3 and animalsTable.auraRemaining("target", ghostly_strike, 14, "", "PLAYER"))) and (combo_points() >= 3 or (rtb_reroll and (GetTime()-animalsTable.combatStartTime) >=10)) then animalsTable.cast(_, ghostly_strike, _, _, _, _, "Ghostly Strike") return end
		if animalsTable.spellCanAttack(pistol_shot) and combo_points("deficit") >= 1 + (animalsTable.aura("player", broadsides) and 1 or 0) and animalsTable.aura("player", opportunity) and energy("tomax") > 2-(animalsTable.talent13 and 1 or 0) then animalsTable.cast(_, pistol_shot, _, _, _, _, "Pistol Shot") return end
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
		-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15)&combo_points.deficit>=4+talent.deeper_strategem.enabled+talent.anticipation.enabled)
		-- actions.cds+=/sprint,if=equipped.thraxis_tricksy_treads&!variable.ss_useable
		-- actions.cds+=/curse_of_the_dreadblades,if=combo_points.deficit>=4&(!talent.ghostly_strike.enabled|debuff.ghostly_strike.up)
	end

	local function finish()
		-- actions.finish=between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&buff.shark_infested_waters.up
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
			if animalsTable.validAnimal() and GetTime() > animalsTable.throttleSlaying then
				rtb_reroll = not animalsTable.talent71 and (rtb_buffs() <= 1 and not animalsTable.aura("player", true_bearing) and ((not animalsTable.aura("player", curse_of_the_dreadblades) and not animalsTable.aura("player", adrenaline_rush)) or not animalsTable.aura("player", shark_infested_waters)))
				ss_useable_noreroll = (combo_points() < 5 + (animalsTable.talent31 and 1 or 0) - (animalsTable.aura("player", broadsides) and 1 or animalsTable.aura("player", jolly_roger) and 1 or 0) - (animalsTable.talent62 and not animalsTable.auraStacks("player", alacrity, 5) and 1 or 0))
				ss_useable = (animalsTable.talent32 and combo_points() < 4) or (not animalsTable.talent32 and ((rtb_reroll and combo_points() < 4 + (animalsTable.talent31 and 1 or 0))  or (not rtb_reroll and ss_useable_noreroll)))
				bf()
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

	local artifact = 0
	local goremaws_bite       = 209782
	local finality            = 197406
	local finality_nightblade = 0

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
				-- actions.cds+=/use_item,slot=trinket2,if=stealthed|target.time_to_die<20
				-- actions.cds+=/blood_fury,if=stealthed
				-- actions.cds+=/berserking,if=stealthed
				-- actions.cds+=/arcane_torrent,if=stealthed&energy.deficit>70
			end
			if animalsTable.spellIsReady(shadow_blades) and not IsStealthed() and not animalsTable.aura("player", shadow_dance.buff) and not animalsTable.aura("player", subterfuge) and not animalsTable.aura("player", shadowmeld) then animalsTable.cast(_, shadow_blades, _, _, _, _, "Shadow Blades") return end
		end
		if animalsTable.getTraitCurrentRank(artifact, goremaws_bite) > 0 and animalsTable.spellCanAttack(goremaws_bite) and not animalsTable.aura("player", shadow_dance.buff) and ((combo_points("deficit") >= 4-((GetTime()-animalsTable.combatStartTime) < 10 and 2 or 0) and energy("deficit") > 50+(animalsTable.talent33 and 25 or 0)-((GetTime()-animalsTable.combatStartTime) >= 10 and 15 or 0)) or animalsTable.animalIsBoss() and animalsTable.getTTD() < 8) then animalsTable.cast(_, goremaws_bite, _, _, _, _, "Goremaw's Bite") return end
		-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|(raid_event.adds.in>40&combo_points.deficit>=4+talent.deeper_strategem.enabled+talent.anticipation.enabled)
	end

	local function finish()
		if animalsTable.talent63 and animalsTable.spellIsReady(enveloping_shadows) and animalsTable.auraRemaining("player", enveloping_shadows, animalsTable.getTTD()) and animalsTable.auraRemaining("player", enveloping_shadows, combo_points()*1.8) then animalsTable.cast(_, enveloping_shadows, false, false, false, "SpellToInterrupt", "Enveloping Shadows") return end
		if animalsTable.aoe and animalsTable.talent73 and animalsTable.spellCanAttack(death_from_above) and animalsTable.targetCount(_, 8) >= 6 then animalsTable.cast(_, death_from_above, _, _, _, _, "Death from Above") return end
		-- if animalsTable.spellIsReady(nightblade) then
		-- -- 	-- actions.finish+=/nightblade,target_if=max:target.time_to_die,if=target.time_to_die>8&((refreshable&(!finality|buff.finality_nightblade.up))|remains<tick_time)
		-- 	if not animalsTable.aoe and animalsTable.spellCanAttack(nightblade) and animalsTable.getTTD() > 8 and ((animalsTable.auraRemaining("target", nightblade, 4.8, "", "PLAYER") and (animalsTable.getTraitCurrentRank(artifact, finality) == 0 or animalsTable.aura("player", finality_nightblade))) or animalsTable.auraRemaining("target", nightblade, 2, "", "PLAYER")) then animalsTable.cast(_, nightblade, _, _, _, _, "Nightblade") return end
		-- end
		if animalsTable.talent73 and animalsTable.spellCanAttack(death_from_above) then animalsTable.cast(_, death_from_above, _, _, _, _, "Death from Above") return end
		if animalsTable.spellCanAttack(eviscerate) then animalsTable.cast(_, eviscerate, _, _, _, _, "Eviscerate") return end
	end

	local function stealth_cds()
		if animalsTable.spellIsReady(shadow_dance.spell) and animalsTable.fracCalc("spell", shadow_dance.spell) >= 2.65 then animalsTable.cast(_, shadow_dance.spell, _, _, _, _, "Shadow Dance: Capped Charges") return true end
		if animalsTable.spellIsReady(vanish) and GetNumGroupMembers() > 1 then
			if vanishPartyCheck() then animalsTable.cast(_, vanish, false, false, false, "SpellToInterrupt", "Vanish") return end
		end
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
		if UnitAffectingCombat("player") then
			if animalsTable.validAnimal() and GetTime() > animalsTable.throttleSlaying then
				ssw_er = animalsTable.equippedGear.Feet ~= shadow_satyrs_walk and 0 or (10 - math.floor(animalsTable.distanceBetween()*0.5))
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