local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil

animalsTable.DEMONHUNTER = {
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

	local function cooldown()
		-- actions.cooldown=use_item,slot=trinket2,if=buff.chaos_blades.up|!talent.chaos_blades.enabled
		-- actions.cooldown+=/nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
		-- actions.cooldown+=/nemesis,if=!raid_event.adds.exists&(cooldown.metamorphosis.remains>100|target.time_to_die<70)
		-- actions.cooldown+=/nemesis,sync=metamorphosis,if=!raid_event.adds.exists
		-- actions.cooldown+=/chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.remains>100|target.time_to_die<20
		-- actions.cooldown+=/metamorphosis,if=variable.pooling_for_meta&fury.deficit<30&(talent.chaos_blades.enabled|!cooldown.fury_of_the_illidari.ready)
		-- actions.cooldown+=/potion,name=old_war,if=buff.metamorphosis.remains>25|target.time_to_die<30
	end

	function animalsTable.DEMONHUNTER1()
		if UnitAffectingCombat("player") then
			if animalsTable.validAnimal() then
				-- actions=auto_attack
				-- actions+=/variable,name=pooling_for_meta,value=cooldown.metamorphosis.ready&buff.metamorphosis.down&(!talent.demonic.enabled|!cooldown.eye_beam.ready)&(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready)&(!talent.nemesis.enabled|debuff.nemesis.up|cooldown.nemesis.ready)
				-- actions+=/variable,name=blade_dance,value=talent.first_blood.enabled|spell_targets.blade_dance1>=2+talent.chaos_cleave.enabled
				-- actions+=/variable,name=pooling_for_blade_dance,value=variable.blade_dance&fury-40<35-talent.first_blood.enabled*20&spell_targets.blade_dance1>=2
				-- actions+=/blur,if=artifact.demon_speed.enabled&cooldown.fel_rush.charges_fractional<0.5&cooldown.vengeful_retreat.remains-buff.momentum.remains>4
				cooldown()
				-- actions+=/pick_up_fragment,if=talent.demonic_appetite.enabled&fury.deficit>=30
				-- actions+=/consume_magic
				
				-- # Vengeful Retreat backwards through the target to minimize downtime.
				-- actions+=/vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
				-- # Fel Rush for Momentum and for fury from Fel Mastery.
				-- if UnitMovementFlags("Player") == 0 and animalsTable.spellIsReady(vengeful_retreat) and (animalsTable.talent21 or animalsTable.talent51) and not animalsTable.aura("player", prepared) and not animalsTable.aura("player", momentum) and animalsTable.playerCount(7, _, 0, ">") then
				-- actions+=/fel_rush,animation_cancel=1,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
				
				-- # Use Fel Barrage at max charges, saving it for Momentum and adds if possible.
				-- actions+=/fel_barrage,if=charges>=5&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
				-- actions+=/throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
				-- actions+=/fury_of_the_illidari,if=active_enemies>desired_targets|raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up)
				-- actions+=/eye_beam,if=talent.demonic.enabled&buff.metamorphosis.down&fury.deficit<30
				-- actions+=/death_sweep,if=variable.blade_dance
				-- actions+=/blade_dance,if=variable.blade_dance
				-- actions+=/throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2+talent.chaos_cleave.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
				-- actions+=/fel_eruption
				-- actions+=/felblade,if=fury.deficit>=30+buff.prepared.up*8
				-- actions+=/annihilation,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
				-- actions+=/throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
				-- actions+=/eye_beam,if=!talent.demonic.enabled&((spell_targets.eye_beam_tick>desired_targets&active_enemies>1)|(raid_event.adds.in>45&!variable.pooling_for_meta&buff.metamorphosis.down&(artifact.anguish_of_the_deceiver.enabled|active_enemies>1)))
				-- # If Demonic is talented, pool fury as Eye Beam is coming off cooldown.
				-- actions+=/demons_bite,if=talent.demonic.enabled&buff.metamorphosis.down&cooldown.eye_beam.remains<gcd&fury.deficit>=20
				-- actions+=/demons_bite,if=talent.demonic.enabled&buff.metamorphosis.down&cooldown.eye_beam.remains<2*gcd&fury.deficit>=45
				-- actions+=/throw_glaive,if=buff.metamorphosis.down&spell_targets>=2
				-- actions+=/chaos_strike,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&(!talent.demonic.enabled|!cooldown.eye_beam.ready)
				-- # Use Fel Barrage if its nearing max charges, saving it for Momentum and adds if possible.
				-- actions+=/fel_barrage,if=charges=4&buff.metamorphosis.down&(buff.momentum.up|!talent.momentum.enabled)&(active_enemies>desired_targets|raid_event.adds.in>30)
				-- actions+=/fel_rush,animation_cancel=1,if=!talent.momentum.enabled&raid_event.movement.in>charges*10
				-- actions+=/demons_bite
				-- actions+=/throw_glaive,if=buff.out_of_range.up|buff.raid_movement.up
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