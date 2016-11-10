local animalsName, animalsTable = ...
local _ = nil

function animalsTable.animalsAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #animalsTable.animalsAurasToIgnore do
        auraToCheck = animalsTable.animalsAurasToIgnore[i]
        if animalsTable.aura(object, auraToCheck) then return false end
    end
    return true
end

function animalsTable.humansAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #animalsTable.humansAurasToIgnore do
        auraToCheck = animalsTable.humansAurasToIgnore[i]
        if animalsTable.aura(object, auraToCheck) then return false end
    end
    return true
end

function animalsTable.logToFile(message)
    local file = ReadFile(animalsTable.logFile)
    local debugStack = string.gsub(debugstack(2, 100, 100), 'Interface\\AddOns\\Animals\\.-(%w+)%.lua', "file: %1, line")
    debugStack = string.gsub(debugStack, "\n", ", ")
    WriteFile(animalsTable.logFile, file..",\n{\n\t"..message.."\n\t\"time\":"..GetTime()..",\n\t\"Line Number\": "..debugStack.."\n}")
end

function animalsTable.humanNotDuplicate(unitPassed)
    local unit
    for i = 1, animalsTable.humansSize do
        unit = animalsTable.targetHumans[i].Player
        if unit == unitPassed then return false end
    end
    return true
end

function animalsTable.sortAnimalsByLowestTTD(a, b)
    return animalsTable.getTTD(a) < animalsTable.getTTD(b)
end

function animalsTable.sortAnimalsByHighestTTD(a, b)
    if animalsTable.getTTD(a) == math.huge then return false elseif animalsTable.getTTD(b) == math.huge then return true end
    return animalsTable.getTTD(a) > animalsTable.getTTD(b)
end

function animalsTable.logAnimalsToFile()
    local unit
    for i = 1, animalsTable.animalsSize do
        unit = animalsTable.targetAnimals[i]
        animalsTable.logToFile(
            UnitName(unit)..":\n\t"..UnitCreatureType(unit).."\n\t"..tostring(UnitIsVisible(unit)).."\n\t"..tostring(animalsTable.animalIsTappedByPlayer(unit))
            )
    end
end

-- ripped from CommanderSirow of the wowace forums
function animalsTable.TTDF(unit) -- keep updated: see if this can be optimized
    -- Setup trigger (once)
    if not nMaxSamples then
        -- User variables
        nMaxSamples = 15             -- Max number of samples
        nScanThrottle = 0.25             -- Time between samples
    end

    -- Training Dummy alternate between 4 and 200 for cooldowns
    if tContains(animalsTable.dummiesID, ObjectID(unit)) then
        if not animalsDataPerChar.dummyTTDMode or animalsDataPerChar.dummyTTDMode == 1 then
            if (not animalsTable.TTD[unit] or animalsTable.TTD[unit] == 200) then animalsTable.TTD[unit] = 4 return else animalsTable.TTD[unit] = 200 return end
        elseif animalsDataPerChar.dummyTTDMode == 2 then
            animalsTable.TTD[unit] = 4
            return
        else
            animalsTable.TTD[unit] = 200
            return
        end
    end

    if not ObjectExists(unit) or not UnitExists(unit) or animalsTable.health(unit) == 0 then animalsTable.TTD[unit] = -1 return end

    -- Query current time (throttle updating over time)
    local nTime = GetTime()
    if not animalsTable.TTDM[unit] or nTime - animalsTable.TTDM[unit].nLastScan >= nScanThrottle then
        -- Current data
        local data = animalsTable.health(unit)

        if not animalsTable.TTDM[unit] then animalsTable.TTDM[unit] = {start = nTime, index = 1, maxvalue = animalsTable.health(unit, max)/2, values = {}, nLastScan = nTime, estimate = nil} end

        -- Remember current time
        animalsTable.TTDM[unit].nLastScan = nTime

        if animalsTable.TTDM[unit].index > nMaxSamples then animalsTable.TTDM[unit].index = 1 end
        -- Save new data (Use relative values to prevent "overflow")
        animalsTable.TTDM[unit].values[animalsTable.TTDM[unit].index] = {dmg = data - animalsTable.TTDM[unit].maxvalue, time = nTime - animalsTable.TTDM[unit].start}

        if #animalsTable.TTDM[unit].values >= 2 then
            -- Estimation variables
            local SS_xy, SS_xx, x_M, y_M = 0, 0, 0, 0

            -- Calc pre-solution values
            for i = 1, #animalsTable.TTDM[unit].values do
                z = animalsTable.TTDM[unit].values[i]
                -- Calc mean value
                x_M = x_M + z.time / #animalsTable.TTDM[unit].values
                y_M = y_M + z.dmg / #animalsTable.TTDM[unit].values

                -- Calc sum of squares
                SS_xx = SS_xx + z.time * z.time
                SS_xy = SS_xy + z.time * z.dmg
            end
            -- for i = 1, #animalsTable.TTDM[unit].values do
            --     -- Calc mean value
            --     x_M = x_M + animalsTable.TTDM[unit].values[i].time / #animalsTable.TTDM[unit].values
            --     y_M = y_M + animalsTable.TTDM[unit].values[i].dmg / #animalsTable.TTDM[unit].values

            --     -- Calc sum of squares
            --     SS_xx = SS_xx + animalsTable.TTDM[unit].values[i].time * animalsTable.TTDM[unit].values[i].time
            --     SS_xy = SS_xy + animalsTable.TTDM[unit].values[i].time * animalsTable.TTDM[unit].values[i].dmg
            -- end

            -- Few last addition to mean value / sum of squares
            SS_xx = SS_xx - #animalsTable.TTDM[unit].values * x_M * x_M
            SS_xy = SS_xy - #animalsTable.TTDM[unit].values * x_M * y_M

            -- Results
            local a_0, a_1, x = 0, 0, 0

            -- Calc a_0, a_1 of linear interpolation (data_y = a_1 * data_x + a_0)
            a_1 = SS_xy / SS_xx
            a_0 = y_M - a_1 * x_M

            -- Find zero-point (Switch back to absolute values)
            a_0 = a_0 + animalsTable.TTDM[unit].maxvalue
            x = - (a_0 / a_1)

            -- Valid/Usable solution
            if a_1 and a_1 < 1 and a_0 and a_0 > 0 and x and x > 0 then
                animalsTable.TTDM[unit].estimate = x + animalsTable.TTDM[unit].start
                -- Fallback
            else
                animalsTable.TTDM[unit].estimate = nil
            end

            -- Not enough data
        else
            animalsTable.TTDM[unit].estimate = nil
        end
        animalsTable.TTDM[unit].index = animalsTable.TTDM[unit].index + 1 -- enable
    end

    if not animalsTable.TTDM[unit].estimate then
        animalsTable.TTD[unit] = math.huge
    elseif nTime > animalsTable.TTDM[unit].estimate then
        animalsTable.TTD[unit] = -1
    else
        animalsTable.TTD[unit] = animalsTable.TTDM[unit].estimate-nTime
    end
