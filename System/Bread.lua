local animalsName, animalsTable = ...
local _ = nil

do -- Combat Check Functions
    function animalsTable.validAnimal(unit)
        if not unit then unit = "target" end
        if ObjectExists(unit)
        and UnitExists(unit)
        and UnitCanAttack("player", unit)
        and (animalsTable.health(unit) > 1 or tContains(animalsTable.dummiesID, animalsTable.getUnitID(unit)))
        and animalsTable.animalsAuraBlacklist(unit)
        and (not animalsDataPerChar.cced or not animalsTable.unitIsCCed(unit))
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
            if tContains(animalsTable.bossIDList, animalsTable.getUnitID(unit)) then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    function animalsTable.los(guid, other, increase)
        other = other or "player"
        if not ObjectExists(guid) then return false end
        if tContains(animalsTable.skipLoS, animalsTable.getUnitID(guid)) or tContains(animalsTable.skipLoS, animalsTable.getUnitID(other)) then return true end
        local X1, Y1, Z1 = ObjectPosition(guid)
        local X2, Y2, Z2 = ObjectPosition(other)
        return not TraceLine(X1, Y1, Z1  + (increase or 2), X2, Y2, Z2 + (increase or 2), 0x10);
    end

    function animalsTable.getTTD(guid)
        if not guid then guid = "target" end
        if not ObjectExists(guid) or not UnitExists(guid) then return math.huge end
        return animalsTable.TTD[ObjectPointer(guid)] or math.huge
    end

    function animalsTable.getUnitID(guid)
        if not guid then guid = "target" end
        if ObjectExists(guid) and UnitExists(guid) then
            local id = select(6,strsplit("-", UnitGUID(guid) or ""))
            return tonumber(id)
        end
        return 0
    end
end

do -- Spell Functions
    function animalsTable.spellCDDuration(spell)
        if spell == 0 then return math.huge end
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
            [106830] = 106832,
    }
    function animalsTable.spellIsReady(spell, execute)
        if type(spell) ~= "string" and type(spell) ~= "number" or spell == "" or spell == 0 then return false end
        local spellTransform = spellKnownTransformTable[spell] or spell
        if not (type(spellTransform) == "number" and GetSpellInfo(GetSpellInfo(spellTransform)) or type(spellTransform) == "string" and GetSpellLink(spellTransform) or IsSpellKnown(spellTransform)) then
            if not spellNotKnown[spellTransform] then
                spellNotKnown[spellTransform] = true
                animalsTable.logToFile("Spell not known: "..spellTransform.." Please Verify.")
            end
            return false
        end
        -- if (type(spell) == "number" and GetSpellInfo(GetSpellInfo(spell)) or type(spell) == "string" and GetSpellLink(spell) or IsSpellKnown(spell) or spell == 77758 --[[or UnitLevel("player") == 100]]) -- thrash bear
        --[[and]] --[[if]]if (--[[animalsTable.spellCDDuration(61304) > 0 and ]]animalsTable.spellCDDuration(spell) <= select(4, GetNetStats())*.001+animalsTable.randomNumberGenerator)
        and (execute and animalsTable.spellIsUsableExecute(spell) or animalsTable.spellIsUsable(spell))
        and (not animalsDataPerChar.thok or animalsTable.thokThrottle < GetTime() or select(4, GetSpellInfo(spell)) <= 0 or animalsTable.thokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001)) -- bottom aurar are ice floes , Kil'jaedens cunning, spiritwalker's grace
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
        if string.sub(unit, 1, 6) == "Player" then unit = ObjectPointer("player") end
        if not ObjectExists(unit) or not UnitExists(unit) then return false end
        if animalsTable.spellIsReady(spell, execute)
        and (animalsTable.inRange(spell, unit) or UnitName(unit) == "Al'Akir") -- fixme: inrange needs an overhaul in the distant future, example Al'Akir @framework @notimportant
        and (not animalsTable.isCAOCH("player") --[[or UnitCastingInfo("player") and (select(6, UnitCastingInfo("player"))/1000-GetTime()) <= select(4, GetNetStats())*.001+animalsTable.randomNumberGenerator ]]or casting--[[ and UnitChannelInfo("player") ~= GetSpellInfo(spell) and UnitCastingInfo("player") ~= GetSpellInfo(spell)]])
        and (not animalsDataPerChar.thok or animalsTable.thokThrottle < GetTime() or animalsTable.thokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001))
        and (not animalsDataPerChar.los or animalsTable.los(unit))
        and (not animalsDataPerChar.cced or not animalsTable.unitIsCCed(unit))
        then
            return true
        else
            return false
        end
    end

    function animalsTable.spellIsUsable(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if isUsable and not notEnoughMana then
            return true
        else
            return false
        end
    end

    function animalsTable.spellIsUsableExecute(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if not notEnoughMana then
            return true
        else
            return false
        end
    end

    function animalsTable.poolCheck(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if animalsTable.spellCDDuration(spell) <= 0
        and not isUsable
        and notEnoughMana
        then
            return true
        else
            return false
        end
    end

    local spellOutranged = {}
    function animalsTable.inRange(spell, unit)
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
            -- elseif (tContains(animalsTable.SpellData.SpellNameRange, spellToString) or tContains(animalsTable.SpellData.SpellNameRange, "MM"..spellToString)) then
            --     for i = 1, #animalsTable.SpellData.SpellNameRange do
            --         if animalsTable.SpellData.SpellNameRange[i] == spellToString then
            --             return animalsTable.distanceBetween(unit) <= animalsTable.SpellData.SpellRange[i]
            --         elseif animalsTable.SpellData.SpellNameRange[i] == "MM"..spellToString then
            --             return animalsTable.distanceBetween(unit) <= (animalsTable.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100))
            --         end
            --     end
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

    function animalsTable.fracCalc(mode, spell)
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

do -- Resources Functions
    function animalsTable.health(guid, max, percent, deficit) -- returns the units max health if max is true, percentage remaining if percent is true and max is false, deficit if deficit is true, or current health
        if not guid then guid = "target" end
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

    function animalsTable.pm() return UnitPower("player")/UnitPowerMax("player")*100 end -- return percentage of mana or default power

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
        if animalsDataPerChar.class == "DEMONHUNTER" and animalsTable.currentSpec == 1 then vPower = 17 end -- Fury
        if animalsDataPerChar.class == "DEMONHUNTER" and animalsTable.currentSpec == 2 then vPower = 18 end -- Pain
        if animalsDataPerChar.class == "DEATHKNIGHT" then vPower = 6 end -- Runic Power
        if not vPower then vPower = 0 end
        if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) elseif mode == "tomax" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower))/GetPowerRegen() else return UnitPower("player", vPower) end
    end

    function animalsTable.cp(mode) -- Returns Chi and Combo Points, modes are max or deficit otherwise current, for Primary Resources Use animalsTable.PP(mode)
        local vPower = (animalsDataPerChar.class == "MONK" and 12 or 4)
        if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) else return UnitPower("player", vPower) end
    end

    function animalsTable.globalCD()
        if animalsDataPerChar.class..animalsTable.currentSpec == "MONK3" then return 1 end
        return math.max((1.5/(1+GetHaste()*.01)), 0.75)
    end

    function animalsTable.simCSpellHaste()
        return 1/(1+GetHaste()*.01)
    end
