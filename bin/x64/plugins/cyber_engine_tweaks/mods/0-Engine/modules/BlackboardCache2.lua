-- BlackboardCache2.lua - PlayerStateMachine state cache (CET-native blackboard polling)
-- Reads directly from the player's PSM blackboard each frame. No RedScript dependency.
-- 0.18.0: early-exit on no-change frames, pre-allocated event payload

local BlackboardCache = { version = "1.3.0-CET" }

local cached = {
    -- Raw PSM values (updated every frame from PlayerStateMachine blackboard)
    psm = {
        locomotion = 0,
        locomotionDetailed = 0,
        upperBody = 0,
        weapon = 0,
        vision = 0,
        swimming = 0,
        sceneTier = 0,
        takedown = 0,
        landing = 0,
        bodyCarrying = 0,
        carrying = 0,
        mountedToVehicle = false
    },

    -- Locomotion (derived from psm.locomotion + psm.locomotionDetailed)
    locomotion = {
        value = 0,              -- basic locomotion enum (backward-compat)
        detailedValue = 0,      -- detailed locomotion enum
        name = "Default",
        detailedName = "Default",
        isStanding = true,
        isCrouching = false,
        isSprinting = false,
        isSliding = false,
        isVaulting = false,
        isClimbing = false,
        isOnLadder = false,
        isFalling = false,
        isJumping = false,
        isDoubleJumping = false,
        isDodging = false,
        isKnockedDown = false,
        isHardLanding = false
    },

    -- Combat (derived from psm.upperBody + psm.weapon + psm.takedown)
    combat = {
        upperBodyValue = 0,
        weaponValue = 0,
        upperBodyName = "Default",
        weaponName = "Default",
        isAiming = false,
        isWeaponDrawn = false,
        isReloading = false,
        isWeaponHolstered = true,
        isTakingDown = false
    },

    -- Body (derived from psm.swimming + psm.carrying + psm.bodyCarrying)
    body = {
        isSwimming = false,
        isCarrying = false,
        isCarryingBody = false
    },

    -- Vision (derived from psm.vision)
    vision = {
        isScanning = false,
        isQuickHacking = false
    },

    -- Vehicle (all from blackboard polling)
    vehicle = {
        isMounted = false,
        vehicle = nil
    },

    -- Scene (derived from psm.sceneTier)
    scene = {
        tier = 0,
        name = "Undefined",
        isFullGameplay = true,
        isStagedGameplay = false,
        isLimitedGameplay = false,
        isCinematic = false
    },

    -- Legacy aliases (backward-compat)
    upperBody = { value = 0 },
    aim = { isAiming = false },
    sprint = { isSprinting = false },
    crouch = { isCrouching = false }
}

local playerBB = nil
local Events = nil
local PlayerStateDefs = nil

-- vehicle mount debounce removed in 0.18.2. The original phantom-remount problem on
-- autosaves is already prevented by PlayerRecreated no longer calling Reset(), and the
-- debounce was incompatible with the early-exit at the top of Update(): once an unmount
-- set psm.mountedToVehicle to match the new BB value, the next frame's early-exit hit
-- before the pending timer could advance, so the unmount event never fired.

-- pre-allocated table for MovementStateChanged event (avoids per-fire allocation)
local movementPayload = {
    locomotion = 0,
    locomotionDetailed = 0,
    upperBody = 0,
    isAiming = false,
    isSprinting = false,
    isCrouching = false
}

local function Trigger(eventName, value)
    if Events and Events[eventName] then
        Events[eventName]:trigger(value)
    end
end

local enumNameCache = {}
local function ResolveName(enumName, value)
    local key = enumName .. value
    local name = enumNameCache[key]
    if name then return name end

    local ok, result = pcall(EnumValueToName, enumName, value)
    if ok and result then
        name = tostring(result.value or result)
        enumNameCache[key] = name
        return name
    end
    return "Unknown"
end

