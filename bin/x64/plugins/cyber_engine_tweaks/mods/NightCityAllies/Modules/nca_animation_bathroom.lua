return {
    name = "NCA Bathroom Animations",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterRoutine("stand_toilet", {
            tag = "man_stand_toilet",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            playback = "linear_randomized",
            animations = {
                { animation = "stand__2h_on_sides__01__to__homeless__stand__piss__01__turn0__01", duration = 5.9, group = "stand__2h_on_sides__01", nextGroup = "stand__homeless__piss__01" },
                { animation = "homeless__stand__piss__01", duration = 9.7333, group = "stand__homeless__piss__01" },
                { animation = "homeless__stand__piss__01__piss__01", duration = 5.3333, group = "stand__homeless__piss__01" },
                { animation = "homeless__stand__piss__01__shuffle__01", duration = 3.6, group = "stand__homeless__piss__01" },
                { animation = "homeless__stand__piss__01__look_left__01", duration = 5.4333, group = "stand__homeless__piss__01" },
                { animation = "homeless__stand__piss__01__to__stand__2h_on_sides__01__turn0__01", group = "stand__homeless__piss__01", nextGroup = "stand__2h_on_sides__01_2" },
            },
        })

        -- stand_shower
        NCA:RegisterRoutine("stand_shower", {
            tag = "stand_shower_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            effects = {
                entry = { { "change_outfit", "shower" } },
                exit = { { "change_outfit", "home" } },
            },
            animations = {
                { animation = "stand__rh_on_shower_wall__01", duration = 6.2667, group = "stand__rh_on_shower_wall__01" },
                { animation = "stand__rh_on_shower_wall__01__wash_face__01", duration = 6.5667, group = "stand__rh_on_shower_wall__01" },
                { animation = "stand__rh_on_shower_wall__01__wash_face__02", duration = 6.9, group = "stand__rh_on_shower_wall__01" },
            },
        })
    end
}
