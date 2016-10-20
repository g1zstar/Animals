local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil

animalsTable.DEMONHUNTER = {
	castVengefulRetreat = false,
	castFelRush = false,
}

do -- Havoc
	local fury = animalsTable.pp

	local pooling_for_meta        = false
	local blade_dance             = false
	local pooling_for_blade_dance = false

	-- talents=1130111
	-- talent_override=fel_barrage,if=active_enemies>1|raid_event.adds.exists

	local blade_dance             = 188499
	local chaos_strike            = 162794
	local consume_magic           = 183752
	local demons_bite             = 162243
	local eye_beam                = 198013
	local fel_rush                = 195072
	local throw_glaive            = 185123
	local vengeful_retreat        = 198793

	local annihilation            = chaos_strike -- 201427
	local death_sweep             = blade_dance -- 210152
	local metamorphosis           = {spell = 191427, buff = 162264}
	
	local chaos_blades            = 211048
	local fel_barrage             = 211053
	local fel_eruption            = 211881
	local felblade                = 213241
	local momentum                = 208628
	local nemesis                 = 206491
	local prepared                = 203650

	local artifact                = 127829
	local anguish_of_the_deceiver = 201473
	local demon_speed             = 201469
	local fury_of_the_illidari    = 201467

	local function freezeFelRush() RunMacroText("/run local t=time()+2;while time()< t do end") end

	local function castVengefulRetreat()
		SetHackEnabled("NoKnockback", true)
		animalsTable.cast(_, vengeful_retreat, _, _, _, _, "Vengeful Retreat")
	end

	local function executeFelRush()
		animalsTable.cast(_, fel_rush, _, _, _, _, "Fel Rush")
	end

	local function castFelRush()
		MoveBackwardStart()
		C_Timer.After(0.04, executeFelRush)
	end

	local function cooldown()
		-- actions.cooldown=use_item,slot=trinket2,if=buff.chaos_blades.up|!talent.chaos_blades.enabled
		-- actions.cooldown+=/nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
		-- actions.cooldown+=/nemesis,if=!raid_event.adds.exists&(cooldown.metamorphosis.remains>100|target.time_to_die<70)
		-- actions.cooldown+=/nemesis,sync=metamorphosis,if=!raid_event.adds.exists
		if animalsTable.talent71 and animalsTable.spellIsReady(chaos_blades) and (animalsTable.aura("player", metamorphosis.buff) or animalsTable.spellCDDuration(metamorphosis.spell) > 100 or animalsTable.getTTD() < 20) then animalsTable.cast(_, chaos_blades, false, false, false, "SpellToInterrupt", "Chaos Blades") return end
		if animalsTable.spellIsReady(metamorphosis.spell) and pooling_for_meta and fury("deficit") < 30 and (animalsTable.talent71 or not animalsTable.spellIsReady(fury_of_the_illidari)) then
			local x, y, z = ObjectPosition("player")
			animalsTable.cast(_, metamorphosis.spell, x, y, z, "SpellToInterrupt", "Metamorphosis")
			return
		end
		-- actions.cooldown+=/potion,name=old_war,if=buff.metamorphosis.remains>25|target.time_to_die<30
	end

	function animalsTable.DEMONHUNTER1()
		if UnitAffectingCombat("player") then
			pooling_for_meta = animalsTable.cds and animalsTable.spellIsReady(metamorphosis.spell) and not animalsTable.aura("player", metamorphosis.buff) and (not animalsTable.talent73 or animalsTable.spellCDDuration(eye_beam) > 0) and (not animalsTable.talent71 or animalsTable.spellIsReady(chaos_blades)) and (not animalsTable.talent53 or animalsTable.aura("target", nemesis, "", "PLAYER") or animalsTable.spellIsReady(nemesis))
			blade_dance = animalsTable.talent32 and animalsTable.playerCount(8, _, 0, ">") or animalsTable.aoe and animalsTable.playerCount(8, _, 2+(animalsTable.talent12 and 1 or 0), ">=")
			pooling_for_blade_dance = blade_dance and fury()-40 < 35-(animalsTable.talent32 and 20 or 0) and animalsTable.aoe and animalsTable.playerCount(8, _, 2, ">=")
			if animalsTable.isCH() then return end
			if animalsTable.DEMONHUNTER.castVengefulRetreat then
				castVengefulRetreat()
				return
			end
			if animalsTable.DEMONHUNTER.castFelRush then
				castFelRush()
				return
			end
			if animalsTable.validAnimal() then
				if animalsTable.spellIsReady(blur) and animalsTable.getTraitCurrentRank(artifact, demon_speed) and animalsTable.fracCalc("spell", fel_rush) < 0.5 and animalsTable.spellCDDuration(vengeful_retreat) - (animalsTable.aura("player", momentum) and (select(7, animalsTable.aura("player", momentum))-GetTime()) or 0) > 4 then animalsTable.cast(_, blur, false, false, false, "SpellToInterrupt", "Blur: Fel Rush Charges") return end
				if animalsTable.cds then cooldown() end
				-- actions+=/call_action_list,name=cooldown
				if animalsTable.spellIsReady(consume_magic) then animalsTable.interruptFunction(_, consume_magic) else animalsTable.interruptFunction() end
				if UnitMovementFlags("Player") == 0 and animalsTable.spellIsReady(vengeful_retreat) and (animalsTable.talent21 or animalsTable.talent51) and not animalsTable.aura("player", prepared) and not animalsTable.aura("player", momentum) and animalsTable.playerCount(7, _, 0, ">") then
					animalsTable.DEMONHUNTER.castVengefulRetreat = true
					return
				end
				SetHackEnabled("NoKnockback", false)
				if UnitMovementFlags("Player") == 0 and animalsTable.spellIsReady(fel_rush) and animalsTable.debugTable["ogSpell"] ~= fel_rush and (animalsTable.talent51 or animalsTable.talent11) and (not animalsTable.talent51 or (GetSpellCharges(fel_rush) == 2 or animalsTable.spellCDDuration(vengeful_retreat) > 4) and not animalsTable.aura("player", momentum)) and (not animalsTable.talent11 or fury("deficit") >= 25) --[[and (GetSpellCharges(fel_rush) == 2 or (raid_event.movement.in > 10 and raid_event.adds.in > 10))]] then
					animalsTable.DEMONHUNTER.castFelRush = true
					return
				end
				-- # Use Fel Barrage at max charges, saving it for Momentum and adds if possible.
				-- actions+=/fel_barrage,if=charges>=5&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
				if animalsTable.spellCanAttack(throw_glaive) and animalsTable.talent33 and (not animalsTable.talent51 or animalsTable.aura("player", momentum)) and GetSpellCharges(throw_glaive) == 2 then animalsTable.cast(_, throw_glaive, false, false, false, "SpellToInterrupt", "Throw Glaive: Bloodlet Capped Charges") return end
				if UnitMovementFlags("player") == 0 and animalsTable.getTraitCurrentRank(artifact, fury_of_the_illidari) > 0 and animalsTable.spellIsReady(fury_of_the_illidari) and animalsTable.distanceBetween() < 8+UnitCombatReach("target") then animalsTable.cast(_, fury_of_the_illidari, false, false, false, "SpellToInterrupt", "Fury of the Illidari") return end
				-- actions+=/fury_of_the_illidari,if=active_enemies>desired_targets|raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up)
				if animalsTable.spellIsReady(eye_beam) and animalsTable.talent73 and not animalsTable.aura("player", metamorphosis.buff) and fury("deficit") < 30 and animalsTable.distanceBetween() < 20 then animalsTable.cast(_, eye_beam, false, false, false, "SpellToInterrupt", "Eye Beam: Demonic") return end
				if animalsTable.spellIsReady(death_sweep) and blade_dance then animalsTable.cast(_, death_sweep, false, false, false, "SpellToInterrupt", "Death Sweep") return end
				if animalsTable.spellIsReady(blade_dance) and blade_dance then animalsTable.cast(_, blade_dance, false, false, false, "SpellToInterrupt", "Blade Dance") return end
				if animalsTable.aoe and animalsTable.spellCanAttack(throw_glaive) and animalsTable.talent33 and animalsTable.targetCount(_, 8) >= (animalsTable.talent12 and 3 or 2) and (not animalsTable.talent61 or not animalsTable.talent51 or animalsTable.aura("player", momentum)) and (animalsTable.targetCount(_, 8) >= 3) then animalsTable.cast(_, throw_glaive, false, false, false, "SpellToInterrupt", "Throw Glaive: AoE") return end
				-- actions+=/throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2+talent.chaos_cleave.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
				if animalsTable.talent52 and animalsTable.spellCanAttack(fel_eruption) then animalsTable.cast(_, fel_eruption, false, false, false, "SpellToInterrupt", "Fel Eruption") return end
				if animalsTable.talent31 and animalsTable.spellCanAttack(felblade) and fury("deficit") >= (animalsTable.aura("player", prepared) and 38 or 30) then animalsTable.cast(_, felblade, false, false, false, "SpellToInterrupt", "Felblade") return end
				if animalsTable.spellCanAttack(chaos_strike) and animalsTable.aura("player", metamorphosis.buff) and (animalsTable.talent22 or not animalsTable.talent51 or animalsTable.aura("player", momentum) or fury("deficit") < 30 + (animalsTable.aura("player", prepared) and 8 or 0) or animalsTable.auraRemaining("player", metamorphosis.buff, 5)) and not pooling_for_blade_dance then animalsTable.cast(_, chaos_strike, _, _, _, _, "Annihilation") return end
				-- actions+=/throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
				-- actions+=/eye_beam,if=!talent.demonic.enabled&((spell_targets.eye_beam_tick>desired_targets&active_enemies>1)|(raid_event.adds.in>45&!variable.pooling_for_meta&buff.metamorphosis.down&(artifact.anguish_of_the_deceiver.enabled|active_enemies>1)))
				if animalsTable.talent73 and animalsTable.spellCanAttack(demons_bite) and not animalsTable.aura("player", metamorphosis.buff) then
					if animalsTable.spellCDDuration(eye_beam) < animalsTable.globalCD() and fury("deficit") >= 20 then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite: Pooling for Demonic Eye Beam Next GCD") return end
					if animalsTable.spellCDDuration(eye_beam) < 2 * animalsTable.globalCD() and fury("deficit") >= 45 then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite: Pooling for Demonic Eye Beam Next 2 GCDs") return end
				end
				if animalsTable.aoe and animalsTable.spellCanAttack(throw_glaive) and not animalsTable.aura("player", metamorphosis.buff) and animalsTable.targetCount(_, 8, _, 2, ">=") then animalsTable.cast(_, throw_glaive, false, false, false, "SpellToInterrupt", "Throw Glaive: Cleave") return end
				if animalsTable.spellCanAttack(chaos_strike) and (animalsTable.talent22 or not animalsTable.talent51 or animalsTable.aura("player", momentum) or fury("deficit") < 30 + (animalsTable.aura("player", prepared) and 8 or 0)) and not pooling_for_meta and not pooling_for_blade_dance and (not animalsTable.talent73 or animalsTable.spellCDDuration(eye_beam) > 0) then animalsTable.cast(_, chaos_strike, _, _, _, _, "Chaos Strike") return end
				-- # Use Fel Barrage if its nearing max charges, saving it for Momentum and adds if possible.
				-- actions+=/fel_barrage,if=charges=4&buff.metamorphosis.down&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
				if UnitMovementFlags("Player") == 0 and animalsTable.spellIsReady(fel_rush) and animalsTable.debugTable["ogSpell"] ~= fel_rush and not animalsTable.talent51 --[[and raid_event.movement.in > charges*10]] then
					animalsTable.DEMONHUNTER.castFelRush = true
					return
				end
				if animalsTable.spellCanAttack(demons_bite) then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite") return end
				if animalsTable.spellCanAttack(throw_glaive) then animalsTable.cast(_, throw_glaive, _, _, _, _, "Throw Glaive: Out of Range") return end
				-- actions+=/felblade,if=movement.distance|buff.out_of_range.up
			end
		end
	end
