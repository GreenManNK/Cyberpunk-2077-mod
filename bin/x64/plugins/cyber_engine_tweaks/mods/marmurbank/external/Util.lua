local Util = { version = '1.0.0' }

local deferredAlerts = {}
local deferredAlertKeys = {}
local nextDeferredAlertDelivery = 0
local MAX_DEFERRED_ALERTS = 24
local DEFERRED_ALERT_INTERVAL = 1.25

local function isMarmurJohnnySuppressed()
	local suppressed = false
	pcall(function()
		local questsSystem = Game.GetQuestsSystem()
		suppressed = questsSystem ~= nil
			and questsSystem:GetFactStr("marmur_mod_suppressed_johnny") > 0
	end)
	if suppressed then return true end

	pcall(function()
		local defs = Game.GetAllBlackboardDefs()
		if defs == nil or defs.Braindance == nil or defs.Braindance.IsActive == nil then return end
		local board = Game.GetBlackboardSystem():Get(defs.Braindance)
		suppressed = board ~= nil and board:GetBool(defs.Braindance.IsActive) == true
	end)
	if suppressed then return true end

	pcall(function()
		local player = Game.GetPlayer()
		suppressed = player ~= nil and player:IsJohnnyReplacer() == true
	end)
	return suppressed
end

local function deferredAlertKey(kind, title, text)
	return tostring(kind or "") .. "\31" .. tostring(title or "") .. "\31" .. tostring(text or "")
end

local function queueDeferredAlert(kind, title, text)
	if text == nil or tostring(text) == "" then return false end
	local key = deferredAlertKey(kind, title, text)
	if deferredAlertKeys[key] then return true end

	deferredAlerts[#deferredAlerts + 1] = {
		kind = kind,
		title = title,
		text = text,
		key = key,
	}
	deferredAlertKeys[key] = true

	while #deferredAlerts > MAX_DEFERRED_ALERTS do
		local removed = table.remove(deferredAlerts, 1)
		if removed and removed.key then deferredAlertKeys[removed.key] = nil end
	end
	return true
end

local function showShardNow(title, text)
	return pcall(function()
		local shardUIevent = NotifyShardRead.new()
		shardUIevent.title = title
		shardUIevent.text = text
		Game.GetUISystem():QueueEvent(shardUIevent)
	end) == true
end

local function showScreenMessageNow(text)
	return pcall(function()
		local message = SimpleScreenMessage.new()
		message.message = text
		message.isShown = true

		local blackboardDefs = Game.GetAllBlackboardDefs()
		local blackboardUI = Game.GetBlackboardSystem():Get(blackboardDefs.UI_Notifications)
		blackboardUI:SetVariant(
			blackboardDefs.UI_Notifications.OnscreenMessage,
			ToVariant(message),
			true
		)
	end) == true
end

function Util.printTrace(isTrace, log1, log2, log3)
	if not isTrace then
		return
	end

	if log3 then
		print(('TSU: %s, %s, %s'):format(log1, log2, log3))
	elseif log2 then
		print(('TSU: %s, %s'):format(log1, log2))
	else
		print(('TSU: %s'):format(log1))
	end
end

function Util.fileExists(filename)
	local f = io.open(filename, "r")

	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function Util.generateLockeyfile()
	local file = io.open("lockey.lua", "w")

	for i = 1, 99999 do
		local str = "LocKey#" .. i
		local lockey = GetLocalizedText(str)

		if lockey and lockey ~= "" then
			file:write(str .. "\t\t" .. lockey .. "\n")
		end
	end

	file:close()
end

function Util.getRandomNum(range)
	if not range or range == 0 then
		return {}
	end

	local rt = {}

	for i = 1, range do
		rt[i] = i
	end

	local ret = {}

	while true do
		local rn = math.random(1, range)

		if rt[rn] == rn then
			table.insert(ret, rn)
			rt[rn] = 0

			if #ret >= range then
				break
			end
		end
	end

	return ret
end

function Util.getPosDataFromText(text)
	local vals = {}

	for word in string.gmatch(text, '([^ ]+)') do
		table.insert(vals, word)
	end

	local px = tonumber(vals[1])
	local py = tonumber(vals[2])
	local pz = tonumber(vals[3])
	local pw = tonumber(vals[4])
	local ang = nil

	if #vals == 5 then
		ang = tonumber(vals[5])
	end

	local ent = { pos = Vector4.new(px, py, pz, pw), ang = ang }
	return ent
end

function Util.getTextFromPosData(position, angle)
	local text = string.format("%.3f", position.x)
		.. " " .. string.format("%.3f", position.y)
		.. " " .. string.format("%.3f", position.z)
		.. " " .. tostring(position.w)

	if angle then
		text = text	.. " " .. string.format("%.3f", angle.yaw)
	end

	return text
end

