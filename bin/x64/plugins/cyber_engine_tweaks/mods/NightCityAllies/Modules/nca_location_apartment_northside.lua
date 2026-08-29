return {
    name = "NCA Northside Apartment",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("Northside_Apartment")

        NCA:RegisterProp("Northside_Apartment", {
            name = "Northside_Apartment_Sofa",
            slots = { "Sofa_Seat_Left", "Sofa_Seat_Right" },
            pos = { -1506.0991211, 2230.0842285, 22.1999969, 1 },
            rot = { 0.0000000, 0.0000000, -0.5593557, 0.8289279 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Left" },
                    pos = { -1506.6099854, 2229.8750000, 22.1999969, 1 },
                    rot = { 0.0000000, 0.0000000, -0.5593557, 0.8289279 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Right" },
                    pos = { -1506.3050537, 2229.0429688, 22.1999969, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6109914, 0.7916374 },
                },
            }
        })

        NCA:RegisterProp("Northside_Apartment", {
            name = "Northside_Apartment_Desk",
            slots = { "Slot_1" },
            pos = { -1505.5939941, 2232.2504883, 22.2126389, 1 },
            rot = { 0.0000000, 0.0000000, 0.9975641, -0.0697560 },
            interactions = {
                {
                    type = "sit_chair",
                    slots = { "Slot_1" },
                    pos = { -1505.8940430, 2232.9599609, 22.2126389, 1 },
                    rot = { 0.0000000, 0.0000000, 0.7918637, -0.6106978 },
                },
            }
        })

        NCA:RegisterProp("Northside_Apartment", {
            name = "Northside_Apartment_Bathroom",
            slots = { "Shower" },
            pos = { -1507.4218750, 2226.3559570, 22.1999969, 1 },
            rot = { 0.0000000, 0.0000000, -0.8786504, -0.4774658 },
            interactions = {
                {
                    type = "stand_shower",
                    slots = { "Shower" },
                    pos = { -1508.5258789, 2227.3959961, 22.1619415, 1 },
                    rot = { 0.0000000, 0.0000000, -0.3298551, -0.9440316 },
                },
            }
        })

        NCA:RegisterProp("Northside_Apartment", {
            name = "Northside_Apartment_Arcade",
            slots = { "Slot_1" },
            pos = { -1504.5126953, 2231.6635742, 22.1999969, 1 },
            rot = { 0.0000000, 0.0000000, -0.8427531, 0.5383002 },
            interactions = {
                {
                    type = "play_arcade",
                    slots = { "Slot_1" },
                    pos = { -1503.8029785, 2232.0900879, 22.1999969, 1 },
                    rot = { 0.0000000, 0.0000000, -0.4716584, 0.8817814 },
                },
            }
        })
        
        NCA:Location():RegisterDistrictTrigger("Northside_Apartment", gamedataDistrict.Northside_Apartment)
    end
}
