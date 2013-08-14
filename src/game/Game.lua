-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

scene = {} 

-----------------------------------------------------------------------------------------

RUNNING 		= 1
IDLE 			= 2
INTROASTEROIDS = 3

-----------------------------------------------------------------------------------------

CLASSIC 		= 0
COMBO 		= 1
KAMIKAZE 	= 2
TIMEATTACK 	= 3

-----------------------------------------------------------------------------------------

state 				= IDLE
timePlayed			= 0
planetFire			= nil
planet 				= {}
asteroids 			= {}
asteroidsCaught 	= {}

-----------------------------------------------------------------------------------------
--set up collision filters

local asteroidFilter = { categoryBits=1, maskBits=14 }
local planetFilter 	= { categoryBits=8, maskBits=1 }

-----------------------------------------------------------------------------------------

function initGameData()

	GLOBALS.savedData = {
		user = "New player",
		fullGame = GLOBALS.savedData ~= nil and GLOBALS.savedData.fullGame,
		requireTutorial = true,
		levels = {}, 
		kamikazeAvailable = false, 	-- require tutorial complete
		timeAttackAvailable = false, 	-- require tutorial complete
		scores = {
			classic={},
			timeattackeasy={},
			timeattackhard={},
			timeattackextreme={},
			kamikazeeasy={},
			kamikazehard={},
			kamikazeextreme={}
		}
	}

	utils.saveTable(GLOBALS.savedData, "savedData.json")
end

-----------------------------------------------------------------------------------------

function init(view)

	---------------------------------------

	if(view) then
		scene = view
	end

	----------------------------------------

	planetFire			= nil
	points 				= 0
	nbAsteroidsCaught = 0
	position 			= nil
	state 				= IDLE

	timePlayed 		 	= 0
	lockTime 		 	= 4*60
	timeCombo 		 	= 0

	lock 					= false
	level 				= 1 

	---------------------------------------

	stop()
	
	---------------------------------------

	setPlanetColor(GHOST)

	----------------------------------------

	hud.initHUD()
	hud.initTopRightText()
	hud.initSpeedCount()

	----------------------------------------

	local tutorial = false
	
	-- Tutorial Classic
	if(mode == CLASSIC and GLOBALS.savedData.requireTutorial) then
		tutorial = true
		hud.refreshTopRightText(T "Tutorial")
		start(false)
		tutorialClassic.start(view)
	end

	if(not tutorial) then

		level = 1 
		hud.refreshTopRightText("Kodo !")
		hud.initAsteroidsCount()
		hud.startComboTimer()

		hud.setExit()
		hud.setupPad()
		
		lock = not GLOBALS.savedData.fullGame
		hud.refreshSpeedCount()
		
		start()
	end   
end

-----------------------------------------------------------------------------------------

function start(requireAsteroidBuilder)

	if(requireAsteroidBuilder == nil) then
		requireAsteroidBuilder = true
	end

	state	= RUNNING

	if(requireAsteroidBuilder) then
		hud.centerText("Start !", display.contentHeight/4, 45)
		asteroidBuilder()

		timer.performWithDelay(1000, nextPlayedSecond)
	end

	if(lock) then
		hud.initLockElements()
		timer.performWithDelay(1000, lockTimer)
		
		if(IOS or ANDROID) then
	   	adsManager.show()
	   end
	end
end


function nextPlayedSecond()
	if(state == IDLE) then	
		timePlayed = 0 
		return
	end
	

	timePlayed = timePlayed+1
	timer.performWithDelay(1000, nextPlayedSecond)
	hud.refreshSpeedCount()

	checkNextStep()	
end


function lockTimer()
	if(state == IDLE) then	
		return
	end

	lockTime = lockTime-1

	if(lockTime < 0) then
		endGame(T "Game Locked", router.openBuy)
		if(mode == CLASSIC) then
			checkUnlockedStuffs()
		end
		return
	end

	hud.refreshLockElements(lockTime)
	timer.performWithDelay(1000, lockTimer)
end

-----------------------------------------------------------------------------------------

