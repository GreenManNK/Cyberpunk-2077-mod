local GameSettings = require("external/GameSettings")
local Cron = require("external/Cron")
local Util = require("external/Util")
local Lang = require("external/Lang")
local PosData = require("data/PosData")
local NpcData = require("data/NpcData")

function npcSpawn(rec, pos, ang)
	local entitySpec = DynamicEntitySpec.new()

	entitySpec.persistState = false
	entitySpec.persistSpawn = false
	entitySpec.alwaysSpawned = false
	entitySpec.spawnInView = true
	entitySpec.tags = { "TSU_NPC" }
	entitySpec.recordID = rec
	entitySpec.position = pos
	entitySpec.orientation =
		EulerAngles.ToQuat(EulerAngles.new(0, 0, ang))

	return Game.GetDynamicEntitySystem():CreateEntity(entitySpec)
end

function setNeutral(entity)
	if not entity then
		return
	end

	local currentRole = entity:GetAIControllerComponent():GetAIRole()

	if currentRole then
		currentRole:OnRoleCleared(entity)
	end

	local noRole = AINoRole.new()
	AIHumanComponent.SetCurrentRole(entity, noRole)

	local sensePreset = entity:GetRecord():SensePreset():GetID()
	SenseComponent.RequestPresetChange(entity, sensePreset, true)
	entity.isPlayerCompanionCached = false
	entity.isPlayerCompanionCachedTimeStamp = 0
end

function setAgainst(fromEnt, toEnt)
	local sensePreset = TweakDBInterface.GetReactionPresetRecord(
		TweakDBID.new("ReactionPresets.Ganger_Aggressive")
	)

	fromEnt:GetAttitudeAgent():SetAttitudeTowards(
		Game.GetPlayer():GetAttitudeAgent(),
		EAIAttitude.AIA_Friendly
	)
	fromEnt:GetAttitudeAgent():SetAttitudeTowards(
		toEnt:GetAttitudeAgent(),
		EAIAttitude.AIA_Hostile
	)
	fromEnt.reactionComponent:SetReactionPreset(sensePreset)
	fromEnt.reactionComponent:TriggerCombat(toEnt)

	toEnt:GetAttitudeAgent():SetAttitudeTowards(
		Game.GetPlayer():GetAttitudeAgent(),
		EAIAttitude.AIA_Friendly
	)
	toEnt:GetAttitudeAgent():SetAttitudeTowards(
		fromEnt:GetAttitudeAgent(),
		EAIAttitude.AIA_Hostile
	)
	toEnt.reactionComponent:TriggerCombat(fromEnt)
end

function setHostile(entity, boss, enemy)
	if not entity then
		return
	end

	local currentRole =
		entity:GetAIControllerComponent():GetAIRole()

	if currentRole then
		currentRole:OnRoleCleared(entity)
	end

	local AIRole = AIRole.new()
	entity:GetAIControllerComponent():SetAIRole(AIRole)
	entity:GetAIControllerComponent():OnAttach()

	local player = Game.GetPlayer()
	entity:GetAttitudeAgent():SetAttitudeGroup('Hostile')
	entity:GetAttitudeAgent():SetAttitudeTowards(
		player:GetAttitudeAgent(),
		EAIAttitude.AIA_Hostile
	)

	for _, val in pairs(boss) do
		if val.entity then
			val.entity:GetAttitudeAgent():SetAttitudeTowards(
				entity:GetAttitudeAgent(),
				EAIAttitude.AIA_Friendly
			)
		end
	end

	for _, val in pairs(enemy) do
		if val.entity then
			val.entity:GetAttitudeAgent():SetAttitudeTowards(
				entity:GetAttitudeAgent(),
				EAIAttitude.AIA_Friendly
			)
		end
	end

	entity.isPlayerCompanionCached = false
	entity.isPlayerCompanionCachedTimeStamp = 0

	local sensePreset = TweakDBInterface.GetReactionPresetRecord(
		TweakDBID.new("ReactionPresets.Ganger_Aggressive")
	)

	entity.reactionComponent:SetReactionPreset(sensePreset)
	entity.reactionComponent:TriggerCombat(player)
