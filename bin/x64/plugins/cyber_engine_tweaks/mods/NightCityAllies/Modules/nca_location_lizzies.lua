--
-- Lizzies location
--
return {
    name = "NCA Lizzies",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("Lizzies")
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_TopRoom_1", pos = { -1191.6678, 1572.5276, 22.915115 }, rot = { 0.0, 0.0, -0.92829186, -0.37185237 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Dancefloor_1", pos = { -1179.7267, 1559.9685, 22.915115 }, rot = { 0.0, 0.0, -0.2913707, -0.95661026 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Backroom_1", pos = { -1191.5793, 1590.7772, 22.915115 }, rot = { 0.0, 0.0, -0.9920929, 0.12550624 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Upper_1", pos = { -1186.0808, 1558.3203, 26.915115 }, rot = { 0.0, 0.0, 0.9480459, 0.31813374 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Upper_2", pos = { -1175.7552, 1553.8058, 26.915115 }, rot = { 0.0, 0.0, -0.32738128, -0.94489235 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Upper_3", pos = { -1189.2341, 1572.8992, 26.915115 }, rot = { 0.0, 0.0, 0.93282825, -0.3603213 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Upper_4", pos = { -1170.8561, 1575.5411, 26.915115 }, rot = { 0.0, 0.0, 0.85473007, 0.51907265 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Upper_5", pos = { -1195.886, 1561.9315, 26.915115 }, rot = { 0.0, 0.0, 0.98302275, -0.18348414 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Stairs_1", pos = { -1190.09, 1554.214, 23.715118 }, rot = { 0.0, 0.0, -0.08685609, -0.9962209 } })
        NCA:RegisterSpawn("Lizzies", { name = "Lizzies_Stairs_2", pos = { -1188.6521, 1557.5181, 23.715118 }, rot = { 0.0, 0.0, 0.6761411, 0.7367722 } })
        NCA:Location():RegisterLizziesTrigger("Lizzies")
        NCA:Spawn():RegisterAffiliationSpawnRule("Lizzies", "Factions.TheMox", 2.4)
        NCA:Spawn():RegisterNotAffiliationSpawnRule("Lizzies", "Factions.TheMox", 0.25)
        NCA:Spawn():RegisterAffiliationSpawnRule("Lizzies", "Factions.Maelstrom", 0.0)

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Dancefloor",
            slots = { "Dance_1", "Dance_2", "Wall" },
            pos = { -1185.4506836, 1562.8779297, 22.9151154, 1 },
            rot = { 0.0000000, 0.0000000, -0.2619951, 0.9650693 },
            interactions = {
                {
                    type = "dance",
                    slots = { "Dance_1" },
                    pos = { -1185.4506836, 1562.8779297, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, -0.2619951, 0.9650693 },
                },
                {
                    type = "dance",
                    slots = { "Dance_2" },
                    pos = { -1183.6042480, 1564.2546387, 22.9329758, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7897432, -0.6134375 },
                },
                {
                    type = "stand_wall",
                    slots = { "Wall" },
                    pos = { -1188.9129639, 1567.8959961, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9997070, 0.0242081 },
                },
            }
        })
        
        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Wall_Upper",
            slots = { "Slot_1" },
            pos = { -1195.5126953, 1561.0341797, 26.9151154, 1 },
            rot = { 0.0000000, 0.0000000, 0.7459069, -0.6660502 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Slot_1" },
                    pos = { -1196.2729492, 1561.0341797, 26.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, 0.7459069, -0.6660502 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Upper_Railing",
            slots = { "Slot_1", "Slot_2", "Slot_3" },
            pos = { -1170.7825928, 1564.0974121, 25.4197845, 1 },
            rot = { 0.0000000, 0.0000000, -0.7197884, 0.6941935 },
            interactions = {
                {
                    type = "stand_rail",
                    slots = { "Slot_1" },
                    pos = { -1190.6629639, 1564.5043945, 26.9430008, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7471837, 0.6646175 },
                },
                {
                    type = "stand_rail",
                    slots = { "Slot_2" },
                    pos = { -1190.3280029, 1567.8972168, 26.9422684, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7368883, 0.6760146 },
                },
                {
                    type = "stand_rail",
                    slots = { "Slot_3" },
                    pos = { -1189.1729736, 1572.0799561, 26.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9311005, 0.3647628 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_DJ_Booth",
            slots = { "Slot_1" },
            pos = { -1196.1569824, 1566.5494385, 29.5489025, 1 },
            rot = { 0.0000000, 0.0000000, 0.6604592, 0.7508619 },
            interactions = {
                {
                    type = "dance",
                    slots = { "Slot_1" },
                    pos = { -1169.2315674, 1567.8728027, 26.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9932618, 0.1158924 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Upper_Bathroom",
            slots = { "Toilet_1", "Toilet_2", "Sink" },
            pos = { -1185.1793213, 1592.7827148, 26.9351196, 1 },
            rot = { 0.0000000, 0.0000000, -0.3599530, -0.9329705 },
            interactions = {
                {
                    type = "stand_toilet",
                    slots = { "Toilet_2" },
                    pos = { -1186.3160400, 1594.2399902, 26.9351196, 1 },
                    rot = { 0.0000000, 0.0000000, 0.0583079, -0.9982986 },
                },
                {
                    type = "stand_toilet",
                    slots = { "Toilet_1" },
                    pos = { -1187.3010254, 1594.2850342, 26.9351196, 1 },
                    rot = { 0.0000000, 0.0000000, 0.0499427, -0.9987522 },
                },
                {
                    type = "stand_sink",
                    slots = { "Sink" },
                    pos = { -1187.0159912, 1592.4189453, 26.9501877, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6680573, -0.7441099 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Lower_Bathroom",
            slots = { "Slot_1" },
            pos = { -1169.6519775, 1588.9597168, 22.9151154, 1 },
            rot = { 0.0000000, 0.0000000, -0.9991102, -0.0421775 },
            interactions = {
                {
                    type = "stand_toilet",
                    slots = { "Slot_1" },
                    pos = { -1169.0169678, 1588.5600586, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9980187, -0.0629182 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Lower_Bathroom_2",
            slots = { "Slot_1", "Slot_2" },
            pos = { -1169.2740479, 1592.6687012, 22.9151154, 1 },
            rot = { 0.0000000, 0.0000000, -0.9991102, -0.0421775 },
            interactions = {
                {
                    type = "stand_toilet",
                    slots = { "Slot_1" },
                    pos = { -1168.7769775, 1591.5899658, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9980187, -0.0629182 },
                },
                {
                    type = "stand_sink",
                    slots = { "Slot_2" },
                    pos = { -1169.6600342, 1591.6159668, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9971229, -0.0758024 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Hallway",
            slots = { "Slot_1" },
            pos = { -1169.4190674, 1569.0570068, 22.9151154, 1 },
            rot = { 0.0000000, 0.0000000, -0.7459096, 0.6660473 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Slot_1" },
                    pos = { -1169.6290283, 1569.0570068, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7459096, 0.6660473 },
                },
            }
        })

        -- todo "unsafe"; NPCS teleport on this sofa and on the roof sometimes, spend some time testing. Roof has navmesh so max distance is prob the fix
        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Dresser_Room",
            slots = { "Sofa_1", "Sofa_2" },
            pos = { -1187.6844482, 1588.2373047, 22.9151173, 1 },
            rot = { 0.0000000, 0.0000000, 0.6482890, 0.7613944 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Sofa_2" },
                    pos = { -1185.3149414, 1588.7779541, 22.9151154, 1 },
                    rot = { 0.0000000, 0.0000000, 0.6482890, 0.7613944 },
                },
                {
                    type = "dance_chair",
                    slots = { "Sofa_2" },
                    pos = { -1185.2020264, 1589.9090576, 22.9151173, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6803722, -0.7328668 },
                },
                {
                    type = "lie_couch",
                    slots = { "Sofa_2", "Sofa_1" },
                    pos = { -1185.4050293, 1589.2750244, 22.9151173, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6683869, -0.7438138 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_2" },
                    pos = { -1185.1800537, 1590.2320557, 22.9151173, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6571465, -0.7537630 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Rooftop_Bench",
            slots = { "Slot_1", "Slot_2" },
            pos = { -1168.5975342, 1567.8288574, 31.3151169, 1 },
            rot = { 0.0000000, 0.0000000, 0.6824735, -0.7309104 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Slot_1" },
                    pos = { -1167.3859863, 1566.9995117, 31.3262024, 1 },
                    rot = { 0.0000000, 0.0000000, 0.7810084, 0.6245205 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Slot_2" },
                    pos = { -1167.3959961, 1568.4000244, 31.3262024, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6541173, -0.7563932 },
                },
            }
        })

        NCA:RegisterProp("Lizzies", {
            name = "Lizzies_Rooftop_Bench_2",
            slots = { "Slot_1", "Slot_2" },
            pos = { -1168.1055908, 1577.6041260, 31.3151093, 1 },
            rot = { 0.0000000, 0.0000000, 0.6824735, -0.7309104 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Slot_1" },
                    pos = { -1166.6309814, 1576.8850098, 31.3507957, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6566214, -0.7542204 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Slot_2" },
                    pos = { -1166.5670166, 1578.1304932, 31.3151093, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6541173, -0.7563932 },
                },
            }
        })
    end
}