function getSpeed()
	local LEVELS = getCurrentLEVELS()
	local speed = math.floor(timePlayed/LEVELS[level].changeDelaySec) 
	
	return "Speed " .. speed
end


function getSpeedDelay()

	local LEVELS = getCurrentLEVELS()
	local speed = math.floor(timePlayed/LEVELS[level].changeDelaySec) 
	local timeDelay = speed * (LEVELS[level].changeDelayAmount - speed*1.5)
	
	if(LEVELS[level].minDelay - timeDelay) < 501 then
		timeDelay = LEVELS[level].minDelay - 501
	end

	return timeDelay
end

function asteroidBuilder()

	local LEVELS = getCurrentLEVELS()
	local timeDelay = getSpeedDelay()

	timer.performWithDelay( math.random(LEVELS[level].minDelay - timeDelay, LEVELS[level].maxDelay - timeDelay), function()
		if(state == RUNNING) then
			createAsteroid()
			asteroidBuilder()
		end
	end)
end

----------------------------------------

function introAsteroidBuilder(auto)
	
	if(state ==  IDLE or (auto and state == INTROASTEROIDS)) then
      state = INTROASTEROIDS
		createAsteroid()

   	timer.performWithDelay( 1500, function()
			introAsteroidBuilder(true)
   	end)
	end
end

----------------------------------------

function setPlanetColor(color)

	display.remove(planet)

	planet = display.newImage(scene, "assets/images/game/planet.".. color ..".png")
	planet:scale(0.27,0.27)
	planet.x = display.contentWidth/2
	planet.y = display.contentHeight/2
	planet.name = "planet"..color
	planet.alpha = 0.8
	planet.color = color
	physics.addBody( planet, "static", { bounce=0, radius=27, filter=planetFilter } )
	
	
	if(not planetFire) then
   	planetFire=CBE.VentGroup{
      		{
      			title="fire",
      			preset="burn",
      			color={{255},{255},{255}},
      			build=function()
      				local size=math.random(24, 38)
      				return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
      			end,
      			onCreation=function()end,
      			perEmit=2,
      			emissionNum=0,
      			x=x,
      			y=y,
      			positionType="inRadius",
      			posRadius=38,
      			emitDelay=50,
      			fadeInTime=1500,
      			lifeSpan=250,
      			lifeStart=250,
      			endAlpha=0,
      			physics={
      				velocity=0.5,
      				xDamping=1,
      				gravityY=0.6,
      				gravityX=0
      			}
      		}
      	}
      	
		planetFire:start("fire")
	end
end

------------------------------------------------------------------------------------------
--
function crashAsteroid( asteroid, event )
	local planet = event.other
	if(asteroid.beingDestroyed) then
		return
	end

	--------------------------

	local goodCatch = asteroid.color == planet.color

	--------------------------

	if(mode == CLASSIC) then

		if(not goodCatch) then
			classicOver()
		else
			nbAsteroidsCaught = nbAsteroidsCaught + 1
			hud.drawCatch(asteroid.x, asteroid.y, "white", 1)
			hud.refreshAsteroidsCount()
		end

		--------------------------

	elseif(mode == COMBO) then

		if(not goodCatch) then
			comboOver()
		end

		--------------------------

	elseif(mode == KAMIKAZE or mode == TIMEATTACK) then

		local change 	= 0 
		local catch 	= 0 
		local total 	= points

		if(goodCatch) then
			catch = 1
			asteroidsCaught[planet.color] = asteroidsCaught[planet.color] + 1
			change = asteroidsCaught[planet.color]
		else 
			catch = -1
			asteroidsCaught[planet.color] = asteroidsCaught[planet.color] - 1
			change = -3

			if(mode == KAMIKAZE) then
				kamikazePercent = kamikazePercent - ASTEROID_CRASH_KAMIKAZE_PERCENT
			end
		end

		total = points + change

		if(asteroidsCaught[planet.color] < 0) then
			asteroidsCaught[planet.color] = 0
		end

		if(total < 0) then
			total = 0
		end

		hud.drawCatch(asteroid.x, asteroid.y, planet.color, catch)
		hud.drawBag()
		hud.drawPoints(change, total, asteroid)

		if(not goodCatch and mode == KAMIKAZE) then
			if(kamikazePercent > 0) then 
				hud.drawProgressBar(kamikazePercent, ASTEROID_CRASH_KAMIKAZE_PERCENT)
			else 
				hud.drawProgressBar(1, ASTEROID_CRASH_KAMIKAZE_PERCENT)
				kamikazeOver()
			end
		end

		points = total

	end

	--------------------------
	-- destroy

	asteroid.beingDestroyed = true

	if(goodCatch) then
		catchAsteroid(asteroid)
	else
		explodeAsteroid(asteroid)
	end
