--
-- The "standing" set contains routines that need no interaction point, played wherever the companion happens to be.
--
return {
    name = "NCA Synced Standing Animations",
    author = "NCA",
    load = function(NCA)
        -- standing
        NCA:RegisterRoutine("standing", {
            tag = "kiss_pm",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            partnerRig = "base\\characters\\entities\\player\\player_man_skeleton.rig",
            label = "Kiss",
            icon = "ChoiceCaptionParts.None",
            playback = "linear",
            partnerOffsetForward = 0.75,
            partnerOffsetYaw = 180,
            effects = {
                exit = { { "love++" } },
            },
            animations = {
                { animation = "synced__lean_wall_female_kiss_player__01_female_average", duration = 6.3, partnerAnimation = "synced__lean_wall_female_kiss_player__01_man_player" },
            },
        })
        NCA:RegisterRoutine("standing", {
            tag = "talk_pm",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            partnerRig = "base\\characters\\entities\\player\\player_man_skeleton.rig",
            label = "Hold hand",
            icon = "ChoiceCaptionParts.None",
            freeCamera = true,
            partnerOffsetForward = 0.32,
            partnerOffsetRight = 0.21,
            partnerOffsetYaw = 154.5,
            effects = {
                exit = { { "love+" } },
            },
            animations = {
                { animation = "synced__player_stand_with_somi__talk__01_somi", duration = 9.8, partnerAnimation = "synced__player_stand_with_somi__talk__01_player" },
                { animation = "synced__player_stand_with_somi__idle__01_somi", duration = 5.0667, partnerAnimation = "synced__player_stand_with_somi__idle__01_player" },
            },
        })
        NCA:RegisterRoutine("standing", {
            tag = "talk_pw",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            partnerRig = "base\\characters\\entities\\player\\player_woman_skeleton.rig",
            label = "Hold hand",
            icon = "ChoiceCaptionParts.None",
            freeCamera = true,
            partnerOffsetForward = 0.32,
            partnerOffsetRight = 0.21,
            partnerOffsetYaw = 154.5,
            effects = {
                exit = { { "love+" } },
            },
            animations = {
                { animation = "synced__player_stand_with_somi__talk__01_somi", duration = 9.8, partnerAnimation = "synced__player_stand_with_somi__talk__01_player" },
                { animation = "synced__player_stand_with_somi__idle__01_somi", duration = 5.0667, partnerAnimation = "synced__player_stand_with_somi__idle__01_player" },
            },
        })
        NCA:RegisterRoutine("standing", {
            tag = "hug_pw",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            partnerRig = "base\\characters\\entities\\player\\player_woman_skeleton.rig",
            label = "Hug",
            icon = "ChoiceCaptionParts.None",
            freeCamera = true,
            partnerOffsetForward = 0.35,
            partnerOffsetRight = 0.025,
            partnerOffsetYaw = 180,
            effects = {
                exit = { { "love+" } },
            },
            animations = {
                { animation = "synced__v_holds_judy__01__judy", duration = 16.5, partnerAnimation = "synced__v_holds_judy__01__player", group = "v_holds_judy" },
                { animation = "synced__v_holds_judy__shuffle__01__judy", duration = 4.2333, partnerAnimation = "synced__v_holds_judy__shuffle__01__player", group = "v_holds_judy" },
                { animation = "synced__v_holds_judy__shuffle__02__judy", duration = 4.4, partnerAnimation = "synced__v_holds_judy__shuffle__02__player", group = "v_holds_judy" },
                { animation = "synced__v_holds_judy__01__hug__01__judy", duration = 6.8, partnerAnimation = "synced__v_holds_judy__01__hug__01__player", group = "v_holds_judy" },
                { animation = "synced__v_holds_judy__yes__01__judy", duration = 2.4667, partnerAnimation = "synced__v_holds_judy__yes__01__player", group = "v_holds_judy" },
                { animation = "synced__v_holds_judy__talk__02__judy", duration = 7.8333, partnerAnimation = "synced__v_holds_judy__talk__02__player", group = "v_holds_judy" },
            },
        })
    end
}
