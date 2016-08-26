local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil

animalsTable.MONK = {
	lastCast = 0,
	soothingMistTarget = "",
	hitComboTable = {
		    100784, -- Blackout Kick
		    117952, -- Crackling Jade Lightning
		    113656, -- Fists of Fury
		    101545, -- Flying Serpent Kick
		    107428, -- Rising Sun Kick
		    101546, -- Spinning Crane Kick
		    100780, -- Tiger Palm
		    115080, -- Touch of Death

		    123986, -- Chi Burst
		    115098, -- Chi Wave
		    116847, -- Rushing Jade Wind
		    152175, -- Whirling Dragon Punch
		},
}

local blood_fury = 33697

do -- Brewmaster
	local energy = animalsTable.pp
	function animalsTable.MONK1()
	    if UnitAffectingCombat("player") then
	        if animalsTable.validAnimal() and animalsTable.throttleSlaying then
	            if animalsTable.talent13 and animalsTable.spellCanAttack(115098, "player") then animalsTable.cast("player", 115098, _, _, _, _, "Chi Wave") return end
	            if animalsTable.talent72 and animalsTable.spellCanAttack(205523) then animalsTable.cast(_, 205523, _, _, _, _, "Blackout Strike: Blackout Combo") return end
	            if animalsTable.spellCanAttack(121253) then animalsTable.cast(_, 121253, _, _, _, _, "Keg Smash") return end
	            if animalsTable.aoe and animalsTable.playerCount(8, _, 2, ">=") then
	                if animalsTable.talent11 and animalsTable.spellIsReady(123986) then animalsTable.cast(_, 123986, _, _, _, _, "Chi Burst") return end
	                if animalsTable.spellIsReady(115181) and animalsTable.aura("target", 121253, "", "PLAYER") then animalsTable.cast(_, 115181, _, _, _, _, "Breath of Fire: AoE") return end
	                if animalsTable.talent61 and animalsTable.spellIsReady(116847) then animalsTable.cast(_, 116847, _, _, _, _, "Rushing Jade Wind") return end
	            end
	            if animalsTable.spellCanAttack(100780) and energy() >= 65 then animalsTable.cast(_, 100780, _, _, _, _, "Tiger Palm") return end
	            if animalsTable.spellCanAttack(205523) then animalsTable.cast(_, 205523, _, _, _, _, "Blackout Strike") return end
	            if animalsTable.talent61 and animalsTable.spellIsReady(116847) then animalsTable.cast(_, 116847, _, _, _, _, "Rushing Jade Wind") return end
	            if animalsTable.spellIsReady(115181) and animalsTable.aura("target", 121253, "", "PLAYER") and animalsTable.distanceBetween("target") < 8+UnitCombatReach("target") then animalsTable.cast(_, 115181, _, _, _, _, "Breath of Fire") return end
	        end
	    end
	end
end

do -- Mistweaver
end

