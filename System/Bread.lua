local animalsName, animalsTable = ...
local _ = nil

do -- Combat Check Functions
    function animalsTable.validAnimal(unit)
        if not unit then unit = "target" end
        if ObjectExists("target")
        and UnitExists("target")
        and UnitCanAttack("player", "target")
        -- and (animalsTable.health("target") > 1 or tContains(animalsTable.Dummies, UnitName("target")))
        -- and animalsTable.animalsAuraBlacklist("target")
        -- and (not animalsDataPerChar.cced or not animalsTable.unitIsCCed("target"))
        then
            return true
        else
            return false
        end
    end

    function animalsTable.animalIsTappedByPlayer(mob)
        if not ObjectExists(mob) or not UnitExists(mob) then return false end
        if UnitTarget("player") and mob == UnitTarget("player") then return true end
        if UnitAffectingCombat(mob) and UnitTarget(mob) then
            local mobTarget = UnitTarget(mob)
            mobTarget = UnitCreator(mobTarget) or mobTarget
            if UnitInParty(mobTarget) then return true end
        end
        return false
    end
end

do -- Unit Functions
    function animalsTable.isCAOCH(unit)
        if not unit then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) and (UnitCastingInfo(unit) or UnitChannelInfo(unit)) then return true else return false end
    end

    function animalsTable.isCA(unit)
        if not unit then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) and UnitCastingInfo(unit) then return true else return false end
    end

    function animalsTable.isCH(unit)
        if not unit then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) and UnitChannelInfo(unit) then return true else return false end
    end

    function animalsTable.distanceBetween(target, base)
        if not target then target = "target" end
        if not type(target) == "string" and string.len(target) >= 6 and string.sub(target, 1, 6) == "Player" then target = "player" end
        if not base or type(base) == "string" and string.len(base) >= 6 and string.sub(base, 1, 6) == "Player" then base = "player" end
        if not ObjectExists(target) or not ObjectExists(base) or not UnitExists(target) or not UnitExists(base) then return math.huge end
        local X1, Y1, Z1 = ObjectPosition(target)
        local X2, Y2, Z2 = ObjectPosition(base)
        return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
    end

    function animalsTable.animalIsBoss(unit)
        if not unit then unit = "target" end
        if ObjectExists(unit) and UnitExists(unit) then
            if tContains(animalsTable.BossList, animalsTable.getUnitID(unit)) then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    function animalsTable.LOS(guid, other, increase)
        other = other or "player"
        if not ObjectExists(guid) then return false end
        if tContains(animalsTable.SkipLoS, animalsTable.getUnitID(guid)) or tContains(animalsTable.SkipLoS, animalsTable.getUnitID(other)) then return true end
        local X1, Y1, Z1 = ObjectPosition(guid)
        local X2, Y2, Z2 = ObjectPosition(other)
        return not TraceLine(X1, Y1, Z1  + (increase or 2), X2, Y2, Z2 + (increase or 2), 0x10);
    end

    function animalsTable.getTTD(guid)
        if not guid then guid = "target" end
        return animalsTable.TTD[ObjectPointer(guid)] or math.huge
    end

    function animalsTable.getUnitID(guid)
        if ObjectExists(guid) and UnitExists(guid) then
            local id = select(6,strsplit("-", UnitGUID(guid) or ""))
            return tonumber(id)
        end
        return 0
    end
end