end

do -- Vengeance
	local shear = 203782
	local soul_cleave = 228477
	local immolation_aura = 178740

	local pain = animalsTable.pp

	function animalsTable.DEMONHUNTER2()
		if UnitAffectingCombat("player") then
			if animalsTable.validAnimal() then
				-- actions+=/infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&artifact.fiery_demise.enabled&dot.fiery_brand.ticking
				-- actions+=/infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&(!artifact.fiery_demise.enabled|(max_charges-charges_fractional)*recharge_time<cooldown.fiery_brand.remains+5)&(cooldown.sigil_of_flame.remains>7|charges=2)
				-- actions+=/spirit_bomb,if=debuff.frailty.down
				-- actions+=/soul_carver,if=dot.fiery_brand.ticking
				if animalsTable.spellIsReady(immolation_aura) and pain() <= 80 then animalsTable.cast(_, immolation_aura, _, _, _, _, "Immolation Aura") return end
				if animalsTable.talent31 and animalsTable.spellCanAttack(felblade) and pain() <= 70 then animalsTable.cast(_, felblade, _, _, _, _, "Felblade") return end
				-- actions+=/soul_barrier
				if animalsTable.spellCanAttack(soul_cleave) and animalsTable.auraStacks("player", 203981, 5) then animalsTable.cast(_, soul_cleave, _, _, _, _, "Soul Cleave: Max Fragments") return end
				-- actions+=/metamorphosis,if=buff.demon_spikes.down&!dot.fiery_brand.ticking&buff.metamorphosis.down&incoming_damage_5s>health.max*0.70
				-- actions+=/fel_devastation,if=incoming_damage_5s>health.max*0.70
				-- actions+=/soul_cleave,if=incoming_damage_5s>=health.max*0.70
				-- actions+=/fel_eruption
				-- actions+=/sigil_of_flame,if=remains-delay<=0.3*duration
				-- actions+=/fracture,if=pain>=80&soul_fragments<4&incoming_damage_4s<=health.max*0.20
				if animalsTable.spellCanAttack(soul_cleave) and pain() >= 80 then animalsTable.cast(_, soul_cleave, _, _, _, _, "Soul Cleave: Dump Pain") return end
				if animalsTable.spellCanAttack(shear) then animalsTable.cast(_, shear, _, _, _, _, "Shear") return end
			end
		end
	end
end