do -- Windwalker
	local chi = animalsTable.cp
	local energy = animalsTable.pp

	local arcane_torrent              = 129597
	local blackout_kick               = 100784
	local blackout_kick_combo         = 116768
	local chi_burst                   = 123986
	local chi_wave                    = 115098
	local energizing_elixir           = 115288
	local fists_of_fury               = 113656
	local invoke_xuen_the_white_tiger = 123904
	local mark_of_the_crane           = 228287
	local rising_sun_kick             = 107428
	local rushing_jade_wind           = 116847
	local serenity                    = 152173
	local spinning_crane_kick         = 101546
	local storm_earth_and_fire        = 137639
	local tiger_palm                  = 100780
	local touch_of_death              = 115080
	local whirling_dragon_punch       = 152175

	function animalsTable.MONK3()
		if UnitAffectingCombat("player") then
			if animalsTable.isCH() then return end
			if animalsTable.validAnimal() and GetTime() > animalsTable.throttleSlaying then
			    if animalsTable.cds then
			        if animalsTable.talent62 and animalsTable.spellCanAttack(invoke_xuen_the_white_tiger) then animalsTable.cast(_, invoke_xuen_the_white_tiger, _, _, _, _, "Invoke Xuen, the White Tiger") return end
			        -- actions+=/potion,name=deadly_grace,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
			        if animalsTable.spellCanAttack(touch_of_death) then animalsTable.cast(_, touch_of_death, _, _, _, _, "Touch of Death") return end
			            -- actions+=/touch_of_death,if=!artifact.gale_burst.enabled
			            -- actions+=/touch_of_death,if=artifact.gale_burst.enabled&cooldown.strike_of_the_windlord.remains<8&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
			        if animalsTable.spellIsReady(blood_fury) then animalsTable.cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial ASP") return end
			        if animalsTable.spellIsReady(berserking) then animalsTable.cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
			        if animalsTable.spellIsReady(arcane_torrent) and chi("deficit") >= 1 then animalsTable.cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Monk") return end
			        if not animalsTable.talent73 and animalsTable.spellIsReady(storm_earth_and_fire) and not animalsTable.aura("player", storm_earth_and_fire) and animalsTable.spellCDDuration(fists_of_fury) <= 9 and animalsTable.spellCDDuration(rising_sun_kick) <= 5 then animalsTable.cast(_, storm_earth_and_fire, _, _, _, _, "Storm, Earth, and Fire") return end
			            -- actions+=/storm_earth_and_fire,if=artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<14&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
			            -- actions+=/storm_earth_and_fire,if=!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
			        if animalsTable.talent73 and animalsTable.spellIsReady(serenity) and chi() > 1 and animalsTable.spellCDDuration(fists_of_fury) <= 3 and animalsTable.spellCDDuration(rising_sun_kick) < 8 then animalsTable.cast(_, serenity, _, _, _, _, "Serenity") return end
			            -- actions+=/serenity,if=artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<7&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
			            -- actions+=/serenity,if=!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
			    end
			    if animalsTable.talent31 and animalsTable.spellIsReady(energizing_elixir) and energy("deficit") > 0 and chi() <= 1 and not animalsTable.aura("player", serenity) then animalsTable.cast(_, energizing_elixir, _, _, _, _, "Energizing Elixir") return end
			    if animalsTable.talent61 and animalsTable.spellIsReady(rushing_jade_wind) and animalsTable.aura("player", serenity) and animalsTable.MONK.lastCast ~= rushing_jade_wind then animalsTable.cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind: Free Serenity") return end
			    -- actions+=/strike_of_the_windlord
			    if animalsTable.talent72 and animalsTable.spellIsReady(whirling_dragon_punch) and not animalsTable.isCH() and animalsTable.distanceBetween("target") < 8+UnitCombatReach("target") then animalsTable.cast(_, whirling_dragon_punch, _, _, _, _, "Whirling Dragon Punch") return end
			    if animalsTable.spellCanAttack(fists_of_fury) then animalsTable.cast(_, fists_of_fury, _, _, _, _, "Fists of Fury") return end
			    if (not animalsTable.aoe or animalsTable.playerCount(8) < 3) then -- Single Target
			        if animalsTable.spellCanAttack(rising_sun_kick) then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
			        if animalsTable.talent61 and animalsTable.spellIsReady(rushing_jade_wind) and chi() > 1 and animalsTable.MONK.lastCast ~= rushing_jade_wind then animalsTable.cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
			        if animalsTable.talent13 and animalsTable.spellCanAttack(chi_wave) and (((energy("deficit"))/GetPowerRegen()) > 2 or not animalsTable.aura("player", serenity)) then animalsTable.cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
			        if animalsTable.talent11 and animalsTable.spellIsReady(chi_burst) and (energy("deficit")/GetPowerRegen() > 2 or not animalsTable.aura("player", serenity)) then animalsTable.cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
			        if animalsTable.spellCanAttack(blackout_kick) and (chi() > 1 or animalsTable.aura("player", blackout_kick_combo)) and not animalsTable.aura("player", serenity) and animalsTable.MONK.lastCast ~= blackout_kick then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick") return end
			        if animalsTable.spellCanAttack(tiger_palm) and not animalsTable.aura("player", serenity) and chi() <= 2 and (animalsTable.MONK.lastCast ~= tiger_palm) then animalsTable.cast(_, tiger_palm, _, _, _, _, "Tiger Palm") return end
			    else -- AoE
			        if animalsTable.spellIsReady(spinning_crane_kick) and animalsTable.MONK.lastCast ~= spinning_crane_kick then animalsTable.cast(_, spinning_crane_kick, _, _, _, _, "Spinning Crane Kick") return end
			        if animalsTable.spellIsReady(rising_sun_kick) then
			        	if animalsTable.spellCanAttack(rising_sun_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick: AoE Mark of the Crane") return end
			        	for i = 1, animalsTable.animalsSize do
			        		rotationUnitIterator = animalsTable.targetAnimals[i]
			        		if animalsTable.spellCanAttack(rising_sun_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, rising_sun_kick, _, _, _, _, "Rising Sun Kick: AoE Mark of the Crane") return end
			        	end
			        	if animalsTable.spellCanAttack(rising_sun_kick) then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick: AoE") return end
			        end
			        if animalsTable.talent61 and animalsTable.spellIsReady(rushing_jade_wind) and chi() > 1 and animalsTable.MONK.lastCast ~= rushing_jade_wind then animalsTable.cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
			        if animalsTable.talent13 and animalsTable.spellCanAttack(chi_wave) and (((energy("deficit"))/GetPowerRegen()) > 2 or not animalsTable.aura("player", serenity)) then animalsTable.cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
			        if animalsTable.talent11 and animalsTable.spellIsReady(chi_burst) and (energy("deficit")/GetPowerRegen() > 2 or not animalsTable.aura("player", serenity)) then animalsTable.cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
			        if animalsTable.spellIsReady(blackout_kick) and (chi() > 1 or animalsTable.aura("player", blackout_kick_combo)) and animalsTable.MONK.lastCast ~= blackout_kick then
			        	if animalsTable.spellCanAttack(blackout_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick: AoE Mark of the Crane") return end
			        	for i = 1, animalsTable.animalsSize do
			        		rotationUnitIterator = animalsTable.targetAnimals[i]
			        		if animalsTable.spellCanAttack(blackout_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, blackout_kick, _, _, _, _, "Blackout Kick: AoE Mark of the Crane") return end
			        	end
			        	if animalsTable.spellCanAttack(blackout_kick) then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick: AoE") return end
			        end
			        if animalsTable.spellIsReady(tiger_palm) and not animalsTable.aura("player", serenity) and chi("deficit") > 1 and animalsTable.MONK.lastCast ~= tiger_palm then
				        if animalsTable.spellCanAttack(tiger_palm) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, tiger_palm, _, _, _, _, "Tiger Palm: AoE Mark of the Crane") return end
				        for i = 1, animalsTable.animalsSize do
				        	rotationUnitIterator = animalsTable.targetAnimals[i]
				        	if animalsTable.spellCanAttack(tiger_palm, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, tiger_palm, _, _, _, _, "Tiger Palm: AoE Mark of the Crane") return end
				        end
				        if animalsTable.spellCanAttack(tiger_palm) then animalsTable.cast(_, tiger_palm, _, _, _, _, "Tiger Palm: AoE") return end
			        end
			    end
			    -- actions.opener=blood_fury
			    -- actions.opener+=/berserking
			    -- actions.opener+=/arcane_torrent,if=chi.max-chi>=1
			    -- actions.opener+=/fists_of_fury,if=buff.serenity.up&buff.serenity.remains<1.5
			    -- if animalsTable.spellCanAttack(rising_sun_kick) then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
			    -- actions.opener+=/blackout_kick,if=chi.max-chi<=1&cooldown.chi_brew.up|buff.serenity.up
			    -- actions.opener+=/serenity,if=chi.max-chi<=2
			    -- actions.opener+=/tiger_palm,if=chi.max-chi>=2&!buff.serenity.up
			end
		end
	end
end