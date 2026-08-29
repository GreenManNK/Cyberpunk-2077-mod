--Author: yakuzadeso
local weaponOverheating = false

HMGVariants = {
    "Items.Preset_HMG_Chopper",
    "Items.Preset_HMG_Default",
    "Items.Preset_HMG_Invisible",
    "Items.Preset_HMG_Military",
    "Items.Preset_HMG_Neon",
    "Items.Preset_HMG_Pimp",
    "Items.Preset_HMG_Sasquatch",
    "Items.Preset_HMG_turret_car_attach",
    "Items.w_special_flak",
}

HMGTags = {
    "Weapon",
    "RangedWeapon",
    "Preload",
    "Weapon",
    "Unique",
    "ForceDismember",
    "HMG",
    "PowerWeapon",
}

HMGattach = {
    "EquipmentGLP.HeavyFastFiringWeaponCloseRangeDamageMult",
}

registerForEvent("onInit", function()
    TweakDB:SetFlat("Items.Flak_Blueprint_inline0.childElements", {
        "Items.Power_AR_SMG_LMG_WeaponMod1Element",
        "Items.Power_AR_SMG_LMG_WeaponMod2Element",
        "Items.Power_AR_SMG_LMG_WeaponMod3Element",
        "Items.Power_AR_SMG_LMG_WeaponMod4Element",
    })

    TweakDB:SetFlat("Items.Base_HMG_Technical_Stats_inline5.value", -1.0)

    TweakDB:SetFlat("Items.Base_HMG_inline1.value", 0.05) --Equip -default 1.0

    TweakDB:SetFlat("Items.Base_HMG_inline2.value", 0.75) --Unequip -default 1.0

    TweakDB:SetFlat("Items.Base_HMG_Spread_Stats.statModifiers", {
        "Items.Base_Defender_Spread_Stats_inline0",
        "Items.Base_Defender_Spread_Stats_inline1",
        "Items.Base_Defender_Spread_Stats_inline2",
        "Items.Base_Defender_Spread_Stats_inline3",
        "Items.Base_Defender_Spread_Stats_inline4",
        "Items.Base_Defender_Spread_Stats_inline5",
        "Items.Base_Defender_Spread_Stats_inline6",
        "Items.Base_Defender_Spread_Stats_inline7",
        "Items.Base_Defender_Spread_Stats_inline8",
        "Items.Base_Defender_Spread_Stats_inline9",
        "Items.Base_Defender_Spread_Stats_inline10",
    })

    TweakDB:SetFlat("Items.Base_HMG_Recoil_Stats.statModifiers", {
        "Items.Base_Defender_Recoil_Stats_inline0",
        "Items.Base_Defender_Recoil_Stats_inline1",
        "Items.Base_Defender_Recoil_Stats_inline2",
        "Items.Base_Defender_Recoil_Stats_inline3",
        "Items.Base_Defender_Recoil_Stats_inline4",
        "Items.Base_Defender_Recoil_Stats_inline5",
        "Items.Base_Defender_Recoil_Stats_inline6",
        "Items.Base_Defender_Recoil_Stats_inline7",
        "Items.Base_Defender_Recoil_Stats_inline8",
        "Items.Base_Defender_Recoil_Stats_inline9",
        "Items.Base_Defender_Recoil_Stats_inline10",
        "Items.Base_Defender_Recoil_Stats_inline11",
        "Items.Base_Defender_Recoil_Stats_inline12",
    })

    TweakDB:SetFlat("Items.Base_HMG_RPG_Stats_inline0.value", 7)

    for i, v in ipairs(HMGVariants) do
        TweakDB:SetFlat(v .. ".ammo", "Ammo.RifleAmmo")
        TweakDB:SetFlat(v .. ".equipArea", "EquipmentArea.Weapon")
        TweakDB:SetFlat(v .. ".OnAttach", HMGattach)
        TweakDB:SetFlat(v .. ".tags", HMGTags)
    end

    Observe('WeaponObject', 'SendAmmoUpdateEvent;GameObjectWeaponObject', function(gameObject, weapon)
        local player = Game.GetPlayer()
        if GameObject.GetActiveWeapon(player) ~= nil then
            local equippedWeapon = GameObject.GetActiveWeapon(player)
            if Game.GetActiveWeapon(GetPlayer()):GetItemData():GetName().value == "w_militech_hmg" then
                if not Game.GetActiveWeapon(GetPlayer()):GetSharedData():GetBool(GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown) then
                    weaponOverheating = false
                end
                if Game.GetMagazineAmmoCount(equippedWeapon) <= 1 and
                    WeaponObject.HasAvailableAmmoInInventory(equippedWeapon) then
                    OverheatReload()
                end
            end
        end
    end)

    Observe('PlayerPuppet', 'OnAction', function(this, action, consumer)
        local player = Game.GetPlayer()
        if GameObject.GetActiveWeapon(player) ~= nil then
            local equippedWeapon = GameObject.GetActiveWeapon(player)
            if action:IsAction(action, 'Reload') and
                Game.GetActiveWeapon(GetPlayer()):GetItemData():GetName().value == "w_militech_hmg" and
                WeaponObject.HasAvailableAmmoInInventory(equippedWeapon) and
                Game.GetMagazineAmmoCount(equippedWeapon) < 200 and
                weaponOverheating == false then
                OverheatReload()
            end
            if action:IsAction(action, 'Reload') and
                Game.GetActiveWeapon(GetPlayer()):GetItemData():GetName().value == "w_militech_hmg" and
                WeaponObject.HasAvailableAmmoInInventory(equippedWeapon) and
                Game.GetMagazineAmmoCount(equippedWeapon) == 0 then
                OverheatReload()
            end
        end
    end)
end)

function OverheatReload()
    local player = Game.GetPlayer()
    local equippedWeapon = GameObject.GetActiveWeapon(player)
    weaponOverheating = true
    Game.ForceWeaponOverheat(equippedWeapon, player)
    GameObject.GetActiveWeapon(player).StartReload(equippedWeapon, 0)
    GameObject.GetActiveWeapon(player).StopReload(equippedWeapon, gameweaponReloadStatus.Standard)
end