end

do -- Aura Functions
    local auraTable = {}

    function animalsTable.aura(guid, ...) -- Example animalsTable.aura("target", 1234, "", "PLAYER") everything past the 2nd argument is not required
        if type(guid) == "string" and string.sub(guid, 1, 6) == "Player" then guid = "player" end
        if not ObjectExists(guid) or not UnitExists(guid) then return false end

        for i = 1, select("#", ...) do
            auraTable[i] = select(i, ...)
        end

        for i = select("#", ...)+1, #auraTable do
            auraTable[i] = nil
        end

        if auraTable[1] == 0 or auraTable[1] == "" then return false end
        if type(auraTable[1]) == "number" then auraTable[1] = GetSpellInfo(auraTable[1]) end

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
        if buff == "" or buff == 0 then return false end
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

    function animalsTable.bloodlust(remaining)
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

do -- AoE Functions
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

    function animalsTable.targetCount(target, yards, tapped)
        if not target then target = "target" end
        if not ObjectExists(target) or not UnitExists(target) or UnitHealth(target) == 0 then return 0 end

        local GMobCount = 0
        local unitPlaceholder = nil


        if mode == "==" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount == goal
        elseif mode == "<=" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount <= goal
        elseif mode == "<" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return false end
            end
            return GMobCount < goal
        elseif mode == ">=" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return true end
            end
            return false
        elseif mode == ">" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            return false
        elseif mode == "~=" then
            for i = 1, animalsTable.animalsSize do
                unitPlaceholder = animalsTable.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
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
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > higherGoal then return false end
            end
            if GMobCount < lowerGoal then return false end
            return true
        end
        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and animalsTable.distanceBetween(unitPlaceholder, "target") <= yards+UnitCombatReach(unitPlaceholder) and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        if GMobCount == 0 then return 1 else return GMobCount end
    end

    function animalsTable.pullAllies(reach)
        if animalsTable.humansSize == 0 then return {} end
        local unitPlaceholder = nil
        local units = {}
        local unitsSize = 0
        for i = 1, animalsTable.humansSize do
            unitPlaceholder = animalsTable.targetHumans[i].Player
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                if animalsTable.distanceBetween(unitPlaceholder) <= reach then
                    units[unitsSize+1] = unitPlaceholder
                    unitsSize = unitsSize + 1
                end
            end
        end
        return units
    end

    function animalsTable.smartAoEFriendly(reach, size, tableX)
        local units = animalsTable.pullAllies(reach)
        local win = 0
        local winners = {}
        for _, enemy in ipairs(units) do
            local preliminary = {} -- new
            local neighbors = 0
            for _, neighbor in ipairs(units) do
                if animalsTable.distanceBetween(enemy, neighbor) <= size then
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
        return animalsTable.avgPosObjects(winners)
    end

    function animalsTable.pullEnemies(reach, tapped, combatreach) -- gets enemies in an AoE
        if animalsTable.animalsSize == 0 then return {} end
        local unitPlaceholder = nil
        local units = {}
        local unitsSize = 0
        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                if animalsTable.distanceBetween(unitPlaceholder) <= reach+(combatreach and UnitCombatReach(unitPlaceholder) or 0) and (not tapped or animalsTable.animalIsTappedByPlayer(unitPlaceholder) or tContains(animalsTable.dummiesID, animalsTable.getUnitID(unitPlaceholder))) then
                    units[unitsSize+1] = unitPlaceholder
                    unitsSize = unitsSize + 1
                end
            end
        end
        return units
    end

    function animalsTable.smartAoE(reach, size, tapped, tableX) -- smart aoe placement --[[credits to phelps a.k.a doc|brown]]
        local units = animalsTable.pullEnemies(reach, tapped)
        local win = 0
        local winners = {}
        for _, enemy in ipairs(units) do
            local preliminary = {} -- new
            local neighbors = 0
            for _, neighbor in ipairs(units) do
                if animalsTable.distanceBetween(enemy, neighbor) <= size then
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
        return animalsTable.avgPosObjects(winners)
    end

    function animalsTable.avgPosObjects(table)
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

    function animalsTable.dotCached(obj, table)
        local table1, table2 = "t"..table, "tNoObject"..table
        if tContains(animalsTable[table1], obj) or tContains(animalsTable[table2], obj) then return false else return true end
    end

    function animalsTable.multiDoT(spell, range)
        local unitPlaceholder = nil
        local spelltable = string.gsub(spell, "[%s:]", "")

        if not animalsTable["tNoObject"..spelltable] then animalsTable["tNoObject"..spelltable] = {} end
        if not animalsTable["t"..spelltable] then animalsTable["t"..spelltable] = {} end

        for i = #animalsTable["tNoObject"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = animalsTable["tNoObject"..spelltable][i]
            if not tContains(animalsTable.targetAnimals, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or range and range < animalsTable.distanceBetween(obj) then
                table.remove(animalsTable["tNoObject"..spelltable], i) -- preliminaries
            else -- check for aura
                local name = animalsTable.aura(unitPlaceholder, spell, "", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if name then table.remove(animalsTable["tNoObject"..spelltable], i) end -- aura is there
            end
        end
        for i = #animalsTable["t"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = animalsTable["t"..spelltable][i]
            if not tContains(animalsTable.targetAnimals, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or range and range < animalsTable.distanceBetween(unitPlaceholder) then table.remove(animalsTable["t"..spelltable], i) -- preliminaries
            else
                local name = animalsTable.aura(unitPlaceholder, spell, "", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if not name then table.remove(animalsTable["t"..spelltable], i) end -- aura is not there
            end
        end

        local unitPlaceholder = nil
        for i = 1, animalsTable.animalsSize do
            unitPlaceholder = animalsTable.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                unitPlaceholder = animalsTable.targetAnimals[i]
                if animalsTable.dotCached(unitPlaceholder, spelltable)
                and (animalsTable.animalIsTappedByPlayer(unitPlaceholder) or tContains(animalsTable.dummiesID, animalsTable.getUnitID(unitPlaceholder)))
                and (not range or range >= animalsTable.distanceBetween(unitPlaceholder)+UnitCombatReach(unitPlaceholder)) then
                    local name = animalsTable.aura(unitPlaceholder, spell, "", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or animalsTable.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                    if name then table.insert(animalsTable["t"..spelltable], unitPlaceholder) end
                    if not name and --[[animalsTable.distanceBetween(unitPlaceholder) <= 50 and ]]UnitCanAttack("player", unitPlaceholder) --[[and animalsTable.los(unitPlaceholder)]] then table.insert(animalsTable["tNoObject"..spelltable], unitPlaceholder) end
                end
            end
        end
    end
end

do -- Cast Functions
    local file, tempStr = "", ""
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
                    animalsTable.interruptNextTick = spell
                    return
                end
                if ("nextTick "..spell) == interrupt then
                    animalsTable.interruptNextTick = string.gsub(interrupt, "nextTick ", "")
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

        if name == 195072 then JumpOrAscendStart() end
        CastSpellByName(Name, guid)

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
            file = ReadFile("C:\\Garrison.json")
            tempStr = json.encode(animalsTable.debugTable, {indent=true})
            WriteFile("C:\\Garrison.json", file..",\n"..tempStr)
        end
        -- animalsTable.waitForCombatLog = true
        animalsTable.interruptNextTick = nil
        animalsTable.toggleLog = true
        return true
    end
end

do -- Artifact Functions
    function animalsTable.getTraitCurrentRank(artifact, perk)
        if animalsTable.equippedGear.MainHand ~= artifact or not animalsTable.artifactWeapon[animalsTable.equippedGear.MainHand].weaponPerks[perk] then return 0 end
        return animalsTable.artifactWeapon[animalsTable.equippedGear.MainHand].weaponPerks[perk].currentRank
    end
end

do -- Encounter Functions
--     local zoneTable = {
--         [1041] = { -- Halls of Valor
--             ["Hymdall"] = {
--                 desired_targets = 1,
--                 adds = false,
--             },
--             ["Hyrja"] = {
--                 desired_targets = 1,
--                 adds = false,
--             },
--             ["Fenryr"] = {
--                 desired_targets = 1,
--                 adds = "heroic",
--                 adds_count = 3,
--             },
--             ["God-King Skovald"] = {
--                 desired_targets = 1,
--                 adds = "heroic",
--                 adds_count = 6,
--             },
--             ["Odyn"] = {
--                 desired_targets = 1,
--                 adds = "heroic",
--                 adds_count = 1,
--             },
--         },
--         [1042] = { -- Maw of Souls
--             ["Ymiron, the Fallen King"] = {
--                 desired_targets = 1,
--                 adds = false,
--             },
--             ["Harbaron"] = {
--                 desired_targets = 1,
--                 adds = 2,
--                 adds1_count = 3, -- Fragment
--                 adds2_count = 1, -- Shackled Servitor
--             },
--             ["Helya"] = {
--                 desired_targets = 1,
--                 adds = false, -- ? should we think of phase 1 as adds?
--             },
--         },
--         [1045] = { -- Vault of the Wardens
--             ["Tirathon Saltheril"] = {
--                 desired_targets = 1,
--                 adds = false,
--             },
--             ["Inquisitor Tormentorum"] = {
--                 desired_targets = 1,
--                 adds = true,
--                 adds_count = 3,
--             },
--             ["Ash'golm"] = {
--                 desired_targets = 1,
--                 adds = false, -- embers are a bit hard to account for
--             },
--             ["Glazer"] = {
--                 desired_targets = 1,
--                 adds = false,
--             },
--             ["Cordana Felsong"] = {
--                 desired_targets = 1,
--                 adds = false, -- she is invulnerable whenever there is an add so no adds effectively
--             },
--         },
--         [1046] = { -- Eye of Azshara
--             ["Warlord Parjesh"] = {
--                 desired_targets = 1,
--                 adds = true,
--                 adds_count = 2,
--             },
--             ["Lady Hatecoil"] = {
--                 desired_targets = 1,
--                 adds = true,
--                 adds_count = 5, -- Saltsea Globules how many? believe it's one per player
--             },
--             ["King Deepbeard"] = {
--                 desired_targets = 1,
--                 adds = false,
--                 adds_count = 0,
--             },
--             ["Serpentrix"] = {
--                 desired_targets = 1,
--                 adds = false, -- Heads are too spread apart to serve as adds
--                 adds_count = 0,
--             },
--             ["Wrath of Azshara"] = {
--                 desired_targets = 1,
--                 adds = false,
--                 adds_count = 0,
--             },
--         },
--         [1065] = { -- Neltharion's Lair
--             ["Rokmora"] = {
--                 desired_targets = 1,
--                 adds = false, -- ignore skitters
--                 adds_count = 0,
--             },
--             ["Ularogg Cragshaper"] = {
--                 desired_targets = 1,
--                 adds = false, -- treat idols as adds?
--                 adds_count = 0,
--             },
--             ["Naraxas"] = {
--                 desired_targets = 1,
--                 adds = true,
--                 adds_count = 2, -- ?
--             },
--             ["Dargrul the Underking"] = {
--                 desired_targets = 1,
--                 adds = true,
--                 adds_count = 1,
--             },
--         },
--         [1066] = { -- Assault on Violet Hold
--         },
--         [1067] = { -- Darkheart Thicket
--         },
--         [1079] = { -- The Arcway
--         },
--         [1081] = { -- Black Rook Hold
--         },
--         [1087] = { -- Court of Stars
--         },

--         [1088] = { -- The Nighthold
--         },
--         [1094] = { -- The Emerald Nightmare
--         },
--     }

    -- function
end