local animalsName, animalsTable = ...
local _ = nil

do -- Havoc
	local chaos_strike = 162794
	local demons_bite = 162243
	local fel_rush = 195072
	local throw_glaive = 185123
	local metamorphosis = {spell = 191427, buff = 162264}
	local eye_beam = 198013
	local prepared = 203650
	local blade_dance = 188499
	local vengeful_retreat = 198793

	local annihilation = chaos_strike -- 201427
	local death_sweep = blade_dance -- 210152

	local felblade = 213241

	local momentum = 0
	local fel_eruption = 0
	local fel_barrage = 0
	local desired_targets = 0
	raid_event = {adds = {}}
	raid_event.adds.cooldown = 0

	local fury = animalsTable.pp
	local function blade_dance_worth_using()
		if animalsTable.talent32 then if animalsTable.playerCount(8, _, 0, ">") then return true else return false end end
		local demons_bite_fury = 25
		local demons_bite_damage = 2.6

		local blade_dance_cost = 35
		local demons_bite_per_dance = blade_dance_cost / demons_bite_fury
		local blade_dance_damage = 5.8
		blade_dance_damage = blade_dance_damage * animalsTable.playerCount(8)

		local chaos_strike_cost = 40
		local demons_bite_per_chaos_strike = ( chaos_strike_cost - 20 * GetCritChance()*.01 ) / demons_bite_fury
		local chaos_strike_damage = 7.15

		return ( blade_dance_damage + demons_bite_per_dance * demons_bite_damage ) / ( 1 + demons_bite_per_dance ) > ( chaos_strike_damage + demons_bite_per_chaos_strike * demons_bite_damage ) / ( 1 + demons_bite_per_chaos_strike )
	end
	local function death_sweep_worth_using()
		if animalsTable.talent32 then if animalsTable.playerCount(8, _, 0, ">") then return true else return false end end
		local demons_bite_fury = 25
		local demons_bite_damage = 2.6

		local blade_dance_cost = 35
		local demons_bite_per_dance = blade_dance_cost / demons_bite_fury
		local blade_dance_damage = 8.58
		blade_dance_damage = blade_dance_damage * animalsTable.playerCount(8)

		local chaos_strike_cost = 40
		local demons_bite_per_chaos_strike = ( chaos_strike_cost - 20 * GetCritChance()*.01 ) / demons_bite_fury
		local chaos_strike_damage = 9.29

		return(blade_dance_damage + demons_bite_per_dance * demons_bite_damage ) / ( 1 + demons_bite_per_dance ) > ( chaos_strike_damage + demons_bite_per_chaos_strike * demons_bite_damage ) / ( 1 + demons_bite_per_chaos_strike )
	end

	local function freezeFelRush() RunMacroText("/run local t=time()+2;while time()< t do end") end

	local lineCD = 0
	function animalsTable.DEMONHUNTER1()
		if UnitAffectingCombat("player") then
			if animalsTable.isCH() then return end
			if animalsTable.validAnimal() then
				-- actions+=/consume_magic
				if animalsTable.spellIsReady(vengeful_retreat) and (animalsTable.talent21 or animalsTable.talent51) and not animalsTable.aura("player", prepared) and not animalsTable.aura("player", momentum) and animalsTable.playerCount(7, _, 1, ">=") then
					SetHackEnabled("Fly", true)
					animalsTable.cast(_, vengeful_retreat, _, _, _, _, "Vengeful Retreat")
					return
				end
				if animalsTable.spellIsReady(fel_rush) and (animalsTable.talent51 or animalsTable.talent11) and (not animalsTable.talent51 or (GetSpellCharges(fel_rush) == 2 or animalsTable.spellCDDuration(vengeful_retreat) > 4) and not animalsTable.aura("player", momentum)) and (not animalsTable.talent11 or fury("deficit") >= 25) then
					if lineCD > 0 then return end
					animalsTable.cast(_, fel_rush, _, _, _, _, "Fel Rush: Talented")
					C_Timer.After(0.01, freezeFelRush)
					lineCD = 1
					return
				end
				lineCD = 0
				if animalsTable.spellIsReady(eye_beam) and animalsTable.distanceBetween("target") < 8+UnitCombatReach("target") and not animalsTable.aura("player", metamorphosis.buff) and (not animalsTable.talent32 or fury() >= 80 or fury("deficit") < 30) then animalsTable.cast(_, eye_beam, _, _, _, _, "Eye Beam: Demonic") return end
				-- # If Metamorphosis is ready, pool fury first before using it.
				-- actions+=/demons_bite,sync=metamorphosis,if=fury.deficit>=25
				-- actions+=/call_action_list,name=cooldown
				-- actions+=/fury_of_the_illidari,if=active_enemies>desired_targets|raid_event.adds.in>55

				if animalsTable.aoe and animalsTable.spellIsReady(death_sweep) and animalsTable.aura("player", metamorphosis.buff) and death_sweep_worth_using() then animalsTable.cast(_, death_sweep, _, _, _, _, "Death Sweep") return end
				if animalsTable.aoe and animalsTable.spellCanAttack(demons_bite) and animalsTable.aura("player", metamorphosis.buff) and not animalsTable.aura("player", metamorphosis.buff) and animalsTable.spellCDDuration(blade_dance) < animalsTable.globalCD() and fury() < 70 and death_sweep_worth_using() then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite: Pool for Death Sweep") return end
				if animalsTable.aoe and animalsTable.spellIsReady(blade_dance) and blade_dance_worth_using() then animalsTable.cast(_, blade_dance, _, _, _, _, "Blade Dance") return end
				-- # Use Fel Barrage at max charges, saving it for Momentum and adds if possible.
				-- actions+=/fel_barrage,if=charges>=5&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
				if animalsTable.aoe and animalsTable.talent33 and animalsTable.spellCanAttack(throw_glaive) and animalsTable.targetCount(8) >= 2+(animalsTable.talent12 and 1 or 0) and (not animalsTable.talent61 or not animalsTable.talent51 or animalsTable.aura("player", momentum)) then animalsTable.cast(_, throw_glaive, _, _, _, _, "Throw Glaive: AoE better than Chaos Cleave") return end
				-- if animalsTable.talent52 and animalsTable.spellCanAttack(fel_eruption) then animalsTable.cast(_, fel_eruption, _, _, _, _, "Fel Eruption") return end
				if animalsTable.talent31 and animalsTable.spellCanAttack(felblade) and fury("deficit") >= 30+(animalsTable.aura("player", prepared) and 8 or 0) then animalsTable.cast(_, felblade, _, _, _, _, "Felblade") return end
				if animalsTable.spellCanAttack(annihilation) and animalsTable.aura("player", metamorphosis.buff) and (not animalsTable.talent51 or animalsTable.aura("player", momentum) or fury("deficit") <= 30+(animalsTable.aura("player", prepared) and 8 or 0) or animalsTable.auraRemaining("player", metamorphosis.buff, 2)) then animalsTable.cast(_, annihilation, _, _, _, _, "Annihilation") return end
				if animalsTable.aoe and animalsTable.talent33 and animalsTable.spellCanAttack(throw_glaive) and (not animalsTable.talent61 or not animalsTable.talent51 or animalsTable.aura("player", momentum)) then animalsTable.cast(_, throw_glaive, _, _, _, _, "Throw Glaive: AoE better than Chaos Cleave") return end
				-- if animalsTable.spellIsReady(eye_beam) and animalsTable.distanceBetween("target") < 8+UnitCombatReach("target") and not animalsTable.talent73 and (animalsTable.targetCount(8) > desired_targets or raid_event.adds.cooldown > 45 and not animalsTable.aura("player", metamorphosis.buff) and (artifact.anguish_of_the_deceiver.enabled or animalsTable.targetCount(8) > 1 or UnitLevel("player") == 100)) then animalsTable.cast(_, eye_beam, _, _, _, _, "Eye Beam") return end
				if animalsTable.spellCanAttack(demons_bite) and not animalsTable.aura("player", metamorphosis.buff) then
					if animalsTable.aoe and animalsTable.spellCDDuration(blade_dance) < animalsTable.globalCD() and fury() < 55 and blade_dance_worth_using() then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite: Pool for Blade Dance") return end
					if animalsTable.talent73 and animalsTable.spellCDDuration(eye_beam) < animalsTable.globalCD()*(fury("deficit") >= 45 and 2 or fury("deficit") >= 20 and 1 or -math.huge) then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite: Pool for Eye Beam") return end
				end
				if animalsTable.aoe and animalsTable.spellCanAttack(throw_glaive) and not animalsTable.aura("player", metamorphosis.buff) and animalsTable.targetCount(8) >= 3 then animalsTable.cast(_, throw_glaive, _, _, _, _, "Throw Glaive: Cleave") return end
				if animalsTable.spellCanAttack(chaos_strike) and (not animalsTable.talent51 or animalsTable.aura("player", momentum) or fury("deficit") <= 30+(animalsTable.aura("player", prepared) and 8 or 0)) then animalsTable.cast(_, chaos_strike, _, _, _, _, "Chaos Strike") return end
				-- # Use Fel Barrage if its nearing max charges, saving it for Momentum and adds if possible.
				-- actions+=/fel_barrage,if=charges=4&buff.metamorphosis.down&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
				if animalsTable.spellIsReady(fel_rush) and not animalsTable.talent51 then
					if lineCD > 0 then return end
					animalsTable.cast(_, fel_rush, _, _, _, _, "Fel Rush: Talented")
					C_Timer.After(0.01, freezeFelRush)
					lineCD = 1
					return
				end
				lineCD = 0
				if animalsTable.spellCanAttack(demons_bite) then animalsTable.cast(_, demons_bite, _, _, _, _, "Demon's Bite") return end
				if animalsTable.spellCanAttack(throw_glaive) then animalsTable.cast(_, throw_glaive, _, _, _, _, "Throw Glaive") return end

				-- actions.cooldown=use_item,slot=trinket2,if=buff.chaos_blades.up|!talent.chaos_blades.enabled
				-- actions.cooldown+=/nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
				-- actions.cooldown+=/nemesis,if=!raid_event.adds.exists&(cooldown.metamorphosis.remains>100|target.time_to_die<70)
				-- actions.cooldown+=/nemesis,sync=metamorphosis,if=!raid_event.adds.exists
				-- actions.cooldown+=/chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.remains>100|target.time_to_die<20
				-- # Use Metamorphosis if Nemesis and Chaos Blades are ready.
				-- actions.cooldown+=/metamorphosis,if=buff.metamorphosis.down&(!talent.demonic.enabled|!cooldown.eye_beam.ready)&(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready)&(!talent.nemesis.enabled|debuff.nemesis.up|cooldown.nemesis.ready)
				-- actions.cooldown+=/potion,name=deadly_grace,if=buff.metamorphosis.remains>25
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