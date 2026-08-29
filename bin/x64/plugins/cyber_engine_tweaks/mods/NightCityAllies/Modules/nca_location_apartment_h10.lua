return {
    name = "NCA H10 Apartment",
    author = "NCA",
    load = function(NCA)
        -- H10 Apartment
        NCA:RegisterLocation("H10_Apartment")
        NCA:RegisterProp("H10_Apartment", {
            name = "H10_Apartment_Sofa",
            slots = { "Sofa_Seat_Left", "Sofa_Seat_Middle", "Sofa_Seat_Right" },
            pos = { -1377.5170898, 1268.5056152, 122.6649017, 1 },
            rot = { 0.0000000, 0.0000000, 0.6813606, 0.7319480 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Middle" },
                    pos = { -1377.5551758, 1267.1009521, 122.6649017, 1 },
                    rot = { 0.0000000, 0.0000000, 0.3538019, 0.9353203 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Left" },
                    pos = { -1377.1181641, 1268.4770508, 122.6649017, 1 },
                    rot = { 0.0000000, 0.0000000, 0.6813606, 0.7319480 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Right" },
                    pos = { -1379.6990967, 1266.8698730, 122.6649017, 1 },
                    rot = { 0.0000000, 0.0000000, -0.1545374, 0.9879870 },
                },
                {
                    type = "lie_bench",
                    slots = { "Sofa_Seat_Left", "Sofa_Seat_Middle" },
                    pos = { -1377.2550049, 1268.0820313, 122.7350006, 1 },
                    rot = { 0.0000000, 0.0000000, 0.7621036, 0.6474551 },
                },
            }
        })

        NCA:RegisterProp("H10_Apartment", {
            name = "H10_Apartment_Window",
            slots = { "Window_Lean_Test" },
            pos = { -1377.0600586, 1272.2431641, 123.0648956, 1 },
            rot = { 0.0000000, 0.0000000, -0.7236905, 0.6901248 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Window_Lean_Test" },
                    pos = { -1376.1209717, 1272.1639404, 123.0648956, 1 },
                    rot = { 0.0000000, 0.0000000, 0.6731420, 0.7395133 },
                },
            }
        })

        NCA:RegisterProp("H10_Apartment", {
            name = "H10_Apartment_Office",
            slots = { "Wall", "Desk_Chair" },
            pos = { -1377.0600586, 1272.2431641, 123.0648956, 1 },
            rot = { 0.0000000, 0.0000000, -0.7236905, 0.6901248 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Wall" },
                    pos = { -1384.0620117, 1274.9479980, 123.0648956, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7236905, 0.6901248 },
                },
                {
                    type = "sit_chair",
                    slots = { "Desk_Chair" },
                    pos = { -1386.1600342, 1274.1529541, 123.0748978, 1 },
                    rot = { 0.0000000, 0.0000000, 0.9815605, 0.1911516 },
                },
            }
        })

        NCA:RegisterProp("H10_Apartment", {
            name = "H10_Apartment_Bed",
            slots = { "Slot_1" },
            pos = { -1380.0718994, 1272.2225342, 123.0648956, 1 },
            rot = { 0.0000000, 0.0000000, -0.7588194, -0.6513011 },
            interactions = {
                {
                    type = "lie_sleep",
                    slots = { "Slot_1" },
                    pos = { -1377.3459473, 1276.1500244, 123.0699997, 1 },
                    rot = { 0.0000000, 0.0000000, 1.0000000, 0.0000000 },
                },
            }
        })
        
        NCA:RegisterProp("H10_Apartment", {
            name = "H10_Apartment_Shower",
            area = "Bathroom",
            slots = { "Slot_1" },
            pos = { -1382.9188232, 1278.1304932, 123.1649017, 1 },
            rot = { 0.0000000, 0.0000000, -0.7342063, 0.6789265 },
            interactions = {
                {
                    type = "stand_shower",
                    slots = { "Slot_1" },
                    pos = { -1383.2690430, 1278.1209717, 123.1649017, 1 },
                    rot = { 0.0000000, 0.0000000, 0.6635324, 0.7481475 },
                },
            }
        })

        NCA:RegisterPath("H10_Apartment", {
            from = "", to = "Bathroom",
            nodes = {
                { -1381.7517090, 1273.9835205, 123.0648956 },
                { -1381.2496338, 1277.9450684, 123.1649017 },
            },
        })
        
        NCA:RegisterPath("H10_Apartment", {
            from = "Bathroom", to = "",
            nodes = {
                { -1381.2496338, 1277.9450684, 123.1649017 },
                { -1381.7517090, 1273.9835205, 123.0648956 },
            },
        })

        NCA:Location():RegisterDistrictTrigger("H10_Apartment", gamedataDistrict.LittleChina_VApartment)
    end
}
