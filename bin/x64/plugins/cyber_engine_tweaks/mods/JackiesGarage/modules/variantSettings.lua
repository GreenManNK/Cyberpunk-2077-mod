-------------------------------------------------------------------------------------------------------------------------------
-- Variants settings listing by Akiway from CP2077 Modding Tools Discord.
--
-- To prevent errors, make sure that all variant names and setting names are unique accross all settings
--   refs can be shared accross settings
-------------------------------------------------------------------------------------------------------------------------------

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


local permanentVariantSettings = {
    -- Swap example that will not show up in menu settings
    -- 
    -- variant_setting_name_1 = {
    --     name = "setting_name_1",
    --     ref = "$/mod/my_mod/setting_1",
    --     variantTrue = "my_mod_variant_name_open",
    --     variantFalse = "my_mod_variant_name_close",
    --     state = false,
    --     
    --     showInMenu = false,
    --     type = "swap",
    --     isPermanent = true,
    -- },


    -- Swap example that will show up in menu settings
    -- 
    -- variant_setting_name_2 = {
    --     name = "setting_name_2",
    --     ref = "$/mod/my_mod/setting_2",
    --     variantTrue = "my_mod_variant_name_a",
    --     variantFalse = "my_mod_variant_name_b",
    --     state = true,
    -- 
    --     showInMenu = true,
    --     type = "swap",
    --     isPermanent = true,
    --     displayName = "My amazing setting"
    -- },

    -- Boolean example
    -- 
    -- variant_setting_name_3 = {
    --     name = "setting_name_3",
    --     ref = "$/mod/my_mod/setting_3",
    --     variant = "my_mod_variant_name",
    --     state = false,
    -- 
    --     showInMenu = false,
    --     type = "boolean",
    --     isPermanent = true,
    -- },

    -- Selector example
    -- 
    -- variant_setting_name_4 = {
    --     name = "setting_name_4",
    --     ref = "$/mod/my_mod/setting_4",
    --     variants = {
    --         [1] = "walls_yellow",
    --         [2] = "walls_teal",
    --         [3] = "walls_blue",
    --         [4] = "walls_orange",
    --         [5] = "walls_grey_dark"
    --     },
    --     state = 1,
    -- 
    --     showInMenu = true,
    --     type = "selector",
    --     isPermanent = true,
    --     variantLabels = {
    --         [1] = "Yellow",
    --         [2] = "Teal",
    --         [3] = "Blue",
    --         [4] = "Orange",
    --         [5] = "Dark grey"
    --     },
    --     displayName = "Living truck - outside walls color",
    --     settingValueName = "outside walls color"
    -- }
}

local variantSettings = {
}

return {
    permanentVariantSettings = permanentVariantSettings,
    variantSettings = variantSettings
}