function Util.getAgainstPosData(distFromPlayer, distFromGround, rotation, updown, pitch)
	local playerAngles = GetSingleton('Quaternion'):ToEulerAngles(
		Game.GetPlayer():GetWorldOrientation()
	)
	local heading = Game.GetPlayer():GetWorldForward()
	local offsetDir = Vector3.new(
		heading.x * distFromPlayer,
		heading.y * distFromPlayer,
		heading.z
	)
	local spawnTransform = Game.GetPlayer():GetWorldTransform()
	local spawnPosition =
		GetSingleton('WorldPosition'):ToVector4(spawnTransform.Position)
	local mx = spawnPosition.x + offsetDir.x
	local my = spawnPosition.y + offsetDir.y
	local mz = spawnPosition.z + distFromGround
	local mw = spawnPosition.w
	local newPosition = Vector4.new(mx, my, mz - updown, mw)
	local myaw = playerAngles.yaw - rotation
	local newAngles = EulerAngles.new(pitch, 0, myaw)

	spawnTransform:SetPosition(spawnTransform, newPosition)
	spawnTransform:SetOrientationEuler(spawnTransform, newAngles)

	local enrty = {
		transform = spawnTransform,
		position = newPosition,
		angle = newAngles
	}

	return enrty
end

function Util.handlingMoney(operation, money)
	local ts = Game.GetTransactionSystem()
	local player = Game.GetPlayer()
	local tid = TweakDBID.new("Items.money")

	if operation == "check" then
		return ts:GetItemQuantity(player, ItemID.new(tid))
	elseif operation == "remove" then
		ts:RemoveItem(player, ItemID.new(tid), money)
	end

	return 0
end

function Util.readShardFirst(shardID)
	Game.GetQuestsSystem():SetFactStr(shardID .. "_showed", 1)
	Game.GetQuestsSystem():SetFactStr(shardID .. "_d", Game.GetTimeSystem():GetGameTime():Days())
	Game.GetQuestsSystem():SetFactStr(shardID .. "_h", Game.GetTimeSystem():GetGameTime():Hours())
	Game.GetQuestsSystem():SetFactStr(shardID .. "_m", Game.GetTimeSystem():GetGameTime():Minutes())
end

function Util.popUpShard(title, text)
	if isMarmurJohnnySuppressed() then
		return queueDeferredAlert("shard", title, text)
	end
	return showShardNow(title, text)
end

function Util.simpleScreenMessage(text)
	if isMarmurJohnnySuppressed() then
		return queueDeferredAlert("screen", "", text)
	end
	return showScreenMessageNow(text)
end

function Util.flushDeferredAlerts()
	if #deferredAlerts == 0 then return false end
	if isMarmurJohnnySuppressed() then return false end

	local now = tonumber(os.clock()) or 0
	if now > 0 and now < nextDeferredAlertDelivery then return false end

	local item = deferredAlerts[1]
	local delivered = false
	if item.kind == "shard" then
		delivered = showShardNow(item.title, item.text)
	else
		delivered = showScreenMessageNow(item.text)
	end
	if not delivered then return false end

	table.remove(deferredAlerts, 1)
	deferredAlertKeys[item.key] = nil
	nextDeferredAlertDelivery = now > 0 and (now + DEFERRED_ALERT_INTERVAL) or 0
	return true
end

function Util.clearDeferredAlerts()
	deferredAlerts = {}
	deferredAlertKeys = {}
	nextDeferredAlertDelivery = 0
end


function Util.formatNumber(num)
	local n = tonumber(num) or 0
	local sign = ""
	if n < 0 then
		sign = "-"
		n = math.abs(n)
	end
	local s = tostring(math.floor(n + 0.5))
	local out = ""
	local len = #s
	for i = 1, len do
		if i > 1 and (len - i + 1) % 3 == 0 then
			out = out .. ","
		end
		out = out .. s:sub(i, i)
	end
	return sign .. out
end

function Util.addToMapPin(mappinToAdd, type)
	Util.addToMapPinDB(
		"Mappins.DropPointDynamicMappin.possibleVariants",
		mappinToAdd
	)

	if type == "job" then
		Util.addToMapPinDB(
			"WorldMap.JobsFilterGroup.mappins",
			mappinToAdd
		)
	end

	if type == "service" then
		Util.addToMapPinDB(
		"WorldMap.AllServicePointsFilterGroup.mappins",
		mappinToAdd
		)
	end
end

function Util.addToMapPinDB(tweakDBToGet, mappinToAdd)
	local MapPinDB = TweakDB:GetFlat(tweakDBToGet)
	local ShouldAddToMapDB = true

	for _, MapPinDBEntry in pairs(MapPinDB) do 
		if MapPinDBEntry == TweakDBID.new(mappinToAdd) then
			ShouldAddToMapDB = false
		end
	end

	if ShouldAddToMapDB == true then
		table.insert(MapPinDB, TweakDBID.new(mappinToAdd))
	end

	TweakDB:SetFlat(tweakDBToGet, MapPinDB)
end

function Util.showMapPin(pos, var, client, caption)
	local newPos = Vector4.new(pos.x, pos.y, pos.z + 2.1, pos.w)
	local mappinData = MappinData.new()

	mappinData.mappinType =
		TweakDBID.new('Mappins.DefaultStaticMappin')
	mappinData.variant = var
	mappinData.visibleThroughWalls = true

	if client and caption then
		mappinData.debugCaption = "TSU_MarmurBank|" .. client .. "|" .. caption
	end

	local ret =
		Game.GetMappinSystem():RegisterMappin(mappinData, newPos)

	return ret
end

return Util
