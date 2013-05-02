local splash = {}

function splash:show(viewport)
	local layer = MOAILayer2D.new()
	layer:setViewport(viewport)

	local background = self:createBackground()
	layer:insertProp ( background )

	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( "splash.png" )
	gfxQuad:setRect ( -128, -128, 128, 128 )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	prop:setLoc ( 0, math.floor ( screenHeight / 7 ) )
	layer:insertProp ( prop )


	--------------------------------------------------------------------------
	-- Loading fonts and defining styles.
	-- Might be worth to create a fontResourceManager for this, in order to reuse
	--------------------------------------------------------------------------

	--characters to load (order dosn't matter) 
	local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
	local fontSize = 24

	local fontRegular = MOAIFont.new()
	fontRegular:load( "Roboto-Regular.ttf" )
	fontRegular:preloadGlyphs ( charcodes, fontSize )
	local styleRegular = MOAITextStyle.new ()
	styleRegular:setFont ( fontRegular )
	styleRegular:setSize ( fontSize )

	local fontBold = MOAIFont.new()
	fontBold:load( "Roboto-Bold.ttf" )
	fontBold:preloadGlyphs ( charcodes, fontSize )
	local styleBold = MOAITextStyle.new ()
	styleBold:setFont ( fontBold )
	styleBold:setSize ( fontSize )

	local textbox = MOAITextBox.new()
	textbox:setStyle ( styleRegular )
	textbox:setStyle ( 'b', styleBold )

	textbox:setRect ( -screenWidth / 2, -20, screenWidth / 2, 20 )
	textbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	local textboxYOffset = -math.floor ( screenHeight / 7 )
	textbox:setLoc ( 0, textboxYOffset )
	textbox:setYFlip ( true )
	textbox:setColor ( 0, 0, 0, 1 )
	layer:insertProp ( textbox )
	
	--local str = "<b>1'230</> COINS INSERTED"
	self.textboxBounds = {0, 0, 0, 0}
	local function setSubtitleString(str)
		textbox:setString ( str )
		local xMin, yMin, xMax, yMax = textbox:getStringBounds ( 1, #str )
		--self.textboxBounds = { textbox:modelToWorld(xMin, yMin),  textbox:modelToWorld(xMax, yMax) } --should work imo. a moai bug???
		self.textboxBounds = { xMin, yMin + textboxYOffset - math.floor((yMax-yMin)/3), xMax, yMax + textboxYOffset - math.floor((yMax-yMin)/3)}
	end
	setSubtitleString( "No internet connection?")
	
	
	--global debugging stuff
	--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, .5, .5, .5, 1 )
	--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
	--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )
	
	local renderTable = { layer }	
	MOAIRenderMgr.setRenderTable ( renderTable )
	
	--self.showTimer = MOAITimer.new()
	--self.showTimer:start()

	--internet stuff

	local getCoinsPHP = MOAIHttpTask.new ()
	getCoinsPHP:setVerb ( MOAIHttpTask.HTTP_GET )
	getCoinsPHP:setUrl ( "http://www.insert-coin.ch/get-coins.php" )
	local function onFinishGetCoins ( task, responseCode )
		print ( "onFinish" )
		print ( responseCode )

		if ( task:getSize ()) then
			local str = task:getString()
			
			local coins = "<b>" .. string.sub(str, 1, #str-1) .. "</>" .. " COINS INSERTED"
			setSubtitleString( coins )
			print ( task:getString ())
		else
			print ( "nothing" )
			setSubtitleString( "No internet connection???")
		end
	end
	getCoinsPHP:setCallback( onFinishGetCoins )
	getCoinsPHP:setVerbose ( true )
	getCoinsPHP:performSync()


	self.insertCoinPHP = MOAIHttpTask.new ()

	self.insertCoinPHP:setVerb ( MOAIHttpTask.HTTP_GET )
	self.insertCoinPHP:setUrl ( "http://www.insert-coin.ch/insert-coin.php" )
	local function onFinishInsertCoin ( task, responseCode )
		print ( "onFinish" )
		print ( responseCode )

		if ( task:getSize ()) then
			print ( task:getString ())
			getCoinsPHP:performSync()
		else
			print ( "nothing" )
		end
	end
	self.insertCoinPHP:setCallback ( onFinishInsertCoin )
	--self.insertCoinPHP:setUserAgent ( "insert-coin mobil" )
	self.insertCoinPHP:setVerbose ( true )
	
end

function splash:tap( x, y )
	--load http://www.insert-coin.ch/insert-coin.php
	-- http://www.insert-coin.ch/get-coins.php
	
	--prop:setLoc( layer:wndToWorld ( x, y ) )
	self.insertCoinPHP:performSync ()
end


function splash:createBackground()

	local prop = MOAIProp2D.new ()

	local function onDraw ( index, xOff, yOff, xFlip, yFlip )

		MOAIGfxDevice.setPenColor ( 1, 1, 1, 1 )
		MOAIDraw.fillRect(-screenWidth / 2, -screenHeight / 2, screenWidth, screenHeight)

		MOAIGfxDevice.setPenColor ( 0.5, 0.5, 0.5, 1 )
		local xMin, yMin, xMax, yMax = unpack(self.textboxBounds)
		--xMin, yMin = prop:worldToModel(xMin, yMin) --not needed, model and world coordinates are identical
		--xMax, yMax = prop:worldToModel(xMax, yMax)
		MOAIDraw.drawLine(xMin-2, yMin, xMax+2, yMin)
		MOAIDraw.drawLine(xMin-2, yMax, xMax+2, yMax)
		
		--draw a red border to check if everything is on the screen
		--MOAIGfxDevice.setPenColor ( 1, 0, 0, 1 )
		--MOAIDraw.drawRect(-screenWidth / 2 + 2, -screenHeight / 2 + 2, screenWidth/2 - 2, screenHeight/2 - 2)
	
	end

	local scriptDeck = MOAIScriptDeck.new ()
	scriptDeck:setRect ( -screenWidth / 2, -screenHeight / 2, screenWidth/2, screenHeight/2 )
	scriptDeck:setDrawCallback ( onDraw )
	
	prop:setDeck ( scriptDeck )

	return prop	
end

return splash