local function DeriveLocomotion(detailed, basic)
    local loc = cached.locomotion

    loc.isStanding      = (basic == 1) or (detailed == 0)
    loc.isCrouching     = (basic == 2) or (detailed == 2) or (detailed == 3)
    loc.isSprinting     = (basic == 6) or (detailed == 4)
    loc.isSliding       = (detailed == 5) or (detailed == 6)
    loc.isVaulting      = (detailed == 9)
    loc.isClimbing      = (detailed == 8)
    loc.isOnLadder      = (detailed >= 10 and detailed <= 13)
    loc.isFalling       = (detailed == 14) or (detailed == 15) or (detailed == 16) or (detailed == 17)
    loc.isJumping       = (detailed == 18) or (detailed == 19) or (detailed == 20) or (detailed == 21)
    loc.isDoubleJumping = (detailed == 19)
    loc.isDodging       = (detailed == 7) or (detailed == 22)
    loc.isKnockedDown   = (detailed == 29) or (detailed == 31)
    loc.isHardLanding   = (detailed == 23) or (detailed == 24) or (detailed == 25)
                          or (detailed == 26) or (detailed == 27)
end

local function DeriveCombat(upperBody, weapon, takedown)
    local c = cached.combat

    c.isAiming         = (upperBody == 1) or (upperBody == 6)
    c.isWeaponDrawn    = (weapon == 1)
    c.isReloading      = (weapon == 2)
    c.isWeaponHolstered = (weapon == 0)
    c.isTakingDown     = (takedown > 0)
end

local function DeriveBody(swimming, carrying, bodyCarrying)
    cached.body.isSwimming     = (swimming > 0)
    cached.body.isCarrying     = (carrying > 0)
    cached.body.isCarryingBody = (bodyCarrying > 0)
end

local function DeriveScene(sceneTier)
    local s = cached.scene

    s.tier              = sceneTier
    s.isFullGameplay    = (sceneTier == 1)
    s.isStagedGameplay  = (sceneTier == 2)
    s.isLimitedGameplay = (sceneTier == 3)
    s.isCinematic       = (sceneTier >= 4)
end

local function SyncLegacy()
    cached.upperBody.value     = cached.psm.upperBody
    cached.aim.isAiming        = cached.combat.isAiming
    cached.sprint.isSprinting  = cached.locomotion.isSprinting
    cached.crouch.isCrouching  = cached.locomotion.isCrouching
end

