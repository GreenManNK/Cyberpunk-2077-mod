return {
    name = "NCA Standing Animations",
    author = "NCA",
    load = function(NCA)
        -- stand_table
        NCA:RegisterRoutine("stand_table", {
            tag = "stand_table_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "stand_table_lean0__2h_on_table__vendor__01", duration = 21.6667, group = "stand_table_lean0__2h_on_table__vendor__01" },
            },
        })
        NCA:RegisterRoutine("stand_table", {
            tag = "stand_table_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "stand_table_lean0__2h_on_table__tense__01", duration = 11.6667, group = "stand_table_lean0__2h_on_table__tense__01" },
                { animation = "stand_table_lean0__2h_on_table__tense__01__look_back__01", duration = 2.0667, group = "stand_table_lean0__2h_on_table__tense__01" },
                { animation = "stand_table_lean0__2h_on_table__tense__01__look_back__02", duration = 1.4333, group = "stand_table_lean0__2h_on_table__tense__01" },
            },
        })
        NCA:RegisterRoutine("stand_table", {
            tag = "stand_table_woman_base_2",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "panam__stand_table_lean0__2h_on_table__01", duration = 7.6333, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__shuffle__01", duration = 3.5333, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__shuffle__02", duration = 3.2333, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__shuffle__03", duration = 2.5, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__head_nod__01", duration = 1.3, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__look_right__02", duration = 2.7667, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__clean_table__01", duration = 6.7667, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__yes__subtle__01", duration = 2.4333, group = "stand_table_lean0__panam__2h_on_table__01" },
                { animation = "panam__stand_table_lean0__2h_on_table__01__yes__subtle__02", duration = 1.9, group = "stand_table_lean0__panam__2h_on_table__01" },
            },
        })
        NCA:RegisterRoutine("stand_table", {
            tag = "stand_table_man_base_2",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "player_johnny__stand_table_lean0__2h_on_table__01", duration = 7.9, group = "stand_table_lean0__player_johnny__2h_on_table__01" },
            },
        })

        -- stand_sink
        NCA:RegisterRoutine("stand_sink", {
            tag = "stand_sink_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "stand_sink_high__2h_front__01", duration = 8.1667 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__01", duration = 4.8333 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__02", duration = 4.4333 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__03", duration = 6.1667 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__04", duration = 5.7333 },
            },
        })
        NCA:RegisterRoutine("stand_sink", {
            tag = "stand_sink_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "stand_sink_high__2h_front__01", duration = 8.1667 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__01", duration = 4.8333 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__02", duration = 4.4333 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__03", duration = 6.1667 },
                { animation = "stand_sink_high__2h_front__01__wash_hands__04", duration = 5.7333 },
            },
        })

        -- stand_wall
        NCA:RegisterRoutine("stand_wall", {
            tag = "stand_wall_man_big",
            rig = "base\\characters\\base_entities\\man_big\\man_big.rig",
            animations = {
                { animation = "stand_wall_lean180__arms_crossed_front__01", duration = 18.7, group = "lean" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__nod__01", duration = 3, group = "lean" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__01", duration = 6.1, group = "lean" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__02", duration = 6.4667, group = "lean" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__03", duration = 4.4, group = "lean" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__yes__neutral__01", duration = 1.4333, group = "lean" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__to__stand_wall_lean180__2h_on_sides__01__turn0__01", duration = 5.3, group = "lean", nextGroup = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01", duration = 18, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__shuffle__01", duration = 6.3, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__01", duration = 3.8333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__02", duration = 4.8333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__03", duration = 6.7333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__to__stand_wall_lean180__arms_crossed_front__01__turn0__01", duration = 4.9333, group = "stand_wall_lean180__2h_on_sides__01", nextGroup = "lean" },
            },
        })
        NCA:RegisterRoutine("stand_wall", {
            tag = "stand_wall_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "stand_wall_lean180__2h_on_sides__01", duration = 18, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__rub_neck__01", duration = 5, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__sigh_heavy__01", duration = 3, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__sigh_heavy__02", duration = 3.5, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__01", duration = 3.8333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__02", duration = 4.8333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__03", duration = 6.7333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__stretch_shoulders__01", duration = 1.9, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__phone_check__nervous__01", duration = 6.0333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__phone_check__nervous__02", duration = 4.7333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__phone_check__nervous__03", duration = 6.1333, group = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__to__stand_wall_lean180__arms_crossed_front__01__turn0__01", duration = 4.4333, group = "stand_wall_lean180__2h_on_sides__01", nextGroup = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01", duration = 18.7, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__01", duration = 6.1, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__02", duration = 6.4667, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__03", duration = 4.4, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__04", duration = 2.2333, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__look_around__01", duration = 6.1, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__to__stand_wall_lean180__2h_on_sides__01__turn0__01", duration = 4.5667, group = "stand_wall_lean180__arms_crossed_front__01", nextGroup = "stand_wall_lean180__2h_on_sides__01" },
            },
        })
        NCA:RegisterRoutine("stand_wall", {
            tag = "stand_wall_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "stand_wall_lean180__2h_on_sides__01", duration = 18, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__rub_neck__01", duration = 5, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__sigh_heavy__01", duration = 3, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__sigh_heavy__02", duration = 3.5, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__01", duration = 3.8333, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__02", duration = 4.8333, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__clean_clothes__03", duration = 6.7333, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__stretch_shoulders__01", duration = 1.9, group = "stand" },
                { animation = "stand_wall_lean180__2h_on_sides__01__to__dirt__stand_wall_lean180__2h_on_sides__01__turn0__01", duration = 8.4333, group = "stand", nextGroup = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01", duration = 10, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__shuffle__01", duration = 7.0667, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__shuffle__02", duration = 6.5, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__shuffle__03", duration = 4, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__whatever__01", duration = 2.5, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__look_around__01", duration = 4.2667, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__look_around__02", duration = 3.6333, group = "stand_wall_lean180__dirt__2h_on_sides__01" },
                { animation = "dirt__stand_wall_lean180__2h_on_sides__01__to__stand_wall_lean180__2h_on_sides__01__turn0__01", duration = 7.8333, group = "stand_wall_lean180__dirt__2h_on_sides__01", nextGroup = "stand_wall_lean180__2h_on_sides__01" },
                { animation = "stand_wall_lean180__2h_on_sides__01__to__stand_wall_lean180__arms_crossed_front__01__turn0__01", duration = 4.9333, nextGroup = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01", duration = 18.7, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__01", duration = 6.1, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__02", duration = 6.4, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__03", duration = 4.4, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__shuffle__04", duration = 2.2333, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__look_around__01", duration = 6.1, group = "stand_wall_lean180__arms_crossed_front__01" },
                { animation = "stand_wall_lean180__arms_crossed_front__01__to__stand_wall_lean180__2h_on_sides__01__turn0__01", duration = 4.3, group = "stand_wall_lean180__arms_crossed_front__01", nextGroup = "stand" },
            },
        })

        -- stand_rail
        NCA:RegisterRoutine("stand_rail", {
            tag = "stand_rail_man_big",
            rig = "base\\characters\\base_entities\\man_big\\man_big.rig",
            animations = {
                { animation = "reed__stand_rail_lean0__2h_on_rail_wide__01", duration = 10, group = "stand_rail_lean0__reed__2h_on_rail_wide__01" },
                { animation = "reed__stand_rail_lean0__2h_on_rail_wide__01__shuffle__01", duration = 5.3, group = "stand_rail_lean0__reed__2h_on_rail_wide__01" },
            },
        })
        NCA:RegisterRoutine("stand_rail", {
            tag = "stand_rail_man_big_2",
            rig = "base\\characters\\base_entities\\man_big\\man_big.rig",
            animations = {
                { animation = "reed__stand_rail_lean0__2h_on_rail_wide__01", duration = 10, group = "stand_rail_lean0__reed__2h_on_rail_wide__01" },
                { animation = "reed__stand_rail_lean0__2h_on_rail_wide__01__shuffle__01", duration = 5.3, group = "stand_rail_lean0__reed__2h_on_rail_wide__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01", duration = 11.8, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__shuffle__01", duration = 3.3667, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__shuffle__02", duration = 6.6, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__involuntary__01", duration = 4.5, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_around__01", duration = 16.6, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_back_right__01", duration = 7.6667, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_phone__01__turn0__01", duration = 6, group = "stand_rail_lean0__2h_on_rail__01", nextGroup = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01", duration = 5, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__01", duration = 12.4667, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__02", duration = 7.3333, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__03", duration = 2.7, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__to__stand_rail_lean0__2h_on_rail__01__turn0__01", duration = 5.1667, group = "stand_rail_lean0__rh_phone__01", nextGroup = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_cigarette__01__turn0__01", duration = 9.5, group = "stand_rail_lean0__rh_phone__01", nextGroup = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01", duration = 11.8, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__puff__01", duration = 4.2333, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__puff__02", duration = 6.6, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__drop_ash__01", duration = 3.0667, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__drop_ash__02", duration = 5.3, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__to__stand_rail_lean0__2h_on_rail__01__turn0__01", duration = 4.1667, group = "stand_rail_lean0__rh_cigarette__01", nextGroup = "stand_rail_lean0__2h_on_rail__01" },
            },
        })
        NCA:RegisterRoutine("stand_rail", {
            tag = "stand_rail_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "stand_rail_lean0__2h_on_rail__01", duration = 11.8 },
                { animation = "stand_rail_lean0__2h_on_rail__01__cheer__01", duration = 8 },
                { animation = "stand_rail_lean0__2h_on_rail__01__cheer__02", duration = 7.8333 },
                { animation = "stand_rail_lean0__2h_on_rail__01__cheer__03", duration = 6.7333 },
                { animation = "stand_rail_lean0__2h_on_rail__01__shuffle__01", duration = 3.3667 },
                { animation = "stand_rail_lean0__2h_on_rail__01__shuffle__02", duration = 6.6 },
                { animation = "stand_rail_lean0__2h_on_rail__01__involuntary__01", duration = 4.5 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_around__02", duration = 6.3667 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_back_left__01", duration = 6.5 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_back_right__01", duration = 7.6667 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_around__01", group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_cigarette__01__turn0__01", duration = 9.5, group = "stand_rail_lean0__2h_on_rail__01", nextGroup = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01", duration = 11.8, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__puff__01", duration = 4.2333, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__puff__02", duration = 6.6, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__shuffle__01", duration = 9.2667, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__drop_ash__01", duration = 3.0667, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__drop_ash__02", duration = 5.3, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__to__stand_rail_lean0__2h_on_rail__01__turn0__01", duration = 4.1667, group = "stand_rail_lean0__rh_cigarette__01", nextGroup = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01", duration = 11.8, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_phone__01__turn0__01", duration = 6, group = "stand_rail_lean0__2h_on_rail__01", nextGroup = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01", duration = 5, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__01", duration = 12.4667, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__02", duration = 7.3333, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__03", duration = 2.7, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__to__stand_rail_lean0__2h_on_rail__01__turn0__01", duration = 5.1667, group = "stand_rail_lean0__rh_phone__01", nextGroup = "stand_rail_lean0__2h_on_rail__01" },
            },
        })
        NCA:RegisterRoutine("stand_rail", {
            tag = "stand_rail_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "stand_rail_lean0__2h_on_rail__01", duration = 11.8 },
                { animation = "stand_rail_lean0__2h_on_rail__01__talk__02", duration = 3.4 },
                { animation = "stand_rail_lean0__2h_on_rail__01__cheer__01", duration = 8 },
                { animation = "stand_rail_lean0__2h_on_rail__01__cheer__02", duration = 7.8333 },
                { animation = "stand_rail_lean0__2h_on_rail__01__cheer__03", duration = 6.7333 },
                { animation = "stand_rail_lean0__2h_on_rail__01__flick__01", duration = 1.5 },
                { animation = "stand_rail_lean0__2h_on_rail__01__flick__02", duration = 2.2333 },
                { animation = "stand_rail_lean0__2h_on_rail__01__flick__04", duration = 2.3333 },
                { animation = "stand_rail_lean0__2h_on_rail__01__shuffle__01", duration = 3.3667 },
                { animation = "stand_rail_lean0__2h_on_rail__01__shuffle__02", duration = 6.6 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_right__01", duration = 3.2 },
                { animation = "stand_rail_lean0__2h_on_rail__01__involuntary__01", duration = 4.5 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_around__01", duration = 16.6 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_back_left__01", duration = 6.5 },
                { animation = "stand_rail_lean0__2h_on_rail__01__look_back_right__01", duration = 7.6667 },
                { animation = "stand_rail_lean0__2h_on_rail__01__talk__aggressive__01", duration = 3.3667 },
                { animation = "alex__stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_cigarette__01__turn0__01", duration = 9.5, group = "stand_rail_lean0__2h_on_rail__01", nextGroup = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01", duration = 11.8, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__puff__01", duration = 4.2333, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__puff__02", duration = 6.6, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__shuffle__01", duration = 9.2667, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__drop_ash__01", duration = 3.0667, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__drop_ash__02", duration = 5.3, group = "stand_rail_lean0__rh_cigarette__01" },
                { animation = "stand_rail_lean0__rh_cigarette__01__to__stand_rail_lean0__2h_on_rail__01__turn0__01", duration = 4.1667, group = "stand_rail_lean0__rh_cigarette__01", nextGroup = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01", duration = 11.8, group = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_phone__01__turn0__01", duration = 6, group = "stand_rail_lean0__2h_on_rail__01", nextGroup = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01", duration = 16.6667, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__01", duration = 4.5, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__02", duration = 3.8333, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__talk_phone__03", duration = 2.7, group = "stand_rail_lean0__rh_phone__01" },
                { animation = "stand_rail_lean0__rh_phone__01__to__stand_rail_lean0__2h_on_rail__01__turn0__01", duration = 5.1667, group = "stand_rail_lean0__rh_phone__01", nextGroup = "stand_rail_lean0__2h_on_rail__01" },
                { animation = "stand_rail_lean0__2h_on_rail__01__to__stand_rail_lean0__rh_cigarette__01__turn0__01", duration = 9.5, group = "stand_rail_lean0__rh_phone__01", nextGroup = "stand_rail_lean0__rh_cigarette__01" },
            },
        })

        -- stand_barstool
        NCA:RegisterRoutine("stand_barstool", {
            tag = "stand_barstool_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "stand_barstool_lean0__2h_on_barstool__01", duration = 10.6 },
                { animation = "stand_barstool_lean0__2h_on_barstool__01__shuffle__01", duration = 1.9333 },
                { animation = "stand_barstool_lean0__2h_on_barstool__01__sexy_move__01", duration = 5.1667 },
                { animation = "stand_barstool_lean0__2h_on_barstool__01__shuffle_sexy__01", duration = 4.9 },
                { animation = "stand_barstool_lean0__2h_on_barstool__01__to__stand__arms_crossed_front__01__turn180__01", duration = 3.7, group = "_goes_elsewhere" },
            },
        })
    end
}
