------------------
--[[
CBEffects ParticleHelper Library

The master helper library, includes ParticlePhysics and ParticlePresets.
--]]
------------------

local ParticleHelper={physics={},presets={}}

local mrand=math.random

------------------
--[[
ParticleHelper Class #1: ParticleFunctions

Adds miscellaneous helper functions to be used with CBEffects.
--]]
------------------
local letters="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890~!@#$%^&*()_+=-{}[]:;\"\'.,></?|"
local function angleBetween( srcX, srcY, dstX, dstY, offset )
   local angle = ( math.deg( math.atan2( dstY-srcY, dstX-srcX ) )+90 ) +offset
   if ( angle < 0 ) then angle = angle + 360 end
   return angle % 360
end
local function formatForPolygon(obj, t)
	local polygon={}
	for i=1, #t, 2 do
		polygon[#polygon+1]={x=t[i]+obj.x, y=t[i+1]+obj.y}
	end
	return polygon
end
local function pointInPolygon( points, dot )
	local i, j = #points, #points
	local oddNodes = false
	for i=1, #points do
		if ((points[i].y < dot.y and points[j].y>=dot.y or points[j].y< dot.y and points[i].y>=dot.y) and (points[i].x<=dot.x or points[j].x<=dot.x)) then
			if (points[i].x+(dot.y-points[i].y)/(points[j].y-points[i].y)*(points[j].x-points[i].x)<dot.x) then
				oddNodes = not oddNodes
			end
		end
		j = i
	end
 
	return oddNodes
end
local function pointInRect( pointX, pointY, left, top, width, height )
	if pointX >= left and pointX <= left + width and pointY >= top and pointY <= top + height then 
		return true
	else 
		return false 
	end
end
local function pointInCircle( pointX, pointY, centerX, centerY, radius)
	local dX, dY = pointX - centerX, pointY - centerY
	if dX * dX + dY * dY <= radius * radius then 
		return true
	else 
		return false 
	end
end
local function fnn( ... ) 
	for i = 1, #arg do
		local theArg = arg[i]
		if(theArg ~= nil) then return theArg end
	end
	return nil
end
local function lengthOf( a, b, c, d )
  local width, height = c-a, d-b
	return (width*width + height*height)^0.5
end
local function pointsAlongLine(x1, y1, x2, y2, d)
	local points={}
	
	local diffX=x2-x1
	local diffY=y2-y1
	
	local distBetween
	
	local x, y=x1, y1
	
	if d=="total" or not d then
		distBetween=lengthOf(x1, y1, x2, y2)
	else
		distBetween=d
	end
	
	local addX, addY=diffX/distBetween, diffY/distBetween
	
	for i=1, distBetween do
		points[#points+1]={x, y}
		x, y=x+addX, y+addY
	end
	
	return points
end
local function forcesByAngle(totalForce, angle)
  local forces = {}
  local radians = -math.rad(angle)
 
  forces.x = math.cos(radians) * totalForce
  forces.y = math.sin(radians) * totalForce
 
  return forces
end
local function either(table)
	if #table==0 then
		return nil
	else
		return table[mrand(#table)]
	end
end
local function inRadius(x, y, radius, innerRadius)
	local X
	local Y
	local inRad
	local Radius=radius*radius
	local finalX, finalY
	if (innerRadius) then
		inRad=innerRadius*innerRadius
	end

	if (inRad) then
		repeat
			X = mrand(-radius, radius)
			Y = mrand(-radius, radius)
		until X*X+Y*Y<=Radius and X*X+Y*Y>=inRad
		finalX, finalY=x+X, y+Y
	else
		repeat
			X = mrand(-radius, radius)
			Y = mrand(-radius, radius)
		until X*X+Y*Y<=Radius
	end
		
	return finalX, finalY
end
local function inRect(x, y, rectLeft, rectTop, rectWidth, rectHeight)
	local X, Y
	
	repeat
		X, Y=mrand(rectLeft, rectLeft+rectWidth), mrand(rectTop, rectTop+rectHeight)
	until pointInRect(X, Y, rectLeft, rectTop, rectWidth, rectHeight)==true
	
	return X, Y
end
local function newTitle()
	local title=""
	for i=1, 20 do
		local r=mrand(92)
		title=title..letters:sub(r, r)
	end
	return title
end

ParticleHelper.pointInPolygon=pointInPolygon
ParticleHelper.pointInRect=pointInRect
ParticleHelper.pointInCircle=pointInCircle
ParticleHelper.formatForPolygon=formatForPolygon
ParticleHelper.angleBetween=angleBetween
ParticleHelper.fnn=fnn
ParticleHelper.lengthOf=lengthOf
ParticleHelper.pointsAlongLine=pointsAlongLine
ParticleHelper.forcesByAngle=forcesByAngle
ParticleHelper.either=either
ParticleHelper.inRadius=inRadius
ParticleHelper.inRect=inRect
ParticleHelper.newTitle=newTitle

------------------
--[[
ParticleHelper Class #2: ParticlePhysics

Uses fake physics equations to move particles onEnterFrame, along with a collision class
--]]
------------------
local function createCollisionSensor(params)
	local cf={}
	
	cf.onCollision=params.onCollision or function() end
	cf.shape=params.shape or "rect"
	
	cf.x=params.x or display.contentCenterX
	cf.y=params.y or display.contentCenterY
	
	cf.rectLeft=params.rectLeft or 0
	cf.rectTop=params.rectTop or 0
	cf.rectWidth=params.rectWidth or 100
	cf.rectHeight=params.rectHeight or 100
	cf.radius=params.radius or 200
	cf.points=params.points or {0, 0, 500, 500, 500, 0}
	cf.polygon=formatForPolygon(cf, cf.points)
	cf.targetPhysics=params.targetPhysics
	cf.singleEffect=params.singleEffect or false
	
	local function checkCollisions()
		for i=cf.targetPhysics.p, cf.targetPhysics.o do
			if cf.targetPhysics.objects[i] then
				if cf.singleEffect==true then
					if cf.targetPhysics.objects[i].ParticleCollision==false then
						cf.targetPhysics.objects[i].ParticleCollision=true
						if cf.shape=="rect" then
							if pointInRect(cf.targetPhysics.objects[i].x, cf.targetPhysics.objects[i].y, cf.rectLeft+cf.x, cf.rectTop+cf.y, cf.rectWidth, cf.rectHeight) then
								cf.onCollision(cf.targetPhysics.objects[i], cf)
							end
						elseif cf.shape=="circle" then
							if pointInCircle(cf.targetPhysics.objects[i].x, cf.targetPhysics.objects[i].y, cf.x, cf.y, cf.radius) then
								cf.onCollision(cf.targetPhysics.objects[i], cf)
							end
						elseif cf.shape=="polygon" then
							cf.polygon=formatForPolygon(cf, cf.points)
							if pointInPolygon(cf.polygon, cf.targetPhysics.objects[i]) then
								cf.onCollision(cf.targetPhysics.objects[i], cf)
							end
						end
					end
				else
					if cf.shape=="rect" then
						if pointInRect(cf.targetPhysics.objects[i].x, cf.targetPhysics.objects[i].y, cf.rectLeft+cf.x, cf.rectTop+cf.y, cf.rectWidth, cf.rectHeight) then
							cf.onCollision(cf.targetPhysics.objects[i], cf)
						end
					elseif cf.shape=="circle" then
						if pointInCircle(cf.targetPhysics.objects[i].x, cf.targetPhysics.objects[i].y, cf.x, cf.y, cf.radius) then
							cf.onCollision(cf.targetPhysics.objects[i], cf)
						end
					elseif cf.shape=="polygon" then
						cf.polygon=formatForPolygon(cf, cf.points)
						if pointInPolygon(cf.polygon, cf.targetPhysics.objects[i]) then
							cf.onCollision(cf.targetPhysics.objects[i], cf)
						end
					end
				end
			end
		end
	end
	cf.enterFrame=checkCollisions
	
	function cf.start()
		Runtime:addEventListener("enterFrame", cf)
	end
	
	function cf.stop()
		Runtime:removeEventListener("enterFrame", cf)
	end
	
	function cf.cancel()
		Runtime:removeEventListener("enterFrame", cf)
		for k, v in pairs(cf) do
			cf[k]=nil
		end
		cf=nil
		return true
	end
	
	return cf
end

local function createPhysics()
	local physics={}
	local scale=1
	physics.gravityX=0
	physics.gravityY=0
	physics.objects={}
	physics.useDivisionDamping=true
	
	physics.o=1
	physics.p=1
	
	physics.F=1
	physics.F2=1
	
	function physics.setGravity(x, y)
		physics.gravityX=x
		physics.gravityY=y
	end
	
	function physics.addBody(obj, bodyType, params)
		local obj=obj
		
		if type(bodyType)=="string" then
			bodyType=bodyType
		elseif type(bodyType)=="table" then
			params=bodyType
		end
		
		if params then
			obj.velX=params.velX or 0
			obj.velY=params.velY or 0
			obj.density=params.density or 1.0
			obj.linearDamping=params.linearDamping or 1
			obj.angularDamping=params.angularDamping or 0
			obj.angularVelocity=params.angularVelocity or 0
			obj.bodyType=params.bodyType or "dynamic"
			obj.sizeX=params.sizeX or 0
			obj.sizeY=params.sizeY or 0
			obj.xbS=params.xbS or 0.1
			obj.ybS=params.ybS or 0.1
			obj.xbL=params.xbL or 3
			obj.ybL=params.ybL or 3
			obj.rotateToVel=params.rotateToVel or false
			obj.offset=params.offset or 0
			obj.xDamping=params.xDamping or obj.linearDamping
			obj.yDamping=params.yDamping or obj.linearDamping
			obj.relativeToSize=params.relative or false
		end
				
		physics.objects[physics.o]=obj
		obj.num=physics.o
		obj._prevX, obj._prevY=obj.x, obj.y
		obj._numUpdates=0
		
		physics.o=physics.o+1
			
		function obj:applyForce(x, y)
			if obj.relativeToSize then
				obj.velX, obj.velY=obj.velX+((x/obj.density)/((obj.width+obj.height))), obj.velY+(y/obj.density)/(obj.width+obj.height)
			else
				obj.velX, obj.velY=obj.velX+(x/obj.density), obj.velY+(y/obj.density)
			end
		end
		
		function obj:setLinearVelocity(x, y)
			obj.velX, obj.velY=x, y
		end
		
		function obj:getLinearVelocity()
			return obj.velX, obj.velY
		end
		
		function obj:applyTorque(value)
			obj.angularVelocity=obj.angularVelocity+(value/obj.density)
		end
	end
	
	function physics.removeBody(n)
		if n and n.num and physics.objects[n.num] then
			physics.p=physics.p+1
			physics.objects[n.num]=nil
		end
	end
	
	local function physicsLoop()
		for i=physics.p, physics.o do
			if physics.objects[i] then
				local p=physics.objects[i]
				
				p._numUpdates=p._numUpdates+1
				
				if p.colorSet then
					p:physicsColor(p.colorSet.r, p.colorSet.g, p.colorSet.b)
				end
				
				if p.density<=0 then
					p.density=1.0
				end
				
				if "dynamic"==p.bodyType then
					if p.relativeToSize then
						p.velX=p.velX+(physics.gravityX*(p.density/(p.width+p.contentHeight/2)))
						p.velY=p.velY+(physics.gravityY*(p.density/(p.width+p.contentHeight/2)))
					else
						p.velX=p.velX+(physics.gravityX*p.density)
						p.velY=p.velY+(physics.gravityY*p.density)
					end
				end
				
				if not physics.useDivisionDamping then
					if p.velX>0 then
						if p.velX-p.xDamping>=0 then
							p.velX=p.velX-p.xDamping
						else
							p.velX=0
						end
					else
						if p.velX+p.xDamping<=0 then
							p.velX=p.velX+p.xDamping
						else
							p.velX=0
						end
					end
					if p.velY>0 then
						if p.velY-p.yDamping>=0 then
							p.velY=p.velY-p.yDamping
						else
							p.velY=0
						end
					else
						if p.velY+p.yDamping<=0 then
							p.velY=p.velY+p.yDamping
						else
							p.velY=0
						end
					end
				else
					p.velY=p.velY/p.yDamping
					p.velX=p.velX/p.xDamping
				end
				
				p:translate(p.velX, p.velY)
				p.curX, p.curY=p.x, p.y
				
				if p.rotateToVel==true then
					p.rotation=angleBetween(p._prevX, p._prevY, p.curX, p.curY, p.offset)
				else
					p.rotation=p.rotation+p.angularVelocity
				end
				
				if p.angularVelocity>0 then
					if p.angularVelocity-p.angularDamping>=0 then
						p.angularVelocity=p.angularVelocity-p.angularDamping
					else
						p.angularVelocity=0
					end
				else
					if p.angularVelocity+p.angularDamping<=0 then
						p.angularVelocity=p.angularVelocity+p.angularDamping
					else
						p.angularVelocity=0
					end
				end
								
				if (p.sizeX>0 and p.xScale<=p.xbL+p.sizeX) or (p.sizeX<0 and p.xScale>=p.xbS+p.sizeX) then
					p.xScale=p.xScale+p.sizeX
				end
				
				if (p.sizeY>0 and p.yScale<=p.ybL+p.sizeY) or (p.sizeY<0 and p.yScale>=p.ybS+p.sizeY) then
					p.yScale=p.yScale+p.sizeY
				end
				
				physics.parentVent.onUpdate(p, physics.parentVent, physics.parentVent.content)
				
				p._prevX, p._prevY=p.x, p.y
				
				
			end
		end
	end

	physics.enterFrame=function()
		for i=1, scale do
			physicsLoop()
		end
	end
	
	function physics.start()
		Runtime:addEventListener("enterFrame", physics)
	end
	
	function physics.pause()
		Runtime:removeEventListener("enterFrame", physics)
	end
	
	function physics.iterate()
		physicsLoop()
	end
	
	function physics.cancel()
		scale=nil
		Runtime:removeEventListener("enterFrame", physics)
		for i=physics.o, physics.p do
			table.remove(physics.objects, i)
		end
		for k, v in pairs(physics) do
			physics[k]=nil
		end
		physics=nil
		return true
	end
	
	return physics
end

ParticleHelper.physics.createPhysics=createPhysics
ParticleHelper.physics.createCollisionSensor=createCollisionSensor


------------------
--[[
ParticleHelper Class #3: ParticlePresets

Contains data for the vent presets
--]]
------------------
local cloudTable={"CBEffects/textures/texture-1.png","CBEffects/textures/texture-2.png"}
local burnColors={{255, 255, 10},{255, 155, 10},{255, 10, 10}}
local function velNil()	return 0, 0 end
local function either(table)if #table==0 then return nil else return table[mrand(#table)] end end

local curAngle=1
local function buildDefault() return display.newRect(0, 0, 20, 20) end
local function buildHyperspace() local b=display.newRect(0, 0, 10, 10) b:setReferencePoint(display.CenterLeftReferencePoint) return b end
local function buildPixelWheel() return display.newRect(0, 0, 50, 50) end
local function buildCircles() local size=mrand(5, 30) return display.newCircle(0, 0, size) end
local function buildEmbers() local size=mrand(10, 20) return display.newImageRect("CBEffects/textures/texture-5.png", size, size) end
local function buildFlame() local size=mrand(100, 300) return display.newImageRect(either(cloudTable), size, size) end
local function buildSmoke() local size=mrand(100, 200) return display.newImageRect(either(cloudTable), size, size) end
local function buildSteam() local size=mrand(50, 100) return display.newImageRect(either(cloudTable), size, size) end
local function buildSparks() local size=mrand(10,20) return display.newImageRect("CBEffects/textures/texture-5.png", size, size) end
local function buildRain() return display.newRect(0, 0, mrand(2,4), mrand(6,25)) end
local function buildConfetti() local width=mrand(10, 15) local height=mrand(10, 15) return display.newRect(0, 0, width, height) end
local function buildSnow() local size=mrand(10,40) return display.newImageRect("CBEffects/textures/texture-5.png", size, size) end
local function velSnow() return mrand(-1,1), mrand(10) end
local function buildBeams() local beam=display.newRect(0, 0, math.random(800), 20) beam:setReferencePoint(display.CenterLeftReferencePoint) return beam end
local function buildBurn() local size=math.random(50, 150) return display.newImageRect("CBEffects/textures/texture-5.png", size, size) end
local function onBurnCreation(p) p.colorChange(burnColors[mrand(2)], 200) end
local function buildFountain() local size=math.random(50, 80) return display.newImageRect("CBEffects/textures/texture-5.png", size, size) end
local function buildEvil() local size=math.random(80, 120) return display.newImageRect("CBEffects/textures/texture-5.png", size, size) end
local function buildLGun() return display.newImageRect("CBEffects/textures/texture-5.png", 150, 10) end
local function buildWisp() local s=mrand(20, 180)return display.newImageRect("CBEffects/textures/texture-5.png", s, s) end
local function buildFluid() local s=mrand(100, 400)return display.newImageRect("CBEffects/textures/texture-5.png", s, s) end
local function buildWater() return display.newImageRect("CBEffects/textures/texture-5.png", 160, 20) end
local function buildAurora() local p=display.newImageRect("CBEffects/textures/texture-5.png", mrand(80,150), mrand(160,550)) p:setReferencePoint(display.BottomCenterReferencePoint) return p end

ParticleHelper.presets.vents={}
ParticleHelper.presets.fields={}


ParticleHelper.presets.vents["beams"]={title="beams",isActive=true,build=buildBeams,x=display.contentCenterX,y=display.contentCenterY,color={{255, 0, 0},{0, 0, 255}},iterateColor=false,curColor=1,emitDelay=1,perEmit=1,emissionNum=0,lifeSpan=2000,alpha=0.3,startAlpha=0,endAlpha=0,onCreation=function(p,v)p.rotation=angleBetween(p.x,p.y,v.x,v.y,90)end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=300,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=30,posInner=1,point1={0,-10},point2={display.contentWidth+150,-10},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=0,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,10}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=false,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["burn"]={title="burn",x=display.contentCenterX,y=display.contentCenterY,isActive=true,build=buildBurn,color={{0,0,255}},iterateColor=false,curColor=1,emitDelay=30,perEmit=3,emissionNum=0,lifeSpan=500,alpha=1,startAlpha=0,endAlpha=0,onCreation=onBurnCreation,onDeath=function()end,propertyTable={blendMode="add"},scale=1.0,lifeStart=0,fadeInTime=500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="atPoint",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=2,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{80,100}},preCalculate=true,sizeX=-0.015,sizeY=-0.015,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=-9.8},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["circles"]={title="circles",isActive=true,build=buildCircles,x=0,y=0,color={{0,0,255},{120,120,255},{0,0,255},{120,120,255},{0,0,255},{120,120,255},{255,0,0}},iterateColor=false,curColor=1,emitDelay=100,perEmit=4,emissionNum=0,lifeSpan=1000,alpha=1,endAlpha=0,startAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=300,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={100,display.contentHeight},point2={display.contentWidth-100,display.contentHeight-100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{75,105}},preCalculate=true,sizeX=-0.01,sizeY=-0.01,minX=0.1,minY=0.1,relativeToSize=true,maxX=100,maxY=100,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["default"]={title="default",x=display.contentCenterX,y=display.contentCenterY,isActive=true,build=buildDefault,color={{255,255,255}},iterateColor=false,curColor=1,emitDelay=5,perEmit=2,emissionNum=0,lifeSpan=1000,alpha=1,startAlpha=1,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=0,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=2,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,360}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["hyperspace"]={title="hyperspace",isActive=true,build=buildHyperspace,x=display.contentCenterX,y=display.contentCenterY,color={{255,255,255}},iterateColor=false,curColor=1,emitDelay=100,perEmit=9,emissionNum=0,lifeSpan=1200,alpha=0.5,startAlpha=0,endAlpha=1,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=1,posInner=1,point1={100,display.contentHeight},point2={display.contentWidth-100,display.contentHeight-100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=-0.1,yDamping=-0.1,density=1,velocity=-5,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,360}},preCalculate=true,sizeX=0.1,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=true,offset=90}}
ParticleHelper.presets.vents["pixelwheel"]={title="pixelwheel",isActive=true,build=buildPixelWheel,x=display.contentCenterX,y=display.contentCenterY,color={{120,120,255},{255,255,255}},iterateColor=false,curColor=1,emitDelay=100,perEmit=9,emissionNum=0,lifeSpan=200,alpha=1,startAlpha=1,endAlpha=1,onCreation=function(p, v)p.strokeWidth=10 p:setStrokeColor(0,0,255) v.velAngles={curAngle} curAngle=curAngle+50 end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=500,fadeInTime=0,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="atPoint",posRadius=1,posInner=1,point1={100,display.contentHeight},point2={display.contentWidth-100,display.contentHeight-100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=10,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{10,11}},preCalculate=false,sizeX=0,sizeY=0,minX=0.1,minY=0.1,relativeToSize=true,maxX=100,maxY=100,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["embers"]={title="embers",isActive=true,build=buildEmbers,x=0,y=0,color={{255,255,0},{255,255,0},{255,255,0},{255,255,0},{255,0,0}},iterateColor=false,curColor=1,emitDelay=100,perEmit=2,emissionNum=0,lifeSpan=1000,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=300,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={100,display.contentHeight},point2={display.contentWidth-100,display.contentHeight},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{75,105}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["flame"]={title="flame",isActive=true,build=buildFlame,x=0,y=0,color={{255,255,0},{255,255,0},{255,255,0},{255,255,0},{200,200,0},{200,200,0},{255,100,0}},iterateColor=false,curColor=1,emitDelay=100,perEmit=2,emissionNum=0,lifeSpan=1000,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={blendMode="screen"},scale=1.0,lifeStart=500,fadeInTime=300,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={300,display.contentHeight+100},point2={display.contentWidth-300,display.contentHeight+100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0.2,yDamping=0.2,density=1,velocity=5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{75,105}},preCalculate=true,sizeX=0.02,sizeY=0.02,minX=0.1,minY=0.1,maxX=1000,maxY=1000,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["smoke"]={title="smoke",isActive=true,build=buildSmoke,x=0,y=0,color={{140},{120},{100},{80}},iterateColor=false,curColor=1,emitDelay=100,perEmit=3,emissionNum=0,lifeSpan=1200,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=700,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={200,display.contentHeight-100},point2={display.contentWidth-200,display.contentHeight-100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0.2,yDamping=0.2,density=1,velocity=6,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{75,105}},preCalculate=true,sizeX=0.015,sizeY=0.015,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["steam"]={title="steam",isActive=true,build=buildSteam,x=display.contentCenterX,y=display.contentHeight,color={{255},{230},{200}},iterateColor=false,curColor=1,emitDelay=50,perEmit=10,emissionNum=0,lifeSpan=800,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=200,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=30,posInner=1,point1={100,display.contentHeight-100},point2={display.contentWidth-100,display.contentHeight-100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=12.5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{85,95}},preCalculate=true,sizeX=0.05,sizeY=0.05,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["waterfall"]={title="waterfall",isActive=true,build=buildSteam,x=display.screenOriginX,y=100,color={{255,255,255},{230,230,255},{222,222,255}, {230,255,255}},iterateColor=false,curColor=1,emitDelay=50,perEmit=3,emissionNum=0,lifeSpan=2000,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=200,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=30,posInner=1,point1={100,display.contentHeight-100},point2={display.contentWidth-100,display.contentHeight-100},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=2.5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,0}},preCalculate=true,sizeX=0.03,sizeY=0.06,minX=0.1,minY=0.1,maxX=5,maxY=4,relativeToSize=true,gravityX=0,gravityY=40},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["sparks"]={title="sparks",isActive=true,build=buildSparks,x=display.contentCenterX,y=display.contentCenterY,color={{255,255,255},{230,230,255}},iterateColor=false,curColor=1,emitDelay=1000,perEmit=6,emissionNum=0,lifeSpan=1000,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function(p,v)v.perEmit=math.random(5,15)end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=300,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=30,posInner=1,point1={100,display.contentHeight},point2={display.contentWidth-100,display.contentHeight},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,360}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=9.8},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["rain"]={title="rain",isActive=true,build=buildRain,x=0,y=0,color={{255,255,255},{230,230,255}},iterateColor=false,curColor=1,emitDelay=1,perEmit=1,emissionNum=0,lifeSpan=2000,alpha=0.3,startAlpha=1,endAlpha=1,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=0,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={0,-10},point2={display.contentWidth+150,-10},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=10,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{250,260}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["confetti"]={title="confetti",isActive=true,build=buildConfetti,x=0,y=0,color={{255,0,0},{0,0,255},{255,255,0},{0,255,0}},iterateColor=false,curColor=1,emitDelay=1,perEmit=2,emissionNum=0,lifeSpan=50,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=1900,fadeInTime=100,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={0,-10},point2={display.contentWidth+150,-10},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=5,angularVelocity=0.04,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{200,340}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=9},rotation={towardVel=true,offset=0}}
ParticleHelper.presets.vents["snow"]={title="snow",isActive=true,build=buildSnow,x=0,y=0,color={{255,255,255},{230,230,255}},iterateColor=false,curColor=1,emitDelay=1,perEmit=1,emissionNum=0,lifeSpan=2000,alpha=0.3,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=300,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={0,-10},point2={display.contentWidth+150,-10},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=0,angularVelocity=0.04,angularDamping=0,velFunction=velSnow,useFunction=true,autoAngle=true,angles={{250,260}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["fountain"]={title="fountain",x=display.contentCenterX,y=display.contentCenterY+250,isActive=true,build=buildFountain,color={{0,218,255}},iterateColor=false,curColor=1,emitDelay=5,perEmit=2,emissionNum=0,lifeSpan=500,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={blendMode="screen"},scale=1.0,lifeStart=0,fadeInTime=500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="atPoint",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=12,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{70,110}},preCalculate=true,sizeX=-0.005,sizeY=-0.005,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=35},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["evil"]={title="evil",x=display.contentCenterX,y=display.contentCenterY,isActive=true,build=buildEvil,color={{100,0,100},{0,0,180},{80,0,60}},iterateColor=false,curColor=1,emitDelay=10,perEmit=1,emissionNum=0,lifeSpan=800,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={blendMode="add"},scale=1.0,lifeStart=0,fadeInTime=1500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="atPoint",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=1.5,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,360}},preCalculate=true,sizeX=-0.005,sizeY=-0.005,minX=0.2,minY=0.2,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["lasergun"]={title="lasergun",x=0,y=display.contentCenterY,isActive=true,build=buildLGun,color={{255,255,0}},iterateColor=false,curColor=1,emitDelay=100,perEmit=1,emissionNum=0,lifeSpan=800,alpha=1,startAlpha=0,endAlpha=1,onCreation=function()end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=120,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="atPoint",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=30,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=false,angles={0},preCalculate=true,sizeX=0,sizeY=0,minX=0.2,minY=0.2,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=90}}
ParticleHelper.presets.vents["wisps"]={title="wisps",x=display.contentCenterX,y=display.contentHeight-(display.contentHeight/7),isActive=true,build=buildWisp,color={{255,255,0},{0,255,0}},iterateColor=false,curColor=1,emitDelay=30,perEmit=1,emissionNum=0,lifeSpan=800,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={blendMode="add"},scale=1.0,lifeStart=0,fadeInTime=1500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRadius",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=0,rectWidth=display.contentWidth,rectHeight=display.contentHeight,onUpdate=function(particle, vent)particle:applyForce((vent.x/3)-(particle.x/3), 0)end,physics={xDamping=0,yDamping=0,density=1,velocity=1.5,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{30,150}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=-3},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["fluid"]={title="fluid",x=0,y=0,isActive=true,build=buildFluid,color={{255,0,255},{255,0,0},{255,0,0},{0,0,255}},iterateColor=false,curColor=1,emitDelay=30,perEmit=1,emissionNum=0,lifeSpan=800,alpha=1,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={blendMode="add"},scale=1.0,lifeStart=0,fadeInTime=1500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRect",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=200,rectTop=200,rectWidth=display.contentWidth/1.75,rectHeight=display.contentHeight/1.75,onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=0.5,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{0,360}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["water"]={title="water",x=0,y=0,isActive=true,build=buildWater,color={{255,255,255},{200,200,200}},iterateColor=false,curColor=1,emitDelay=1,perEmit=2,emissionNum=0,lifeSpan=500,alpha=0.5,startAlpha=0,endAlpha=0,onCreation=function(particle) local a=(particle.y-(display.contentHeight/3))/500+0.05 if a<=0.2 then particle.isVisible=false else particle.yScale=a end end,onDeath=function()end,propertyTable={},scale=1.0,lifeStart=0,fadeInTime=500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="inRect",posRadius=30,posInner=1,point1={1,1},point2={2,1},rectLeft=0,rectTop=display.contentHeight/3,rectWidth=display.contentWidth,rectHeight=display.contentHeight-(display.contentHeight/3),onUpdate=function(particle)local a=(particle.y-(display.contentHeight/3))/500+0.05 if a<=0 then particle.xScale=1 particle.isVisible=false else particle.yScale=a end end,physics={xDamping=0,yDamping=0,density=1,velocity=1,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=true,angles={{-20,20},{160,200}},preCalculate=true,sizeX=0,sizeY=0,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}
ParticleHelper.presets.vents["aurora"]={title="aurora",x=0,y=0,isActive=true,build=buildAurora,color={{0,255,0},{150,255,150}},iterateColor=true,curColor=1,emitDelay=1,perEmit=1,emissionNum=0,lifeSpan=1500,alpha=0.2,startAlpha=0,endAlpha=0,onCreation=function()end,onDeath=function()end,propertyTable={blendMode="add"},scale=1.0,lifeStart=0,fadeInTime=500,iteratePoint=false,curPoint=1,lineDensity="total",pointList={{0,0},{1,1}},positionType="alongLine",posRadius=30,posInner=1,point1={display.contentWidth/6,display.contentCenterY+(display.contentHeight/6)},point2={display.contentWidth-(display.contentWidth/6),display.contentCenterY+(display.contentHeight/6)},rectLeft=0,rectTop=display.contentHeight/3,rectWidth=display.contentWidth,rectHeight=display.contentHeight-(display.contentHeight/3),onUpdate=function()end,physics={xDamping=0,yDamping=0,density=1,velocity=1,angularVelocity=0,angularDamping=0,velFunction=velNil,useFunction=false,autoAngle=false,angles={0,180},preCalculate=true,sizeX=0,sizeY=-0.002,minX=0.1,minY=0.1,maxX=100,maxY=100,relativeToSize=true,gravityX=0,gravityY=0},rotation={towardVel=false,offset=0}}

ParticleHelper.presets.fields["default"]={title="default",shape="circle",radius=100,x=display.contentCenterX,y=display.contentCenterY,innerRadius=1,rectLeft=0,rectTop=0,rectWidth=100,rectHeight=100,singleEffect=false,points={0,0,500,500,500,0},onCollision=function(p,f)p:applyForce(f.x-p.x, f.y-p.y)end}
ParticleHelper.presets.fields["out"]={title="out",shape="circle",radius=100,x=display.contentCenterX,y=display.contentCenterY,innerRadius=1,rectLeft=0,rectTop=0,rectWidth=100,rectHeight=100,singleEffect=false,points={0,0,500,500,500,0},onCollision=function(p,f)p:applyForce(p.x-f.x, p.y-f.y)end}
ParticleHelper.presets.fields["colorChange"]={title="colorChange",shape="rect",radius=100,x=display.contentCenterX,y=display.contentCenterY,innerRadius=1,rectLeft=0,rectTop=0,rectWidth=512,rectHeight=768,singleEffect=true,points={0,0,500,500,500,0},onCollision=function(p,f)p.colorChange({0, 0, 255}, 500, 0)end}
ParticleHelper.presets.fields["rotate"]={title="rotate",shape="circle",radius=150,x=display.contentCenterX,y=display.contentCenterY,innerRadius=1,rectLeft=0,rectTop=0,rectWidth=512,rectHeight=768,singleEffect=false,points={0,0,500,500,500,0},onCollision=function(p,f)p.rotation=p.rotation+2 end}
ParticleHelper.presets.fields["stop"]={title="rotate",shape="circle",radius=150,x=display.contentCenterX,y=display.contentCenterY,innerRadius=1,rectLeft=0,rectTop=0,rectWidth=512,rectHeight=768,singleEffect=false,points={0,0,500,500,500,0},onCollision=function(p,f)p:setLinearVelocity(p.velX/2,p.velY/2) end}

return ParticleHelper