do -- Spell Functions
    function animalsTable.spellCDDuration(spell)
        local start, duration = GetSpellCooldown(spell)
        return start == 0 and 0 or start + duration - GetTime()
    end

    function animalsTable.chargeCD(spell)
        if GetSpellCharges(spell) == select(2, GetSpellCharges(spell)) then return 0 end
        return select(4, GetSpellCharges(spell))-(GetTime()-select(3, GetSpellCharges(spell)))
    end

    function animalsTable.castTime(spell)
        return (select(4, GetSpellInfo(spell))*0.001)
    end

    local spellNotKnown = {}
    local spellKnownTransformTable = {
            [106830] = 106832
    }
    function animalsTable.spellIsReady(spell, execute)
        if type(spell) ~= "string" and type(spell) ~= "number" then return false end
        local spellTransform = spellKnownTransformTable[spell] or spell
        if not (type(spellTransform) == "number" and GetSpellInfo(GetSpellInfo(spellTransform)) or type(spellTransform) == "string" and GetSpellLink(spellTransform) or IsSpellKnown(spellTransform)) then
            if not spellNotKnown[spellTransform] then
                spellNotKnown[spellTransform] = true
                animalsTable.logToFile("Spell not known: "..spellTransform.." Please Verify.")
            end
            return false
        end
        -- if (type(spell) == "number" and GetSpellInfo(GetSpellInfo(spell)) or type(spell) == "string" and GetSpellLink(spell) or IsSpellKnown(spell) or spell == 77758 --[[or UnitLevel("player") == 100]]) -- thrash bear
        --[[and]] --[[if]]if animalsTable.spellCDDuration(spell) <= 0
        and (execute and animalsTable.SpellIsUsableExecute(spell) or animalsTable.SpellIsUsable(spell))
        and (not animalsDataPerChar.thok or animalsTable.ThokThrottle < GetTime() or select(4, GetSpellInfo(spell)) <= 0 or animalsTable.ThokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001)) -- bottom aurar are ice floes , Kil'jaedens cunning, spiritwalker's grace
        and (UnitMovementFlags("player") == 0 or select(4, GetSpellInfo(spell)) <= 0 or spell == 77767 or spell == 56641 or spell == aimed_shot or spell == 2948 or not animalsTable.auraRemaining("player", 108839, (select(4, GetSpellInfo(spell))*0.001)) or not animalsTable.auraRemaining("player", 79206, (select(4, GetSpellInfo(spell))*0.001)))
        -- Ice Floes, SpiritWalker's Grace
        then
            return true
        else
            return false
        end
    end

    function animalsTable.spellCanAttack(spell, unit, casting, execute)
        if not unit then unit = "target" end
        if not ObjectExists(unit) or not UnitExists(unit) then return false end
        if string.sub(unit, 1, 6) == "Player" then unit = ObjectPointer("player") end
        if UnitExists(unit)
        and animalsTable.spellIsReady(spell, execute)
        and (animalsTable.InRange(spell, unit) or UnitName(unit) == "Al'Akir") -- fixme: inrange needs an overhaul in the distant future, example Al'Akir @framework @notimportant
        and (not animalsTable.isCAOCH("player") or casting--[[ and UnitChannelInfo("player") ~= GetSpellInfo(spell) and UnitCastingInfo("player") ~= GetSpellInfo(spell)]])
        and (not animalsDataPerChar.thok or animalsTable.ThokThrottle < GetTime() or animalsTable.ThokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001))
        and (not animalsDataPerChar.los or animalsTable.LOS(unit)) -- fixme: LOS @framework
        and (not animalsDataPerChar.cced or not animalsTable.UnitIsCCed(unit))
        then
            return true
        else
            return false
        end
    end

    function animalsTable.SpellIsUsable(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if isUsable and not notEnoughMana then
            return true
        else
            return false
        end
    end

    function animalsTable.SpellIsUsableExecute(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if not notEnoughMana then
            return true
        else
            return false
        end
    end

    function animalsTable.PoolCheck(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if animalsTable.SpellCDDuration(spell) <= 0
        and not isUsable
        and notEnoughMana
        then
            return true
        else
            return false
        end
    end

    local spellOutranged = {}
    function animalsTable.InRange(spell, unit)
        if not unit then unit = "target" end
        local spellToString

        if tonumber(spell) then spellToString = GetSpellInfo(spell) end

        if ObjectExists(unit) and UnitExists(unit) and animalsTable.health(unit) > 0 then
            local inRange = IsSpellInRange(spellToString, unit)

            if inRange == 1 then
                return true
            elseif inRange == 0 then
                if not spellOutranged[spell] then
                    spellOutranged[spell] = true
                    animalsTable.logToFile("Spell out of Range: "..spell.." Please Verify.")
                end
                return false
            elseif (tContains(animalsTable.SpellData.SpellNameRange, spellToString) or tContains(animalsTable.SpellData.SpellNameRange, "MM"..spellToString)) then
                for i = 1, #animalsTable.SpellData.SpellNameRange do
                    if animalsTable.SpellData.SpellNameRange[i] == spellToString then
                        return animalsTable.Distance(unit) <= animalsTable.SpellData.SpellRange[i]
                    elseif animalsTable.SpellData.SpellNameRange[i] == "MM"..spellToString then
                        return animalsTable.Distance(unit) <= (animalsTable.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100))
                    end
                end
            -- elseif FindSpellBookSlotBySpellID(spell) then
            --     return IsSpellInRange(FindSpellBookSlotBySpellID(spell), "spell", unit) == 1
            else
                for i = 1, 200 do
                    if GetSpellBookItemName(i, "spell") == spellToString then
                        if IsSpellInRange(i, "spell", unit) == 1 then
                            return true
                        else
                            if not spellOutranged[spell] then
                                spellOutranged[spell] = true
                                animalsTable.logToFile("Spell out of Range: "..spell.." Please Verify.")
                            end
                            return false
                        end
                    end
                end
                if not spellOutranged[spell] then
                    spellOutranged[spell] = true
                    animalsTable.logToFile("Spell has no range: "..spell.." Please Verify and add Custom.")
                end
            end
        end
    end

    function animalsTable.FracCalc(mode, spell)
        if mode == "spell" then
            local spellFrac = 0
            local cur, max, start, duration = GetSpellCharges(spell)

            if cur then
                if cur >= 1 then spellFrac = spellFrac + cur end
                if spellFrac == max then return spellFrac end
                spellFrac = spellFrac + (GetTime()-start)/duration
                return spellFrac
            else
                -- local start, duration = GetSpellCooldown(spell)
                -- if start == 0 then return 1 end
                -- spellFrac = (GetTime()-start)/duration
                return print("Tried to calculate fraction of a non charge based skill")
            end
        elseif mode == "rune" then
        end
    end
end

-- Resources
    function animalsTable.health(guid, max, percent, deficit) -- returns the units max health if max is true, percentage remaining if percent is true and max is false, deficit if deficit is true, or current health
        if max then
            return UnitHealthMax(guid)
        elseif percent then
            return UnitHealth(guid)/UnitHealthMax(guid)*100
        elseif deficit then
            return UnitHealthMax(guid)-UnitHealth(guid)
        else
            return UnitHealth(guid)
        end
    end

    function animalsTable.PM() return UnitPower("player")/UnitPowerMax("player")*100 end -- return percentage of mana or default power

    function animalsTable.pp(mode) -- Returns Primary Resources, modes are max or deficit otherwise current, Excluding Chi and Combo Points Use animalsTable.CP(mode)
        local vPower = nil
        if animalsDataPerChar.class == "WARRIOR" then vPower = 1 end -- Rage
        if animalsDataPerChar.class == "PALADIN" and animalsTable.currentSpec == 3 then vPower = 9 end -- Holy Power
        if animalsDataPerChar.class == "HUNTER" then vPower = 2 end -- Focus
        if animalsDataPerChar.class == "ROGUE" then vPower = 3 end -- Energy Use animalsTable.CP() for Combo Points
        if animalsDataPerChar.class == "PRIEST" and animalsTable.currentSpec == 3 then vPower = 13 end -- Insanity
        if animalsDataPerChar.class == "SHAMAN" and animalsTable.currentSpec ~= 3 then vPower = 11 end -- Maelstrom
        if animalsDataPerChar.class == "MAGE" and animalsTable.currentSpec == 1 then vPower = 16 end -- Arcane Charges
        if animalsDataPerChar.class == "WARLOCK" then vPower = 7 end -- Soul Shards
        if animalsDataPerChar.class == "MONK" and animalsTable.currentSpec == 1 then vPower = 3 end -- Energy
        if animalsDataPerChar.class == "MONK" and animalsTable.currentSpec == 3 then vPower = 3 end -- Energy
        if animalsDataPerChar.class == "DRUID" and animalsTable.currentSpec == 1 then vPower = 8 end -- Astral Power
        if animalsDataPerChar.class == "DRUID" and animalsTable.currentSpec == 2 then vPower = 3 end -- Energy Use animalsTable.CP() for Combo Points
        if animalsDataPerChar.class == "DRUID" and animalsTable.currentSpec == 3 then vPower = 1 end -- Rage
        -- DEMON HUNTER
        if animalsDataPerChar.class == "DEATHKNIGHT" then vPower = 6 end -- Runic Power
        if not vPower then vPower = 0 end
        if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) elseif mode == "tomax" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower))/GetPowerRegen() else return UnitPower("player", vPower) end
    end

    function animalsTable.cp(mode) -- Returns Chi and Combo Points, modes are max or deficit otherwise current, for Primary Resources Use animalsTable.PP(mode)
        local vPower = (animalsDataPerChar.class == "MONK" and 12 or 4)
        if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) else return UnitPower("player", vPower) end
    end

    function animalsTable.GCD()
        if animalsDataPerChar.class..animalsTable.currentSpec == "MONK3" then return 1 end
        return math.max((1.5/(1+GetHaste()*.01)), 0.75)
    end

    function animalsTable.SimCSpellHaste()
        return 1/(1+GetHaste()*.01)
    end

