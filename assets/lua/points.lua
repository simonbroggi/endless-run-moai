local points = {}

points.instances = {} --todo: implement a queue http://www.lua.org/pil/19.2.html
points.skins = {}
--adfjk
function points:loadDeck()
	self.deck = MOAIGfxQuad2D.new ()
	self.deck:setRect ( -32, -32, 32, 32 )
end

function points:initialize(layer, n)
	self.layer = layer
	self.startX = -400
	self.numX = 0

	local numPoints = 0
	while numPoints < n do
		numPoints = numPoints+1
		self:addRandomPoint(0)
	end
end

function points:addRandomPoint(minX)
	local pointAdded = false

	if minX < self.startX - self.numX*150 then
		self.numX = -math.floor( (minX -self.startX) / 150)
	end

	while not pointAdded do
		self.numX = self.numX+1
		if math.random(4) == 1 then
			self:new(self.layer, self.startX - self.numX*150, -90)
			pointAdded = true
			return
		end
		if not pointAdded and math.random(4) == 1 then
			self:new(self.layer, self.startX - self.numX*150, 200)
			pointAdded = true
			return
		end
	end
end

function points:new(layer, x, y)
	local pInst = MOAIProp2D.new()
	pInst:setDeck(self.deck)
	pInst:setLoc(x, y)
	pInst.collectable = true
	--print("adding point at "..x.." / "..y)
	table.insert(points.instances, pInst)
	layer:insertProp(pInst)
end

function points:setSkin(name)
	--print("seting points skin "..name)
	local skin = points.skins[name]
	if ( skin == nil ) then  --load skin
		skin = self:loadSkin(name)
	end
	self.skin = skin
	self.deck:setTexture(skin.tex)
end

function points:loadSkin(name)
	--print("loading points skin " .. name)
	local skin = {}
	--runnerDeck.oldTexture:release
	local tex = MOAITexture.new()

	--tex:load ( name.."/point.png" )
	skin.tex = tex

	skin.imageDataBuffer = MOAIDataBuffer.new()
	local function loadedCallback()
		local texture = MOAITexture.new ()
		tex:load(skin.imageDataBuffer)
		print("point texture loaded!!!!")
	end
	print("starting to load point texture async")

	skin.imageDataBuffer:loadAsync(name.."/point.png", loaderTaskThread, loadedCallback)

	points.skins[name] = skin

	return skin
end

function points:checkCollision(scene)
	local indicesToDelete = {}
	local rx, ry = scene.clayRunner:getLoc()
	for k, v in ipairs(self.instances) do
		
		local x, y = v:getLoc()
		
		local dx = x-rx

		if dx > worldWidth/2 then--remove if passed
			table.insert(indicesToDelete, k)
		elseif v.collectable and math.abs(dx) < 80 then
			local dy = y-ry
			if math.abs(dy) < 120 then
				local cx, cy = scene.camera:getLoc()
				local anim = v:seekLoc(cx+worldWidth/2, cy+worldHeight/2, 0.7, MOAIEaseType.LINEAR)
				local function gotCoin()
					scene.clayRunner.pointsCollected = scene.clayRunner.pointsCollected+1
					scene.scoreTextbox:setString(string.format( "%d", scene.clayRunner.pointsCollected ) )
					if scene.clayRunner.pointsCollected % 10 == 0 then
						scene:addPortal()
					end
				end
				anim:setListener(MOAITimer.EVENT_TIMER_END_SPAN, gotCoin)
				
				v.collectable = false
				
			end
		end
	end
	for k, v in ipairs(indicesToDelete) do
		scene.layer:removeProp(self.instances[v])
		table.remove(self.instances, v)
		self:addRandomPoint(rx - worldWidth/2)
	end
end

return points
