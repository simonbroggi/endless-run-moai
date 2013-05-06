local scene = {}

scene.isRunning = false

function scene:load()
	self.layer = MOAILayer2D.new()
	self.layer:setViewport(worldScaleViewport)
	self.camera = MOAICamera2D.new()
	self.layer:setCamera(self.camera)

	self.layerStaticBG = MOAILayer2D.new()
	self.layerStaticBG:setViewport(pixelperfectViewport)
	local bgProp = MOAIProp2D.new ()
	local scriptDeck = MOAIScriptDeck.new()
	scriptDeck:setRect ( -screenWidth / 2, -screenHeight / 2, screenWidth/2, screenHeight/2 )
	scriptDeck:setDrawCallback ( function ( index, xOff, yOff, xFlip, yFlip )
		MOAIGfxDevice.setPenColor ( .7, .8, .9, 1 )
		MOAIDraw.fillRect(-screenWidth / 2, -screenHeight / 2, screenWidth, screenHeight)
		MOAIGfxDevice.setPenColor ( .8, .8, .7, 1 )
		MOAIDraw.fillRect(-screenWidth / 2, -screenHeight/7, screenWidth, -screenHeight/2)
	end )
	bgProp:setDeck ( scriptDeck )
	self.layerStaticBG:insertProp(bgProp)

	--HUD
	self.layerHUD = MOAILayer2D.new()
	self.layerHUD:setViewport(pixelperfectViewport)
	local textbox = MOAITextBox.new()
	textbox:setStyle ( defaultTextStyle )
	textbox:setRect ( -screenWidth/10, -screenHeight/10, screenWidth/10, screenHeight/10 )
	textbox:setLoc ( -screenWidth/2+screenWidth/8, screenHeight/2-screenHeight/10)
	textbox:setColor ( 0, 0, 0, 1 )
	textbox:setYFlip ( true )
	textbox:setAlignment ( MOAITextBox.RIGHT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	self.layerHUD:insertProp ( textbox )
	self.distanceTextbox = textbox

	textbox = MOAITextBox.new()
	textbox:setStyle ( defaultTextStyle )
	textbox:setRect ( -screenWidth/10, -screenHeight/10, screenWidth/10, screenHeight/10 )
	textbox:setLoc ( screenWidth/2-screenWidth/8, screenHeight/2-screenHeight/10)
	textbox:setColor ( 0, 0, 0, 1 )
	textbox:setYFlip ( true )
	textbox:setAlignment ( MOAITextBox.RIGHT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	textbox:setString("0")
	self.layerHUD:insertProp ( textbox )
	self.scoreTextbox = textbox
	-- end HUD
	
	runnerClass = require( "runnerClass" )
	
	self.clayRunner = runnerClass:newRunnerProp()
	
	--[[
	local whiteRunner = runnerClass:newRunnerProp()
	whiteRunner:setSkin("white_clay")
	whiteRunner:setLoc(200, -50)
	self.layer:insertProp ( whiteRunner )
	self.whiteRunner = whiteRunner
	--]]

	self.camera:setAttrLink(MOAITransform2D.ATTR_X_LOC, self.clayRunner, MOAITransform2D.ATTR_X_LOC)

	self.points = require("points")
	self.points:loadDeck()

	self.points:initialize(self.layer, 10)

	self.layer:insertProp ( self.clayRunner )

	self.portals = require("portals")
	--self.portals:loadDeck()
	
	--local p = self.portals:new(self.layer, -2000, 0, "white_clay")
end

function scene:setSkin(name)
	if name[#name]=="/" then
		name = string.sub( name, 1, -2)
	end
	print("scene setting skin "..name)
	self.points:setSkin(name)
	self.clayRunner:setSkin(name)
	self.activ_skin = name
end

function scene:loadSkin(name)
	print("scene loading Skin "..name)
	if self.points.skins[name] == nil then
		self.points:loadSkin(name)
	end
	if runnerClass.skins[name] == nil then
		runnerClass:loadSkin(name)
	end
end

function scene:addPortal()
	local camPosX = self.camera:getLoc()
	local directories = MOAIFileSystem.listDirectories()
	local nDirs = #directories
	if nDirs > 1 then
		local chosenDir = math.random(nDirs-1)
		local i = 1
		while i<= chosenDir do
			if string.sub(directories[i], 1, -2) == self.activ_skin then
				chosenDir = chosenDir+1
				i = chosenDir
			else
				i=i+1
			end
		end
		local portalName = directories[chosenDir]
		if portalName[#portalName]=="/" then
			portalName = string.sub( portalName, 1, -2)
		end
		self:loadSkin(portalName)
		--self.portals:remove(self.layer)
		self.portals:new(self.layer, camPosX-worldWidth/2 - 32, 0, portalName)
	else
		local portalName = directories[1]
		if portalName[#portalName]=="/" then
			portalName = string.sub( portalName, 1, -2)
		end
		--self.portals:remove(self.layer)
		self.portals:new(self.layer, camPosX-worldWidth/2 - 32, 0, portalName)
	end
end

function scene:show()
	local renderTable = { self.layerStaticBG, self.layer, self.layerHUD }	
	MOAIRenderMgr.setRenderTable ( renderTable )
end

function scene:start()
	local thread = MOAICoroutine.new ()
	local function update ()
		while (self.isRunning) do
			coroutine.yield()
			local x,y = self.clayRunner:getLoc()
			self.distanceTextbox:setString(string.format( "%d", math.floor(math.abs(x/128)) ))
			self.points:checkCollision(self)
			self.portals:checkCollision(self)
		end
	end

	self.isRunning = true
	thread:run ( update )

	--self.whiteRunner:startRunning()
end

function scene:tap()
	if self.clayRunner:isRunning() then
		self.clayRunner:jump()
	else
		self.clayRunner:startRunning()
	end
end

return scene
