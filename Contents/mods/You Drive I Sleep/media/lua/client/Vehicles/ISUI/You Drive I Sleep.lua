require "Vehicles/ISUI/ISVehicleMenu"

local ISVehicleMenu_onSleep = ISVehicleMenu.onSleep
---@param playerObj IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function ISVehicleMenu.onSleep(playerObj, vehicle)
	if not playerObj:isAsleep() and not vehicle:isDriver(playerObj) then
		local playerNum = playerObj:getPlayerNum()
		local modal = ISModalDialog:new(0,0, 250, 150, getText("IGUI_ConfirmSleep"), true, nil, ISVehicleMenu.onConfirmSleep, playerNum, playerNum, nil);
		modal:initialise()
		modal:addToUIManager()
		if JoypadState.players[playerNum+1] then
			setJoypadFocus(playerNum, modal)
		end
	else
		ISVehicleMenu_onSleep(playerObj, vehicle)
	end
end


local ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu
function ISVehicleMenu.showRadialMenu(playerObj)

	ISVehicleMenu_showRadialMenu(playerObj)

	local vehicle = playerObj:getVehicle()
	---@type ISRadialMenu|ISPanelJoypad|ISUIElement|ISBaseObject
	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())

	if menu then

		local sleepSliceIndex
		for index,slice in pairs(menu.slices) do
			if slice.text == getText("IGUI_PlayerText_CanNotSleepInMovingCar") then
				sleepSliceIndex = index
			end
		end

		if sleepSliceIndex and (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
			local newText = ""

			if (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
				local doSleep = true
				local sleepNeeded = not isClient() or getServerOptions():getBoolean("SleepNeeded")

				if sleepNeeded and (playerObj:getStats():getFatigue() <= 0.3) then
					newText = "IGUI_Sleep_NotTiredEnough"
					doSleep = false

				elseif vehicle:isDriver(playerObj) and (vehicle:getCurrentSpeedKmHour() > 1 or vehicle:getCurrentSpeedKmHour() < -1) then
					newText = "IGUI_PlayerText_CanNotSleepInMovingCar"
					doSleep = false

				else
					if playerObj:getSleepingTabletEffect() < 2000 then

						if playerObj:getMoodles():getMoodleLevel(MoodleType.Pain) >= 2 and playerObj:getStats():getFatigue() <= 0.85 then
							newText = "ContextMenu_PainNoSleep"
							doSleep = false

						elseif playerObj:getMoodles():getMoodleLevel(MoodleType.Panic) >= 1 then
							newText = "ContextMenu_PanicNoSleep"
							doSleep = false

						elseif sleepNeeded and ((playerObj:getHoursSurvived() - playerObj:getLastHourSleeped()) <= 1) then
							newText = "ContextMenu_NoSleepTooEarly"
							doSleep = false
						end
					end
				end
				if doSleep then
					newText = "ContextMenu_Sleep"
					menu.slices[sleepSliceIndex].command = {ISVehicleMenu.onSleep, playerObj, vehicle}
				end
				menu:setSliceText(sleepSliceIndex, getText(newText))
			end
		end
	end
end