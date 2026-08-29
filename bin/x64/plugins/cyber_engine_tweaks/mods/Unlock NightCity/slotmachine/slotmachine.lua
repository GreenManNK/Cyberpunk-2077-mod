local SlotMachineManager = {}

local SlotMachines = {
	-- V Apartment
	vApartmentOutsideVendorMachine = { x = -1394, y = 1278, z = 123, spawnLoc = { x = -1394.4841, y = 1277.2742, z = 123.1824, w = 1.0 }, type = 'Special' },
}

local ss = Game.GetStatsSystem()
local ps = Game.GetPersistencySystem()
local lm = Game.GetLootManager()
local ts = Game.GetTransactionSystem()
local qs = Game.GetQuestsSystem()
local tsm = Game.GetTimeSystem()
local as = Game.GetActivityLogSystem()

lastTimeUsedSlot = 0

function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function generateRandomQuality(itemData, isSpecial)
	local newQuality = math.random(3, 4);

	local statObj = itemData:GetStatsObjectID() -- Get Item Stats Obj

	local itemQuality = ss:GetStatValue(statObj, 'Quality')
	
	ss:RemoveAllModifiers(statObj, 'Quality', true)
	
	local qualityMod = Game['gameRPGManager::CreateStatModifier;gamedataStatTypegameStatModifierTypeFloat']('Quality', 'Additive', newQuality)
	
	ss:AddSavedModifier(statObj, qualityMod);
end

function generateRandomItem(ItemsManager)
	local itemTypes = { "Weapons", "Clothes" }
	local randomTypeGeneration = math.random(1, 2)

	local itemID = nil

	if itemTypes[randomTypeGeneration] == "Weapons" then
		local listOfWeapons = ItemsManager.Weapons()
		itemID = listOfWeapons[math.random(1, #listOfWeapons)]
	else
		local listOfClothes = ItemsManager.Clothes()
		itemID = listOfClothes[math.random(1, #listOfClothes)]
	end

	local tdbid = TweakDBID.new(itemID)
	local item = ItemID.new(tdbid, math.random(100, 9999999999))
	return item
end

function getNextSlotUsableTime(slotCoolDownTime)
	local currentGameTime = tsm:GetGameTime()
	local coolDownDays = math.floor(slotCoolDownTime/1440)
	local days = currentGameTime:Days(currentGameTime) + coolDownDays
	local hours = currentGameTime:Hours(currentGameTime) + math.floor((slotCoolDownTime-(coolDownDays*1440))/60)
	local minutes = currentGameTime:Minutes(currentGameTime) + math.floor((slotCoolDownTime%60)+0.5)
	local seconds = currentGameTime:Seconds(currentGameTime)

	local newGameTime = currentGameTime:MakeGameTime(days, hours, minutes, seconds)

	return newGameTime:GetSeconds(newGameTime)
end


function SlotMachineManager.CheckSlotMachine(object, slotCoolDownTime, ItemsManager)

    if object:ToString() == 'VendingMachine' then 
        
        local objCoords = object:GetWorldPosition()

        local currentTime = tsm:GetGameTimeStamp()
        local lastTimeUsedSlot = qs:GetFactStr("lastTimeUsedSlot")

        for sMachine, sMachineData in pairs(SlotMachines) do

            match = sMachineData.x == round(objCoords.x) and sMachineData.y == round(objCoords.y)
            matchz = sMachineData.z == nil or sMachineData.z == round(objCoords.z)

            if match and matchz then

                if(slotCoolDownTime == 0 or currentTime > lastTimeUsedSlot) then
                    -- if(not object:IsActive()) then
                    -- 	ps:QueuePSDeviceEvent(object:GetDevicePS():ActionToggleON())
                    -- end
 
                    local item = generateRandomItem(ItemsManager) -- Generate Random Item

                    ts:GiveItem(object, item , 1) -- Give Item to slotMachine
 
                    local itemData = ts:GetItemData(object, item) -- Get Item Data

                    generateRandomQuality(itemData) -- Generate Random Quality

                    lm:SpawnItemDrop(object, item, ToVector4{ x = sMachineData.spawnLoc.x, y = sMachineData.spawnLoc.y, z = sMachineData.spawnLoc.z, w = 1.0 } , Game.GetPlayer():GetWorldOrientation())

                    qs:SetFactStr("lastTimeUsedSlot", getNextSlotUsableTime(slotCoolDownTime))

					Game.GetPlayer():SetWarningMessage("Slot Machine: Item Generated !")
                else
					Game.GetPlayer():SetWarningMessage("Slot Machine: Still In Cooldown !")
                end

                return true
            end

        end

    end

end

function SlotMachineManager.Log()
	print('[Unlock NightCity] SlotMachineManager Loaded')
end


return SlotMachineManager