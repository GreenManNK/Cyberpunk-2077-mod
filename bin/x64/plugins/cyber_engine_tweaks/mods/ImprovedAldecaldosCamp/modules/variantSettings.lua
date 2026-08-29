-- swap type
--      2 variants
--          variantTrue
--          variantFalse
--      labels :
--          displayName
--          settingValueName (optional)

-- boolean type 
--      single variant
--      labels :
--          displayName
--          settingValueName (optional)

-- selector type 
--      array of variants (number indexed)
--      labels :
--          displayName
--          variantLabels
--          settingValueName (optional)

local variantSettings = {
    {
        name = "v_tent/door",
        ref = "$/mod/iac/v_tent",
        variantTrue = "iac_v_tent_close",
        variantFalse = "iac_v_tent_open",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "v_tent/box",
        ref = "$/mod/iac/v_tent",
        variantTrue = "iac_v_tent_box_big",
        variantFalse = "iac_v_tent_box_normal",
        state = false,

        showInMenu = true,
        displayName = "v_tent/box-displayName",
        type = "swap"
    },
    {
        name = "showers/curtains_color",
        ref = "$/mod/iac/showers",
        variantTrue = "iac_curtains_white",
        variantFalse = "iac_curtains_transparent",
        state = true,

        showInMenu = true,
        type = "swap",
        displayName = "showers/immersive_curtains_opacity"
    },
    {
        name = "cassidy_tent/door",
        ref = "$/mod/iac/cassidy_tent/door",
        variantTrue = "iac_cassidy_tent_close",
        variantFalse = "iac_cassidy_tent_open",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "showers_tent/door",
        ref = "$/mod/iac/showers_tent/door",
        variantTrue = "iac_showers_tent_close",
        variantFalse = "iac_showers_tent_open",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "new_tent/door",
        ref = "$/mod/iac/new_tent/door",
        variantTrue = "iac_new_tent_close",
        variantFalse = "iac_new_tent_open",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "outside/tent_camo",
        ref = "$/mod/iac/outside",
        variantTrue = "iac_outside_tent_camo_night",
        variantFalse = "iac_outside_tent_camo_day",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "outside/tent_brown",
        ref = "$/mod/iac/outside",
        variantTrue = "iac_outside_tent_brown_night",
        variantFalse = "iac_outside_tent_brown_day",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "outside/hangar_basilisk",
        ref = "$/mod/iac/outside",
        variantTrue = "iac_outside_hangar_basilisk_night",
        variantFalse = "iac_outside_hangar_basilisk_day",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "outside/hangar",
        ref = "$/mod/iac/outside",
        variantTrue = "iac_outside_hangar_night",
        variantFalse = "iac_outside_hangar_day",
        state = false,

        showInMenu = false,
        type = "swap"
    },
    {
        name = "techie_truck/logo",
        ref = "$/mod/iac/techie_truck/logo_emissive",
        variantTrue = "iac_truck_logo_emissive_true",
        variantFalse = "iac_truck_logo_emissive_false",
        state = true,

        showInMenu = true,
        type = "swap",
        displayName = "techie_truck/logo-displayName"
    }
    --living_truck_outside_walls = {
    --    name = "living_truck/outside_walls",
    --    ref = "$/mod/iac/living_truck/outside_walls",
    --    variants = {
    --        [1] = "walls_yellow",
    --        [2] = "walls_teal",
    --        [3] = "walls_blue",
    --        [4] = "walls_orange",
    --        [5] = "walls_grey_dark"
    --    },
    --    state = 1,
    --
    --    showInMenu = true,
    --    type = "selector",
    --    variantLabels = {
    --        [1] = "living_truck/outside_walls-value-1",
    --        [2] = "living_truck/outside_walls-value-2",
    --        [3] = "living_truck/outside_walls-value-3",
    --        [4] = "living_truck/outside_walls-value-4",
    --        [5] = "living_truck/outside_walls-value-5"
    --    },
    --    displayName = "living_truck/outside_walls-displayName",
    --    settingValueName = "living_truck/outside_walls-settingValueName"
    --}
}

return variantSettings