end

function setFriendly(entity)
	if not entity then
		return
	end

	local currentRole = entity:GetAIControllerComponent():GetAIRole()

	if currentRole then
		currentRole:OnRoleCleared(entity)
	end

	if entity.isPlayerCompanionCached then
		return
	end

	local player = Game.GetPlayer()
	entity:GetAttitudeAgent():SetAttitudeGroup(
		player:GetAttitudeAgent():GetAttitudeGroup()
	)
	entity:GetAttitudeAgent():SetAttitudeTowards(
		player:GetAttitudeAgent(),
		EAIAttitude.AIA_Friendly
	)

	entity.isPlayerCompanionCached = true
	entity.isPlayerCompanionCachedTimeStamp = 0
end

function setCompanion(entity, distance, companion)
	if not entity then
		return
	end

	local npcManager = entity.NPCManager
	npcManager:ScaleToPlayer()

	local currentRole = entity:GetAIControllerComponent():GetAIRole()

	if currentRole then
		currentRole:OnRoleCleared(entity)
	end

	if entity.isPlayerCompanionCached then
		return
	end

	local followerRole = AIFollowerRole.new()
	followerRole.followerRef = Game.CreateEntityReference("#player", {})

	entity:GetAIControllerComponent():SetAIRole(followerRole)
	entity:GetAIControllerComponent():OnAttach()

	local player = Game.GetPlayer()
	entity:GetAttitudeAgent():SetAttitudeGroup(
		player:GetAttitudeAgent():GetAttitudeGroup()
	)
	entity:GetAttitudeAgent():SetAttitudeTowards(
		player:GetAttitudeAgent(),
		EAIAttitude.AIA_Friendly
	)

	if companion then
		for _, val in pairs(companion) do
			val.entity:GetAttitudeAgent():SetAttitudeTowards(
				entity:GetAttitudeAgent(),
				EAIAttitude.AIA_Friendly
			)
		end
	end

	entity.isPlayerCompanionCached = true
	entity.isPlayerCompanionCachedTimeStamp = 0

	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowCloseMovePolicy.distance'),
		distance
	)
	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowCloseMovePolicy.avoidObstacleWithinTolerance'),
		true
	)
	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowCloseMovePolicy.ignoreCollisionAvoidance'),
		false
	)
	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowCloseMovePolicy.ignoreSpotReservation'),
		false
	)
	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowCloseMovePolicy.tolerance'),
		0.0
	)
	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowStayPolicy.distance'),
		distance
	)
	TweakDB:SetFlatNoUpdate(
		TweakDBID.new('FollowerActions.FollowGetOutOfWayMovePolicy.distance'),
		0.0
	)
	TweakDB:Update(TweakDBID.new('FollowerActions.FollowCloseMovePolicy'))
	TweakDB:Update(TweakDBID.new('FollowerActions.FollowStayPolicy'))
	TweakDB:Update(TweakDBID.new('FollowerActions.FollowGetOutOfWayMovePolicy'))
end

function setWeapon(entity, isPrimary)
	if not entity then
		return
	end

	local cmd = nil
	if isPrimary then
		cmd = NewObject("handle:AISwitchToPrimaryWeaponCommand")
	else
		cmd = NewObject("handle:AISwitchToSecondaryWeaponCommand")
	end

	cmd = cmd:Copy()
	entity:GetAIControllerComponent():SendCommand(cmd)
end

