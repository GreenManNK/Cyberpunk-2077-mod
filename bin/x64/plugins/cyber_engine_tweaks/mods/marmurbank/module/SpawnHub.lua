local GameSettings = require("external/GameSettings")
local Cron = require("external/Cron")
local Util = require("external/Util")
local Lang = require("external/Lang")
local PosData = require("data/PosData")
local NpcData = require("data/NpcData")

function SPAWN:showSubTitle(text, size, vert, autohide)
	if self.verval_text == text then
		return
	end

	self.verval_text = text
	self.verval_size = size
	self.verval_vert = vert

	if autohide then
		self.verval_time = os.clock()
	else
		self.verval_time = 0
	end
end

function SPAWN:checkSubTitle()
	if self.verval_size == 0 then
		self.subTitle.hudText:SetVisible(false)
		return
	end

	if self.verval_text then
		if self.verval_time == 0
			or (os.clock() - self.verval_time) <= 3 then
			if self.verval_vert == "Center" then
				self.subTitle.hudText:SetVerticalAlignment(textVerticalAlignment.Center)
			end

			pcall(function() self.subTitle.hudText:SetFontFamily(Lang.getFontFamily()) end)
			pcall(function() self.subTitle.hudText:SetFontStyle(Lang.getFontStyle()) end)
			self.subTitle.hudText:SetFontSize(self.verval_size)
			self.subTitle.hudText:SetText(self.verval_text)
			self.subTitle.hudText:SetVisible(true)
		else
			self.verval_text = nil
			self.verval_size = 55
			self.verval_time = nil
			self.subTitle.hudText:SetVerticalAlignment(textVerticalAlignment.Top)
			self.subTitle.hudText:SetVisible(false)
		end
	else
		self.subTitle.hudText:SetVerticalAlignment(textVerticalAlignment.Top)
		self.subTitle.hudText:SetVisible(false)
	end
end

function SPAWN:showHub(i)
	local hubId = "banking"
	local locationType = "banker"

	if self.hubId and self.hubId == hubId then
		return
	end

	if self.hub then
		self:hideHub(false)
	end

	if self.hubHide then
		return
	end

	if self.friendList[i].distance > 3 then
		return
	end

	self:showSubTitle(
		self.BANK:getText(locationType),
		self.atmFontSize,
		"Center"
	)

	local choices = {}
	local message = self.BANK:getMenu(locationType)

	for menu, val in ipairs(message) do
		local choiceAction = self.interactionUI.createChoice(
			val.text,
			TweakDBInterface.GetChoiceCaptionIconPartRecord(
				"ChoiceCaptionParts.OpenVendorIcon"
			),
			val.type
		)

		table.insert(choices, choiceAction)

		self.interactionUI.callbacks[menu] = function()
			if val.type ~= gameinteractionsChoiceType.QuestImportant then
				return
			end

			if val.menu == "hours" then
				self.BANK:doMenu(val.menu, menu, locationType)
				self:hideHub(true)
				return
			end

			self.BANK:doMenu(val.menu, menu, locationType)
			self.hubHide = true
			self:hideHub(true)

			local entity = self.friendList[i].entity
			if entity and self.BANK:isLocationOpen(locationType) then
				if self.friendList[i].anims_handle then
					stopAnimation(entity, self.friendList[i].anims_handle)
					self.friendList[i].anims_handle = nil
				end

				self.friendList[i].anims_handle = setAnimation(
					entity,
					ANIM_ENT,
					ANIM_NAME_CORPO_BOW,
					ANIM_COMP
				)
			end

			Cron.After(5, function()
				if entity and self.friendList and self.friendList[i] then
					if self.friendList[i].anims_handle then
						stopAnimation(entity, self.friendList[i].anims_handle)
						self.friendList[i].anims_handle = nil
					end

					self.friendList[i].anims_handle = setAnimation(
						entity,
						ANIM_ENT,
						ANIM_NAME_CORPO_STAND,
						ANIM_COMP
					)
				end
				self.hubHide = false
			end)
		end
	end

	if #choices > 0 then
		self.hub = self.interactionUI.createHub(
			Lang.getText("hub_Bank_Target"),
			choices
		)
		self.hubId = hubId
		self.interactionUI.setupHub(self.hub)
		self.interactionUI.showHub()
		Game.GetStatusEffectSystem():ApplyStatusEffect(
			GetPlayer():GetEntityID(),
			"GameplayRestriction.NoHealing",
			GetPlayer():GetRecordID(),
			GetPlayer():GetEntityID()
		)
	end
end

function SPAWN:hideHub(withSub)
	if self.hub then
		self.hub = nil
		self.hubId = nil
		self.interactionUI.hideHub()
		Game.GetStatusEffectSystem():RemoveStatusEffect(
			GetPlayer():GetEntityID(),
			"GameplayRestriction.NoHealing"
		)
	end

	if withSub then
		self:showSubTitle(nil, self.atmFontSize, "Center")
	end
end

return SPAWN
