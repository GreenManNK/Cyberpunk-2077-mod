local Cron = require("External/Cron")

local BlackwallUpload = {}

BlackwallUpload.range = 75.0
BlackwallUpload.showPlayerEffect = true
-- this doesn't do anything
local forcedCarryWoundedAnim = false

local function isDefined(value)
  return value ~= nil and IsDefined(value)
end

function BlackwallUpload.PlaySongbirdHandAnimation(player)
  player = player or Game.GetPlayer()
  if not isDefined(player) then return end

  local wasAlreadyUsingCarryWrapper = StatusEffectSystem.ObjectHasStatusEffect(
    player,
    "GameplayRestriction.BodyCarryingWoundedSoldier"
  )

  if not wasAlreadyUsingCarryWrapper then
    ---@diagnostic disable-next-line: undefined-field
    Game.SetAnimWrapperWeight(player, "carry_woundedSoldier", 1.0)
    forcedCarryWoundedAnim = true
  end

  local blackboard = player:GetBlackboard()
  local blackwallAnimDefs = GetAllBlackboardDefs().BlackwallDeathAnim
  local handGestureIndex = blackboard:GetInt(blackwallAnimDefs.handGestureAnimNumber)

  if handGestureIndex < 0 or handGestureIndex == 5 then
    handGestureIndex = 0
  end

  local animationEvent = AdHocAnimationEvent.new()
  animationEvent.animationIndex = handGestureIndex
  animationEvent.useBothHands = true
  animationEvent.unequipWeapon = true

  player:QueueEvent(animationEvent)
  blackboard:SetInt(blackwallAnimDefs.handGestureAnimNumber, handGestureIndex + 1)
end

local function getNearbyEnemyTargets(player, range, dismiss)
  local targetingSystem = Game.GetTargetingSystem()
  if not targetingSystem then return nil end

  local searchQuery = TSQ_EnemyNPC()
  searchQuery.maxDistance = dismiss and 15.0 or (range or BlackwallUpload.range)
  searchQuery.testedSet = dismiss and gameTargetingSet.Complete or gameTargetingSet.Visible
  ---@diagnostic disable-next-line: missing-parameter
  searchQuery.searchFilter = TSF_And(
    TSF_Not(gametargetingSystemSearchFilterMaskValue.Att_Friendly),
    TSF_Any(gametargetingSystemSearchFilterMaskValue.Sp_Aggressive),
    TSF_Any(gametargetingSystemSearchFilterMaskValue.St_Alive)
  )

  local success, parts = targetingSystem:GetTargetParts(player, searchQuery)
  if not success or parts == nil then return nil end

  return parts
end

local function canApplyBlackwallUpload(target)
  if not isDefined(target) then return false end

  local godModeSystem = Game.GetGodModeSystem()
  if not godModeSystem then return true end

  return not godModeSystem:HasGodMode(target:GetEntityID(), gameGodModeType.Invulnerable)
end

function BlackwallUpload.Execute(range, dismiss)
  dismiss = dismiss or false
  local player = Game.GetPlayer()
  if not isDefined(player) then return 0 end
  if not dismiss then
    BlackwallUpload.PlaySongbirdHandAnimation(player)
  end

  local targetParts = getNearbyEnemyTargets(player, range, dismiss)
  if targetParts == nil then return 0 end

  local affectedTargets = 0
  local playerEffectPlayed = false

  for _, targetPart in ipairs(targetParts) do
    ---@type GameObject
    ---@diagnostic disable-next-line: assign-type-mismatch
    local target = targetPart:GetComponent():GetEntity()

    if canApplyBlackwallUpload(target) then
      Cron.After(dismiss and 0.0 or 1.0, function()
        if isDefined(target) then
          StatusEffectHelper.ApplyStatusEffect(
            target,
            "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload",
            0.0
          )
        end

        if BlackwallUpload.showPlayerEffect and not playerEffectPlayed then
          ---@diagnostic disable-next-line: missing-parameter
          GameObjectEffectHelper.StartEffectEvent(player, "blackwall_use_force")
          playerEffectPlayed = true
        end
      end, true)

      affectedTargets = affectedTargets + 1
    end
  end

  return affectedTargets
end

BlackWallHackFX = BlackWallHackFX or {}
BlackWallHackFX.ExecuteBlackwallUpload = BlackwallUpload.Execute
BlackWallHackFX.BlackwallUpload = BlackwallUpload

return BlackwallUpload
