------------------
--[[
CBEffects library

This is the main CBEffects library, and what you require().

Version Two and Four-Ninths
--]]
------------------

local CBEffects={}
local VentGroups={}
local FieldGroups={}

local mrand=math.random
math.randomseed(os.time())

local ParticleHelper=require("CBEffects.ParticleHelper")

local masterPresets=ParticleHelper.presets
local masterPhysics=ParticleHelper.physics

local pointInRect=ParticleHelper.pointInRect
local fnn=ParticleHelper.fnn
local lengthOf=ParticleHelper.lengthOf
local pointsAlongLine=ParticleHelper.pointsAlongLine
local forcesByAngle=ParticleHelper.forcesByAngle
local either=ParticleHelper.either
local inRadius=ParticleHelper.inRadius
local inRect=ParticleHelper.inRect
local newTitle=ParticleHelper.newTitle

local VentGroup
local FieldGroup
local DemoPreset

local NilVentGroup
local NilFieldGroup
local NilDemoPreset

--Creates and returns a handle to a new VentGroup
function VentGroup(params)
	local master={_title=newTitle()}
	local vent={}
	local titleReference={}
	
	local numVents=#params
		
	for i=1, numVents do
		vent[i]={}
		vent[i].particle={}
		
		vent[i].velAngles={}
		vent[i].e=1
		
		local params=params
		local preset=masterPresets.vents[params[i].preset] or masterPresets.vents.default
		
		local par=params[i] or {}
		local pPar=preset

		vent[i].x, vent[i].y		= fnn( par.x, pPar.x, 0), fnn( par.y, pPar.y, 0 ) -- One
		vent[i].build           = fnn( par.build, pPar.build, function()return display.newRect(0, 0, 10, 10) end ) -- One
		vent[i].color           = fnn( par.color, pPar.color, {{255, 255, 255}} ) -- One
		vent[i].iterateColor		= fnn( par.iterateColor, pPar.iterateColor, false ) -- Two
		vent[i].curColor				= fnn( par.curColor, pPar.curColor, 1 ) -- Two
		
		vent[i].emitDelay       = fnn( par.emitDelay, pPar.emitDelay, 500 ) -- One
		vent[i].perEmit         = fnn( par.perEmit, pPar.perEmit, 5 ) -- One
		vent[i].emissionNum     = fnn( par.emissionNum, pPar.emissionNum, 50 ) -- One
		vent[i].emissionNum 		= math.abs(math.round(vent[i].emissionNum))

		vent[i].lifeSpan	      = fnn( par.lifeSpan, pPar.lifeSpan, 1000 ) -- One
		vent[i].alpha           = fnn( par.alpha, pPar.alpha, 1) -- One
		vent[i].startAlpha      = fnn( par.startAlpha, pPar.startAlpha, 0 ) -- One
		vent[i].endAlpha        = fnn( par.endAlpha, pPar.endAlpha, 0 ) -- One
		vent[i].lifeStart       = fnn( par.lifeStart, pPar.lifeStart, 1000) -- One
		vent[i].fadeInTime      = fnn( par.fadeInTime, pPar.fadeInTime, 500 ) -- One
		vent[i].onCreation      = fnn( par.onCreation, pPar.onCreation, function()end ) -- One
		vent[i].onDeath	      	= fnn( par.onDeath, pPar.onDeath, function()end ) -- One
		vent[i].onUpdate				= fnn( par.onUpdate, pPar.onUpdate, function()end ) -- Two
		vent[i].propertyTable   = fnn( par.propertyTable, pPar.propertyTable, {} ) -- One
		vent[i].scale						= fnn( par.scale, pPar.scale, 1 ) -- One and One-Fourth
		vent[i].parentGroup			= par.parentGroup
		
		local parPhysics      	= par.physics or {} -- One
		local pParPhysics     	= pPar.physics
		
		vent[i].linearDamping   = fnn( parPhysics.linearDamping, pParPhysics.linearDamping, 1 ) -- One
		vent[i].xDamping				= fnn( parPhysics.xDamping, vent[i].linearDamping, pParPhysics.xDamping, pParPhysics.linearDamping ) -- One and Three-Fourths
		vent[i].yDamping				= fnn( parPhysics.yDamping, vent[i].linearDamping, pParPhysics.yDamping, pParPhysics.linearDamping ) -- One and Three-Fourths
		vent[i].density         = fnn( parPhysics.density, pParPhysics.density, 1 ) -- One
		vent[i].velocity        = fnn( parPhysics.velocity, pParPhysics.velocity, 15 ) -- One
		vent[i].angularVelocity = fnn( parPhysics.angularVelocity, pParPhysics.angularVelocity, 0 ) -- One
		vent[i].angularDamping  = fnn( parPhysics.angularDamping, pParPhysics.angularDamping, 0 ) -- One
		vent[i].sizeX           = fnn( parPhysics.sizeX, pParPhysics.sizeX, 0.01 ) -- One
		vent[i].sizeY           = fnn( parPhysics.sizeY, pParPhysics.sizeY, 0.01 ) -- One
		vent[i].maxX            = fnn( parPhysics.maxX, pParPhysics.maxX, 3 ) -- One
		vent[i].maxY            = fnn( parPhysics.maxY, pParPhysics.maxY, 3 ) -- One
		vent[i].minX            = fnn( parPhysics.minX, pParPhysics.minX, 0.1 ) -- One
		vent[i].minY            = fnn( parPhysics.minY, pParPhysics.minY, 0.1 ) -- One
		vent[i].velFunction     = fnn( parPhysics.velFunction, pParPhysics.velFunction, function()end ) -- One
		vent[i].useFunction     = fnn( parPhysics.useFunction, pParPhysics.useFunction, false ) -- One
		vent[i].relativeToSize	= fnn( parPhysics.relativeToSize, pParPhysics.relativeToSize, false ) -- Two
		vent[i].divisionDamping = fnn( parPhysics.divisionDamping, pParPhysics.divisionDamping, true ) -- Two and One-Fourth
		
		local autoAngle       	= fnn( parPhysics.autoAngle, pParPhysics.autoAngle, false ) -- One
		vent[i].angles          = fnn( parPhysics.angles, pParPhysics.angles, {1} ) -- One
		vent[i].preCalculate		= fnn( parPhysics.preCalculate, pParPhysics.preCalculate, true ) -- Two
		vent[i].iterateAngle		= fnn( parPhysics.iterateAngle, pParPhysics.iterateAngle, false ) -- Two and One-Fourth
		vent[i].curAngle				= fnn( parPhysics.curAngle, pParPhysics.curAngle, 1 ) -- Two and One-Fourth

		vent[i].gravX           = fnn( parPhysics.gravityX, pParPhysics.gravityX, 0 ) -- One
		vent[i].gravY           = fnn( parPhysics.gravityY, pParPhysics.gravityY, 9.8 ) -- One
		
		vent[i].positionType    = fnn( par.positionType, pPar.positionType, "alongLine") -- One
		
		vent[i].pointList				= fnn( par.pointList, pPar.pointList, {{0,0},{5,5},{10,10},{20,20}} ) -- Two
		vent[i].iteratePoint		= fnn( par.iteratePoint, pPar.iteratePoint, false ) -- Two
		vent[i].curPoint				= fnn( par.curPoint, pPar.curPoint, 1 ) -- Two
		
		local point1          	= fnn( par.point1, pPar.point1, {0,0} ) -- One
		local point2          	= fnn( par.point2, pPar.point2, {500, 0} ) -- One
		vent[i].lineDensity			= fnn( par.lineDensity, pPar.lineDensity, "total" ) -- Two
		
		vent[i].posRadius       = fnn( par.posRadius, pPar.posRadius, 10 ) -- One
		vent[i].posInner        = fnn( par.posInner, pPar.posInner, 1 ) -- One
		
		vent[i].rectLeft        = fnn( par.rectLeft, pPar.rectLeft, 0 ) -- One
		vent[i].rectTop         = fnn( par.rectTop, pPar.rectTop, 0 ) -- One
		vent[i].rectWidth       = fnn( par.rectWidth, pPar.rectWidth, 50 ) -- One
		vent[i].rectHeight      = fnn( par.rectHeight, pPar.rectHeight, 50 ) -- One
				
		local rotation       		= par.rotation or {}
		local pRotation       	= pPar.rotation
		
		vent[i].towardVel       = fnn( rotation.towardVel, pRotation.towardVel, false ) -- One
		vent[i].offset          = fnn( rotation.offset, pRotation.offset, 0 ) -- One
		
		vent[i].pointTable      = pointsAlongLine(point1[1]*vent[i].scale, point1[2]*vent[i].scale, point2[1]*vent[i].scale, point2[2]*vent[i].scale, vent[i].lineDensity)
	
		if ( autoAngle ) then
			for w=1, #vent[i].angles do
				for a=vent[i].angles[w][1], vent[i].angles[w][2], 0.5 do
					if vent[i].preCalculate then
						vent[i].velAngles[#vent[i].velAngles+1]=forcesByAngle(vent[i].velocity, a)
					else
						vent[i].velAngles[#vent[i].velAngles+1]=a
					end
				end
			end
		else
			if vent[i].preCalculate then
				for a=1, #vent[i].angles do
					vent[i].velAngles[#vent[i].velAngles+1]=forcesByAngle(vent[i].velocity, vent[i].angles[a])
				end
			else
				for a=1, #vent[i].angles do
					vent[i].velAngles[#vent[i].velAngles+1]=vent[i].angles[a]
				end
			end
		end
		
		vent[i].pPhysics=masterPhysics.createPhysics()
		vent[i].pPhysics.start()
		vent[i].pPhysics.setGravity(vent[i].gravX, vent[i].gravY)
		vent[i].pPhysics.parentVent=vent[i]
		vent[i].pPhysics.useDivisionDamping=vent[i].divisionDamping
		
		vent[i].isActive						= fnn( par.isActive, pPar.isActive, true ) -- One
		vent[i].title								= fnn( par.title, pPar.title, "vent" ) -- One
		
		titleReference[vent[i].title]=vent[i]
		vent[i].roundNum=0
						
		vent[i].content=display.newGroup()
		vent[i].content.x, vent[i].content.y=fnn( par.contentX, pPar.contentX, 0 ), fnn( par.contentY, pPar.contentY, 0 ) -- Two
		
		if vent[i].parentGroup then
			vent[i].parentGroup:insert(vent[i].content) -- Two
		end

		vent[i].emit=function()
			for l=1, vent[i].perEmit do
				vent[i].particle[vent[i].e]=vent[i].build(vent[i])
				vent[i].roundNum=l
				local p=vent[i].particle[vent[i].e]
				vent[i].e=vent[i].e+1
				vent[i].pPhysics.addBody(p, "dynamic", {relative=vent[i].relativeToSize, density=vent[i].density*vent[i].scale, xbL=vent[i].maxX*vent[i].scale, ybL=vent[i].maxY*vent[i].scale, xbS=vent[i].minX*vent[i].scale, ybS=vent[i].minY*vent[i].scale, sizeX=vent[i].sizeX*vent[i].scale, sizeY=vent[i].sizeY*vent[i].scale, rotateToVel=vent[i].towardVel, offset=vent[i].offset})
				p._prevX, p._prevY=p.x, p.y
				p.ParticleCollision=false
	
				p.alpha=vent[i].startAlpha
				
				p.width, p.height=p.width*vent[i].scale, p.height*vent[i].scale
					
				p.xDamping=vent[i].xDamping*vent[i].scale
				p.yDamping=vent[i].yDamping*vent[i].scale
				p.angularDamping=vent[i].angularDamping
			
				p.n=vent[i].e-1
								
				if type(vent[i].angularVelocity)=="number" then
					p.angularVelocity=vent[i].angularVelocity
				elseif type(vent[i].angularVelocity)=="function" then
					p.angularVelocity=vent[i].angularVelocity()
				end
				
				if type(vent[i].lifeSpan)=="number" then
					p.lifeSpan=vent[i].lifeSpan
				elseif type(vent[i].lifeSpan)=="function" then
					p.lifeSpan=vent[i].lifeSpan()
				end
				
				if type(vent[i].lifeStart)=="number" then
					p.lifeStart=vent[i].lifeStart
				elseif type(vent[i].lifeStart)=="function" then
					p.lifeStart=vent[i].lifeStart()
				end
				
				for k, v in pairs(vent[i].propertyTable) do
					p[k]=vent[i].propertyTable[k]
				end

				if vent[i].useFunction==true then
					local xVel, yVel=vent[i].velFunction(p, vent[i], vent[i].content)
					p:setLinearVelocity(xVel*vent[i].scale, yVel*vent[i].scale)
				else
					if not vent[i].iterateAngle then
						if vent[i].preCalculate==true then
							p.angleTable=either(vent[i].velAngles)
							p:setLinearVelocity(p.angleTable.x*vent[i].scale, p.angleTable.y*vent[i].scale)
						else
							p.angle=either(vent[i].velAngles)
							p.velTable=forcesByAngle(vent[i].velocity, p.angle)
							p:setLinearVelocity(p.velTable.x*vent[i].scale, p.velTable.y*vent[i].scale)
						end
					else
						if vent[i].preCalculate==true then
							p.angleTable=vent[i].velAngles[vent[i].curAngle]
							p:setLinearVelocity(p.angleTable.x*vent[i].scale, p.angleTable.y*vent[i].scale)
						else
							p.angle=vent[i].velAngles[vent[i].curAngle]
							p.velTable=forcesByAngle(vent[i].velocity, p.angle)
							p:setLinearVelocity(p.velTable.x*vent[i].scale, p.velTable.y*vent[i].scale)
						end
						vent[i].curAngle=vent[i].curAngle+1
						if vent[i].curAngle>=#vent[i].velAngles+1 then
							vent[i].curAngle=1
						end							
					end
				end

				if "inRadius"==vent[i].positionType then
					p.x, p.y=inRadius(vent[i].x, vent[i].y, vent[i].posRadius*vent[i].scale, vent[i].posInner*vent[i].scale)
				elseif "alongLine"==vent[i].positionType then
					local pPoint=either(vent[i].pointTable)
					p.x, p.y=pPoint[1], pPoint[2]
				elseif "inRect"==vent[i].positionType then
					p.x, p.y=inRect(vent[i].x, vent[i].y, vent[i].rectLeft*vent[i].scale, vent[i].rectTop*vent[i].scale, vent[i].rectWidth*vent[i].scale, vent[i].rectHeight*vent[i].scale)
				elseif "atPoint"==vent[i].positionType then
					p.x, p.y=vent[i].x, vent[i].y
				elseif "fromPointList"==vent[i].positionType then
					if vent[i].iteratePoint then
						local pointX, pointY=unpack(vent[i].pointList[vent[i].curPoint])
						p.x, p.y=pointX+vent[i].x, pointY+vent[i].y
					else
						local pointX, pointY=unpack(either(vent[i].pointList))
						p.x, p.y=pointX+vent[i].x, pointY+vent[i].y
					end
				elseif type(vent[i].positionType)=="function" then
					p.x, p.y=vent[i].positionType(p, vent[i], vent[i].content)
				end
				
				if p["setFillColor"] then
					p.physicsColor=p["setFillColor"]
					if type(vent[i].color)=="table" then
						local pColor
						if vent[i].iterateColor then
							pColor=vent[i].color[vent[i].curColor]
						else
							pColor=either(vent[i].color)
						end
						p.colorSet={r=pColor[1] or 0, g=pColor[2] or pColor[1], b=pColor[3] or pColor[1], a=pColor[4] or 255}
						p:setFillColor(unpack(pColor))
						p.colorChange=function(colorTo, time, delay, trans)
							if colorTo then
								p.colorTrans=transition.to(p.colorSet, {r=colorTo[1] or p.colorSet.r, g=colorTo[2] or p.colorSet.g, b=colorTo[3] or p.colorSet.b, a=colorTo[4] or p.colorSet.a, time=time or 1000, delay=delay or 0, transition=trans or easing.linear})
							end
						end
					elseif type(vent[i].color)=="function" then
						p:setFillColor(vent[i].color())
					end
				elseif p["setTextColor"] then
					p.physicsColor=p["setTextColor"]
					if type(vent[i].color)=="table" then
						local pColor=either(vent[i].color)
						p.colorSet={r=pColor[1] or 0, g=pColor[2] or pColor[1], b=pColor[3] or pColor[1], a=pColor[4] or 255}
						p:setTextColor(unpack(pColor))
						p.colorChange=function(colorTo, time, delay, trans)
							if colorTo then
								p.colorTrans=transition.to(p.colorSet, {r=colorTo[1] or p.colorSet.r, g=colorTo[2] or p.colorSet.g, b=colorTo[3] or p.colorSet.b, a=colorTo[4] or p.colorSet.a, time=time or 1000, delay=delay or 0, transition=trans or easing.linear})
							end
						end
					elseif type(vent[i].color)=="function" then
						p:setTextColor(vent[i].color())
					end
				end
				
				p.kill=function()
					vent[i].onDeath(vent[i].particle[p.n], vent[i])
					if vent[i].particle[p.n].colorTrans then 
						transition.cancel(vent[i].particle[p.n].colorTrans)
						vent[i].particle[p.n].colorTrans=nil 
					end
					vent[i].pPhysics.removeBody(vent[i].particle[p.n])
					display.remove(vent[i].particle[p.n]) 
					vent[i].particle[p.n]=nil
				end
				
				p.inTrans=transition.to(p, {alpha=vent[i].alpha, time=vent[i].fadeInTime}) 
				p.trans=transition.to(p, {alpha=vent[i].endAlpha, time=p.lifeSpan*vent[i].scale, delay=p.lifeStart+vent[i].fadeInTime, onComplete=p.kill})
				
				if vent[i].iteratePoint then
					if vent[i].curPoint<#vent[i].pointList then
						vent[i].curPoint=vent[i].curPoint+1
					else
						vent[i].curPoint=1
					end
				end
				
				if vent[i].iterateColor then
					if vent[i].curColor<#vent[i].color then
						vent[i].curColor=vent[i].curColor+1
					else
						vent[i].curColor=1
					end
				end
				
				vent[i].onCreation(vent[i].particle[p.n], vent[i], vent[i].content)
				vent[i].content:insert(vent[i].particle[p.n])
									
			end			
			vent[i].roundNum=0		
		end
		
		vent[i].resetPoints=function()
			vent[i].pointTable=pointsAlongLine(vent[i].point1[1]*vent[i].scale, vent[i].point1[2]*vent[i].scale, vent[i].point2[1]*vent[i].scale, vent[i].point2[2]*vent[i].scale, vent[i].lineDensity)
		end
		
		vent[i].set=function(params)
			for k, v in pairs(params) do
				vent[i][k]=params[k]
			end
		end
		
		master[vent[i].title]=vent[i].emit
		
		par=nil
		pPar=nil
		parPhysics=nil
		pParPhysics=nil
		rotation=nil
		pRotation=nil
		point1=nil
		point2=nil
		autoAngle=nil
	end

	function master:startMaster()
		for i=1, numVents do
			if vent[i] then
				if vent[i].isActive==true then
					vent[i].particleTimer=timer.performWithDelay(vent[i].emitDelay, vent[i].emit, 0)
				end
			end
		end
	end
	
	function master:emitMaster()
		for i=1, numVents do
			if vent[i] then
				if vent[i].isActive==true then
					vent[i].emit()
				end
			end
		end
	end
	
	function master:stopMaster()
		for i=1, numVents do
			if vent[i] then
				if vent[i].particleTimer then
					timer.cancel(vent[i].particleTimer)
				end
			end
		end
	end
	
	function master:start(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t].particleTimer=timer.performWithDelay(titleReference[t].emitDelay, titleReference[t].emit, titleReference[t].emissionNum)
			elseif not titleReference[t] then
				print("Missing vent \""..t.."\"")
			end
		end
	end
	
	function master:emit(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t].emit()
			elseif not titleReference[t] then
				print("Missing vent \""..t.."\"")
			end
		end
	end
	
	function master:stop(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				if titleReference[t].particleTimer then
					timer.cancel(titleReference[t].particleTimer)
				end
			elseif not titleReference[t] then
				print("Missing vent \""..t.."\"")
			end
		end
	end
	
	function master:get(...)
		local getTable={}
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				getTable[i]=titleReference[t]
			else
				getTable[i]="Missing vent \""..t.."\""
				print(getTable[i])
			end
		end
		return unpack(getTable)
	end
	
	function master:clean(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				for i=1, titleReference[t].e do
					if titleReference[t].particle[i] then
						if titleReference[t].particle[i].inTrans then
							transition.cancel(titleReference[t].particle[i].inTrans)
							titleReference[t].particle[i].inTrans=nil
						end
						if titleReference[t].particle[i].trans then
							transition.cancel(titleReference[t].particle[i].trans)
							titleReference[t].particle[i].trans=nil
						end
						if titleReference[t].particle[i].colorTrans then
							transition.cancel(titleReference[t].particle[i].colorTrans)
							titleReference[t].particle[i].colorTrans=nil
						end
						
						titleReference[t].pPhysics.removeBody(titleReference[t].particle[i])
						display.remove(titleReference[t].particle[i])
						titleReference[t].particle[i]=nil
					end
				end
				titleReference[t].e=1
			else
				print("Missing vent \""..t.."\"")
			end
		end
	end	
	
	function master:destroy(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				master:clean(t)
				if titleReference[t].particleTimer then
					timer.cancel(titleReference[t].particleTimer)
					titleReference[t].particleTimer=nil
				end
				titleReference[t].pPhysics.cancel()
				titleReference[t].pPhysics=nil
				display.remove(titleReference[t].content)
				titleReference[t].content=nil
				for k, v in pairs(titleReference[t]) do
					titleReference[t][k]=nil
				end
				titleReference[t]=nil
				return true
			else
				print("Missing vent \""..t.."\"")
			end
			t=nil
		end
	end
	
	function master:destroyMaster()
		for i=1, #vent do
			master:destroy(vent[i].title)
		end
		VentGroups[master._title]=nil
		for k, v in pairs(master) do
			master[k]=nil
		end
		for k, v in pairs(titleReference) do
			titleReference[k]=nil
		end
		vent=nil
		master=nil
		titleReference=nil
		numVents=nil
	end
	
	function master:translate(t, x, y)
		if titleReference[t] then
			titleReference[t].x, titleReference[t].y=x or display.contentCenterX, y or display.contentCenterY
		else
			print("Missing vent \""..t.."\"")
		end
	end

	VentGroups[master._title]=master

	return master
end

--Creates and returns a new FieldGroup
function FieldGroup(params)
	local numFields=#params
	local field={_title=newTitle()}
	local titleReference={}
	
	for i=1, numFields do
		local fieldParams={}
		
		local preset=masterPresets.fields[params[i].preset] or masterPresets.fields["default"]
		
		fieldParams.shape							= fnn( params[i].shape, preset.shape, "rect" )
		fieldParams.rectWidth					= fnn( params[i].rectWidth, preset.rectWidth, 100 )
		fieldParams.rectHeight				= fnn( params[i].rectHeight, preset.rectHeight, 100 )
		fieldParams.x									= fnn( params[i].x, preset.x, 0 )
		fieldParams.y									= fnn( params[i].y, preset.y, 0 )
		fieldParams.radius						= fnn( params[i].radius, preset.radius, 50 )
		fieldParams.points						= fnn( params[i].points, preset.points, {0, 0, 500, 500, 500, 0} )
		fieldParams.onCollision				= fnn( params[i].onCollision, preset.onCollision, function()end )
		fieldParams.singleEffect		 	= fnn( params[i].singleEffect, preset.singleEffect, false )
		
		local targetVent=params[i].targetVent
		fieldParams.targetPhysics=targetVent.pPhysics
		
		field[i]=masterPhysics.createCollisionSensor(fieldParams)
		field[i].title								= fnn(params[i].title, preset.title, "field")
		titleReference[field[i].title]=field[i]

		field[i].set=function(params)
			for k, v in pairs(params) do
				field[k]=params[k]
			end
		end
				
	end
	
	function field:translate(t, x, y)
		if titleReference[t] then
			titleReference[t].x, titleReference[t].y=x, y
		elseif not titleReference[t] then
			print("ERROR: Field \""..t.."\" was not found for \"translate\" command.")
		end
	end
	
	function field:start(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t].start()
			elseif not titleReference[t] then
				print("Missing field \""..t.."\"")
			end	
		end
	end
	
	function field:stop(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t].stop()
			elseif not titleReference[t] then
				print("Missing field \""..t.."\"")
			end
		end
	end
	
	function field:destroy(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t].cancel()
				titleReference[t]=nil
			elseif not titleReference[t] then
				print("Missing field \""..t.."\"")
			end
		end
	end
	
	function field:startMaster()
		for i=1, #field do
			field[i].start()
		end
	end
	
	function field:stopMaster()
		for i=1, #field do
			field[i].stop()
		end
	end
	
	function field:destroyMaster()
		for i=1, #field do
			field:destroy(field[i].title)
		end
		FieldGroups[field._title]=nil
		for k, v in pairs(field) do
			--field[k]=nil
		end
		field=nil
	end
	
	function field:get(...)
		local getTable={}
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				getTable[i]=titleReference[t]
			else
				getTable[i]="Missing field \""..t.."\""
				print(getTable[i])
			end
		end
		return unpack(getTable)
	end
	
	FieldGroups[field._title]=field

	return field
end

--Builds and returns a raw preset VentGroup without parameter additions and starts it
function DemoPreset(preset)
	local presetVentGroup=VentGroup{
		{
			preset=preset
		}
	}
	presetVentGroup:startMaster()
	return presetVentGroup
end


--Returns a fake VentGroup
function NilVentGroup(params)
	local master={}
	local vent={}
	local titleReference={}
	
	local numVents=#params
		
	for i=1, numVents do
		vent[i]={}
				
		vent[i].pPhysics={
			start=function()end,
			pause=function()end,
			cancel=function()end,
			setGravity=function()end,
			addBody=function()end,
			removeBody=function()end
		}

		vent[i].title								= fnn( params[i].title, params[i].preset, "vent"..i )
		
		titleReference[vent[i].title]=vent[i]
						
		vent[i].content={}
		
		vent[i].emit=function()end
		
		vent[i].resetPoints=function()end
		
		vent[i].set=function()end
		
		master[vent[i].title]=vent[i].emit
		
	end

	function master:startMaster()end
	
	function master:emitMaster()end
	
	function master:stopMaster()end
	
	function master:start()end
	
	function master:emit()end
	
	function master:stop()end
	
	function master:get(...)
		local getTable={}
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				getTable[i]=titleReference[t]
			else
				getTable[i]="Missing vent \""..t.."\""
				print(getTable[i])
			end
		end
		return unpack(getTable)
	end
	
	function master:clean()end	
	
	function master:destroy(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t]=nil
				return true
			else
				print("Missing vent \""..t.."\"")
			end
		end
	end
	
	function master:destroyMaster()
		for i=1, #vent do
			master:destroy(vent[i].title)
		end
		for k, v in pairs(master) do
			master[k]=nil
		end
		master=nil
	end
	
	function master:translate()end

	return master
end

--The same, only now it's a fake FieldGroup
local function NilFieldGroup(params)
	local numFields=#params
	local field={}
	local titleReference={}
	
	for i=1, numFields do
		field[i]={}
		field[i].title=fnn(params[i].title, params[i].preset, "field"..i)
		titleReference[field[i].title]=field[i]		
	end
	
	function field:translate()end
	
	function field:start()end
	
	function field:stop()end
	
	function field:destroy(...)
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				titleReference[t]=nil
			elseif not titleReference[t] then
				print("Missing field \""..t.."\"")
			end
		end
	end
	
	function field:startMaster()end
	
	function field:stopMaster()end
	
	function field:destroyMaster()
		for i=1, #field do
			field:destroy(field[i].title)
		end
		for k, v in pairs(field) do
			field[k]=nil
		end
		field=nil
	end
	
	function field:get(...)
		local getTable={}
		for i=1, #arg do
			local t=arg[i]
			if titleReference[t] then
				getTable[i]=titleReference[t]
			else
				getTable[i]="Missing field \""..t.."\""
				print(getTable[i])
			end
		end
		return unpack(getTable)
	end
	
	return field
end

--Demo preset, fake version
local function NilDemoPreset(preset)
	local presetVentGroup=NilVentGroup{
		{
			preset=preset
		}
	}
	return presetVentGroup
end


--Change the render type
local function Render(renderType)
	if renderType=="hidden" then
		CBEffects.VentGroup=NilVentGroup
		CBEffects.FieldGroup=NilFieldGroup
		CBEffects.DemoPreset=NilDemoPreset
	else
		CBEffects.VentGroup=VentGroup
		CBEffects.FieldGroup=FieldGroup
		CBEffects.DemoPreset=DemoPreset
	end
end

--Delete all existing CBObjects (VentGroups and FieldGroups)
local function DeleteAll()
	for k, v in pairs(VentGroups) do
		VentGroups[k]:destroyMaster()
		VentGroups[k]=nil
	end
	for k, v in pairs(FieldGroups) do
		FieldGroups[k]:destroyMaster()
		FieldGroups[k]=nil
	end
end

CBEffects.VentGroup=VentGroup
CBEffects.FieldGroup=FieldGroup
CBEffects.DemoPreset=DemoPreset
CBEffects.Render=Render
CBEffects.DeleteAll=DeleteAll

return CBEffects