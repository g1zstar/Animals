local animalsName, animalsTable = ...
local _ = nil

local rotationUnitIterator = nil

animalsTable.HUNTER = {
}

local focus = animalsTable.pp

local arcane_torrent = 0
local blood_fury     = 0
local berserking     = 0

do -- Beast Mastery
end

do -- Marksman
	local vulnerable_time = 0
	-- talents=1103021

	local arcane_shot = 185358
	local hunters_mark = 185365
	local marking_targets = 223138
	local vulnerability = 187131
	local marked_shot = 185901
	local multishot = 2643
	local aimed_shot = 19434

	local trueshot = 193526

	local a_murder_of_crows = 131894
	local barrage = 120360
	local piercing_shot = 198670
	local sentinel = 206817
	local true_aim = 199803
	local lock_and_load = 194594
	local black_arrow = 194599
	local steady_focus = 193534
	local explosive_shot = 212431
	local sidewinders = 214579

	local artifact = 128826
	local windburst = 204147
	local bullseye = 0


	local function cooldowns()
		-- actions.cooldowns=potion,name=deadly_grace,if=(buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<31
		-- actions.cooldowns+=//trueshot,if=buff.bloodlust.react|target.time_to_die>=(cooldown+30)|buff.bullseye.react>25|target.time_to_die<16
	end

	local function open()
		-- actions.open=a_murder_of_crows
		-- actions.open+=/trueshot
		-- actions.open+=/sidewinders,if=(buff.marking_targets.down&buff.trueshot.remains<2)|(charges_fractional>=1.9&focus<80)
		-- actions.open+=/marked_shot
		-- actions.open+=/aimed_shot,if=buff.lock_and_load.up&execute_time<debuff.vulnerability.remains
		-- actions.open+=/black_arrow
		-- actions.open+=/barrage
		-- actions.open+=/aimed_shot,if=execute_time<debuff.vulnerability.remains
		-- actions.open+=/sidewinders
		-- actions.open+=/aimed_shot
		-- actions.open+=/arcane_shot
	end

	local function targetdie()
		-- actions.targetdie=marked_shot
		-- actions.targetdie+=/windburst
		-- actions.targetdie+=/aimed_shot,if=execute_time<debuff.vulnerability.remains
		-- actions.targetdie+=/sidewinders
		-- actions.targetdie+=/aimed_shot
		-- actions.targetdie+=/arcane_shot
	end

	local function trueshotaoe()
		if animalsTable.spellIsReady(marked_shot) then animalsTable.cast(_, marked_shot, _, _, _, _, "Marked Shot: Trueshot AoE") return end
		-- actions.trueshotaoe+=/piercing_shot
		-- actions.trueshotaoe+=/barrage
		-- actions.trueshotaoe+=/explosive_shot
		-- actions.trueshotaoe+=/aimed_shot,if=active_enemies=2&buff.lock_and_load.up&execute_time<debuff.vulnerability.remains
		if animalsTable.spellCanAttack(multishot) then animalsTable.cast(_, multishot, _, _, _, _, "Multi-Shot: Trueshot AoE") return end
	end

	function animalsTable.HUNTER2()
		if UnitAffectingCombat("player") then
			if animalsTable.isCH() then return end
			if animalsTable.validAnimal() and GetTime() > animalsTable.throttleSlaying then
				-- actions=auto_shot
				-- actions+=/arcane_torrent,if=focus.deficit>=30&(!talent.sidewinders.enabled|cooldown.sidewinders.charges<2)
				-- actions+=/blood_fury
				-- actions+=/berserking
				-- actions+=/auto_shot
				-- actions+=/variable,name=vulnerable_time,value=debuff.vulnerability.remains
				if (GetTime()-animalsTable.combatStartTime) <= 15 and animalsTable.talent71 and (not animalsTable.aoe or animalsTable.targetCount(_, 8, _, 1, "==")) then open() end
				if animalsTable.cds then cooldowns() end
				if animalsTable.talent61 and animalsTable.spellCanAttack(a_murder_of_crows) and not animalsTable.aura("target", hunters_mark, "", "PLAYER") then animalsTable.cast(_, hunters_mark, _, _, _, _, "A Murder of Crows") return end
				if animalsTable.aoe and animalsTable.targetCount(_, 8, _, 1, ">") and not animalsTable.talent71 and animalsTable.aura("player", trueshot) then trueshotaoe() end
				-- actions+=/barrage,if=debuff.hunters_mark.down
				-- actions+=/black_arrow,if=debuff.hunters_mark.down
				-- actions+=/a_murder_of_crows,if=(target.health.pct>30|target.health.pct<=20)&variable.vulnerable_time>execute_time&debuff.hunters_mark.remains>execute_time&focus+(focus.regen*variable.vulnerable_time)>60&focus+(focus.regen*debuff.hunters_mark.remains)>=60
				-- actions+=/barrage,if=variable.vulnerable_time>execute_time&debuff.hunters_mark.remains>execute_time&focus+(focus.regen*variable.vulnerable_time)>90&focus+(focus.regen*debuff.hunters_mark.remains)>=90
				-- actions+=/black_arrow,if=variable.vulnerable_time>execute_time&debuff.hunters_mark.remains>execute_time&focus+(focus.regen*variable.vulnerable_time)>70&focus+(focus.regen*debuff.hunters_mark.remains)>=70
				-- actions+=/piercing_shot,if=!talent.patient_sniper.enabled&focus>50
				-- actions+=/windburst,if=(!talent.patient_sniper.enabled|talent.sidewinders.enabled)&(debuff.hunters_mark.down|debuff.hunters_mark.remains>execute_time&focus+(focus.regen*debuff.hunters_mark.remains)>50)
				-- actions+=/windburst,if=talent.patient_sniper.enabled&!talent.sidewinders.enabled&((debuff.vulnerability.down|debuff.vulnerability.remains<2)|(debuff.hunters_mark.up&buff.marking_targets.up&debuff.vulnerability.down))
				if animalsTable.getTTD() < 6 and (not animalsTable.aoe or animalsTable.targetCount(_, 8, _, 1, "==")) then targetdie() end
				-- actions+=/sidewinders,if=(debuff.hunters_mark.down|(buff.marking_targets.down&buff.trueshot.down))&((buff.trueshot.react&focus<80)|charges_fractional>=1.9)
				-- actions+=/sentinel,if=debuff.hunters_mark.down&(buff.marking_targets.down|buff.trueshot.up)
			-- actions+=/marked_shot,target=2,if=!talent.patient_sniper.enabled&debuff.vulnerability.stack<3
			-- actions+=/arcane_shot,if=!talent.patient_sniper.enabled&spell_targets.barrage=1&debuff.vulnerability.stack<3&((buff.marking_targets.up&debuff.hunters_mark.down)|buff.trueshot.up)
			-- actions+=/multishot,if=!talent.patient_sniper.enabled&spell_targets.barrage>1&debuff.vulnerability.stack<3&((buff.marking_targets.up&debuff.hunters_mark.down)|buff.trueshot.up)
			-- actions+=/arcane_shot,if=talent.steady_focus.enabled&spell_targets.barrage=1&(buff.steady_focus.down|buff.steady_focus.remains<2)
			-- actions+=/multishot,if=talent.steady_focus.enabled&spell_targets.barrage>1&(buff.steady_focus.down|buff.steady_focus.remains<2)
				-- actions+=/explosive_shot
				-- actions+=/marked_shot,if=!talent.patient_sniper.enabled|(talent.barrage.enabled&spell_targets.barrage>2)
				-- actions+=/aimed_shot,if=debuff.hunters_mark.remains>execute_time&variable.vulnerable_time>execute_time&(buff.lock_and_load.up|(focus+debuff.hunters_mark.remains*focus.regen>=80&focus+focus.regen*variable.vulnerable_time>=80))
				-- actions+=/aimed_shot,if=debuff.hunters_mark.down&debuff.vulnerability.remains>execute_time&(talent.sidewinders.enabled|buff.marking_targets.down|(debuff.hunters_mark.remains>execute_time+gcd&focus+5+focus.regen*debuff.hunters_mark.remains>80))
				-- actions+=/marked_shot,if=debuff.hunters_mark.remains<1|variable.vulnerable_time<1|spell_targets.barrage>1|buff.trueshot.up
				-- actions+=/marked_shot,if=buff.marking_targets.up&(!talent.sidewinders.enabled|cooldown.sidewinders.charges_fractional>=1.2)
				-- actions+=/sidewinders,if=buff.marking_targets.up&debuff.hunters_mark.down&(focus<=80|(variable.vulnerable_time<2&cooldown.windburst.remains>3&cooldown.sidewinders.charges_fractional>=1.2))
				-- actions+=/piercing_shot,if=talent.patient_sniper.enabled&focus>80
			-- actions+=/arcane_shot,if=spell_targets.barrage=1&(debuff.hunters_mark.down&buff.marking_targets.react|focus.time_to_max>=2)
			-- actions+=/multishot,if=spell_targets.barrage>1&(debuff.hunters_mark.down&buff.marking_targets.react|focus.time_to_max>=2)
			-- actions+=/aimed_shot,if=debuff.vulnerability.down&focus>80&cooldown.windburst.remains>3
				if animalsTable.aoe and animalsTable.spellCanAttack(multishot) and animalsTable.targetCount(_, 8, _, 2, ">") then animalsTable.cast(_, multishot, false, false, false, "SpellToInterrupt", "Multi-Shot: AoE") return end
			end
		end
	end
end

do -- Survival
end