function BlackboardCache.Update(player)
    if not playerBB then return end

    local psm = cached.psm

    -- Read all PSM values in one batch
    local locomotion         = playerBB:GetInt(PlayerStateDefs.Locomotion)
    local locomotionDetailed = playerBB:GetInt(PlayerStateDefs.LocomotionDetailed)
    local upperBody          = playerBB:GetInt(PlayerStateDefs.UpperBody)
    local weapon             = playerBB:GetInt(PlayerStateDefs.Weapon)
    local vision             = playerBB:GetInt(PlayerStateDefs.Vision)
    local swimming           = playerBB:GetInt(PlayerStateDefs.Swimming)
    local sceneTier          = playerBB:GetInt(PlayerStateDefs.SceneTier)
    local takedown           = playerBB:GetInt(PlayerStateDefs.Takedown)
    local landing            = playerBB:GetInt(PlayerStateDefs.Landing)
    local bodyCarrying       = playerBB:GetInt(PlayerStateDefs.BodyCarrying)
    local carrying           = playerBB:GetInt(PlayerStateDefs.Carrying)
    local mounted            = playerBB:GetBool(PlayerStateDefs.MountedToVehicle)

    -- early exit: if nothing changed since last read, skip all derivation and events.
    -- this is the CET-native equivalent of the RedScript version's generation counter.
    -- saves ~95% of frames from doing any work beyond the 12 blackboard reads above.
    if locomotion == psm.locomotion
        and locomotionDetailed == psm.locomotionDetailed
        and upperBody == psm.upperBody
        and weapon == psm.weapon
        and vision == psm.vision
        and swimming == psm.swimming
        and sceneTier == psm.sceneTier
        and takedown == psm.takedown
        and landing == psm.landing
        and bodyCarrying == psm.bodyCarrying
        and carrying == psm.carrying
        and mounted == psm.mountedToVehicle then
        return
    end

    local movementChanged = false
    local combatInputsChanged = false
    local bodyInputsChanged = false

    ------------------------------------------------
    -- Locomotion (basic)
    ------------------------------------------------
    if psm.locomotion ~= locomotion then
        psm.locomotion = locomotion
        cached.locomotion.value = locomotion
        cached.locomotion.name = ResolveName('gamePSMLocomotionStates', locomotion)
        movementChanged = true
        Trigger("LocomotionStateChanged", locomotion)
    end

    ------------------------------------------------
    -- Locomotion (detailed)
    ------------------------------------------------
    if psm.locomotionDetailed ~= locomotionDetailed then
        local prevDetailed = psm.locomotionDetailed
        psm.locomotionDetailed = locomotionDetailed
        cached.locomotion.detailedValue = locomotionDetailed
        cached.locomotion.detailedName = ResolveName('gamePSMDetailedLocomotionStates', locomotionDetailed)
        movementChanged = true
        Trigger("DetailedLocomotionChanged", locomotionDetailed)

        DeriveLocomotion(locomotionDetailed, locomotion)

        local prevSliding = (prevDetailed == 5) or (prevDetailed == 6)
        local nowSliding  = cached.locomotion.isSliding
        if prevSliding ~= nowSliding then
            Trigger("SlidingChanged", nowSliding)
        end

        local prevLadder = (prevDetailed >= 10 and prevDetailed <= 13)
        local nowLadder  = cached.locomotion.isOnLadder
        if prevLadder ~= nowLadder then
            Trigger("LadderChanged", nowLadder)
        end

        local prevFalling = (prevDetailed == 14) or (prevDetailed == 15) or (prevDetailed == 16) or (prevDetailed == 17)
        local nowFalling  = cached.locomotion.isFalling
        if prevFalling ~= nowFalling then
            Trigger("FallingChanged", nowFalling)
        end

        local prevKnockdown = (prevDetailed == 29) or (prevDetailed == 31)
        local nowKnockdown  = cached.locomotion.isKnockedDown
        if prevKnockdown ~= nowKnockdown then
            Trigger("KnockdownChanged", nowKnockdown)
        end

        local prevHardLand = (prevDetailed == 23) or (prevDetailed == 24) or (prevDetailed == 25)
                             or (prevDetailed == 26) or (prevDetailed == 27)
        local nowHardLand  = cached.locomotion.isHardLanding
        if prevHardLand ~= nowHardLand then
            Trigger("HardLandingChanged", nowHardLand)
        end
    else
        -- Locomotion basic may have changed without detailed changing
        DeriveLocomotion(locomotionDetailed, locomotion)
    end

    ------------------------------------------------
    -- Upper Body
    ------------------------------------------------
    if psm.upperBody ~= upperBody then
        psm.upperBody = upperBody
        cached.combat.upperBodyValue = upperBody
        cached.combat.upperBodyName = ResolveName('gamePSMUpperBodyStates', upperBody)
        movementChanged = true
        combatInputsChanged = true
        Trigger("UpperBodyStateChanged", upperBody)
    end

    ------------------------------------------------
    -- Weapon
    ------------------------------------------------
    if psm.weapon ~= weapon then
        psm.weapon = weapon
        cached.combat.weaponValue = weapon
        cached.combat.weaponName = ResolveName('gamePSMWeaponStates', weapon)
        combatInputsChanged = true
        Trigger("WeaponStateChanged", weapon)
    end

    ------------------------------------------------
    -- Vision
    ------------------------------------------------
    if psm.vision ~= vision then
        psm.vision = vision
        cached.vision.isScanning = (vision >= 1)
        cached.vision.isQuickHacking = (vision == 2)
        Trigger("VisionStateChanged", cached.vision.isScanning)
    end

    ------------------------------------------------
    -- Swimming
    ------------------------------------------------
    if psm.swimming ~= swimming then
        local wasSwimming = (psm.swimming > 0)
        psm.swimming = swimming
        cached.body.isSwimming = (swimming > 0)
        bodyInputsChanged = true
        if wasSwimming ~= cached.body.isSwimming then
            Trigger("SwimmingChanged", cached.body.isSwimming)
        end
    end

    ------------------------------------------------
    -- Scene Tier
    ------------------------------------------------
    if psm.sceneTier ~= sceneTier then
        psm.sceneTier = sceneTier
        DeriveScene(sceneTier)
        cached.scene.name = ResolveName('gamePSMSceneTier', sceneTier)
        Trigger("SceneTierChanged", sceneTier)
    end

    ------------------------------------------------
    -- Takedown
    ------------------------------------------------
    if psm.takedown ~= takedown then
        local wasTaking = (psm.takedown > 0)
        psm.takedown = takedown
        cached.combat.isTakingDown = (takedown > 0)
        combatInputsChanged = true
        if wasTaking ~= cached.combat.isTakingDown then
            Trigger("TakedownChanged", cached.combat.isTakingDown)
        end
    end

    ------------------------------------------------
    -- Landing
    ------------------------------------------------
    if psm.landing ~= landing then
        psm.landing = landing
        Trigger("LandingChanged", landing)
    end

    ------------------------------------------------
    -- Carrying
    ------------------------------------------------
    if psm.carrying ~= carrying then
        local wasCarrying = (psm.carrying > 0)
        psm.carrying = carrying
        cached.body.isCarrying = (carrying > 0)
        bodyInputsChanged = true
        if wasCarrying ~= cached.body.isCarrying then
            Trigger("CarryingChanged", cached.body.isCarrying)
        end
    end

    ------------------------------------------------
    -- Body Carrying
    ------------------------------------------------
    if psm.bodyCarrying ~= bodyCarrying then
        local wasCarryingBody = (psm.bodyCarrying > 0)
        psm.bodyCarrying = bodyCarrying
        cached.body.isCarryingBody = (bodyCarrying > 0)
        bodyInputsChanged = true
        if wasCarryingBody ~= cached.body.isCarryingBody then
            Trigger("BodyCarryingChanged", cached.body.isCarryingBody)
        end
    end

    ------------------------------------------------
    -- Mounted to Vehicle
    ------------------------------------------------
    if psm.mountedToVehicle ~= mounted then
        psm.mountedToVehicle = mounted
        cached.vehicle.isMounted = mounted
        if mounted then
            local ok, veh = pcall(Game['GetMountedVehicle;GameObject'], player)
            cached.vehicle.vehicle = ok and veh or nil
            Trigger("VehicleMount", cached.vehicle.vehicle)
        else
            cached.vehicle.vehicle = nil
            Trigger("VehicleUnmount")
        end
        Trigger("MountedToVehicleChanged", mounted)
        Trigger("VehicleStateChanged", mounted)
    end

    ------------------------------------------------
    -- Derive combat flags (only when inputs changed)
    ------------------------------------------------
    if combatInputsChanged then
        DeriveCombat(upperBody, weapon, takedown)
    end

    ------------------------------------------------
    -- Derive body flags (only when inputs changed)
    ------------------------------------------------
    if bodyInputsChanged then
        DeriveBody(swimming, carrying, bodyCarrying)
    end

    ------------------------------------------------
    -- Derived movement flag events (aiming, sprinting, crouching)
    ------------------------------------------------
    local aiming = cached.combat.isAiming
    if cached.aim.isAiming ~= aiming then
        movementChanged = true
        Trigger("AimStateChanged", aiming)
    end

    local sprinting = cached.locomotion.isSprinting
    if cached.sprint.isSprinting ~= sprinting then
        movementChanged = true
        Trigger("SprintStateChanged", sprinting)
    end

    local crouching = cached.locomotion.isCrouching
    if cached.crouch.isCrouching ~= crouching then
        movementChanged = true
        Trigger("CrouchStateChanged", crouching)
    end

    ------------------------------------------------
    -- Sync legacy aliases
    ------------------------------------------------
    SyncLegacy()

    ------------------------------------------------
    -- Composite movement event
    ------------------------------------------------
    if movementChanged then
        movementPayload.locomotion = locomotion
        movementPayload.locomotionDetailed = locomotionDetailed
        movementPayload.upperBody = upperBody
        movementPayload.isAiming = cached.combat.isAiming
        movementPayload.isSprinting = cached.locomotion.isSprinting
        movementPayload.isCrouching = cached.locomotion.isCrouching
        Trigger("MovementStateChanged", movementPayload)
    end
