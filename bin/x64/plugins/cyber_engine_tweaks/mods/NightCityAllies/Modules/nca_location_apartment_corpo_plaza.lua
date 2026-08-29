return {
    name = "NCA Corpo Plaza Apartment",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("CorpoPlaza_Apartment")

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Armchair",
            slots = { "Armchair_Seat" },
            pos = { -1602.7952881, 357.5891724, 48.6271744, 1 },
            rot = { 0.0000000, 0.0000000, 0.4216516, -0.9067580 },
            interactions = {
                {
                    type = "sit_armchair",
                    slots = { "Armchair_Seat" },
                    pos = { -1603.4410400, 357.5209961, 48.6769981, 1 },
                    rot = { 0.0000000, 0.0000000, -0.3731578, 0.9277679 },
                },
            }
        })

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Sofa",
            slots = { "Sofa_Seat_Left", "Sofa_Seat_Right" },
            pos = { -1600.6939697, 356.7329407, 48.6271744, 1 },
            rot = { 0.0000000, 0.0000000, -0.0155135, 0.9998797 },
            interactions = {
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Left" },
                    pos = { -1600.7064209, 356.1329956, 48.6271744, 1 },
                    rot = { 0.0000000, 0.0000000, -0.0155135, 0.9998797 },
                },
                {
                    type = "sit_sofa",
                    slots = { "Sofa_Seat_Right" },
                    pos = { -1602.1899414, 356.1700134, 48.6271744, 1 },
                    rot = { 0.0000000, 0.0000000, -0.0013772, 0.9999990 },
                },
            }
        })

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Wall",
            slots = { "Wall" },
            pos = { -1611.5300293, 354.1285706, 49.2000046, 1 },
            rot = { 0.0000000, 0.0000000, 0.9945927, -0.1038533 },
            interactions = {
                {
                    type = "stand_wall",
                    slots = { "Wall" },
                    pos = { -1610.9489746, 353.2470093, 49.2063293, 1 },
                    rot = { 0.0000000, 0.0000000, -0.2866696, 0.9580296 },
                },
            }
        })

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Kitchen",
            slots = { "Bar" },
            pos = { -1606.4116211, 350.6216125, 49.4000015, 1 },
            rot = { 0.0000000, 0.0000000, -0.0095872, -0.9999541 },
            interactions = {
                {
                    type = "stand_barkeeper",
                    slots = { "Bar" },
                    pos = { -1607.6899414, 350.8169861, 49.4000015, 1 },
                    rot = { 0.0000000, 0.0000000, -0.0261769, 0.9996573 },
                },
            }
        })
        
        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Desk",
            slots = { "Slot_1" },
            pos = { -1598.3037109, 357.8421936, 48.7996597, 1 },
            rot = { 0.0000000, 0.0000000, 0.8073752, -0.5900385 },
            interactions = {
                {
                    type = "sit_chair",
                    slots = { "Slot_1" },
                    pos = { -1598.6689453, 357.5910034, 48.6200027, 1 },
                    rot = { 0.0000000, 0.0000000, -0.2595018, 0.9657426 },
                },
            }
        })

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Shower",
            slots = { "Slot_1" },
            pos = { -1623.9757080, 353.0695801, 51.0144196, 1 },
            rot = { 0.0000000, 0.0000000, -0.7160546, -0.6980442 },
            interactions = {
                {
                    type = "stand_shower",
                    slots = { "Slot_1" },
                    pos = { -1623.5050049, 353.1430054, 49.2955627, 1 },
                    rot = { 0.0000000, 0.0000000, -0.7160546, -0.6980442 },
                },
            }
        })

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Table",
            slots = { "Sit_01" },
            pos = { -1603.4912109, 352.7720032, 49.2071762, 1 },
            rot = { 0.0000000, 0.0000000, -0.7488247, 0.6627682 },
            interactions = {
                {
                    type = "sit_table",
                    slots = { "Sit_01" },
                    pos = { -1603.0770264, 352.1785278, 49.2064896, 1 },
                    rot = { 0.0000000, 0.0000000, 0.4069200, 0.9134638 },
                },
            }
        })

        NCA:RegisterProp("CorpoPlaza_Apartment", {
            name = "CorpoPlaza_Apartment_Bed",
            slots = { "Bed" },
            pos = { -1614.7320557, 356.6577148, 49.2000046, 1 },
            rot = { 0.0000000, 0.0000000, 0.7275169, -0.6860898 },
            interactions = {
                {
                    type = "lie_sleep",
                    slots = { "Bed" },
                    pos = { -1614.6040039, 358.5969849, 49.0559998, 1 },
                    rot = { 0.0000000, 0.0000000, -0.5978840, 0.8015826 },
                },
            }
        })
        
        NCA:Location():RegisterDistrictTrigger("CorpoPlaza_Apartment", gamedataDistrict.CorpoPlaza_Apartment)
    end
}
