return {
    name = "NCA Synced Sitting Animations",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterRoutine("sit_sofa", {
            tag = "sit_sofa_cuddle_pm",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            partnerRig = "base\\characters\\entities\\player\\player_man_skeleton.rig",
            label = "Cuddle",
            icon = "ChoiceCaptionParts.None",
            freeCamera = true,
            partnerOffsetForward = -0.54,
            partnerOffsetRight = -0.41,
            partnerOffsetYaw = 115,
            animations = {
                { animation = "dirt__sit_chair_lean180__2h_on_lap__02", duration = 13.333, partnerAnimation = "player__sit_chair_lean0__rh_on_backrest__01", group = "judy_lies_on_v_lap" },
            },
        })
        NCA:RegisterRoutine("sit_table", {
            tag = "sit_table_kiss_pm",
            rig = "base\\characters\\base_entities\\woman_base\\woman_base.rig",
            partnerRig = "base\\characters\\entities\\player\\player_man_skeleton.rig",
            label = "Kiss",
            icon = "ChoiceCaptionParts.None",
            playback = "linear",
            partnerOffsetForward = 0.61,
            partnerOffsetYaw = 180,
            animations = {
                { animation = "synced__v_kiss_pool_table__01", duration = 8.5, partnerAnimation = "synced__v_kiss_pool_table__01", group = "v_kiss_pool_table" },
            },
        })
    end
}
