local input = {}

local pointerX, pointerY = 0, 0
--local previousX, previousY = 0, 0

local tapDownFunctions = {}

function input:registerTapDownFunction ( tapDownFunction, functionOwner )
	tapDownFunctions [ tapDownFunction ] = functionOwner
end

function input:unregisterTapDownFunction ( tapDownFunction )
	tapDownFunctions [ tapDownFunction ] = nil
end

local function handleClickOrTouchDown(x, y)
	for func, owner in pairs ( tapDownFunctions ) do
		func (owner, x , y)
	end
end

function input:initialize()
	--set Moai input events. overwrites other inputs
	if MOAIInputMgr.device.pointer then
		local pointerDown = false
		MOAIInputMgr.device.mouseLeft:setCallback(
			function(isMouseDown)
				if(isMouseDown) then
					handleClickOrTouchDown(MOAIInputMgr.device.pointer:getLoc())
					pointerDown = true;
				else
					--handleClickOrTouchUp(MOAIInputMgr.device.pointer:getLoc())
					pointerDown = false;
				end
				-- Do nothing on mouseUp
			end
		)
		MOAIInputMgr.device.pointer:setCallback (
			function(x,y)
				if pointerDown then
					self:handleClickOrTouchMove(x,y)
				end
			end
		)
	else
	-- If it isn't a mouse, its a touch screen... or some really weird device.
		MOAIInputMgr.device.touch:setCallback (
			function ( eventType, idx, x, y, tapCount )
				--if (tapCount > 1) then
				--	print("menu doesn't handle multitouch")
				--else
					if eventType == MOAITouchSensor.TOUCH_DOWN then
						handleClickOrTouchDown(x,y)
					elseif eventType == MOAITouchSensor.TOUCH_MOVE then
						--handleClickOrTouchMove(x,y)
					elseif eventType == MOAITouchSensor.TOUCH_UP then
						--handleClickOrTouchUp(x,y)
					end
				--end
			end
		)
	end
end

return input

