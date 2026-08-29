return {
    name = "NCA Arcade Animations",
    author = "NCA",
    load = function(NCA)
        -- play_arcade
        NCA:RegisterRoutine("play_arcade", {
            tag = "play_arcade_woman_base",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            animations = {
                { animation = "stand__2h_on_game_machine__01", duration = 5.1667, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__01", duration = 8.1667, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__02", duration = 4.8, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__03", duration = 3.2667, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__04", duration = 5.5, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__05", duration = 3.2333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__06", duration = 2.3333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__07", duration = 6.8333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__08", duration = 7.2, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__dance__01", duration = 4.0333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__01", duration = 4, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__02", duration = 4.3333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__03", duration = 3.3, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__04", duration = 3.7, group = "stand__2h_on_game_machine__01" },
            },
        })
        NCA:RegisterRoutine("play_arcade", {
            tag = "play_arcade_man_base",
            rig = "base\\characters\\base_entities\\man_base\\man_base.rig",
            animations = {
                { animation = "stand__2h_on_game_machine__01", duration = 5.1667, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__01", duration = 8.1667, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__02", duration = 4.8, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__03", duration = 3.2667, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__04", duration = 5.5, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__05", duration = 3.2333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__06", duration = 2.3333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__07", duration = 6.8333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__play__08", duration = 7.2, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__dance__01", duration = 4.0333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__01", duration = 4, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__02", duration = 4.3333, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__03", duration = 3.3, group = "stand__2h_on_game_machine__01" },
                { animation = "stand__2h_on_game_machine__01__shuffle__04", duration = 3.7, group = "stand__2h_on_game_machine__01" },
            },
        })
    end
}