do -- Aura Functions
    local auraTable = {}

    function animalsTable.aura(guid, ...) -- Example animalsTable.aura("target", 1234, "", "PLAYER") everything past the 2nd argument is not required
        for i = 1, select("#", ...) do
            auraTable[i] = select(i, ...)
        end

        for i = select("#", ...)+1, #auraTable do
            auraTable[i] = nil
        end

        if type(auraTable[1]) == "number" then auraTable[1] = GetSpellInfo(auraTable[1]) end
        if type(guid) == "string" and string.sub(guid, 1, 6) == "Player" then guid = "player" end

        if not ObjectExists(guid) or not UnitExists(guid) then return false end

        -- return UnitBuff(guid, unpack(auraTable)) or UnitDebuff(guid, unpack(auraTable)) or UnitAura(guid, unpack(auraTable))
        if UnitBuff(guid, unpack(auraTable)) then return UnitBuff(guid, unpack(auraTable)) elseif UnitDebuff(guid, unpack(auraTable)) then return UnitDebuff(guid, unpack(auraTable)) else return UnitAura(guid, unpack(auraTable)) end
    end
    
    function animalsTable.auraRemaining(unit, buff, time, ...) -- ... is the same as above, this checks for <= the time argument. if you want greater than, than do "not animalsTable.auraRemaining", this will return true if the aura isn't there
        if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) then
            if tonumber(buff) then buff = GetSpellInfo(buff) end
            local name, _, _, _, _, _, expires = animalsTable.aura(unit, buff, ...)
            if not name then return true
            elseif (expires-GetTime()) <= time then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    function animalsTable.auraStacks(unit, buff, stacks, ...) -- ... is the same as above, this checks for >= stacks argument, if you want less than, than do "not animalsTable.auraStacks", this will return false if the aura isn't there
        if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) then
            if tonumber(buff) then buff = GetSpellInfo(buff) end
            local name, _, _, count = animalsTable.aura(unit, buff, ...)
            if not name then return false end
            if count >= stacks then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    function animalsTable.Bloodlust(remaining)
        if remaining then
            return ((animalsTable.aura("player", 80353) and not animalsTable.auraRemaining("player", 80353, remaining))
                    or (animalsTable.aura("player", 2825) and not animalsTable.auraRemaining("player", 2825, remaining))
                    or (animalsTable.aura("player", 32182) and not animalsTable.auraRemaining("player", 32182, remaining))
                    or (animalsTable.aura("player", 90355) and not animalsTable.auraRemaining("player", 90355, remaining))
                    or (animalsTable.aura("player", 160452) and not animalsTable.auraRemaining("player", 160452, remaining))
                    or (animalsTable.aura("player", 146555) and not animalsTable.auraRemaining("player", 146555, remaining))
                    or (animalsTable.aura("player", 178207) and not animalsTable.auraRemaining("player", 178207, remaining)))
        end
        if animalsTable.aura("player", 80353) or animalsTable.aura("player", 2825) or animalsTable.aura("player", 32182) or animalsTable.aura("player", 90355) or animalsTable.aura("player", 160452) or animalsTable.aura("player", 146555) or animalsTable.aura("player", 178207) then
            return true
        else
            return false
        end
    end