end

------------------------------------------------------------------------------------------

function actionOnLightning(asteroid)

	if(mode == COMBO) then

		local goodCatch = COMBO_LEVELS[level].combo[requestedAsteroid] == asteroid.color

		if(goodCatch) then
			hud.drawCombo(level, requestedAsteroid)
			requestedAsteroid = requestedAsteroid + 1

			if(requestedAsteroid > #COMBO_LEVELS[level].combo) then
				completeLevel()
			end
		else
			requestedAsteroid = 1
			hud.drawCombo(level, 0)
		end

	elseif(mode == KAMIKAZE or mode == TIMEATTACK) then

		local change 		= asteroidsCaught[asteroid.color] * asteroidsCaught[asteroid.color]
		local changeText 	= asteroidsCaught[asteroid.color] .. " x "  ..  asteroidsCaught[asteroid.color]
		local total = points + change

		asteroidsCaught[asteroid.color] = math.floor(asteroidsCaught[asteroid.color]/2)
		kamikazePercent = kamikazePercent - LIGHTNING_KAMIKAZE_PERCENT

		hud.drawPoints(changeText, total, asteroid, true)
		hud.drawCatch(asteroid.x, asteroid.y, asteroid.color, "/2")
		hud.drawBag()

		if(mode == KAMIKAZE) then
			if(kamikazePercent > 0) then 
				hud.drawProgressBar(kamikazePercent, LIGHTNING_KAMIKAZE_PERCENT)
			else 
				hud.drawProgressBar(1, LIGHTNING_KAMIKAZE_PERCENT)
				kamikazeOver()
			end 
		end 

		points = total
	end

end

------------------------------------------------------------------------------------------

function destroyAsteroid(asteroid)
	local indexToRemove
	for i in pairs(asteroids) do
		if(asteroids[i] == asteroid) then
			indexToRemove = i
			break
		end
	end

	table.remove(asteroids, indexToRemove)

	--------------------------
	-- destroy

	transition.to( asteroid, { time=150, alpha=0, onComplete=function()
		display.remove(asteroid) 
		asteroid = nil 
	end})
	
end

------------------------------------------------------------------------------------------

function shootOnClosestAsteroid() 

	local asteroid = findClosestAsteroid()
	if(asteroid and not asteroid.beingDestroyed) then

		asteroid.beingDestroyed = true

		local asteroidPosition 	= vector2D:new(asteroid.x, asteroid.y)
		local center 				= vector2D:new(display.contentWidth/2, display.contentHeight/2)
		local direction 			= vector2D:Sub(asteroidPosition, center)

		direction:normalize()
		direction:mult(20)

		local planetPosition = vector2D:Add(center, direction)

		lightPlanet(asteroid) 

		local thunderDone = function() 
			actionOnLightning(asteroid)
			explodeAsteroid(asteroid) 
		end

		lightning.thunder(planetPosition, asteroidPosition, thunderDone)
		musicManager.playLight()
	end

end

------------------------------------------------------------------------------------------

function findClosestAsteroid()
	local closestDistance = 10000
	local closestAsteroid

	for i in pairs(asteroids) do
		local asteroid = asteroids[i]
		local asteroidPosition 	= vector2D:new(asteroid.x, asteroid.y)
		local planetPosition 	= vector2D:new(display.contentWidth/2, display.contentHeight/2)

		local distance = vector2D:Dist(asteroidPosition, planetPosition)

		if(distance < closestDistance) then
			closestDistance = distance
			closestAsteroid = asteroid
		end
	end

	if(closestAsteroid == nil) then
		return nil
	else
		return closestAsteroid
	end

end

------------------------------------------------------------------------------------------

function lightPlanet(asteroidDestoyed)
	
	local color = asteroidDestoyed.color
	local colors
	
	if(color == COLORS[1] or color == COLORS[5] ) then
   	print("light planet 1")
		colors={{0, 111, 255}, {0, 70, 255}}
	elseif(color == COLORS[2] or color == COLORS[6] ) then
   	print("light planet 2")
		colors={{181, 255, 111}, {120, 255, 70}}
	elseif(color == COLORS[3] or color == COLORS[7] ) then
   	print("light planet 3")
		colors={{255, 255, 111}, {255, 255, 70}}
	elseif(color == COLORS[4] or color == COLORS[8] ) then
   	print("light planet 4")
		colors={{255, 111, 0}, {255, 70, 0}}
	else
		colors={{65,65,62},{55,55,20}}
	end
	

	local light=CBE.VentGroup{
		{
			title="explosionPlanet",
			preset="wisps",
			color=colors,
			x = planet.x,
			y = planet.y,
			emissionNum = 7,
			physics={
				gravityX=0,
				gravityY=4.5,
			}
		}
	}
	light:start("explosionPlanet")
	
	timer.performWithDelay(5000, function()
		light:destroy("explosionPlanet")
		light = nil
	end)
end

function catchAsteroid(asteroid)
	
	local color = asteroid.color
	local colors
	
	if(color == COLORS[1] or color == COLORS[5] ) then
		colors={{0, 111, 255}, {0, 70, 255}}
	elseif(color == COLORS[2] or color == COLORS[6] ) then
		colors={{181, 255, 111}, {120, 255, 70}}
	elseif(color == COLORS[3] or color == COLORS[7] ) then
		colors={{255, 255, 111}, {255, 255, 70}}
	elseif(color == COLORS[4] or color == COLORS[8] ) then
		colors={{255, 111, 0}, {255, 70, 0}}
	else
		colors={{65,65,62},{55,55,20}}
	end


	local light=CBE.VentGroup{
		{
			title="explosion",
			preset="wisps",
			color=colors,
			x = asteroid.x,
			y = asteroid.y,
			emissionNum = 3,
			physics={
				gravityX=-16.2,
				gravityY=-11.2,
			}
		}
	}

	light:start("explosion")
	lightPlanet(asteroid)
	musicManager.playPlanet()

	destroyAsteroid(asteroid)
	
	timer.performWithDelay(3000, function()
		light:destroy("explosion")
		light = nil
	end)
end

------------------------------------------------------------------------------------------

function explodeAsteroid(asteroid)

	local colors
	if(asteroid.color == "blue") then
		colors={{0, 111, 255}, {0, 70, 255}}
	elseif(asteroid.color == "green") then
		colors={{181, 255, 111}, {120, 255, 70}}
	elseif(asteroid.color == "yellow") then
		colors={{255, 255, 111}, {255, 255, 70}}
	elseif(asteroid.color == "red") then
		colors={{255, 111, 0}, {255, 70, 0}}
	else
		colors={{255, 111, 0}, {255, 70, 0}}
	end

	local light=CBE.VentGroup{
		{
			title="explosion",
			preset="burn",
			color=colors,
			build=function()
				local size=math.random(30, 35)
				return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
			end,
			onCreation=function()end,
			perEmit=4,
			emissionNum=math.random(3,5),
			x=asteroid.x,
			y=asteroid.y,
			positionType="inRadius",
			posRadius=20,
			emitDelay=50,
			fadeInTime=50,
			lifeSpan=250,
			lifeStart=250,
			endAlpha=0,
			physics={
				relativeToSize=false,
				sizeX=-0.01,
				sizeY=-0.01,
				relativeToSize=false,
				velocity=1.5,
				xDamping=1,
				gravityY=0,
				gravityX=0
			}
		}
	}
	light:start("explosion")

	destroyAsteroid(asteroid)
	musicManager.playAsteroid(
	
	timer.performWithDelay(3000, function()
		light:destroy("explosion")
		light = nil
	end))
end

------------------------------------------------------------------------------------------

function getAsteroid(name)
	for i in pairs(asteroids) do
		if(asteroids[i].name == name) then
			return asteroids[i]
		end
	end
end

------------------------------------------------------------------------------------------

function createAsteroid()

	if(not level) then level = 1 end
	
	local LEVELS = CLASSIC_LEVELS
	local nbColors = 2
	
	
	if(state == INTROASTEROIDS) then
		nbColors = 8
	else
   	if(timePlayed > 90) then
   		nbColors = 8
   	elseif(timePlayed > 60) then
   		nbColors = 6
   	elseif(timePlayed > 30) then
   		nbColors = 4
   	end
	end

	local num = math.random(1,nbColors)
	local color = COLORS[num]

	local asteroid = display.newImageRect( "assets/images/game/asteroid." .. color .. ".png", 48, 48 )
	asteroid.color = color
	physics.addBody( asteroid, { bounce=0, radius=23, filter=asteroidFilter } )

	local planetCenterPoint = vector2D:new(display.contentWidth/2, display.contentHeight/2)

	local leftOrRight = math.random(0,1)
	local topOrBottom = math.random(1,2)
	
	local startAlpha = math.random(nbColors*11)
	local alpha = math.rad( leftOrRight * 180 + (3 - 2*topOrBottom) * startAlpha )
	
	local distance = 300

	local asteroidPoint = vector2D:new(distance*math.cos(alpha), distance*math.sin(alpha))
	asteroidPoint = vector2D:Add(planetCenterPoint, asteroidPoint)
	asteroid.x = asteroidPoint.x
	asteroid.y = asteroidPoint.y

	local speed = math.random(LEVELS[level].minSpeed, LEVELS[level].maxSpeed)/100
	local speedOffset = math.floor(timePlayed/LEVELS[level].changeDelaySec)/100 * 0.75

	asteroidDirection = vector2D:Sub(planetCenterPoint, asteroidPoint)
	asteroidDirection:mult(speed + speedOffset) 
	asteroid:setLinearVelocity( asteroidDirection.x, asteroidDirection.y )

	asteroid.collision = crashAsteroid ; 
	asteroid:addEventListener( "collision", asteroid )
	asteroid.name = "asteroid"..math.random(1000)

	table.insert(asteroids, asteroid)

end


------------------------------------------------------------------------------------------

-- Combo Game Over
function comboOver()
	endGame("Game Over !")
	timeCombo = T "Fail !"
end

------------------------------------------------------------------------------------------

-- end of Time Attack Level
function timerDone()
	endGame("Game Over !")
end

------------------------------------------------------------------------------------------

-- end of Kamikaze Level
function kamikazeOver()
	endGame("Game Over !")
end

------------------------------------------------------------------------------------------

-- end of Classic mode
function classicOver()
	local min,sec = utils.getMinSec(timeCombo)
	endGame(min .. ":" .. sec)
--	checkUnlockedStuffs()
end

--function checkUnlockedStuffs()
--	if(not GLOBALS.savedData.levels[1] and timeCombo > 89) then
--		displayInfo("Combo mode unlocked !")
--		GLOBALS.savedData.levels[1] = { available = true }
--		utils.saveTable(GLOBALS.savedData, "savedData.json")
--		
--		if(IOS) then
--			gameCenter.postAchievement("classic.2min")
--   	end
--	end
--end

------------------------------------------------------------------------------------------

function stop()

	while (#asteroids > 0) do
		hud.explode(asteroids[1], 4, 4400, asteroids[1].color)
		table.remove(asteroids, 1)
	end

	if(planetFire) then planetFire:destroy("fire") end
	state	= IDLE
end

function exit()
	stop()
	print("game exit", position, "mode : ", mode)
	checkNewRecord()	
	print("checked record", position, "mode : ", mode)
	if(position) then
		router.openNewRecord()
	else
		router.openScore()
	end
end

-----------------------------------------------------------------------------------------

function endGame(message, next)
	stop()
	hud.explodeHUD()
	hud.explode(planet, 7, 3500, planet.color)
	
	if(message) then		
		hud.centerText(message)

		if(next) then		
			timer.performWithDelay(2000, next)
		else
			timer.performWithDelay(2000, exit)
		end
	else
		-- button exit
		timer.performWithDelay(1200, function() router.openAppHome() end)
	end
end

-----------------------------------------------------------------------------------------

function completeLevel()	
	endGame("Level " .. level .. " Complete !")
	GLOBALS.savedData.levels[level+1] = { available = true }
	utils.saveTable(GLOBALS.savedData, "savedData.json")
end

-----------------------------------------------------------------------------------------

function checkNextStep()
	
	if(timePlayed == 30) then
		displayInfo(T "Nice !")
		hud.setup4Buttons()
	elseif(timePlayed == 60) then
		displayInfo(T "1mn ! Great !")
		hud.setup6Buttons()
	elseif(timePlayed == 90) then
		displayInfo(T "Awesome !")
		hud.setup8Buttons()
	elseif(timePlayed == 120) then
		displayInfo(T "2mn ! Fantastic !")
	elseif(timePlayed == 150) then
		displayInfo(T "Excellent !")
	elseif(timePlayed == 180) then
		displayInfo(T "3mn ! Incredible !")
	elseif(timePlayed == 210) then
		displayInfo(T "Unstoppable !")
	elseif(timePlayed == 240) then
		displayInfo(T "4mn ! Godlike !")
	elseif(timePlayed == 270) then
		displayInfo(T "You're still here ?!")
	elseif(timePlayed == 300) then
		displayInfo(T "5mn ! What a game !")
	elseif(timePlayed == 330) then
		displayInfo(T "Impossible !")
	elseif(timePlayed == 360) then
		displayInfo(T "6mn ?! Who are you ??")
	elseif(timePlayed == 390) then
		displayInfo(T "Close to Chuck Norris")
	elseif(timePlayed == 420) then
		displayInfo(T "7mn : Definetely Chuck Norris")
	elseif(timePlayed == 450) then
		displayInfo(T "Well I can't add more to that")
	elseif(timePlayed == 480) then
		displayInfo(T "8mn...Now I'm really voiceless")
	end
end

-----------------------------------------------------------------------------------------

function displayInfo(message)

	local text = display.newText( message, 0, 0, FONT, 25 )
	text:setTextColor( 255 )	
	text.alpha = 0
	text.x = display.contentWidth/2
	text.y = display.contentHeight/4
	scene:insert(text)

	transition.to( text, { 
		time=300, 
		alpha=1, 
		onComplete = function()
			timer.performWithDelay( 800, function ()
				transition.to( text, { time=300, alpha=0}) 
			end) 
		end
	})
end


-----------------------------------------------------------------------------------------

function getCurrentLEVELS()

	if(mode == COMBO) then
		return COMBO_LEVELS
	elseif(mode == CLASSIC) then
		return CLASSIC_LEVELS
	elseif(mode == KAMIKAZE) then
		return KAMIKAZE_LEVELS
	elseif(mode == TIMEATTACK) then
		return TIMEATTACK_LEVELS
	end

end

-----------------------------------------------------------------------------------------
-- End Game
-- 

function nextLevel()
	level = level + 1
	local wasLastLevel = false

	if(mode == CLASSIC) then 
		wasLastLevel = true

	elseif(mode == COMBO) then 
		if(level == 41) then
			wasLastLevel = true
		end

		-- next level not available
		if(type(timeCombo) ~= "number") then
			level = level - 1
		end

	elseif(mode == KAMIKAZE or mode == TIMEATTACK) then 
		if(level == 5) then
			wasLastLevel = true
		end
	end

	if(wasLastLevel) then
		router.openSelection()
	else
	
   	if(mode == COMBO and not GLOBALS.savedData.fullGame and level > 10) then
   		router.openBuy()
   	else
			router.openPlayground()
		end
	end

end


function getGameType()

	if(mode == COMBO) then 
		return T "Combo"

	elseif(mode == CLASSIC) then 
		return T "Classic"

	elseif(mode == KAMIKAZE) then 
		return T "Kamikaze"

	elseif(mode == TIMEATTACK) then 
		return T "Time Attack"

	end
end

function getBoard()

	if(mode == CLASSIC) then 
		return GLOBALS.savedData.scores.classic

	elseif(mode == KAMIKAZE) then 
		if(level == 2) then 
   		return GLOBALS.savedData.scores.kamikazeeasy
		elseif(level == 3) then 
   		return GLOBALS.savedData.scores.kamikazehard
		elseif(level == 4) then 
   		return GLOBALS.savedData.scores.kamikazeextreme
   	end

	elseif(mode == TIMEATTACK) then 
		if(level == 2) then 
   		return GLOBALS.savedData.scores.timeattackeasy
		elseif(level == 3) then 
   		return GLOBALS.savedData.scores.timeattackhard
		elseif(level == 4) then 
   		return GLOBALS.savedData.scores.timeattackextreme
   	end
	end
	
	return nil
end

function getLevel()

	if(mode == COMBO) then 
		if(level == 1) then
			return T "Tutorial" 
		else
			return "Level " .. level
		end

	elseif(mode == CLASSIC) then 
		return "" 

	elseif(mode == KAMIKAZE) then 
		if(level == 1) then
			return T "Tutorial" 
		elseif(level == 2) then
			return T "Easy" 
		elseif(level == 3) then
			return T "Hard" 
		elseif(level == 4) then
			return T "Extreme" 
		end

	elseif(mode == TIMEATTACK) then 
		if(level == 1) then
			return T "Tutorial" 
		elseif(level == 2) then
			return "2 min" 
		elseif(level == 3) then
			return "5 min" 
		elseif(level == 4) then
			return "8 min" 
		end

	end

end

function getValue()

	if(mode == COMBO) then 
		if(type(timeCombo) == "number") then
			return timeCombo
		else
			return -1
		end

	elseif(mode == CLASSIC) then
		return timeCombo 

	elseif(mode == KAMIKAZE or mode == TIMEATTACK) then 
		return points

	end
end

function getTextValue()

	if(mode == COMBO) then 
		if(level == 1) then
			return "" 
		else
			if(type(timeCombo) == "number") then
				local min,sec = utils.getMinSec(timeCombo)
				return min .. ":" .. sec
			else
				return timeCombo -- Fail !
			end
		end

	elseif(mode == CLASSIC) then 
		local min,sec = utils.getMinSec(timeCombo)
		return min .. ":" .. sec .. "  ( ".. nbAsteroidsCaught .. " kodos)"

	elseif(mode == KAMIKAZE) then 
		return points .." pts"

	elseif(mode == TIMEATTACK) then 
		return points .." pts"

	end
end


function storeRecord()
	local board	= getBoard()
	local value 


	if(mode == CLASSIC) then 
		local min,sec = utils.getMinSec(timeCombo)
		value =  min .. ":" .. sec
	elseif(mode == KAMIKAZE or mode == TIMEATTACK) then 
		value = points
	end
		
	table.remove(board, 10)
	table.insert(board, position, {
		name 	= GLOBALS.savedData.user, 
		value = value 
	})
	
	utils.saveTable(GLOBALS.savedData, "savedData.json")
	
	
	if(IOS) then
		if(mode == CLASSIC) then 
			gameCenter.postScore("kodo", timeCombo)
   	end
	end
end

function checkNewRecord()

	if(mode == COMBO) then return end
	if((mode ~= CLASSIC) and (level == 1)) then return end
	
	local newRecord 	= false
	local board 		= getBoard()
	local newValue 	= getValue()
	
	for p=1,10 do
		if(board[p]) then
      	local value = board[p].value
      	if(type(value) ~= "number") then
      		value = utils.split(value)
      		value = value[1] * 60 + value[2]
      	end
   		
   		if(newValue > value) then
   			position = p
   			break
   		end
   		
		else
			position = p
			break
		end
	end
end