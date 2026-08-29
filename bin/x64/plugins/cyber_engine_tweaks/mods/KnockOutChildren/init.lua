KOC = {
	description = "Knock Out Children - Add-on to the MOD 'Beatable Brats'",
	version = "1.1"
}

-- Cron.lua from cp2077-cet-kit (https://github.com/psiberx/cp2077-cet-kit)
--	Copyright (c) 2021 psiberx
--	Released under the MIT license (https://opensource.org/licenses/mit-license.php)
Cron = require('External/Cron.lua')

function KOC:new()

	registerForEvent("onInit", function()
--		if Codeware then
--			print("Codeware is loaded.")
--		end

		-- Setup Observers to capture all hits
		ObserveAfter('ScriptedPuppet', 'OnHit', function(this, hitEvent)
			-- 'this' is the object that received the hit

			if hitEvent.attackData and hitEvent.attackData.instigator then
				if IsDefined(hitEvent.attackData.instigator) then
					-- 'hitEvent.attackData.instigator' is the object that hit(attack) someone

					if this:IsA('NPCPuppet') then
						-- some NPC received the hit
						if hitEvent.attackData.instigator:IsA('PlayerPuppet') or -- Player hit this NPC
						   hitEvent.attackData.instigator:IsA('NPCPuppet') then -- some other NPC hit this NPC
							if this:IsNPC() then
								local thisAppearance = tostring(this:GetCurrentAppearanceName()):match("%[ (%g+) -")
								-- There are 21 different appearance for citizen-children:
								--  citizenchildren_mc_average_boy_01 ,02 ,03, 04
								--  citizenchildren_mc_average_girl_01 ,02 ,03
								--  citizenchildren_mc_poor_boy_01 ,02 ,03, 04, 05
								--  citizenchildren_mc_poor_girl_01 ,02 ,03
								--  citizenchildren_mc_rich_boy_01 ,02 ,03
								--  citizenchildren_mc_rich_girl01 ,02 ,03
								--print("thisAppearance="..thisAppearance)
								if string.find(thisAppearance,"children") ~= nil then
									KOC:KnockoutChildren(this, thisAppearance)
								end
							end
						end
					end 
				end
			end
		end)
			
	end)

	registerForEvent("onUpdate", function(deltaTime)

		Cron.Update(deltaTime)  -- required for Cron to function

	end)

   return KOC
end

function KOC:KnockoutChildren(target, targetAppearance)

	target:Dispose()

	local targetEntityPath = "Character.ChildRich"  -- All characters of children use this entity

	local pos = target:GetWorldPosition()
	local heading = target:GetWorldForward()
	local angles = GetSingleton('Quaternion'):ToEulerAngles(target:GetWorldOrientation())
	--print("target position = "..tostring(pos))
	--print("target heading = "..tostring(heading))
	--print("target angles = "..tostring(angles))

	-- Spawning entities using "Codeware"
	local entitySpec = DynamicEntitySpec.new()
	entitySpec.recordID = TweakDBID.new(targetEntityPath)
	entitySpec.position = pos
	entitySpec.orientation = angles
	local newNpcEntityID = Game.GetDynamicEntitySystem():CreateEntity(entitySpec)

	Cron.Every(0.1, {tick = 1}, function(timer)
		-- ** Measures that were necessary when using Game.GetPreventionSpawnSystem():RequestSpawn in the previous version.
		-- ** Not sure if it's needed now.
		-- retry several times in Cron until "Game.FindEntityByID" returns a value
		-- (usually returns a value within one or a few times)
		local newNpcEntity = Game.FindEntityByID(newNpcEntityID)
		if newNpcEntity then
			--print("tick="..timer.tick)
			newNpcEntity:PrefetchAppearanceChange(targetAppearance)
			newNpcEntity:ScheduleAppearanceChange(targetAppearance)

--			Cron.After(0.1, function()
				newNpcEntity:Kill(newNpcEntity, false, false)
--			end)

			Cron.Halt(timer)
		else
			timer.tick = timer.tick + 1
			if timer.tick > 30 then
				--print("****(not found) tick="..timer.tick)
				Cron.Halt(timer)
			end
		end
	end)
end

return KOC:new()