end

function BlackboardCache.Init(events)
    Events = events
    PlayerStateDefs = GetAllBlackboardDefs().PlayerStateMachine
end

function BlackboardCache.Attach(player)
    local bbSystem = Game.GetBlackboardSystem()

    playerBB = bbSystem:GetLocalInstanced(
        player:GetEntityID(),
        PlayerStateDefs
    )
end

function BlackboardCache.Detach()
    playerBB = nil
end

function BlackboardCache.Reset()
    playerBB = nil

    cached.psm.locomotion = 0
    cached.psm.locomotionDetailed = 0
    cached.psm.upperBody = 0
    cached.psm.weapon = 0
    cached.psm.vision = 0
    cached.psm.swimming = 0
    cached.psm.sceneTier = 0
    cached.psm.takedown = 0
    cached.psm.landing = 0
    cached.psm.bodyCarrying = 0
    cached.psm.carrying = 0
    cached.psm.mountedToVehicle = false

    cached.locomotion.value = 0
    cached.locomotion.detailedValue = 0
    cached.locomotion.name = "Default"
    cached.locomotion.detailedName = "Default"
    cached.locomotion.isStanding = true
    cached.locomotion.isCrouching = false
    cached.locomotion.isSprinting = false
    cached.locomotion.isSliding = false
    cached.locomotion.isVaulting = false
    cached.locomotion.isClimbing = false
    cached.locomotion.isOnLadder = false
    cached.locomotion.isFalling = false
    cached.locomotion.isJumping = false
    cached.locomotion.isDoubleJumping = false
    cached.locomotion.isDodging = false
    cached.locomotion.isKnockedDown = false
    cached.locomotion.isHardLanding = false

    cached.combat.upperBodyValue = 0
    cached.combat.weaponValue = 0
    cached.combat.upperBodyName = "Default"
    cached.combat.weaponName = "Default"
    cached.combat.isAiming = false
    cached.combat.isWeaponDrawn = false
    cached.combat.isReloading = false
    cached.combat.isWeaponHolstered = true
    cached.combat.isTakingDown = false

    cached.body.isSwimming = false
    cached.body.isCarrying = false
    cached.body.isCarryingBody = false

    cached.vision.isScanning = false
    cached.vision.isQuickHacking = false

    cached.vehicle.isMounted = false
    cached.vehicle.vehicle = nil

    cached.scene.tier = 0
    cached.scene.name = "Undefined"
    cached.scene.isFullGameplay = true
    cached.scene.isStagedGameplay = false
    cached.scene.isLimitedGameplay = false
    cached.scene.isCinematic = false

    cached.upperBody.value = 0
    cached.aim.isAiming = false
    cached.sprint.isSprinting = false
    cached.crouch.isCrouching = false
end

---@return table
function BlackboardCache.Get()
    return cached
end

return BlackboardCache