end
-- ripped from CommanderSirow of the wowace forums

-- animalsTable.interruptTable = {
local interruptTable = {
    -- Legion Dungeons
        [1041] = { -- Halls of Valor
            [95842]  = {[198595] = {type = "cast", verify = "Thunderous Bolt"}}, -- Valarjar Thundercaller
            [95834]  = {[198931] = {type = "cast", verify = "Healing Light"}, [215433] = {type = "cast", verify = "Holy Radiance"}}, -- Valarjar Mystic
            [96664]  = {[198962] = {type = "cast", verify = "Shattered Rune"}}, -- Valarjar Runecarver
            [97197]  = {[192563] = {type = "cast", verify = "Cleansing Flames"}}, -- Valarjar Purifier
            [97202]  = {[192288] = {type = "cast", verify = "Searing Light"}}, -- Olmyr the Enlightened
            [95843]  = {[199726] = {type = "cast", verify = "Unruly Yell"}}, -- King Haldor
            [97083]  = {[199726] = {type = "cast", verify = "Unruly Yell"}}, -- King Ranulf
            [97084]  = {[199726] = {type = "cast", verify = "Unruly Yell"}}, -- King Tor
            [97081]  = {[199726] = {type = "cast", verify = "Unruly Yell"}}, -- King Bjorn
            [102019] = {[198750] = {type = "cast", verify = "Surge"}}, -- Stormforged Obliterator
        },
        [1042] = { -- Maw of Souls
            [99188]  = {["Soul Siphon"] = {type = "channel", verify = "Soul Siphon"}}, -- Waterlogged Soul Guard
            [97365]  = {[199514] = {type = "cast", verify = "Torrent of Souls"}}, -- Seacursed Mistmender
            -- [id]    = {[id] = {type = "cast", verify = ""}}, -- Seacursed Mistmaiden
            [97097]  = {[198405] = {type = "cast", verify = "Bone Chilling Scream"}}, -- Helarjar Champion
            [98693]  = {[194266] = {type = "cast", verify = "Void Snap"}}, -- Shackled Servitor
            [99033]  = {[199589] = {type = "cast", verify = "Whirlpool of Souls"}}, -- Helarjar Mistcaller
            [99307]  = {[195293] = {type = "cast", verify = "Debilitating Shout"}}, -- Skjal
            [99447]  = {[198407] = {type = "cast", verify = "Necrotic Bolt"}}, -- Skeletal Sorcerer
            [96759]  = {[198495] = {type = "cast", verify = "Torrent"}}, -- Helya
        },
        [1045] = { -- Vault of the Wardens
            [96587]  = {[193069] = {type = "cast", verify = "Nightmares"}}, -- Felsworn Infestor
            [99198]  = {[191823] = {type = "cast", verify = "Furious Blast"}}, -- Tirathon Saltheril
            [107101] = {[212541] = {type = "cast", verify = "Scorch"}}, -- Fel Fury
            [98963]  = {[194675] = {type = "cast", verify = "Fireblast"}}, -- Blazing Imp
            [102583] = {[202661] = {type = "cast", verify = "Inferno Blast"}}, -- Fel Scorcher
            [96015]  = {[200905] = {type = "cast", verify = "Sap Soul"}}, -- Inquisitor Tormentorum
            [99657]  = {[201488] = {type = "cast", verify = "Frightening Shout"}}, -- Deranged Mindflayer
            [99233]  = {[195332] = {type = "cast", verify = "Sear"}}, -- Ember
        },
        [1046] = { -- Eye of Azshara
            [111638] = {[218532] = {type = "cast", verify = "Arc Lightning"}, ["Storm"] = {type = "channel", verify = "Storm"}}, -- Hatecoil Stormweaver
            [111632] = {[195129] = {type = "cast", verify = "Thundering Stomp"}}, -- Hatecoil Crusher
            [111636] = {[195046] = {type = "cast", verify = "Rejuvenating Waters"}}, -- Hatecoil Oracle
            [97269]  = {[197502] = {type = "cast", verify = "Restoration"}}, -- Hatecoil Crestrider
            [97171]  = {[196027] = {type = "cast", verify = "Aqua Spout"}}, -- Hatecoil Arcanist
            [95947]  = {[196175] = {type = "cast", verify = "Armorshell"}}, -- Mak'rana Hardshell
            [97259]  = {[192003] = {type = "cast", verify = "Blazing Nova"}}, -- Blazing Hydra Spawn
            [91808]  = {["Rampage"] = {type = "channel", verify = "Rampage"}}, -- Serpentrix
            [97260]  = {[192005] = {type = "cast", verify = "Arcane Blast"}}, -- Arcane Hydra Spawn
        },
        [1065] = { -- Neltharion's Lair
            [91006]  = {[202181] = {type = "cast", verify = "Stone Gaze"}}, -- Rockback Gnasher
            [102232] = {[193585] = {type = "cast", verify = "Bound"}}, -- Rockbound Trapper
        },
        [1066] = { -- Assault on Violet Hold
            [102337] = {["Shield of Eyes"] = {type = "channel", verify = "Shield of Eyes"}}, -- Portal Guardian - Inquisitor
            [102336] = {[204901] = {type = "cast", verify = "Carrion Swarm"}, [204947] = {type = "cast", verify = "Vampiric Cleave"}}, -- Portal Keeper - Dreadlord
            [102302] = {["Fel Destruction"] = {type = "channel", verify = "Fel Destruction"}}, -- Portal Keeper - Felguard
            [102372] = {["Drain Essence"] = {type = "channel", verify = "Drain Essence"}}, -- Felhound Mage Slayer
            [102380] = {[205121] = {type = "cast", verify = "Chaos Bolt"}}, -- Shadow Council Warlock
            [112738] = {[224453] = {type = "cast", verify = "Lob Poison"}}, -- Acolyte of Sael'orn
            [112733] = {[224460] = {type = "cast", verify = "Venom Nova"}}, -- Venomhide shadowspinner
            [102103] = {[201369] = {type = "cast", verify = "Rocket Chicken Rocket"}}, -- Thorium Rocket Chicken
            [102618] = {[201146] = {type = "cast", verify = "Hysteria"}}, -- Mindflayer Kaahrj
            [102282] = {[204963] = {type = "cast", verify = "Shadow Bolt Volley"}}, -- Lord Malgath
        },
        [1067] = { -- Darkheart Thicket
            [95771]  = {[200658] = {type = "cast", verify = "Star Shower"}}, -- Dreadsoul Ruiner
            [95769]  = {[200630] = {type = "cast", verify = "Unnerving Screech"}}, -- Mindshattered Screecher
            [101991] = {["Tormenting Eye"] = {type = "channel", verify = "Tormenting Eye"}}, -- Nightmare Dweller
            [100527] = {[201399] = {type = "cast", verify = "Dread Inferno"}}, -- Dreadfire Imp
        },
        [1079] = { -- The Arcway
            [105952] = {["Siphon Essence"] = {type = "channel", verify = "Siphon Essence"}}, -- Withered Manawraith
            [113699] = {[226269] = {type = "cast", verify = "Torment"}}, -- Forgotten Spirit
            [105915] = {[211007] = {type = "cast", verify = "Eye of the Vortex"}}, -- Nightborne Reclaimer
            [105617] = {[211757] = {type = "cast", verify = "Portal: Argus"}, [226285] = {type = "cast", verify = "Demonic Ascension"}}, -- Eredar Chaosbringer
            [98756]  = {[226206] = {type = "cast", verify = "Arcane Reconstitution"}}, -- Arcane Anomaly
            [106059] = {[211115] = {type = "cast", verify = "Phase Breach"}, [226206] = {type = "cast", verify = "Arcane Reconstitution"}}, -- Warp Shade
            [98203]  = {["Overcharge Mana"] = {type = "channel", verify = "Overcharge Mana"}}, -- Ivanyr
            [98208]  = {[203176] = {type = "cast", verify = "Accelerating Blast"}}, -- Advisor Vandros
            [111057] = {[221285] = {type = "cast", verify = "Plague Bolt"}}, -- The Rat King
        },
        [1081] = { -- Black Rook Hold
            [98370]  = {[225573] = {type = "cast", verify = "Dark Mending"}}, -- Ghostly Councilor
            [98521]  = {[196883] = {type = "cast", verify = "Spirit Blast"}}, -- Lord Etheldrin Ravencrest
            [98280]  = {[200248] = {type = "cast", verify = "Arcane Blitz"}}, -- Risen Arcanist
            [102788] = {[227913] = {type = "cast", verify = "Felfrenzy"}}, -- Felspite Dominator
        },
        [1087] = { -- Court of Stars
            [104251] = {[210261] = {type = "cast", verify = "Sound Alaram"}}, -- Duskwatch Sentry
            [104918] = {[215204] = {type = "cast", verify = "Hinder"}}, -- Vigilant Duskwatch
            [105704] = {[209485] = {type = "cast", verify = "Drain Magic"}}, -- Arcane Manifestation
            [104247] = {[209404] = {type = "cast", verify = "Seal Magic"}}, -- Duskwatch Arcanist
            [104270] = {[209413] = {type = "cast", verify = "Suppress"}, [225100] = {type = "cast", verify = "Charging Station"}}, -- Guardian Construct
            [105715] = {[211299] = {type = "cast", verify = "Searing Glare"}}, -- Watchful Inquisitor
            [104300] = {[211470] = {type = "cast", verify = "Bewitch"}}, -- Shadow Mistress
            [104295] = {["Drifting Embers"] = {type = "channel", verify = "Drifting Embers"}}, -- Blazing Imp
            [104217] = {[208165] = {type = "cast", verify = "Withering Soul"}}, -- Talixae Flamewreath
            [112668] = {["Drifting Embers"] = {type = "channel", verify = "Drifting Embers"}}, -- Infernal Imp
        },
        [1115] = { -- Karazhan
            [114626] = {[228255] = {type = "cast", verify = "Soul Leech"}}, -- Forlorn Spirit
            [114627] = {[228239] = {type = "cast", verify = "Shrieking Terror"}}, -- Shrieking Terror
            [114329] = {[228025] = {type = "cast", verify = "Heat Wave"}}, -- Luminore
            -- [114522] = {[228011] = {type = "cast", verify = "Soup Spray"}, [228019] = {type = "cast", verify = "Leftovers"}}, -- Mrs. Cauldrons
            [114328] = {[227987] = {type = "cast", verify = "Dinner Bell!"}}, -- Coggleston
            [114266] = {[227420] = {type = "cast", verify = "Bubble Blast"}}, -- Shoreline Tidespeaker
            -- [] = {[] = {type = "cast", verify = ""}}, -- Elfyra
            -- [] = {[] = {type = "cast", verify = ""}}, -- Galindre
        },
        

    -- Legion Raids
        [1088] = { -- The Nighthold
        }, 
        [1094] = { -- The Emerald Nightmare
            [111004] = {[221059] = {type = "cast", verify = "Wave of Decay"}}, -- Gelatinized Decay
            -- [id] = {[205070] = {type = "cast", verify = "Spread Infestation"}}, -- Player MC'ed Mythic Nythendra
            [112153] = {[223392] = {type = "cast", verify = "Dread Wrath Volley"}}, -- Dire Shaman
            [112290] = {[223565] = {type = "cast", verify = "Screech"}}, -- Horrid Eagle
            [105322] = {[208697] = {type = "cast", verify = "Mind Flay"}}, -- Deathglare Tentacle
            -- [id] = {[id] = {type = "cast", verify = "Mind Flay"}}, -- Shriveled Eyestalk
            [113089] = {["Raining Filth"] = {type = "channel", verify = "Raining Filth"}}, -- Defiled Keeper
            [103691] = {[205300] = {type = "cast", verify = "Corruption"}}, -- Essence of Corruption
            [112261] = {[223038] = {type = "cast", verify = "Erupting Terror"}, [223590] = {type = "cast", verify = "Darkfall"}}, -- Dreadsoul Corruptor
            [112260] = {[222939] = {type = "cast", verify = "Shadow Volley"}}, -- Dreadsoul Defiler
            [105495] = {[211368] = {type = "cast", verify = "Twisted Touch of Life"}}, -- Twisted Sister
        },
        ["Trial of Valor"] = { -- Trial of Valor

        },
}
local verifyTable = {
}

function animalsTable.interruptFunction(target, interruptID)
    if not target then target = "target" end
    if not ObjectExists(target) or not UnitExists(target) or not UnitCastingInfo(target) and not UnitChannelInfo(target) then return end
    local zone, unitID, spellID, spellName, spellBegin, spellEnd = GetCurrentMapAreaID(), ObjectID(target), nil, nil
    if not zone or not unitID or not interruptTable[zone] then return end
    if not verifyTable[zone] then verifyTable[zone] = {} end

    if UnitCastingInfo(target) and not select(9, UnitCastingInfo(target)) then
        spellID, spellName = select(10, UnitCastingInfo(target)), UnitCastingInfo(target)
        if not verifyTable[zone][unitID] then verifyTable[zone][unitID] = {} end
        if (not interruptTable[zone][unitID] or not interruptTable[zone][unitID][spellID]) and not verifyTable[zone][unitID][spellID] then verifyTable[zone][unitID][spellID] = {mob = UnitName(target), type = "cast", verify = spellName} return end
    elseif UnitChannelInfo(target) and not select(8, UnitChannelInfo(target)) then
        spellID = UnitChannelInfo(target)
        if spellID then
            if not verifyTable[zone][unitID] then verifyTable[zone][unitID] = {} end
            if (not interruptTable[zone][unitID] or not interruptTable[zone][unitID][spellID]) and not verifyTable[zone][unitID][spellID] then verifyTable[zone][unitID][spellID] = {mob = UnitName(target), type = "channel", verify = spellID} return end
        end
    end

    if not interruptID then return end

    if UnitCastingInfo(target) and not select(9, UnitCastingInfo(target)) and interruptTable[zone][unitID] then
        spellID, spellName = select(10, UnitCastingInfo(target)), UnitCastingInfo(target)
        spellBegin         = select(5, UnitCastingInfo(target))*.001
        spellEnd           = select(6, UnitCastingInfo(target))*.001
        for k,v in pairs(interruptTable[zone][unitID]) do
            if k == spellID then
                if v.type ~= "cast" or v.verify ~= spellName then verifyTable[zone][unitID][spellID] = {type = "cast", verify = spellName} end
                if math.random(animalsDataPerChar.castMin, animalsDataPerChar.castMax)*.01 < ((GetTime()-spellBegin)/(spellEnd-spellBegin)) then animalsTable.cast(target, interruptID, _, _, _, _, "Interrupting") return end
            end
        end
    elseif UnitChannelInfo(target) and not select(8, UnitChannelInfo(target)) and interruptTable[zone][unitID] then
        spellID    = UnitChannelInfo(target)
        spellBegin = select(5, UnitChannelInfo(target))*.001
        spellEnd   = select(6, UnitChannelInfo(target))*.001
        for k,v in pairs(interruptTable[zone][unitID]) do
            if k == spellID then
                if v.type ~= "channel" or v.verify ~= spellID then verifyTable[zone][unitID][spellID] = {type = "channel", verify = spellID} end
                if math.random(animalsDataPerChar.channelMin, animalsDataPerChar.channelMax)*.01 > ((spellEnd-GetTime())/(spellEnd-spellBegin)) then animalsTable.cast(target, interruptID, _, _, _, _, "Interrupting") return end
            end
        end
    end
end

function animalsTable.dumpVerifyTable()
    -- for k,v in pairs(verifyTable) do
    --     print(k,v)
    -- end
    SlashCmdList["DUMP"]("verifyTable")
end