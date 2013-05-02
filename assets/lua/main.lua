screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
--print("Starting up on:" .. MOAIEnvironment.osBrand  .. " version:" .. MOAIEnvironment.osVersion)

if screenWidth == nil then screenWidth = 640 end --then screenWidth =1280 end
if screenHeight == nil then screenHeight = 480 end --then screenHeight = 720 end

MOAISim.openWindow ( "Clay Run", screenWidth, screenHeight )

pixelperfectViewport = MOAIViewport.new()
pixelperfectViewport:setSize(screenWidth,screenHeight)
pixelperfectViewport:setScale(screenWidth,screenHeight)

worldWidth = 1280
worldHeight = 720
worldScaleViewport = MOAIViewport.new()
worldScaleViewport:setSize(screenWidth, screenHeight)

local aspectDifference = worldWidth / worldHeight - screenWidth / screenHeight
if aspectDifference > 0 then
	--crop sides
	local newWorldWidth = screenWidth / screenHeight * worldHeight
	worldWidth = newWorldWidth
elseif aspectDifference < 0 then
	--crop top and bottom
	local newWorldHeight = screenHeight / screenWidth * worldWidth
	worldHeight = newWorldHeight
end

worldScaleViewport:setScale(worldWidth, worldHeight)

print("World scale is "..worldWidth.." / "..worldHeight)

local splash = require("splash")
splash:show(pixelperfectViewport)

input = require("input")
input:initialize()

input:registerTapDownFunction( splash.tap, splash )

--initialize sound
if MOAIUntzSystem then
	MOAIUntzSystem.initialize()
	print("Untz Sound System initialized")
end

loaderTaskThread = MOAITaskThread.new()

--initialize global text style
defaultTextStyle = MOAITextStyle.new ()
--local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
local charcodes = '0123456789'
local fontSize = 80
local fontRegular = MOAIFont.new()
fontRegular:load( "LondrinaShadow-Regular.ttf" )
fontRegular:preloadGlyphs ( charcodes, fontSize )
defaultTextStyle:setFont ( fontRegular )
defaultTextStyle:setSize ( fontSize )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, .5, .5, .5, 1 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )

local scene = require("scene")


scene:load()
local directories = MOAIFileSystem.listDirectories()
local nDirs = #directories
local deviceTime = MOAISim.getDeviceTime()
print("random seed: "..deviceTime)
math.randomseed (deviceTime)
local dirName = directories[math.random(nDirs)]
if dirName[#dirName]=="/" then
	dirName = string.sub( dirName, 1, -2)
end
scene:setSkin( dirName )
--scene:show()
--input:registerTapDownFunction( scene.tap, scene )
--scene:start()

----[[ --show splash screen for the first four seconds, then start the scene
local waitThread = MOAICoroutine.new ()
local function waitFunc ()
	--print ("elapsed time = " .. MOAISim.getElapsedTime () )
	while (MOAISim.getElapsedTime () < 4.0) do
		--print ("elapsed time = " .. MOAISim.getElapsedTime () )
		coroutine.yield()
	end
	input:unregisterTapDownFunction( splash.tap, splash )
	scene:show()
	splash = nil
	input:registerTapDownFunction( scene.tap, scene )
	collectgarbage()
	
	scene:start()
end
waitThread:run ( waitFunc )
--]] 






