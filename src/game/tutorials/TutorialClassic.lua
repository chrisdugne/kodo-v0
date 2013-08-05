-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

scene = {}
local currentStep = 0

-----------------------------------------------------------------------------------------
--set up collision filters

local asteroidFilter = { categoryBits=1, maskBits=14 }
local planetFilter 	= { categoryBits=8, maskBits=1 }

-----------------------------------------------------------------------------------------

function start(view)
	scene = view
	
	hud.setExit(function()
		if(currentStep > 1 and texts[currentStep-1].item) then
   		hud.explode(texts[currentStep-1].item)
   	end
		
		if(currentStep > 1 and arrows[currentStep-1].item) then
			hud.explode(arrows[currentStep-1].item)
   	end
   	
		if(texts[currentStep].item) then
   		hud.explode(texts[currentStep].item)
   	end
		
		if(arrows[currentStep].item) then
			hud.explode(arrows[currentStep].item)
   	end
	end)
	
	stepContent[1]()

-- debug got to step
--	game.setPlanetColor(GREEN)
--	hud.setupButtons()
--	currentStep = 5
--	step(6)
end

-----------------------------------------------------------------------------------------

function step(num)

	-------------------------------------------------
	-- Checking tutorial status
	
	if(game.mode ~= game.CLASSIC) then
		-- going from a tuto to another : both continue ??
		return
	end
	
	if(currentStep < num-1) then
		-- Classic tutorial exit + come back
		return
	end

	if(currentStep == num) then
		-- Tutorial exit at step 1 and come back as quick as possible... return here and this will catch the previous stepper
		return
	end

	-------------------------------------------------

	local next
	currentStep = num
	next = stepContent[num]

	openStep(num, next)
end

-----------------------------------------------------------------------------------------

function openStep(step, next)

	if (game.state == game.IDLE) then
		return
	end

	if(conditionFilled(step-1)) then
		transition.to( texts[step-1].item, 		{ time=300, alpha=0, onComplete = function() display.remove(texts[step-1].item) end		})
		transition.to( arrows[step-1].item, 	{ time=300, alpha=0, onComplete = function() display.remove(arrows[step-1].item) end 	})
		next()
	else
		timer.performWithDelay( 40, function ()
			openStep(step, next)
		end) 
   end
end

-----------------------------------------------------------------------------------------

function conditionFilled(step)

	if(step == 4) then
		return game.planet.color == COLORS[2]
	else
		return true
	end
	
end

-----------------------------------------------------------------------------------------

stepContent = {
	------ Step 1
   function()
   	currentStep = 1
   	game.setPlanetColor(COLORS[1])
   	displayArrow(1)
   end,
	------ Step 2
	function() 
		local asteroid = createAsteroid(COLORS[2], -math.pi/3, 180, 2)
		local vx, vy = asteroid:getLinearVelocity() 
		displayText(2)
	end,
	------ Step 3
	function() 
   	hud.setupButtons()
		local asteroid = game.getAsteroid("asteroid_step2")
		asteroid.vx, asteroid.vy = asteroid:getLinearVelocity()
		asteroid:setLinearVelocity( 0, 0 )
		displayArrow(3)
		
   	square = display.newImage(game.scene, "assets/images/hud/square.png")
   	square:scale(0.35,0.35)
   	square.x = asteroid.x
   	square.y = asteroid.y
	end,
	------ Step 4
	function()
		display.remove(square) 
		displayArrow(4)
	end,
	------ Step 5
	function() 
   	hud.disableColors()
   	local asteroid = game.getAsteroid("asteroid_step2")
		asteroid:setLinearVelocity( asteroid.vx, asteroid.vy )
		displayText(5)
	end,
	------ Step 22
	function()
		game.endGame("Tutorial Complete !", router.openAppHome)
		GLOBALS.savedData.requireTutorial = false
   	utils.saveTable(GLOBALS.savedData, "savedData.json")
		displayText(6)
		
		timer.performWithDelay(1600, function() hud.explode(texts[6].item) end)
	end
}

-----------------------------------------------------------------------------------------

