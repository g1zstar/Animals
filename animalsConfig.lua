local animalsName, animalsTable = ...
local _ = nil

animalsDataPerChar = animalsDataPerChar or {Log = false}

animalsTable.logFile = "F:\\Garrison.json"

-- if not animalsDataPerChar.chaosMin then
	animalsDataPerChar.chaosMin = -20
	animalsDataPerChar.chaosMax = 40
-- end
-- if not animalsDataPerChar.castMin then
    animalsDataPerChar.castMin = 10
    animalsDataPerChar.castMax = 25
    animalsDataPerChar.channelMin = 85
    animalsDataPerChar.channelMax = 95
-- end

animalsTable.skipLoS = {
    76585, -- Ragewing
    77692, -- Kromog
    77182, -- Oregorger
}
animalsTable.animalNamesToIgnore = {
    "Unknown",
    "Manifestation",
    "Kor'Kron Cannon",
    "Spike Mine",
    "Prismatic Crystal",
}
animalsTable.animalTypesToIgnore = {
    "Critter",
    "Critter nil",
    "Wild Pet",
    "Pet",
    "Totem",
    -- "Not specified",
    -- Creature in the shadows xavius trash is this type
}
animalsTable.animalsAurasToIgnore = {
    "Arcane Protection",
    "Water Bubble",
    "Stuff of Nightmares",
    "Spectral Service",
}
animalsTable.humansAurasToIgnore = {
}


animalsTable.animalsThatInterrupt = {
    "Thok the Bloodthirsty",
    "Pol",
    "Franzok",
    "Grom'kar Firemender",
    "Blade Dancer Illianna",
    "Fenryr",
}
animalsTable.spellsThatInterrupt = {}
animalsTable.spellsThatInterrupt["Thok the Bloodthirsty"] = 0
animalsTable.spellsThatInterrupt["Pol"] = 0
animalsTable.spellsThatInterrupt["Franzok"] = 0
animalsTable.spellsThatInterrupt["Grom'kar Firemender"] = 0
animalsTable.spellsThatInterrupt["Blade Dancer Illianna"] = 0

-- todo: populate with boss IDs
animalsTable.bossIDList = {
}
-- todo: should healing/tanking/instance dummies be under this?
animalsTable.dummiesID = {
    31144, -- 080
    31146, -- ???
    32541, -- 055
    32542, -- 065
    32545, -- 055
    32546, -- 080
    32543, -- 075
    32666, -- 060
    32667, -- 070
    46647, -- 085
    67127, -- 090
    79414, -- 095 Talador
    87317, -- 100 Garrison (Mage Tower?)
    87318, -- 102 Garrison (Lunarfall)
    87320, -- ??? Alliance Ashran and Garrison (Lunarfall) Dummy
    -- 87321, -- 100 Alliance Ashran Healing Dummy
    -- 87322, -- 102 Alliance Ashran Tanking Dummy
    -- 87329, -- ??? Alliance Ashran Tanking Dummy
    87760, -- 100 Garrison (Frostwall)
    87761, -- 102 Garrison (Frostwall)
    87762, -- ??? Horde Ashran and Garrison (Frostwall) Dummy
    -- 88288, -- 102 Garrison (Frostwall) Tanking Dummy
    -- 88289, -- 100 Garrison Healing Dummy (Frostwall)
    -- 88314, -- 102 Garrison (Lunarfall) Tanking Dummy
    -- 88316, -- 100 Garrison Healing Dummy (Lunarfall)
    -- 88835, -- 100 Horde Ashran Healing Dummy
    -- 88836, -- 102 Horde Ashran Tanking Dummy
    -- 88837, -- ??? Horde Ashran Tanking Dummy
    88967, -- 100 Garrison
    89078, -- ??? Garrison
    -- 89321, -- 100 Garrison Healing Dummy
    -- Unknown Location Commented out for now
        -- 24792, -- ???
        -- 30527, -- ???
        -- 79987, -- ???
    -- Dungeons Commented out for now
        -- 17578, -- 001 The Shattered Halls
        -- 60197, -- 001 Scarlet Monastery
        -- 64446, -- 001 Scarlet Monastery
    -- Raids Commented out for now
        -- 70245, -- ??? Throne of Thunder
        -- 93828, -- 102 Hellfire Citadel
    -- Starting Zone Dummies Commented out for now
        -- 44171, -- 003
        -- 44389, -- 003
        -- 44548, -- 003
        -- 44614, -- 003
        -- 44703, -- 003
        -- 44794, -- 003
        -- 44820, -- 003
        -- 44848, -- 003
        -- 44937, -- 003
        -- 48304, -- 003
    -- Added in Legion Patches
         92164, -- ??? Training Dummy <Damage>
         92165, -- ??? Dungeoneer's Training Dummy <Damage>
         92166, -- ??? Raider's Training Dummy <Damage>
        --  92167, -- ??? Training Dummy <Healing>
        --  92168, -- ??? Dungeoneer's Training Dummy <Tanking>
        --  92169, -- ??? Raider's Training Dummy <Tanking>
        --  96442, -- ??? Training Dummy <Damage>
        --  97668, -- ??? Boxer's Training Dummy
        --  98581, -- ??? Prepfoot Training Dummy
        -- 107557, -- ??? Training Dummy <Healing>
        -- 108420, -- ??? Training Dummy
        -- 109595, -- ??? Training Dummy
        -- 111824, -- ??? Training Dummy
        -- 113858, -- ??? Training Dummy <Damage>
        -- 113859, -- ??? Dungeoneer's Training Dummy <Damage>
        -- 113860, -- ??? Raider's Training Dummy <Damage>
        -- 113862, -- ??? Training Dummy <Damage>
        -- 113863, -- ??? Dungeoneer's Training Dummy <Damage>
        -- 113864, -- ??? Raider's Training Dummy <Damage>
        -- 113871, -- ??? Bombardier's Training Dummy <Damage>
        -- 113963, -- ??? Raider's Training Dummy <Damage>
        -- 113964, -- ??? Raider's Training Dummy <Tanking>
        -- 113966, -- ??? Dungeoneer's Training Dummy <Damage>
        -- 113967, -- ??? Training Dummy <Healing>
        -- 114832, -- ??? PvP Training Dummy
        -- 114840, -- ??? PvP Training Dummy
}
animalsTable.dummiesName = {
    "Training Bag",
    "Training Dummy",
    "Dungeoneer's Training Dummy",
    "Raider's Training Dummy",
    "Initiate's Training Dummy",
    "Disciple's Training Dummy",
    "Veterans's Training Dummy",
    "Ebon Knight's Training Dummy",
    "Highlord's Nemesis Trainer",
    "Small Illusionary Amber-Weaver",
    "Large Illusionary Amber-Weaver",
    "Small Illusionary Mystic",
    "Large Illusionary Mystic",
    "Small Illusionary Guardian",
    "Large Illusionary Guardian",
    "Small Illusionary Slayer",
    "Large Illusionary Slayer",
    "Small Illusionary Varmint",
    "Large Illusionary Varmint",
    "Small Illusionary Banana-Tosser",
    "Large Illusionary Banana-Tosser",
}