end

-- AoE Functions
    function animalsTable.playerCount(yards, tapped, goal, mode, goal2)
        local GMobCount = 0
        local unitPlaceholder = nil

        if mode == "==" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount == goal
        elseif mode == "<=" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount <= goal
        elseif mode == "<" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return false end
            end
            return GMobCount < goal
        elseif mode == ">=" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return true end
            end
            return false
        elseif mode == ">" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            return false
        elseif mode == "~=" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            if GMobCount < goal then return true end
            return false
        elseif mode == "inclusive" then
            local higherGoal = math.max(goal, goal2)
            local lowerGoal = math.min(goal, goal2)
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > higherGoal then return false end
            end
            if GMobCount < lowerGoal then return false end
            return true
        end
        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        return GMobCount
    end

    function animalsTable.TargetCount(yards, tapped)
        if not ObjectExists("target") or not UnitExists("target") or UnitHealth("target") == 0 then return 0 end

        local GMobCount = 0
        local unitPlaceholder = nil

        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.Distance(unitPlaceholder, "target") <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        if GMobCount == 0 then return 1 else return GMobCount end
    end

    function animalsTable.FocusCount(yards, tapped)
        if not ObjectExists("focus") or not UnitExists("focus") or UnitHealth("focus") == 0 then return 0 end

        local GMobCount = 0
        local unitPlaceholder = nil

        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.Distance(unitPlaceholder, "focus") <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        return GMobCount
    end

    function animalsTable.BeastCleaveCount(yards, tapped)
        local GMobCount = 0
        local unitPlaceholder = nil

        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.Distance(unitPlaceholder, "pet") <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        return GMobCount
    end

    function animalsTable.PullAllies(reach)
        if animalsTable.AllyTargetsSize == 0 then return {} end
        local unitPlaceholder = nil
        local units = {}
        local unitsSize = 0
        for i = 1, animalsTable.AllyTargetsSize do
            unitPlaceholder = animalsTable.AllyTargets[i].Player
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                if animalsTable.Distance(unitPlaceholder) <= reach then
                    units[unitsSize+1] = unitPlaceholder
                    unitsSize = unitsSize + 1
                end
            end
        end
        return units
    end

    function animalsTable.SmartAoEFriendly(reach, size, tableX)
        local units = animalsTable.PullAllies(reach)
        local win = 0
        local winners = {}
        for _, enemy in ipairs(units) do
            local preliminary = {} -- new
            local neighbors = 0
            for _, neighbor in ipairs(units) do
                if animalsTable.Distance(enemy, neighbor) <= size then
                    table.insert(preliminary, neighbor)
                    neighbors = neighbors + 1
                end
            end
            if neighbors >= win and neighbors > 0 then
                winners = preliminary
                -- table.insert(winners, enemy)
                win = neighbors
            end
        end
        if tableX then return winners end
        return animalsTable.AvgPosObjects(winners)
    end

    function animalsTable.PullEnemies(reach, tapped, combatreach) -- gets enemies in an AoE
        if animalsTable.animalsSize == 0 then return {} end
        local unitPlaceholder = nil
        local units = {}
        local unitsSize = 0
        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                if animalsTable.Distance(unitPlaceholder) <= reach+(combatreach and UnitCombatReach(unitPlaceholder) or 0) and (not tapped or animalsTable.animalIsTappedByPlayer(unitPlaceholder) or tContains(animalsTable.Dummies, UnitName(unitPlaceholder))) then
                    units[unitsSize+1] = unitPlaceholder
                    unitsSize = unitsSize + 1
                end
            end
        end
        return units
    end

    function animalsTable.SmartAoE(reach, size, tapped, tableX) -- smart aoe placement --[[credits to phelps a.k.a doc|brown]]
        local units = animalsTable.PullEnemies(reach, tapped)
        local win = 0
        local winners = {}
        for _, enemy in ipairs(units) do
            local preliminary = {} -- new
            local neighbors = 0
            for _, neighbor in ipairs(units) do
                if animalsTable.Distance(enemy, neighbor) <= size then
                    table.insert(preliminary, neighbor) -- new
                    neighbors = neighbors + 1
                end
            end
            if neighbors >= win and neighbors > 0 then
                winners = preliminary
                -- table.insert(winners, enemy)
                win = neighbors
            end
        end
        if tableX then return winners end
        return animalsTable.AvgPosObjects(winners)
    end -- use it like this: animalsTable.Cast(nil, 104232, GSmartAoE(35, 8))

    function animalsTable.AvgPosObjects(table)
        local Total = #table;
        local X, Y, Z = 0, 0, 0;

        if Total == 0 then return nil, nil, nil end

        for Key, ThisObject in pairs(table) do
            if ThisObject then
                local ThisX, ThisY, ThisZ = ObjectPosition(ThisObject);
                if ThisX and ThisY then
                    X = X + ThisX;
                    Y = Y + ThisY;
                    Z = Z + ThisZ;
                end
            end
        end

        X = X / Total;
        Y = Y / Total;
        Z = Z / Total;
        return X, Y, Z;
    end

    function animalsTable.DoTCached(obj, table)
        local table1, table2 = "t"..table, "tNoObject"..table
        if tContains(GS[table1], obj) or tContains(GS[table2], obj) then return false else return true end
    end

    function animalsTable.MultiDoT(spell, range)
        local unitPlaceholder = nil
        local spelltable = string.gsub(spell, "%s", "")
        spelltable = string.gsub(spelltable, ":", "")

        if not GS["tNoObject"..spelltable] then GS["tNoObject"..spelltable] = {} end
        if not GS["t"..spelltable] then GS["t"..spelltable] = {} end

        for i = #GS["tNoObject"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = GS["tNoObject"..spelltable][i]
            if not tContains(animalsTable.MobTargets, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or range and range < animalsTable.Distance(obj) then
                table.remove(GS["tNoObject"..spelltable], i) -- preliminaries
            else -- check for aura
                local name = animalsTable.aura(unitPlaceholder, spell, "", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if name then table.remove(GS["tNoObject"..spelltable], i) end -- aura is there
            end
        end
        for i = #GS["t"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = GS["t"..spelltable][i]
            if not tContains(animalsTable.MobTargets, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or range and range < animalsTable.Distance(unitPlaceholder) then table.remove(GS["t"..spelltable], i) -- preliminaries
            else
                local name = animalsTable.aura(unitPlaceholder, spell, "", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if not name then table.remove(GS["t"..spelltable], i) end -- aura is not there
            end
        end

        for i = 1, #animalsTable.MobTargets do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                local unitPlaceholder = animalsTable.targetAnimals[i]
                if animalsTable.DoTCached(unitPlaceholder, spelltable)
                and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or tContains(animalsTable.Dummies, UnitName(unitPlaceholder)))
                and (not range or range >= animalsTable.Distance(unitPlaceholder)+animalsTable.CombatReach(unitPlaceholder)) then
                    local name = animalsTable.aura(unitPlaceholder, spell, "", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                    if name then table.insert(GS["t"..spelltable], unitPlaceholder) end
                    if not name and --[[animalsTable.Distance(unitPlaceholder) <= 50 and ]]UnitCanAttack("player", unitPlaceholder) --[[and animalsTable.LOS(unitPlaceholder)]] then table.insert(GS["tNoObject"..spelltable], unitPlaceholder) end -- fixme: LOS @framework
                end
            end
        end
    end

-- Cast Functions
    function animalsTable.cast(guid, Name, x, y, z, interrupt, reason)
        if animalsTable.waitForCombatLog then return end
        local name = Name
        if type(Name) == "number" then Name = GetSpellInfo(Name) end

        if UnitChannelInfo("player") then
            local spell = UnitChannelInfo("player")

            if type(interrupt) == "string" and interrupt ~= "SpellToInterrupt" then
                if interrupt == "chain" and spell == Name then animalsTable.logToFile("Going to Chain.") end
                if spell == interrupt then SpellStopCasting() end
                if interrupt == "nextTick" then
                    animalsTable.InterruptNextTick = spell
                    return
                end
                if ("nextTick "..spell) == interrupt then
                    animalsTable.InterruptNextTick = string.gsub(interrupt, "nextTick ", "")
                    return
                end
            elseif type(interrupt) == "table" then
                if tContains(interrupt, spell) then SpellStopCasting() end
            elseif interrupt == "all" then
                SpellStopCasting()
            elseif type(interrupt) == "number" then
                if name == interrupt then SpellStopCasting() end
            elseif interrupt ~= "SpellToInterrupt" and interrupt ~= nil then
                return
            end
        elseif UnitCastingInfo("player") then
            local spell = UnitCastingInfo("player")
            if type(interrupt) == "string" and interrupt ~= "SpellToInterrupt" then
                if spell == interrupt then SpellStopCasting() end
            elseif type(interrupt) == "table" then
                if tContains(interrupt, spell) then SpellStopCasting() end
            elseif interrupt == "all" then
                SpellStopCasting()
            elseif type(interrupt) == "number" then
                if name == interrupt then SpellStopCasting() end
            elseif interrupt ~= "SpellToInterrupt" and interrupt ~= nil then
                return
            end
        end

        if not guid then guid = "target" end
        if UnitGUID("player") == guid then guid = "player" end

        if not guid then
            CastSpellByName(Name)
        else
            CastSpellByName(Name, guid)
        end

        if IsAoEPending() then
            if x and y and z then
                CastAtPosition(x + math.random(-0.01, 0.01), y + math.random(-0.01, 0.01), z + math.random(-0.01, 0.01))
            else
                rotationXC, rotationYC, rotationZC = ObjectPosition(guid)
                CastAtPosition(rotationXC + math.random(-0.01, 0.01), rotationYC + math.random(-0.01, 0.01), rotationZC + math.random(-0.01, 0.01))
            end
            if IsAoEPending() then
                CancelPendingSpell()
                return
            end
        end
        -- debug stuff
        animalsTable.debugTable["debugStack"] = string.gsub(debugstack(2, 100, 100), 'Interface\\AddOns\\Animals\\.-(%w+)%.lua', "file: %1, line")
        animalsTable.debugTable["pointer"] = guid or "N/A"
        if animalsTable.debugTable["pointer"] ~= "N/A" then animalsTable.debugTable["nameOfTarget"] = UnitName(guid) else animalsTable.debugTable["nameOfTarget"] = "N/A" end
        animalsTable.debugTable["ogSpell"] = name
        animalsTable.debugTable["Spell"] = Name
        animalsTable.debugTable["x"] = x or "N/A"
        animalsTable.debugTable["y"] = y or "N/A"
        animalsTable.debugTable["z"] = z or "N/A"
        animalsTable.debugTable["interrupt"] = interrupt or "N/A"
        animalsTable.debugTable["RotationCacheCounter"] = rotationCacheCounter
        animalsTable.debugTable["timeSinceLast"] = animalsTable.debugTable["time"] and (GetTime() - animalsTable.debugTable["time"]) or 0
        animalsTable.debugTable["time"] = GetTime()
        animalsTable.debugTable["reason"] = reason or "N/A"
        if animalsDataPerChar.log then
            animalsTable.File = ReadFile("C:\\Garrison.json")
            animalsTable.tempStr = json.encode(animalsTable.debugTable, {indent=true})
            WriteFile("C:\\Garrison.json", animalsTable.File..",\n"..animalsTable.tempStr)
        end
        animalsTable.waitForCombatLog = true
        animalsTable.interruptNextTick = nil
        animalsTable.toggleLog = true
        return true
    end
