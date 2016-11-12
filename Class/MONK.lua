local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil

animalsTable.MONK = {
	lastCast = 0,
	soothingMistTarget = "",
	hitComboTable = {
	    100780, -- Tiger Palm
	    100784, -- Blackout Kick
	    101545, -- Flying Serpent Kick
	    101546, -- Spinning Crane Kick
	    107428, -- Rising Sun Kick
	    113656, -- Fists of Fury
	    115080, -- Touch of Death
	    117952, -- Crackling Jade Lightning

	    115098, -- Chi Wave
	    116847, -- Rushing Jade Wind
	    123986, -- Chi Burst
	    152175, -- Whirling Dragon Punch

	    205320, -- Strike of the Wind Lord
	},
}

local blood_fury        =  33697
local spear_hand_strike = 116705

do -- Brewmaster
	local energy = animalsTable.pp
	function animalsTable.MONK1()
	    if UnitAffectingCombat("player") then
	        if animalsTable.validAnimal() then
	        	if animalsTable.spellCanAttack(spear_hand_strike) then animalsTable.interruptFunction(nil, spear_hand_strike) else animalsTable.interruptFunction() end
	            if animalsTable.spellCanAttack(121253) then animalsTable.cast(_, 121253, _, _, _, _, "Keg Smash") return end
	            if animalsTable.talent13 and animalsTable.spellCanAttack(115098, "player") then animalsTable.cast("player", 115098, _, _, _, _, "Chi Wave") return end
	            if animalsTable.talent72 and animalsTable.spellCanAttack(205523) then animalsTable.cast(_, 205523, _, _, _, _, "Blackout Strike: Blackout Combo") return end
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
	local blackout_kick              = 100784
	local chi_burst                  = 123986
	local effuse                     = 116694
	local enveloping_mist            = 124682
	local essence_font               = 191837
	local mistwalk                   = 0
	local refreshing_jade_wind       = 0
	local renewing_mist              = 115151
	local rising_sun_kick            = 107428
	local teachings_of_the_monastery = 202090
	local thunder_focus_tea          = 116680
	local tiger_palm                 = 100780
	local viviy                      = 116670
	local zen_pulse                  = 0
end

