--
-- Totentaz location
--
return {
    name = "NCA Totentaz",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("Totentaz")
        --NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Entrance", pos = { -1727.2933, 2218.5376, 90.3999 }, rot = { 0.0, 0.0, -0.19292854, -0.98121285 } })
        --NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Entrance_2", pos = { -1733.2319, 2242.451, 18.210007 }, rot = { 0.0, 0.0, 0.86637414, 0.49939546 } })
        --NCA:RegisterSpawn("Totentaz", { name = "Totentaz_EntranceUpper_1", pos = { -1734.7659, 2245.4941, 22.211624 }, rot = { 0.0, 0.0, -0.7458825, -0.66607755 } })
        --NCA:RegisterSpawn("Totentaz", { name = "Totentaz_EntranceUpper_2", pos = { -1751.4021, 2230.212, 22.199997 }, rot = { 0.0, 0.0, -0.26395792, 0.9645342 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Stairs", pos = { -1737.6052, 2206.6162, 88.211624 }, rot = { 0.0, 0.0, 0.15464608, -0.98796993 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Upper_1", pos = { -1743.2649, 2214.4016, 90.2 }, rot = { 0.0, 0.0, -0.810208, 0.5861426 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Upper_2", pos = { -1737.3215, 2195.3113, 90.2 }, rot = { 0.0, 0.0, -0.2629261, -0.964816 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Upper_3", pos = { -1740.4305, 2193.7373, 90.2 }, rot = { 0.0, 0.0, -0.4975227, 0.8674511 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Upper_4", pos = { -1734.9128, 2183.9722, 90.211624 }, rot = { 0.0, 0.0, -0.24104941, 0.9705129 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Upper_5", pos = { -1729.9922, 2183.518, 90.23122 }, rot = { 0.0, 0.0, 0.54187685, 0.840458 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Upper_6", pos = { -1734.5845, 2189.878, 90.21001 }, rot = { 0.0, 0.0, 0.57698107, -0.81675756 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Dance_1", pos = { -1730.9822, 2213.6013, 86.211624 }, rot = { 0.0, 0.0, 0.9988264, 0.04843562 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Dance_2", pos = { -1709.0643, 2203.9124, 86.2 }, rot = { 0.0, 0.0, 0.96388096, 0.26633364 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Dance_3", pos = { -1726.7949, 2185.7021, 86.2 }, rot = { 0.0, 0.0, 0.05240191, 0.99862605 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Bar", pos = { -1715.8394, 2219.7808, 86.2 }, rot = { 0.0, 0.0, 0.4015288, 0.91584647 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Lower_1", pos = { -1704.0068, 2208.0122, 86.2 }, rot = { 0.0, 0.0, 0.72277194, 0.6910867 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Backroom_1", pos = { -1751.4438, 2239.314, 86.20773 }, rot = { 0.0, 0.0, -0.96500915, 0.26221645 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Backroom_2", pos = { -1718.7241, 2232.0754, 86.2 }, rot = { 0.0, 0.0, -0.31650442, -0.94859105 } })
        NCA:RegisterSpawn("Totentaz", { name = "Totentaz_Backroom_3", pos = { -1714.8812, 2244.522, 86.2 }, rot = { 0.0, 0.0, 0.96004015, 0.27986234 } })
        NCA:Location():RegisterDistrictTrigger("Totentaz", gamedataDistrict.Northside_Totentaz)
        NCA:Spawn():RegisterAffiliationSpawnRule("Totentaz", "Factions.AfterlifeMercs", 0.55)
        NCA:Spawn():RegisterAffiliationSpawnRule("Totentaz", "Factions.Maelstrom", 1.5)
        NCA:Spawn():RegisterAffiliationSpawnRule("Totentaz", "Factions.TheMox", 0.0)

        NCA:RegisterProp("Totentaz", {
            name = "Totentaz_Dancefloor",
            slots = { "Slot_1", "Slot_2", "Slot_3", "Slot_4", "Slot_5" },
            pos = { -1719.2207031, 2200.2529297, 86.2116165, 1 },
            rot = { 0.0000000, 0.0000000, -0.5771440, -0.8166425 },
            interactions = {
                {
                    type = "dance",
                    slots = { "Slot_1" },
                    pos = { -1715.9219971, 2199.0620117, 86.2351074, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9713010, 0.2378540 },
                },
                {
                    type = "dance",
                    slots = { "Slot_2" },
                    pos = { -1718.5240479, 2185.8244629, 87.2611694, 1 },
                    rot = { 0.0000000, 0.0000000, 0.2222275, 0.9749949 },
                },
                {
                    type = "dance",
                    slots = { "Slot_3" },
                    pos = { -1726.3627930, 2201.5803223, 87.2050018, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6994141, 0.7147167 },
                },
                {
                    type = "dance",
                    slots = { "Slot_4" },
                    pos = { -1712.1719971, 2193.9736328, 87.2050018, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6070986, -0.7946266 },
                },
                {
                    type = "dance",
                    slots = { "Slot_5" },
                    pos = { -1720.3181152, 2205.8339844, 87.2050018, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9999211, -0.0125659 },
                },
            }
        })

        NCA:RegisterProp("Totentaz", {
            name = "Totentaz_Backroom",
            slots = { "Slot_1" },
            pos = { -1701.4923096, 2197.5383301, 90.2357330, 1 },
            rot = { 0.0000000, 0.0000000, 0.0300154, -0.9995494 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Slot_1" },
                    pos = { -1702.6080322, 2194.6206055, 90.1707611, 1 },
                    rot = { 0.0000000, 0.0000000, 0.4636052, -0.8860419 },
                },
            }
        })

        NCA:RegisterProp("Totentaz", {
            name = "Totentaz_Upper_Railing",
            slots = { "Slot_1" },
            pos = { -1733.5186768, 2196.7934570, 90.1999969, 1 },
            rot = { 0.0000000, 0.0000000, 0.4786908, -0.8779836 },
            interactions = {
                {
                    type = "stand_rail",
                    slots = { "Slot_1" },
                    pos = { -1733.3890381, 2196.7934570, 90.1999969, 1 },
                    rot = { 0.0000000, 0.0000000, -0.5387707, 0.8424524 },
                },
            }
        })

        NCA:RegisterProp("Totentaz", {
            name = "Totentaz_Upper_Railing_2",
            slots = { "Slot_1" },
            pos = { -1737.2216797, 2213.6552734, 90.2075348, 1 },
            rot = { 0.0000000, 0.0000000, 0.9670901, -0.2544342 },
            interactions = {
                {
                    type = "stand_rail",
                    slots = { "Slot_1" },
                    pos = { -1737.0019531, 2213.6552734, 90.2075348, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9808193, 0.1949191 },
                },
            }
        })

        NCA:RegisterProp("Totentaz", {
            name = "Totentaz_Lounge_Sofa",
            slots = { "Slot_1" },
            pos = { -1709.3294678, 2208.6574707, 90.2536163, 1 },
            rot = { 0.0000000, 0.0000000, 0.8599415, 0.5103925 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Slot_1" },
                    pos = { -1708.1269531, 2208.3686523, 90.1999969, 1 },
                    rot = { 0.0000000, 0.0000000, 0.8599415, 0.5103925 },
                },
            }
        })

        NCA:RegisterProp("Totentaz", {
            name = "Totentaz_Bar",
            slots = { "Wall_Lean" },
            pos = { -1712.1145020, 2219.5002441, 86.1999969, 1 },
            rot = { 0.0000000, 0.0000000, -0.8760545, -0.4822123 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Wall_Lean" },
                    pos = { -1712.0129395, 2219.8229980, 86.1998138, 1 },
                    rot = { 0.0000000, 0.0000000, -0.8674184, -0.4975794 },
                },
            }
        })
    end
}