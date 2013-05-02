local runnerClass = {}

runnerClass.skins = {}

function runnerClass:newRunnerProp( )
	local prop = MOAIProp2D.new()

	prop.pointsCollected = 0
	
	local sheetIndexCurve = MOAIAnimCurve.new ()
	local numFrames = 12
	local timePerFrame = 0.25
	sheetIndexCurve:reserveKeys ( numFrames + 1 )
	for i=0, numFrames-1 do
		sheetIndexCurve:setKey (i+1, i*timePerFrame, i+1, MOAIEaseType.FLAT )
	end
	sheetIndexCurve:setKey (numFrames+1, numFrames*timePerFrame, 1, MOAIEaseType.FLAT )
	sheetIndexCurve:setWrapMode ( MOAIAnimCurve.WRAP )
	
	local forwardMovementCurve = MOAIAnimCurve.new()
	forwardMovementCurve:reserveKeys( 2 )
	forwardMovementCurve:setKey(1, 0, 0, MOAIEaseType.LINEAR)
	forwardMovementCurve:setKey(2, 1, -100, MOAIEaseType.LINEAR)
	forwardMovementCurve:setWrapMode ( MOAIAnimCurve.APPEND )

	local anim = MOAIAnim:new ()
	anim:reserveLinks ( 2 )
	anim:setLink ( 1, sheetIndexCurve, prop, MOAIProp2D.ATTR_INDEX )
	anim:setLink ( 2, forwardMovementCurve, prop, MOAIProp2D.ATTR_X_LOC, true )
	anim:setMode ( MOAITimer.CONTINUE )
	prop.runnerSpeed = 2.5
	anim:throttle(prop.runnerSpeed)--scale animation to run faster
	--anim:start ()
	--anim:start(self.rootAction) --start running
	
	local jumpCurve = MOAIAnimCurve.new()
	jumpCurve:reserveKeys(3)
	local jumpLength = 1.0
	jumpCurve:setKey( 1, 0.0, 0, MOAIEaseType.SOFT_EASE_IN )
	jumpCurve:setKey( 2, jumpLength/2, 100, MOAIEaseType.SOFT_EASE_OUT )
	jumpCurve:setKey( 3, jumpLength, 0, MOAIEaseType.FLAT )
	local sheetIndexCurveJump = MOAIAnimCurve.new ()
	local numFrames = 4
	local timePerFrame = jumpLength/4
	sheetIndexCurveJump:reserveKeys ( numFrames +1)
	for i=0, numFrames-1 do
		print ( "setKeyframe " .. i+1 .. " time " .. i*timePerFrame .. " index ".. i+13)
		sheetIndexCurveJump:setKey (i+1, i*timePerFrame, i+13, MOAIEaseType.FLAT )
	end
	sheetIndexCurveJump:setKey (numFrames+1, jumpLength, 16, MOAIEaseType.FLAT )
	local jumpAnim = MOAIAnim:new()
	jumpAnim:reserveLinks(2)
	jumpAnim:setLink( 1, jumpCurve, prop, MOAITransform2D.ATTR_Y_LOC)
	jumpAnim:setLink ( 2, sheetIndexCurveJump, prop, MOAIProp2D.ATTR_INDEX )
	jumpAnim:setMode( MOAITimer.NORMAL )

	--local function jumpEnd ()
	--end
	--jumpAnim:setListener( MOAITimer.EVENT_TIMER_END_SPAN, jumpEnd )
	
	function prop:jump()
		jumpAnim:start(self.rootAction)
	end
	
	function prop:isJumping()
		return jumpAnim:isActive()
	end
	
	function prop:increaseSpeed()
		self.runnerSpeed = self.runnerSpeed+0.2
		anim:throttle(prop.runnerSpeed)
	end

	function prop:startRunning()
		anim:start ()
		if self.current_skin.runSound then
			self.current_skin.runSound:play()
		end
	end

	function prop:isRunning()
		return anim:isActive()
	end

	function prop:setSkin(name)
		
		if self.current_skin and self.current_skin.runSound and self.current_skin.runSound:isPlaying() then
			self.current_skin.runSound:stop()
		end
		local skin = runnerClass.skins[name]
		if ( skin == nil ) then  --load skin
			skin = runnerClass:loadSkin(name)
		end
		prop.skin = skin
		prop:setDeck(skin.deck)
		if skin.runSound and anim:isActive() then
			skin.runSound:play()
		end
		self.current_skin = skin
	end
	
	return prop
end

function runnerClass:loadSkin(name)
	print("loading runnerClass skin " .. name)
	local skin = {}
	local deck = MOAITileDeck2D.new ()
	--runnerDeck.oldTexture:release
	
	deck:setSize ( 4, 4 )
	deck:setRect ( -128, -128, 128, 128 )
	skin.deck = deck

	skin.imageDataBuffer = MOAIDataBuffer.new()
	local function loadedCallback()
		local texture = MOAITexture.new ()
		texture:load(skin.imageDataBuffer)
		deck:setTexture ( texture )
		print("loaded texture!!!!")
	end
	print("starting to load texture async")
	skin.imageDataBuffer:loadAsync(name.."/runner.png", loaderTaskThread, loadedCallback)

	if MOAIUntzSystem then
		local runSound = MOAIUntzSound.new ()		
		skin.runSound = runSound
		runSound:load(name.."/runSound.ogg")
		runSound:setLooping(true)
	end
	self.skins[name] = skin

	return skin
end

return runnerClass
