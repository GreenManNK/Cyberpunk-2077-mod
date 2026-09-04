input = {
	interactKey = false,
	up = false,
	down = false,
	observerStarted = false
}

function input.startInputObserver()
	if input.observerStarted then
		return
	end

	input.observerStarted = true

	Observe('PlayerPuppet', 'OnGameAttached', function(this)
	end)

	Observe('PlayerPuppet', 'OnAction', function(_, action)
		if not action then
			return
		end

		local actionName = Game.NameToString(action:GetName(action))
		local actionType = action:GetType(action).value

		if actionName == 'Reload' or actionName == 'TagButton' then
			if actionType == 'BUTTON_PRESSED' then
				input.interactKey = true
			elseif actionType == 'BUTTON_RELEASED' then
				input.interactKey = false
			end
		end
	end)
end

return input