do -- Windwalker
	local chi                         = animalsTable.cp
	local energy                      = animalsTable.pp

	local blackout_kick               = 100784
	local blackout_kick_combo         = 116768
	local crackling_jade_lightning    = 117952
	local fists_of_fury               = 113656
	local mark_of_the_crane           = 228287
	local rising_sun_kick             = 107428
	local spinning_crane_kick         = 101546
	local tiger_palm                  = 100780
	
	local arcane_torrent              = 129597
	local storm_earth_and_fire        = 137639
	local touch_of_death              = 115080
	
	local chi_burst                   = 123986
	local chi_wave                    = 115098
	local energizing_elixir           = 115288
	local invoke_xuen_the_white_tiger = 123904
	local rushing_jade_wind           = 116847
	local serenity                    = 152173
	local whirling_dragon_punch       = 152175
	
	local artifact                    = 128940
	local gale_burst                  = 195399
	local strike_of_the_windlord      = 205320

	local function cd_action_list()
		if animalsTable.talent62 and animalsTable.spellCanAttack(invoke_xuen_the_white_tiger) then animalsTable.cast(_, invoke_xuen_the_white_tiger, _, _, _, _, "Invoke Xuen") return end
		if animalsTable.spellIsReady(blood_fury) then animalsTable.cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial ASP") return end
		if animalsTable.spellIsReady(berserking) then animalsTable.cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
		if animalsTable.spellIsReady(touch_of_death) then
			if animalsTable.getTraitCurrentRank(artifact, gale_burst) == 0 then
				if animalsTable.equippedGear.Hands == 137057 then
					if animalsTable.spellCanAttack(touch_of_death) and animalsTable.MONK.lastCast ~= touch_of_death then animalsTable.cast(_, touch_of_death, _, _, _, _, "Touch of Death") return end
					-- actions.cd+=/touch_of_death,cycle_targets=1,max_cycle_targets=2,if=!artifact.gale_burst.enabled&equipped.137057&!prev_gcd.touch_of_death
				else
					if animalsTable.spellCanAttack(touch_of_death) then animalsTable.cast(_, touch_of_death, _, _, _, _, "Touch of Death") return end
				end
			else
				if animalsTable.equippedGear.Hands == 137057 then
					if animalsTable.spellCanAttack(touch_of_death) and animalsTable.MONK.lastCast ~= touch_of_death and animalsTable.spellCDDuration(strike_of_the_windlord) < 8 and animalsTable.spellCDDuration(fists_of_fury) <= 4 and animalsTable.spellCDDuration(rising_sun_kick) < 7 then animalsTable.cast(_, touch_of_death, _, _, _, _, "Touch of Death") return end
					-- actions.cd+=/touch_of_death,cycle_targets=1,max_cycle_targets=2,if=artifact.gale_burst.enabled&equipped.137057&cooldown.strike_of_the_windlord.remains<8&cooldown.fists_of_fury.remains<=4&cooldown.rising_sun_kick.remains<7&!prev_gcd.touch_of_death
				else
					if animalsTable.spellCanAttack(touch_of_death) and animalsTable.spellCDDuration(strike_of_the_windlord) < 8 and animalsTable.spellCDDuration(fists_of_fury) <= 4 and animalsTable.spellCDDuration(rising_sun_kick) < 7 then animalsTable.cast(_, touch_of_death, _, _, _, _, "Touch of Death: Gale Burst") return end
				end
			end
		end
	end

	local function st_action_list()
		if animalsTable.cds then cd_action_list() end
		if animalsTable.spellIsReady(arcane_torrent) and chi("deficit") >= 1 and energy("tomax") >= 0.5 then animalsTable.cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Monk") return end
		if animalsTable.talent31 and animalsTable.spellIsReady(energizing_elixir) and energy("deficit") > 0 and chi() <= 1 then animalsTable.cast(_, energizing_elixir, _, _, _, _, "Energizing Elixir") return end
		if animalsTable.spellCanAttack(strike_of_the_windlord) and (animalsTable.talent73 or not animalsTable.aoe or animalsTable.targetCount(_, 8) < 6) then animalsTable.cast(_, strike_of_the_windlord, _, _, _, _, "Strike of the Windlord") return end
		if animalsTable.spellCanAttack(fists_of_fury) then animalsTable.cast(_, fists_of_fury, _, _, _, _, "Fists of Fury") return end
	    if animalsTable.spellIsReady(rising_sun_kick) then
	    	if animalsTable.spellCanAttack(rising_sun_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick: Mark of the Crane") return end
	    	if animalsTable.aoe then
		    	for i = 1, animalsTable.animalsSize do
		    		rotationUnitIterator = animalsTable.targetAnimals[i]
		    		if animalsTable.spellCanAttack(rising_sun_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, rising_sun_kick, _, _, _, _, "Rising Sun Kick: AoE Mark of the Crane") return end
		    	end
		    end
	    	if animalsTable.spellCanAttack(rising_sun_kick) then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
	    end
		if animalsTable.talent72 and animalsTable.spellIsReady(whirling_dragon_punch) and animalsTable.distanceBetween("target") < 8+UnitCombatReach("target") then animalsTable.cast(_, whirling_dragon_punch, _, _, _, _, "Whirling Dragon Punch") return end
		if animalsTable.aoe and animalsTable.spellIsReady(spinning_crane_kick) and animalsTable.MONK.lastCast ~= spinning_crane_kick and animalsTable.playerCount(8, false, 3, ">=") then animalsTable.cast(_, spinning_crane_kick, _, _, _, _, "Spinning Crane Kick") return end
		if animalsTable.talent61 and animalsTable.spellIsReady(rushing_jade_wind) and animalsTable.distanceBetween("target") < 8+UnitCombatReach("target") and chi("deficit") > 1 and animalsTable.MONK.lastCast ~= rushing_jade_wind then animalsTable.cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
		if animalsTable.spellIsReady(blackout_kick) and (chi() > 1 or animalsTable.aura("player", blackout_kick_combo)) and animalsTable.MONK.lastCast ~= blackout_kick then
			if animalsTable.spellCanAttack(blackout_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick: Mark of the Crane") return end
			if animalsTable.aoe then
				for i = 1, animalsTable.animalsSize do
					rotationUnitIterator = animalsTable.targetAnimals[i]
					if animalsTable.spellCanAttack(blackout_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, blackout_kick, _, _, _, _, "Blackout Kick: AoE Mark of the Crane") return end
				end
			end
			if animalsTable.spellCanAttack(blackout_kick) then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick") return end
		end
		if animalsTable.talent13 and animalsTable.spellCanAttack(chi_wave) and energy("deficit")/GetPowerRegen() >= 2.25 then animalsTable.cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
		if animalsTable.talent11 and animalsTable.spellIsReady(chi_burst) and energy("deficit")/GetPowerRegen() >= 2.25 then animalsTable.cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
        if animalsTable.spellIsReady(tiger_palm) and animalsTable.MONK.lastCast ~= tiger_palm then
	        if animalsTable.spellCanAttack(tiger_palm) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, tiger_palm, _, _, _, _, "Tiger Palm: Mark of the Crane") return end
	        if animalsTable.aoe then
		        for i = 1, animalsTable.animalsSize do
		        	rotationUnitIterator = animalsTable.targetAnimals[i]
		        	if animalsTable.spellCanAttack(tiger_palm, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, tiger_palm, _, _, _, _, "Tiger Palm: AoE Mark of the Crane") return end
		        end
	        end
	        if animalsTable.spellCanAttack(tiger_palm) then animalsTable.cast(_, tiger_palm, _, _, _, _, "Tiger Palm") return end
        end
	end

	local function serenity_action_list()
		if animalsTable.talent31 and animalsTable.spellIsReady(energizing_elixir) then animalsTable.cast(_, energizing_elixir, _, _, _, _, "Energizing Elixir") return end
		if animalsTable.cds then cd_action_list() end
		if animalsTable.spellIsReady(serenity) then animalsTable.cast(_, serenity, _, _, _, _, "Serenity") return end
		if animalsTable.spellCanAttack(strike_of_the_windlord) then animalsTable.cast(_, strike_of_the_windlord, _, _, _, _, "Strike of the Windlord") return end
		if animalsTable.spellIsReady(rising_sun_kick) and (not animalsTable.aoe or animalsTable.playerCount(8, false, 3, "<")) then
	    	if animalsTable.spellCanAttack(rising_sun_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick: Mark of the Crane") return end
	    	if animalsTable.aoe then
		    	for i = 1, animalsTable.animalsSize do
		    		rotationUnitIterator = animalsTable.targetAnimals[i]
		    		if animalsTable.spellCanAttack(rising_sun_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, rising_sun_kick, _, _, _, _, "Rising Sun Kick: AoE Mark of the Crane") return end
		    	end
		    end
	    	if animalsTable.spellCanAttack(rising_sun_kick) then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
		end
		if animalsTable.spellCanAttack(fists_of_fury) then animalsTable.cast(_, fists_of_fury, _, _, _, _, "Fists of Fury") return end
		if animalsTable.aoe and animalsTable.spellIsReady(spinning_crane_kick) and animalsTable.MONK.lastCast ~= spinning_crane_kick and animalsTable.playerCount(8, false, 3, ">=") then animalsTable.cast(_, spinning_crane_kick, _, _, _, _, "Spinning Crane Kick") return end
		if animalsTable.aoe and animalsTable.spellIsReady(rising_sun_kick) and animalsTable.playerCount(8, false, 3, ">=") then
	    	if animalsTable.spellCanAttack(rising_sun_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick: Mark of the Crane") return end
	    	if animalsTable.aoe then
		    	for i = 1, animalsTable.animalsSize do
		    		rotationUnitIterator = animalsTable.targetAnimals[i]
		    		if animalsTable.spellCanAttack(rising_sun_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, rising_sun_kick, _, _, _, _, "Rising Sun Kick: AoE Mark of the Crane") return end
		    	end
		    end
	    	if animalsTable.spellCanAttack(rising_sun_kick) then animalsTable.cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
		end
		if animalsTable.spellIsReady(blackout_kick) and animalsTable.MONK.lastCast ~= blackout_kick then
			if animalsTable.spellCanAttack(blackout_kick) and not animalsTable.aura("target", mark_of_the_crane, "", "PLAYER") then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick: Mark of the Crane") return end
			if animalsTable.aoe then
				for i = 1, animalsTable.animalsSize do
					rotationUnitIterator = animalsTable.targetAnimals[i]
					if animalsTable.spellCanAttack(blackout_kick, rotationUnitIterator) and not animalsTable.aura(rotationUnitIterator, mark_of_the_crane, "", "PLAYER") then animalsTable.cast(rotationUnitIterator, blackout_kick, _, _, _, _, "Blackout Kick: AoE Mark of the Crane") return end
				end
			end
			if animalsTable.spellCanAttack(blackout_kick) then animalsTable.cast(_, blackout_kick, _, _, _, _, "Blackout Kick") return end
		end
		if animalsTable.spellIsReady(spinning_crane_kick) and animalsTable.MONK.lastCast ~= spinning_crane_kick then animalsTable.cast(_, spinning_crane_kick, _, _, _, _, "Spinning Crane Kick") return end
		if animalsTable.talent61 and animalsTable.spellIsReady(rushing_jade_wind) and animalsTable.MONK.lastCast ~= rushing_jade_wind then animalsTable.cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
	end

	local function sef_action_list()
		if animalsTable.talent31 and animalsTable.spellIsReady(energizing_elixir) then animalsTable.cast(_, energizing_elixir, _, _, _, _, "Energizing Elixir") return end
		if animalsTable.spellIsReady(arcane_torrent) and chi("deficit") >= 1 and energy("tomax") >= 0.5 then animalsTable.cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Monk") return end
		if animalsTable.cds then cd_action_list() end
		if animalsTable.spellIsReady(storm_earth_and_fire) and not animalsTable.aura("player", storm_earth_and_fire) then animalsTable.cast(_, storm_earth_and_fire, _, _, _, _, "Storm, Earth, and Fire") return end
		st_action_list()
	end

	function animalsTable.MONK3()
		if UnitAffectingCombat("player") then
			if UnitChannelInfo("player") == "Crackling Jade Lightning" then SpellStopCasting() return end
			if animalsTable.isCH() then return end
			if animalsTable.validAnimal() then
				-- actions=auto_attack
				if animalsDataPerChar.interrupt then if animalsTable.spellCanAttack(spear_hand_strike) then animalsTable.interruptFunction(nil, spear_hand_strike) else animalsTable.interruptFunction() end end
				-- actions+=/potion,name=old_war,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
				if animalsTable.getTraitCurrentRank(artifact, strike_of_the_windlord) > 0 then
					if animalsTable.talent73 then
						if animalsTable.cds and animalsTable.spellIsReady(serenity) and animalsTable.spellCDDuration(strike_of_the_windlord) <= 14 and animalsTable.spellCDDuration(rising_sun_kick) <= 4 or animalsTable.aura("player", serenity) then
							serenity_action_list()
							return
						end
					else
						if animalsTable.cds and animalsTable.spellIsReady(storm_earth_and_fire) and not animalsTable.aura("player", storm_earth_and_fire) and animalsTable.spellCDDuration(strike_of_the_windlord) <= 14 and animalsTable.spellCDDuration(fists_of_fury) <= 6 and animalsTable.spellCDDuration(rising_sun_kick) <= 6 or animalsTable.aura("player", storm_earth_and_fire) then
							sef_action_list()
							return
						end
					end
				else
					if animalsTable.talent73 then
						if animalsTable.cds and animalsTable.spellIsReady(serenity) and animalsTable.spellCDDuration(fists_of_fury) < 14 and animalsTable.spellCDDuration(rising_sun_kick) < 7 or animalsTable.aura("player", serenity) then
							serenity_action_list()
							return
						end
					else
						if animalsTable.cds and animalsTable.spellIsReady(storm_earth_and_fire) and not animalsTable.aura("player", storm_earth_and_fire) and animalsTable.spellCDDuration(fists_of_fury) <= 9 and animalsTable.spellCDDuration(rising_sun_kick) <= 5 or animalsTable.aura("player", storm_earth_and_fire) then
							sef_action_list()
							return
						end
					end
				end
				st_action_list()
			end
		end
	end
end