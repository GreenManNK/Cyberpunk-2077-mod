return {
    name = "NCA Glen Apartment",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("Glen_Apartment")
        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Sofa",
            slots = { "Sofa_Seat_Left", "Sofa_Seat_Right" },
            pos = { -1520.2313232, -976.2456665, 86.7708588, 1 },
            rot = { 0.0000000, 0.0000000, -0.6863383, 0.7272825 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Left" },
                    pos = { -1520.6306152, -976.2687988, 86.7708588, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6863383, 0.7272825 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Right" },
                    pos = { -1519.2631836, -977.0783081, 86.7893219, 1 },
                    rot = { 0.0000000, 0.0000000, 0.0263361, 0.9996532 },
                },
            }
        })

        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Kitchen",
            slots = { "Bar", "Sink", "Stool_1", "Stool_2", "Pillar" },
            pos = { -1521.4226074, -981.3685913, 86.9649963, 1 },
            rot = { 0.0000000, 0.0000000, -0.9999906, -0.0043300 },
            interactions = {
                {
                    type = "stand_barkeeper", -- todo make stand lean table
                    slots = { "Bar" },
                    pos = { -1520.8559570, -983.6500854, 86.9400024, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7120495, -0.7021293 },
                },
                {
                    type = "stand_sink",
                    slots = { "Sink" },
                    pos = { -1522.7419434, -986.0479736, 86.9400024, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9999952, -0.0031033 },
                },
                {
                    type = "sit_barstool",
                    slots = { "Stool_1" },
                    pos = { -1522.1140137, -982.6350098, 86.9400024, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7198464, 0.6941335 },
                },
                {
                    type = "sit_barstool",
                    slots = { "Stool_2" },
                    pos = { -1522.0279541, -984.1630249, 86.9400024, 1 },
                    rot = { 0.0000000, 0.0000000, -0.6563540, 0.7544531 },
                },
                {
                    type = "stand_wall",
                    slots = { "Pillar" },
                    pos = { -1521.4239502, -980.8729858, 86.9770203, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9995793, 0.0290050 },
                },
            }
        })

        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Arcade",
            slots = { "Slot_1" },
            pos = { -1528.2143555, -978.2805786, 86.9700012, 1 },
            rot = { 0.0000000, 0.0000000, 0.7132381, 0.7009219 },
            interactions = {
                {
                    type = "play_arcade",
                    slots = { "Slot_1" },
                    pos = { -1528.7840576, -978.3309937, 86.9700012, 1 },
                    rot = { 0.0000000, 0.0000000, 0.7132381, 0.7009219 },
                },
            }
        })

        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Bookcorner",
            slots = { "Slot_1" },
            pos = { -1516.5749512, -969.1305542, 89.6018066, 1 },
            rot = { 0.0000000, 0.0000000, 0.6999015, 0.7142395 },
            interactions = {
                {
                    type = "lie_lounger",
                    slots = { "Slot_1" },
                    pos = { -1519.4060059, -969.0159912, 89.3669968, 1 },
                    rot = { 0.0000000, 0.0000000, -0.9702957, 0.2419219 },
                },
            }
        })
        
        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Railing",
            area = "Upstairs",
            slots = { "Slot_1", "Slot_2" },
            pos = { -1521.7257080, -980.2681274, 90.9964447, 1 },
            rot = { 0.0000000, 0.0000000, 0.9999994, -0.0010874 },
            interactions = {
                {
                    type = "stand_rail",
                    slots = { "Slot_1" },
                    pos = { -1525.0924072, -980.4210205, 90.9964447, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9999870, -0.0051018 },
                },
                {
                    type = "stand_rail",
                    slots = { "Slot_2" },
                    pos = { -1521.5389404, -976.9372559, 90.9964447, 1 },
                    rot = { 0.0000000, 0.0000000, 0.7117524, -0.7024304 },
                },
            }
        })

        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Bed",
            area = "Upstairs",
            slots = { "Slot_1" },
            pos = { -1525.6729736, -977.0148315, 91.6662827, 1 },
            rot = { 0.0000000, 0.0000000, 0.7174251, 0.6966357 },
            interactions = {
                {
                    type = "lie_sleep",
                    slots = { "Slot_1" },
                    pos = { -1524.0529785, -977.4790039, 90.9449997, 1 },
                    rot = { 0.0000000, 0.0000000, -0.0467162, 0.9989082 },
                },
            }
        })

        NCA:RegisterProp("Glen_Apartment", {
            name = "Glen_Apartment_Shower",
            area = "Upstairs",
            slots = { "Slot_1" },
            pos = { -1528.9935303, -971.7051392, 91.1762695, 1 },
            rot = { 0.0000000, 0.0000000, -0.0007992, 0.9999998 },
            interactions = {
                {
                    type = "stand_shower",
                    slots = { "Slot_1" },
                    pos = { -1528.9699707, -969.3170166, 91.0762787, 1 },
                    rot = { 0.0000000, 0.0000000, -0.0007992, 0.9999998 },
                },
            }
        })

        -- stairs
        NCA:RegisterPath("Glen_Apartment", {
            from = "", to = "Upstairs",
            nodes = {
                { -1528.9730225, -973.0300293, 86.9700012 },
                { -1528.8859863, -979.0162354, 90.9721222 },
            },
        })
        NCA:RegisterPath("Glen_Apartment", {
            from = "Upstairs", to = "",
            nodes = {
                { -1528.3260498, -979.0269775, 90.9699860 },
                { -1527.9940186, -973.0549927, 86.9700012 },
            },
        })
        
        NCA:Location():RegisterDistrictTrigger("Glen_Apartment", gamedataDistrict.Glen_Apartment)
    end
}