function createAsteroid(color, alpha, distance, step)
	
	local asteroid = display.newImageRect( "assets/images/game/asteroid." .. color .. ".png", 48, 48 )
	asteroid.color = color
	physics.addBody( asteroid, { bounce=0, radius=24, filter=asteroidFilter } )
	
	local planetCenterPoint = vector2D:new(display.contentWidth/2, display.contentHeight/2)
	
	local asteroidPoint = vector2D:new(distance*math.cos(alpha), distance*math.sin(alpha))
	asteroidPoint = vector2D:Add(planetCenterPoint, asteroidPoint)
	asteroid.x = asteroidPoint.x
	asteroid.y = asteroidPoint.y

	asteroidDirection = vector2D:Sub(planetCenterPoint, asteroidPoint)
	asteroidDirection:mult(20/100) --random range : level params
	asteroid:setLinearVelocity( asteroidDirection.x, asteroidDirection.y )
	
	asteroid.collision = game.crashAsteroid  
	asteroid:addEventListener( "collision", asteroid )
	asteroid.name = "asteroid_step".. step
	
	table.insert(game.asteroids, asteroid)
	
	return asteroid
end

-----------------------------------------------------------------------------------------

function displayArrow(num, velocityX, velocityY)

	local arrow = display.newImage("assets/images/tutorial/arrow.".. arrows[num].way ..".png")
	arrow:scale(0.21,0.21)
	arrow.x = arrows[num].xFrom
	arrow.y = arrows[num].yFrom
	scene:insert(arrow)
	
	if(velocityX) then
		physics.addBody( arrow, { bounce=0, radius=12, filter=asteroidFilter } )
		arrow:setLinearVelocity( velocityX, velocityY )
	end
	
	transition.to( arrow, { time=200, x = arrows[num].xTo, y = arrows[num].yTo , onComplete=function() displayText(num) end } )
	
	arrows[num].item = arrow
end

-----------------------------------------------------------------------------------------

function displayText(num)

	local text = display.newText( texts[num].text, 0, 0, FONT, 15 )
	text:setTextColor( 255 )	
	text.alpha = 0
	text.x = texts[num].x
	text.y = texts[num].y
	scene:insert(text)
	texts[num].item = text

	transition.to( text, { 
		time=300, 
		alpha=1, 
		onComplete = function()
			timer.performWithDelay( texts[num].delay, function ()
				step(num+1)
			end) 
		end
	})
end

-----------------------------------------------------------------------------------------

texts = {
	{ --------------------------- STEP 1
		text 	= T "This is Big Kodo",
		x 		= display.contentWidth/5,
		y 		= display.contentHeight/2,
		delay = 1700,
	},
	{ --------------------------- STEP 2 
		text 	= T "And this is a small Kodo",
		x 		= display.contentWidth/2,
		y 		= 100,
		delay = 1700,
	},
	{ --------------------------- STEP 3
		text 	= T "These buttons change Big Kodo",
		x 		= display.contentWidth/2,
		y 		= display.contentHeight - 125,
		delay = 1500,
	},
	{ --------------------------- STEP 4
		text 	= T "Match the small Kodo",
		x 		= display.contentWidth/2,
		y 		= display.contentHeight - 125,
		delay = 100,
	},
	{ --------------------------- STEP 5
		text 	= T "You catch small Kodos when they match",
		x 		= display.contentWidth/2,
		y 		= display.contentHeight/2 + 40,
		delay = 2000,
	},
	{ --------------------------- STEP 22
		text 	= T "Well done ! Now you're ready to play !",
		x 		= display.contentWidth/2,
		y 		= display.contentHeight/2 + 40,
		delay = 800,
	},
}

-----------------------------------------------------------------------------------------

arrows = {
	{ --------------------------- STEP 1
		way 			= "right",
		xFrom 		= 110,
		yFrom 		= display.contentHeight/2,
		xTo 			= display.contentWidth/2 - 60,
		yTo 			= display.contentHeight/2
	},
	{ --------------------------- STEP 2
	},
	{ --------------------------- STEP 3
		way 			= "right",
		xFrom 		= display.contentWidth /2,
		yFrom 		= display.contentHeight - 70,
		xTo 			= display.contentWidth - 170,
		yTo 			= display.contentHeight - 70
	},
	{ --------------------------- STEP 4
		way 			= "right",
		xFrom 		= display.contentWidth - 170,
		yFrom 		= display.contentHeight - 70,
		xTo 			= display.contentWidth - 170,
		yTo 			= display.contentHeight - 70
	},
	{ --------------------------- STEP 5
	},
	{ --------------------------- STEP 22
	},
}

-----------------------------------------------------------------------------------------
