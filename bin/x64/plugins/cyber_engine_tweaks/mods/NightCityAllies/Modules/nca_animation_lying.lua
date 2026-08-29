return {
    name = "NCA Lying Animations",
    author = "NCA",
    load = function(NCA)
        -- lie_bench
        NCA:RegisterRoutine("lie_bench", {
            tag = "lie_bench_man_base",
            blockReactions = true,
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "lie_bench_90__sleep__01", duration = 11.8667 },
                { animation = "lie_bench_90__sleep__01__flick__01", duration = 3.5667 },
                { animation = "lie_bench_90__sleep__01__flick__03", duration = 2.9 },
                { animation = "lie_bench_90__sleep__01__flick__04", duration = 3.7667 },
                { animation = "lie_bench_90__sleep__01__flick__05", duration = 3.3667 },
                { animation = "lie_bench_90__sleep__01__scratch__01", duration = 3.4 },
                { animation = "lie_bench_90__sleep__01__scratch__02", duration = 4.5667 },
                { animation = "lie_bench_90__sleep__01__shuffle__01", duration = 4.4333 },
                { animation = "lie_bench_90__sleep__01__shuffle__02", duration = 5.2667 },
            },
        })
        NCA:RegisterRoutine("lie_bench", {
            tag = "lie_bench_woman_base",
            blockReactions = true,
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "lie_bench_90__sleep__01", duration = 11.8667 },
                { animation = "lie_bench_90__sleep__01__flick__01", duration = 3.5667 },
                { animation = "lie_bench_90__sleep__01__flick__03", duration = 2.9 },
                { animation = "lie_bench_90__sleep__01__flick__04", duration = 3.7667 },
                { animation = "lie_bench_90__sleep__01__flick__05", duration = 3.3667 },
                { animation = "lie_bench_90__sleep__01__scratch__01", duration = 3.4 },
                { animation = "lie_bench_90__sleep__01__scratch__02", duration = 4.5667 },
                { animation = "lie_bench_90__sleep__01__shuffle__01", duration = 4.4333 },
                { animation = "lie_bench_90__sleep__01__shuffle__02", duration = 5.2667 },
                { animation = "lie_bench_90__sleep__01__shuffle__03", duration = 4.9667 },
                { animation = "lie_bench_90__sleep__01__shuffle__04", duration = 8 },
            },
        })

        -- lie_couch
        NCA:RegisterRoutine("lie_couch", {
            tag = "lie_couch_man_fat",
            rig = "base\\characters\\base_entities\\man_fat\\man_fat.rig",
            animations = {
                { animation = "lie_couch__2h_tablet__01", duration = 10.8333 },
                { animation = "lie_couch__2h_tablet__01__flick__01", duration = 5 },
                { animation = "lie_couch__2h_tablet__01__flick__02", duration = 4.2 },
                { animation = "lie_couch__2h_tablet__01__flick__03", duration = 3.3667 },
                { animation = "lie_couch__2h_tablet__01__flick__04", duration = 4.3 },
                { animation = "lie_couch__2h_tablet__01__flick__05", duration = 4.5667 },
                { animation = "lie_couch__2h_tablet__01__scratch__01", duration = 6 },
                { animation = "lie_couch__2h_tablet__01__shuffle__01", duration = 3.8333 },
                { animation = "lie_couch__2h_tablet__01__shuffle__02", duration = 5.1667 },
                { animation = "lie_couch__2h_tablet__01__shuffle__03", duration = 5.2333 },
            },
        })
        NCA:RegisterRoutine("lie_couch", {
            tag = "lie_couch_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "lie_couch__2h_tablet__01", duration = 10.8333 },
                { animation = "lie_couch__2h_tablet__01__flick__01", duration = 5 },
                { animation = "lie_couch__2h_tablet__01__flick__02", duration = 4.2 },
                { animation = "lie_couch__2h_tablet__01__flick__03", duration = 3.3667 },
                { animation = "lie_couch__2h_tablet__01__flick__04", duration = 4.3 },
                { animation = "lie_couch__2h_tablet__01__flick__05", duration = 4.5667 },
                { animation = "lie_couch__2h_tablet__01__scratch__01", duration = 6 },
                { animation = "lie_couch__2h_tablet__01__shuffle__01", duration = 3.8333 },
                { animation = "lie_couch__2h_tablet__01__shuffle__02", duration = 5.1667 },
                { animation = "lie_couch__2h_tablet__01__shuffle__03", duration = 5.2333 },
            },
        })
        NCA:RegisterRoutine("lie_couch", {
            tag = "lie_couch_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "lie_couch__2h_tablet__01", duration = 10.8333 },
                { animation = "lie_couch__2h_tablet__01__flick__01", duration = 5 },
                { animation = "lie_couch__2h_tablet__01__flick__02", duration = 4.2 },
                { animation = "lie_couch__2h_tablet__01__flick__03", duration = 3.3667 },
                { animation = "lie_couch__2h_tablet__01__flick__04", duration = 4.3 },
                { animation = "lie_couch__2h_tablet__01__flick__05", duration = 4.5667 },
                { animation = "lie_couch__2h_tablet__01__scratch__01", duration = 6 },
                { animation = "lie_couch__2h_tablet__01__shuffle__01", duration = 3.8333 },
                { animation = "lie_couch__2h_tablet__01__shuffle__02", duration = 5.1667 },
                { animation = "lie_couch__2h_tablet__01__shuffle__03", duration = 5.2333 },
            },
        })

        -- lie_lounger
        NCA:RegisterRoutine("lie_lounger", {
            tag = "lie_lounger_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "henry__lie_lounger_lean180__2h_back_head__01", duration = 25.9 },
                { animation = "henry__lie_lounger_lean180__2h_back_head__01__laugh__01", duration = 3.7 },
                { animation = "henry__lie_lounger_lean180__2h_back_head__01__taunt__02", duration = 2.3333 },
                { animation = "henry__lie_lounger_lean180__2h_back_head__01__scratch__01", duration = 5 },
                { animation = "henry__lie_lounger_lean180__2h_back_head__01__stretch_arms__02", duration = 7.3333 },
            },
        })

        -- lie_sleep
        NCA:RegisterRoutine("lie_sleep", {
            tag = "lie_sleep_man_base",
            blockReactions = true,
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            effects = {
                entry = { { "change_outfit", "bed" } },
            },
            animations = {
                { animation = "lie_sleep_bench_back_01", duration = 28.1 },
                { animation = "lie_sleep_bench_back_01__look_around__01", duration = 6.6333 },
                { animation = "lie_sleep_bench_back_01__shuffle__01", duration = 4.5 },
                { animation = "lie_sleep_bench_back_01__shuffle__02", duration = 4.4333 },
            },
        })
        NCA:RegisterRoutine("lie_sleep", {
            tag = "lie_sleep_woman_base",
            blockReactions = true,
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            effects = {
                entry = { { "change_outfit", "bed" } },
            },
            animations = {
                { animation = "lie_sleep_bench_back_01", duration = 21.2667 },
                { animation = "lie_sleep_bench_back_01__look_around__01", duration = 6.6333 },
                { animation = "lie_sleep_bench_back_01__shuffle__01", duration = 4.5 },
                { animation = "lie_sleep_bench_back_01__shuffle__02", duration = 4.4333 },
            },
        })
    end
}
