local portals = {}

portals.instances = {}
portals.skins = {}

function portals:loadSkin(name)
	local skin = {}
	local deck = MOAIGfxQuad2D.new()
	deck:setTexture(name.."/portal.png")
	deck:setRect ( -64, -64, 64, 64 )
	print("loaded "..name.."/portal.png")
	skin.deck = deck
	skin.name = name
	self.skins[name] = skin
	return skin
end

function portals:new(layer, x, y, skin_name)
	local pInst = MOAIProp2D.new()

	pInst:setLoc(x, y)
	pInst.collectable = true
	table.insert(portals.instances, pInst)
	
	function pInst:setSkin(name)
		local skin = portals.skins[name]
		if ( skin == nil ) then  --load skin
			skin = portals:loadSkin(name)
		end
		self.skin = skin
		self:setDeck(skin.deck)
	end

	pInst:setSkin(skin_name)
	layer:insertProp(pInst)
end

function portals:remove(layer)
	local n = #self.instances
	layer:removeProp(self.instances[n])
	table.remove(self.instances, n)
end

function portals:checkCollision(scene)
	for k, v in ipairs(self.instances) do
		if v.collectable then
			local x, y = v:getLoc()
			local rx, ry = scene.clayRunner:getLoc()
			local dx = x-rx
			if math.abs(dx) < 128 then
				local dy = y-ry
				if math.abs(dy) < 128 then
					v.collectable = false
					local anim = v:moveRot(360*3, 2)
					v:moveScl(5, 5, 2)
					v:moveLoc(-200, 0, 2)
					local function endPortalAnim()
						scene:setSkin(v.skin.name)
					end
					anim:setListener(MOAITimer.EVENT_TIMER_END_SPAN, endPortalAnim)
				end
			end
		end
	end
end

return portals
