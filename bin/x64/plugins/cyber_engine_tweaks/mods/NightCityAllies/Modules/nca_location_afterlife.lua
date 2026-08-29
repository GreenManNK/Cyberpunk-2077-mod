--
-- Afterlife location
--
return {
    name = "NCA Afterlife",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("Afterlife")
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Bar_1", pos = { -1449.4476, 1028.737, 16.5 }, rot = { 0.0, 0.0, 0.9963004, 0.085939266 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Bar_2", pos = { -1428.6642, 1007.1262, 16.499992 }, rot = { 0.0, 0.0, -0.8921921, -0.45165634 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Bar_3", pos = { -1465.3229, 1014.1746, 16.899994 }, rot = { 0.0, 0.0, 0.8331142, -0.553101 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Backroom_1", pos = { -1464.0199, 999.2049, 16.508324 }, rot = { 0.0, 0.0, -0.94158834, 0.33676624 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Backroom_2", pos = { -1463.5027, 996.14374, 16.50071 }, rot = { 0.0, 0.0, -0.19406343, 0.98098904 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Toilet_1", pos = { -1437.3789, 1038.9954, 16.91822 }, rot = { 0.0, 0.0, -0.6785446, -0.73455924 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Lounge_1", pos = { -1455.9932, 1017.5203, 16.525002 }, rot = { 0.0, 0.0, -0.7258555, 0.6878472 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Lounge_2", pos = { -1437.9082, 1027.3657, 16.525002 }, rot = { 0.0, 0.0, 0.7498805, -0.66157335 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Hallway_1", pos = { -1434.2758, 1015.0881, 16.5 }, rot = { 0.0, 0.0, 0.99139935, -0.13087162 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Hallway_2", pos = { -1458.0537, 1020.4079, 16.5 }, rot = { 0.0, 0.0, 0.10261763, -0.99472094 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_ElevatorArea_1", pos = { -1455.3617, 1032.2256, 16.827286 }, rot = { 0.0, 0.0, -0.89940476, -0.4371169 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_PoolTable_1", pos = { -1465.5461, 1013.30096, 16.899994 }, rot = { 0.0, 0.0, -0.6241525, 0.7813027 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_PoolTable_2", pos = { -1458.214, 1011.9682, 16.94896 }, rot = { 0.0, 0.0, -0.18377988, -0.98296744 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Bar_4", pos = { -1445.8214, 1011.748, 16.522469 }, rot = { 0.0, 0.0, 0.12221592, 0.9925035 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Bar_5", pos = { -1439.938, 1015.0589, 16.499992 }, rot = { 0.0, 0.0, 0.9770456, 0.21303064 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Bar_6", pos = { -1433.2726, 1015.2979, 16.5 }, rot = { 0.0, 0.0, -0.992038, -0.12593947 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Sideroom_1", pos = { -1434.4215, 1031.575, 16.899994 }, rot = { 0.0, 0.0, -0.9968137, -0.07976452 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Sideroom_2", pos = { -1435.9335, 1031.7168, 16.899994 }, rot = { 0.0, 0.0, -0.99154717, 0.12974708 } })
        NCA:RegisterSpawn("Afterlife", { name = "Afterlife_Sideroom_3", pos = { -1438.5847, 1032.4741, 16.947426 }, rot = { 0.0, 0.0, -0.99891037, -0.046670876 } })
        NCA:Location():RegisterAfterlifeTrigger("Afterlife")
        NCA:Spawn():RegisterAffiliationSpawnRule("Afterlife", "Factions.AfterlifeMercs", 1.5)
        NCA:Spawn():RegisterAffiliationSpawnRule("Afterlife", "Factions.Maelstrom", 0.0)
        NCA:Spawn():RegisterAffiliationSpawnRule("Afterlife", "Factions.TheMox", 0.0)
        
        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Planning_Table",
            slots = { "Slot_1" },
            pos = { -1432.2441406, 1010.9060059, 16.5000000, 1 },
            rot = { 0.0000000, 0.0000000, -0.6674418, -0.7446620 },
            interactions = {
                {
                    type = "stand_table",
                    slots = { "Slot_1" },
                    pos = { -1433.0229492, 1008.6329956, 16.5092468, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6793122, -0.7338495 },
                },
            }
        })

        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Bathroom",
            slots = { "Toilet", "Sink" },
            pos = { -1435.6396484, 1038.7083740, 16.9000015, 1 },
            rot = { 0.0000000, 0.0000000, 0.7654848, -0.6434540 },
            interactions = {
                {
                    type = "stand_toilet",
                    slots = { "Toilet" },
                    pos = { -1435.6591797, 1041.7655029, 16.9427109, 1 },
                    rot = { 0.0000000, 0.0000000, 0.0678439, -0.9976960 },
                },
                {
                    type = "stand_sink",
                    slots = { "Sink" },
                    pos = { -1438.3489990, 1038.2512207, 16.9449234, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6657498, -0.7461751 },
                },
            }
        })

        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Corridor",
            slots = { "Table", "Wall" },
            pos = { -1432.7792969, 990.5093384, 16.4999924, 1 },
            rot = { 0.0000000, 0.0000000, -0.6590804, -0.7520725 },
            interactions = {
                {
                    type = "sit_table",
                    slots = { "Table" },
                    pos = { -1434.2969971, 992.4069824, 16.4200001, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9902681, 0.1391731 },
                },
                {
                    type = "stand_wall",
                    slots = { "Wall" },
                    pos = { -1431.3790283, 988.4550171, 16.4850006, 1 },
                    rot = { 0.0000000, 0.0000000, 0.0553026, -0.9984697 },
                },
            }
        })

        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Bar",
            slots = { "Slot_1", "Slot_2", "Slot_3" },
            pos = { -1446.1993408, 1013.2396851, 16.4999924, 1 },
            rot = { 0.0000000, 0.0000000, -0.9965363, -0.0831598 },
            interactions = {
                {
                    type = "dance",
                    slots = { "Slot_1" },
                    pos = { -1446.1993408, 1013.2396851, 16.4999924, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9965363, -0.0831598 },
                },
                {
                    type = "dance",
                    slots = { "Slot_2" },
                    pos = { -1453.6722412, 1013.9840088, 16.4999924, 1 },
                    rot = { 0.0000000, 0.0000000, -0.8758036, 0.4826677 },
                },
                {
                    type = "stand_wall",
                    slots = { "Slot_3" },
                    pos = { -1453.6939697, 1007.2230225, 16.4850006, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6584237, -0.7526476 },
                },
            }
        })

        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Hall",
            slots = { "Slot_1", "Slot_2" },
            pos = { -1438.2509766, 1026.7448730, 16.5000000, 1 },
            rot = { 0.0000000, 0.0000000, -0.0631994, 0.9980010 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Slot_1" },
                    pos = { -1443.6949463, 1022.9240112, 16.5000000, 1 },
                    rot = { 0.0000000, 0.0000000, -0.0631994, 0.9980010 },
                },
                {
                    type = "sit_table",
                    slots = { "Slot_2" },
                    pos = { -1440.0689697, 1029.5866699, 16.9909992, 1 },
                    rot = { 0.0000000, 0.0000000, -0.5125450, 0.8586603 },
                },
            }
        })

        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Wall_1",
            slots = { "Slot_1" },
            pos = { -1434.6727295, 1015.1822510, 16.5000000, 1 },
            rot = { 0.0000000, 0.0000000, -0.7483776, 0.6632730 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Slot_1" },
                    pos = { -1434.8330078, 1015.1822510, 16.5000000, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7483776, 0.6632730 },
                },
            }
        })

        NCA:RegisterProp("Afterlife", {
            name = "Afterlife_Lounge",
            slots = { "Sofa_1", "Sofa_2" },
            pos = { -1466.2124023, 1013.9481201, 16.8999939, 1 },
            rot = { 0.0000000, 0.0000000, 0.9909127, 0.1345062 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Sofa_1" },
                    pos = { -1468.3620605, 1015.1879883, 16.8999939, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9218386, -0.3875740 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_2" },
                    pos = { -1468.5670166, 1013.4871216, 16.8999939, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7664611, 0.6422907 },
                },
            }
        })
    end
}