function setAnimation(entity, ent, name, comp, instant)
	if not entity or not name then
		return nil
	end

	local transform = entity:GetWorldTransform()
	local angle = entity:GetWorldOrientation():ToEulerAngles()

	angle.yaw = angle.yaw + 180
	transform:SetPosition(entity:GetWorldPosition())
	transform:SetOrientationEuler(EulerAngles.new(0, 0, angle.yaw))

	local entityID =
		WorldFunctionalTests.SpawnEntity(ent, transform, '')

	local handle = {
		entityID = entityID,
		entity = nil,
		disposed = false,
	}

	Cron.Every(0.2, {tick = 0}, function(timer)
		if handle.disposed then
			Cron.Halt(timer)
			return
		end

		timer.tick = timer.tick + 1
		local newEntity = nil

		if entityID then
			newEntity = Game.FindEntityByID(entityID)
		end

		if newEntity then
			handle.entity = newEntity
			Game.GetWorkspotSystem():PlayInDeviceSimple(
				newEntity, entity, false, comp, nil, nil, 0, 1, nil
			)
			Game.GetWorkspotSystem():SendJumpToAnimEnt(
				entity, name[math.random(1, #name)], instant
			)
			Cron.Halt(timer)
		elseif timer.tick >= 25 then
			Cron.Halt(timer)
		end
	end)

	return handle
end

function stopAnimation(entity, anims)
	if entity then
		pcall(function()
			Game.GetWorkspotSystem():StopInDevice(entity)
		end)
	end

	if not anims then
		return
	end

	if type(anims) == "table" then
		anims.disposed = true
		local spawned = anims.entity

		if not spawned and anims.entityID then
			pcall(function()
				spawned = Game.FindEntityByID(anims.entityID)
			end)
		end

		if spawned then
			pcall(function() exEntitySpawner.Despawn(spawned) end)
			pcall(function() spawned:Dispose() end)
		elseif anims.entityID then
			pcall(function()
				Game.GetDynamicEntitySystem():DeleteEntity(anims.entityID)
			end)
		end
		return
	end

	pcall(function() exEntitySpawner.Despawn(anims) end)
	pcall(function() anims:Dispose() end)
end

function moveToPosition(entity, positon, movetype, stealth)
	if not entity then
		return
	end

	local dest = NewObject('WorldPosition')
	dest:SetVector4(dest, positon)

	local positionSpec = NewObject('AIPositionSpec')
	positionSpec:SetWorldPosition(positionSpec, dest)

	local cmd = NewObject('handle:AIMoveToCommand')
	cmd.movementTarget = positionSpec
	cmd.rotateEntityTowardsFacingTarget = false
	cmd.ignoreNavigation = false
	cmd.desiredDistanceFromTarget = 2
	cmd.movementType = movetype or "Walk"
	cmd.finishWhenDestinationReached = true
	cmd.alwaysUseStealth = stealth or false
	entity:GetAIControllerComponent():SendCommand(cmd)
end

function talkToNPC(entity, vo, category, idle, upperBody)
	local stimComp = entity:GetStimReactionComponent()
	local animComp = entity:GetAnimationControllerComponent()

	if stimComp and animComp then
		local animFeat = NewObject("handle:AnimFeature_FacialReaction")
		animFeat.category = category or 3
		animFeat.idle = idle or 5
		stimComp:ActivateReactionLookAt(
			Game.GetPlayer(),
			false,
			1,
			upperBody or true,
			true
		)
		Game["gameObject::PlayVoiceOver;GameObjectCNameCNameFloatEntityIDBool"](
			entity,
			CName.new(vo or "greeting"),
			CName.new(""),
			1,
			entity:GetEntityID(),
			true
		)
		animComp:ApplyFeature(CName.new("FacialReaction"), animFeat)
	end
end

function scaleDamage(hitEvent, mult)
	local attackValues = hitEvent.attackComputed:GetAttackValues()

	for i, val in ipairs(attackValues) do
		attackValues[i] = val * mult
	end

	hitEvent.attackComputed:SetAttackValues(attackValues)
end

function getSkillProficiencyType(skill)
	local ret = nil

	if not skill then
		return ret
	end

	if skill == "Cool" then
		ret = gamedataProficiencyType.CoolSkill

	elseif skill == "Intelligence" then
		ret = gamedataProficiencyType.IntelligenceSkill

	elseif skill == "Reflexes" then
		ret = gamedataProficiencyType.ReflexesSkill

	elseif skill == "Strength" then
		ret = gamedataProficiencyType.StrengthSkill

	elseif skill == "TechnicalAbility" then
		ret = gamedataProficiencyType.TechnicalAbilitySkill

	elseif skill == "Espionage" then
		ret = gamedataProficiencyType.Espionage
	end

	return ret
end

return SPAWN
