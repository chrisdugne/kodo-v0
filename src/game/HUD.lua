-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

local colorsEnabled = true
local lightningEnabled = true

-----------------------------------------------------------------------------------------

elements = display.newGroup()
powerBarFire 	= nil

-----------------------------------------------------------------------------------------

function initHUD()
	utils.emptyGroup(elements)
	lockElements = display.newGroup()
	
	if(powerBarFire) then
		powerBarFire:destroy("fire")
		powerBarFire = nil
	end
end

-----------------------------------------------------------------------------------------

function setExit(toApply)
	exitButton = display.newImage( game.scene, "assets/images/hud/exit.png")
	exitButton.x = display.contentWidth - 20
	exitButton.y = 45
	exitButton.alpha = 0.5
	exitButton:scale(0.75,0.75)
	exitButton:addEventListener("touch", function(event)
		if(toApply) then 
			toApply()
		end 
		game.endGame() 
	end)
	elements:insert(exitButton)
end

function setBackToHome()
	exitButton = display.newImage( game.scene, "assets/images/hud/exit.png")
	exitButton.x = display.contentWidth - 20
	exitButton.y = 45
	exitButton.alpha = 0.5
	exitButton:scale(0.75,0.75)
	exitButton:addEventListener("touch", function(event)
		router.openAppHome()
	end)
	elements:insert(exitButton)
end

-----------------------------------------------------------------------------------------

function initTopRightText()
	display.remove(topRightText)
	topRightText = display.newText( game.scene, "0", 0, 0, FONT, 21 )
	topRightText:setTextColor( 255 )	
	topRightText:setReferencePoint( display.CenterReferencePoint )
	topRightText.x = display.contentWidth - topRightText.contentWidth/2 - 10
	topRightText.y = 20
	elements:insert(topRightText)
end

function refreshTopRightText(text)
	if(topRightText) then
		topRightText.text = text
		topRightText.x 	= display.contentWidth - topRightText.contentWidth/2 - 10
	end
end

-----------------------------------------------------------------------------------------

function initAsteroidsCount()
	display.remove(asteroidsCountIcon)
  	asteroidsCountIcon = display.newImage(game.scene, "assets/images/game/planet.white.png")
	asteroidsCountIcon.x = 25
	asteroidsCountIcon.y = 45 
	asteroidsCountIcon:scale(0.05,0.05)
	asteroidsCountIcon.alpha = 0.75
	elements:insert(asteroidsCountIcon)
	
	display.remove(asteroidsCountText)
	asteroidsCountText = display.newText( game.scene, "0", 0, 0, FONT, 17 )
	asteroidsCountText:setTextColor( 255 )	
	asteroidsCountText:setReferencePoint( display.CenterReferencePoint )
	asteroidsCountText.x = 45
	asteroidsCountText.y = 43
	elements:insert(asteroidsCountText)
end

function refreshAsteroidsCount()
	if(asteroidsCountText) then
		asteroidsCountText.text = game.nbAsteroidsCaught
	end
end

-----------------------------------------------------------------------------------------

function initSpeedCount()
	display.remove(speedCountText)
	speedCountText = display.newText( game.scene, "", 0, 0, FONT, 18 )
	speedCountText:setTextColor( 255 )	
	speedCountText:setReferencePoint( display.CenterReferencePoint )
	
	speedCountText.x = 45
	speedCountText.y = 20
	
	elements:insert(speedCountText)
end

function refreshSpeedCount()
	if(speedCountText) then
		speedCountText.text = game.getSpeed()
	end
end

-----------------------------------------------------------------------------------------
--- The bottom part asking to unlock the game

function initLockElements()
	display.remove(lockElements)
	
	local text = display.newText( lockElements, "", 0, 0, FONT, 10 )
	text:setTextColor( 255 )	
	text:addEventListener	("touch", goToBuy)

	lockElements.text = text

	local lockImage = display.newImage(lockElements, "assets/images/hud/lock.png")
	lockImage.x = 150
	lockImage.y = display.contentHeight-12
	lockImage:scale(0.15,0.15)
	lockImage:addEventListener	("touch", goToBuy)

	local arrowImage = display.newImage(lockElements, "assets/images/tutorial/arrow.left.png")
	arrowImage.x = 165
	arrowImage.y = display.contentHeight-10
	arrowImage:scale(0.07,0.07)
	arrowImage:addEventListener	("touch", goToBuy)

	elements:insert(lockElements)
	lockElements.alpha = 0
end

function refreshLockElements(time)
	if(time < 31) then
   	lockElements.alpha = 1
   	local min,sec = utils.getMinSec(time)
   	local text = "Get the full version to remove time limit   "
   	if(lockElements) then
   		lockElements.text.text =  text .. min .. ":" .. sec 
     		lockElements.text:setReferencePoint(display.TopLeftReferencePoint)
   		lockElements.text.x = 175
   		lockElements.text.y = display.contentHeight-18
   	end
   end
end

function goToBuy() 
	game.endGame("", router.openBuy)
end

-----------------------------------------------------------------------------------------

function setupPad()
	setupButtons()
	
	if(game.mode ~= game.CLASSIC) then
		setupLightningButton()
   end
end

-----------------------------------------------------------------------------------------

function setupButtons()
	colorsEnabled = true

	ghostButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[1] ..".png")
	ghostButton.x = display.contentWidth - 55
	ghostButton.y = display.contentHeight - 30
	ghostButton:scale(0.15,0.15)
	ghostButton:addEventListener("touch", function(event) touch(event, ghostButton) color(event, COLORS[1]) end)
	elements:insert(ghostButton)

	octopusButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[2] ..".png")
	octopusButton.x = display.contentWidth - 25
	octopusButton.y = display.contentHeight - 70
	octopusButton:scale(0.15,0.15)
	octopusButton:addEventListener("touch", function(event) touch(event, octopusButton) color(event, COLORS[2]) end)
	elements:insert(octopusButton)

	horrorButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[3] ..".png")
	horrorButton.x = display.contentWidth - 85
	horrorButton.y = display.contentHeight - 70
	horrorButton:scale(0.15,0.15)
	horrorButton:addEventListener("touch", function(event) touch(event, horrorButton) color(event, COLORS[3]) end)
	elements:insert(horrorButton)

	monsterButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[4] ..".png")
	monsterButton.x = display.contentWidth - 55
	monsterButton.y = display.contentHeight - 110
	monsterButton:scale(0.15,0.15)
	monsterButton:addEventListener("touch", function(event) touch(event, monsterButton) color(event, COLORS[4]) end)
	elements:insert(monsterButton)

	ninjaButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[5] ..".png")
	ninjaButton.x = 55
	ninjaButton.y = display.contentHeight - 30
	ninjaButton:scale(0.15,0.15)
	ninjaButton:addEventListener("touch", function(event) touch(event, ninjaButton) color(event, COLORS[5]) end)
	elements:insert(ninjaButton)

	skullButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[6] ..".png")
	skullButton.x = 25
	skullButton.y = display.contentHeight - 70
	skullButton:scale(0.15,0.15)
	skullButton:addEventListener("touch", function(event) touch(event, skullButton) color(event, COLORS[6]) end)
	elements:insert(skullButton)

	eyesButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[7] ..".png")
	eyesButton.x = 85
	eyesButton.y = display.contentHeight - 70
	eyesButton:scale(0.15,0.15)
	eyesButton:addEventListener("touch", function(event) touch(event, eyesButton) color(event, COLORS[7]) end)
	elements:insert(eyesButton)

	blinkButton = display.newImage( game.scene, "assets/images/hud/button.".. COLORS[8] ..".png")
	blinkButton.x = 55
	blinkButton.y = display.contentHeight - 110
	blinkButton:scale(0.15,0.15)
	blinkButton:addEventListener("touch", function(event) touch(event, blinkButton) color(event, COLORS[8]) end)
	elements:insert(blinkButton)

	Runtime:addEventListener("touch", function(event) screenTouch(event) end)
end

-----------------------------------------------------------------------------------------

function setupLightningButton()
	lightningEnabled = true

	lightButton = display.newImage( game.scene, "assets/images/hud/button.light.png")
	lightButton.x = 40
	lightButton.y = display.contentHeight - 60
	lightButton:scale(0.15,0.15)
	lightButton:addEventListener("touch", function(event) touch(event, lightButton) light(event) end)
	elements:insert(lightButton)
end

------------------------------------------------------------------------------------------

function screenTouch( event )
	if(event.phase == "ended") then
   	
   	if(ghostButton) then
	   	ghostButton.alpha = 1
	   end
   	
   	if(octopusButton) then
	   	octopusButton.alpha = 1
	   end
	   
   	if(horrorButton) then
	   	horrorButton.alpha = 1
	   end
	   
   	if(monsterButton) then
	   	monsterButton.alpha = 1
	   end
   	
   	if(ninjaButton) then
	   	ninjaButton.alpha = 1
	   end
	   
   	if(skullButton) then
	   	skullButton.alpha = 1
	   end

   	if(eyesButton) then
	   	eyesButton.alpha = 1
	   end

   	if(blinkButton) then
	   	blinkButton.alpha = 1
	   end
   	
		transition.to( game.planet, { time=140, alpha=0.8 })
   end
end

function light( event )
	if(event.phase == "began" and lightningEnabled) then
		transition.to( game.planet, { time=40, alpha=1 })
		game.shootOnClosestAsteroid()
   end
end

function touch( event, button )
	if(event.phase == "began") then
   	button.alpha = 0.3
   end
end

function color( event, color )
	if(event.phase == "began" and colorsEnabled) then
   	game.setPlanetColor(color)
   end
end

-----------------------------------------------------------------------------------------

function lightCombo(element)
	local light=CBE.VentGroup{
   	{
   		title="fire",
   		preset="burn",
   		color={getRGB(element.color)},
   		build=function()
   			local size=math.random(8, 12) -- Particles are a bit bigger than ice comet particles
   			return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
			end,
			onCreation=function()end,
			perEmit=1,
			emissionNum=1,
			point1={element.x-2, element.y},
			point2={element.x+2, element.y},
			positionType="alongLine",
			emitDelay=10,
   		fadeInTime=100,
   		lifeSpan=150, -- Particles are removed sooner than the ice comet
   		lifeStart=50,
   		endAlpha=0,
   		physics={
   			velocity=0.2,
   			gravityX=0.1,
   			gravityY=0.6,
   		}
   	}
	}
   	
	light:start("fire")
	
	timer.performWithDelay(3000, function()
		light:destroy("fire")
		light = nil
	end)
end

-----------------------------------------------------------------------------------------


function drawCombo(level, numCompleted)
	
   for i=elements.numChildren,1,-1 do
		if(elements[i].isComboElement) then
   		
   		if(numCompleted == 0 and not elements[i].dontLight) then
				lightCombo(elements[i])
			end
			
			display.remove(elements[i])
   	end
	end
	
	local square = display.newImage(game.scene, "assets/images/hud/square.png")
	square:scale(0.5,0.5)
	square.x = 35
	square.y = 35
	square.isComboElement = true
	square.dontLight = true
	
	elements:insert(square)
	
	local combo = COMBO_LEVELS[level].combo[numCompleted+1]
	
	if(combo) then
		drawCurrentCombo(combo, numCompleted+1)
	end

	for c = numCompleted+2, #COMBO_LEVELS[level].combo do
		local color = COMBO_LEVELS[level].combo[c]
   	drawComboTodo(color, c, numCompleted)
	end
	
	for c = 1, numCompleted do
		local color = COMBO_LEVELS[level].combo[c]
   	drawComboDone(color, c)
	end
	
	
	
end

function drawCurrentCombo(color, num)

	local asteroid = display.newImage(game.scene, "assets/images/game/asteroid." .. color .. ".png")
	asteroid.color 			= color
	asteroid.isComboElement = true
	asteroid.comboNum 		= num
	asteroid.dontLight 		= true

	asteroid.x = 35
	asteroid.y = 35
	asteroid:scale(0.8,0.8)
	asteroid.alpha = 0
	
	transition.to(asteroid, {alpha = 1, time=300})
	elements:insert(asteroid)
end

function drawComboTodo(color, num, numCompleted)

	local asteroid = display.newImage(game.scene, "assets/images/game/asteroid." .. color .. ".png")
	asteroid.color 	= color
	asteroid.comboNum = num

	local i = math.floor((num-2-numCompleted)/10) + 1
	local j = (num-2-numCompleted)%10

	asteroid.x = 5 + 13 * i
	asteroid.y = 90 + 15 * (j-1)
	asteroid:scale(0.24,0.24)

	lightCombo(asteroid)

	asteroid.isComboElement = true
	elements:insert(asteroid)
end

function drawComboDone(color, num)

	local asteroid = display.newImage(game.scene, "assets/images/game/asteroid." .. color .. ".png")
	asteroid.color 	= color
	asteroid.comboNum = num

	local i = (num-1)%16
	local j = math.floor((num-1)/16) + 1

	asteroid.x = 70 + 13 * i
	asteroid.y = 5 + 13 * j
	asteroid:scale(0.24,0.24)

	lightCombo(asteroid)

	asteroid.isComboElement = true
	elements:insert(asteroid)
end

-----------------------------------------------------------------------------------------

function drawBag()
   for i=elements.numChildren,1,-1 do
		if(elements[i].isBagElement) then
			display.remove(elements[i])
   	end
	end
	
	local LEVELS
	if(game.mode == KAMIKAZE) then
		LEVELS = KAMIKAZE_LEVELS
	else
		LEVELS = TIMEATTACK_LEVELS
	end
	
	for c = 1, LEVELS[game.level].colors do
		local color = COLORS[c]
   	local asteroid = display.newImage(game.scene, "assets/images/game/asteroid." .. color .. ".png")
   	asteroid.color = color
   	
   	local i = 20
   	
   	asteroid.x = 13
   	asteroid.y = 25 * c - 10 
		asteroid:scale(0.48,0.48)
		asteroid.alpha = 0.75

   	colorText = display.newText( game.asteroidsCaught[color], 0, 0, FONT, 13 )
   	colorText:setTextColor( 255 )	
   	colorText.x = 30
   	colorText.y = asteroid.y - 3
   	colorText:setReferencePoint( display.CenterReferencePoint )
		colorText.isBagElement = true
   	elements:insert(colorText)

		asteroid.isBagElement = true
   	elements:insert(asteroid)
	end
end

-----------------------------------------------------------------------------------------

function buildPowerbar(percent)

	return CBE.VentGroup{
   	{
   		title="fire",
   		preset="burn",
   		color={{160-percent,155*percent/100,15 + percent/40}},
   		build=function()
   			local size=math.random(34, 58) -- Particles are a bit bigger than ice comet particles
   			return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
			end,
			onCreation=function()end,
			perEmit=3,
			emissionNum=0,
			point1={display.contentWidth/4, 20},
			point2={display.contentWidth/4 + display.contentWidth/2 * percent/100, 20},
			positionType="alongLine",
			emitDelay=10,
   		fadeInTime=1200,
   		lifeSpan=1250, -- Particles are removed sooner than the ice comet
   		lifeStart=50,
   		endAlpha=0,
   		physics={
   			velocity=0.2,
   			gravityY=0.1,
   		}
   	}
	}
   	
end         

function drawProgressBar(percent, loss)         
	
	if(powerBarFire) then 
		powerBarFire:get("fire").point1={display.contentWidth/4, 20}
		powerBarFire:get("fire").point2={display.contentWidth/4 + display.contentWidth/2 * percent/100, 20}
		powerBarFire:get("fire").resetPoints()
	else
		powerBarFire = buildPowerbar(percent)
		powerBarFire:start("fire")
   end

	if(loss) then	
   	local lossFire=CBE.VentGroup{
      	{
      		title="fire",
      		preset="burn",
      		color={{140-percent,155*percent/100,15 + percent/40}},
      		build=function()
      			local size=math.random(34, 38) -- Particles are a bit bigger than ice comet particles
      			return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
   			end,
   			onCreation=function()end,
   			perEmit=6,
   			emissionNum=loss,
   			point1={display.contentWidth/4 + display.contentWidth/2 * percent/100, 20},
   			point2={display.contentWidth/4 + display.contentWidth/2 * (percent+loss)/100, 20},
   			positionType="alongLine",
   			emitDelay=10,
      		fadeInTime=1600,
      		lifeSpan=450, -- Particles are removed sooner than the ice comet
      		lifeStart=50,
      		endAlpha=0,
      		physics={
      			velocity=0.2,
      			gravityX=2.1,
      			gravityY=1.1,
      		}
      	}
   	}
      	
   	lossFire:start("fire")
   	
   	timer.performWithDelay(4000, function()
   		lossFire:destroy("fire")
   		lossFire = nil
   	end)
   end
end

-----------------------------------------------------------------------------------------

function drawCatch(x, y, color, value, huge)

	if(type(value) == "number" and value > 0) then
		value = "+ " .. value
	end

	local scale = 2.5
	if(huge) then scale = 4 end	

	local time = 1600
	if(huge) then time = 3000 end	
	
	local rgb = getRGB(color) 
	local colorText = display.newText( value, 0, 0, FONT, 16 )
	colorText:setTextColor( rgb[1], rgb[2], rgb[3] )	
	colorText.x = x
	colorText.y = y
	colorText.alpha = 1
	colorText:setReferencePoint( display.CenterReferencePoint )
	
	transition.to( colorText, { 
		time=time, 
		alpha=0, 
--		x= 40, 
--		y= 25 * getColorNum(color) - 10,
		x= 25,
		y= 45, 
		xScale=scale,
		yScale=scale,
		onComplete=function()
			display.remove(colorText)
		end
	})
	
end

-----------------------------------------------------------------------------------------

function drawPoints(change, total, asteroid, huge)

	if(type(change) == "number" and change > 0) then
		change = "+ " .. change
	end
	
	refreshTopRightText(total .. " pts")
	
	local scale = 2.5
	local time = 2000
	
	local x = asteroid.x
	local y = asteroid.y

	if(huge) then 
		scale = 4 
   	time = 4000
   	x = 40
		y= 25 * getColorNum(asteroid.color) - 10 
	end	
	
	local rgb = getRGB(asteroid.color) 
	local changeText = display.newText( change, 0, 0, FONT, 16 )
	changeText:setTextColor( rgb[1], rgb[2], rgb[3] )	
	changeText.x = x
	changeText.y = y
	changeText.alpha = 1
	changeText:setReferencePoint( display.CenterReferencePoint )
	
	transition.to( changeText, { 
		time=2000,
		alpha=0, 
		x= topRightText.x -20,
		y= 5, 
		xScale=2.5,
		yScale=2.5,
		onComplete=function()
			display.remove(changeText)
		end
	})
	
end

-----------------------------------------------------------------------------------------

function disableColors()
 	colorsEnabled = false 
end

function enableColors()
 	colorsEnabled = true 
end

function disableLightning()
 	lightningEnabled = false 
end

function enableLightning()
 	lightningEnabled = true 
end

-----------------------------------------------------------------------------------------

function explodeHUD()
   for i=elements.numChildren,1,-1 do
		explode(elements[i], 4, 2400, elements[i].color)
	end
	
	if(powerBarFire) then powerBarFire:stop("fire") end
end
			
-----------------------------------------------------------------------------------------

function explode(element, emissionNum, fadeInTime, color)

	if(not color) then color = "white" end

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
	
	if(not emissionNum) then
		emissionNum = 3
	end

	if(not fadeInTime) then
		fadeInTime = 3500
	end
	
   local explosion=CBE.VentGroup{
   	{
   		title="fire",
   		preset="wisps",
   		color=colors,
   		x = element.x,
   		y = element.y,
   		emissionNum = emissionNum,
   		fadeInTime = fadeInTime,
   		physics={
   			gravityX=1.2,
   			gravityY=13.2,
   		}
   	}
   }
   
   explosion:start("fire")
   display.remove(element)
   element = nil
   
	timer.performWithDelay(fadeInTime + 2000, function()
		explosion:destroy("fire")
		explosion = nil
	end)
end
			
-----------------------------------------------------------------------------------------

function drawTimer(seconds)
	
	local min,sec = utils.getMinSec(seconds)
	
	display.remove(timeLeftText)
	timeLeftText = display.newText( game.scene, "0", 0, 0, FONT, 34 )
	timeLeftText:setTextColor( 255 )	
	timeLeftText.text = min .. ":" .. sec
	timeLeftText:setReferencePoint( display.CenterReferencePoint )
	timeLeftText.x = display.contentWidth/2
	timeLeftText.y = 20
	elements:insert(timeLeftText)

	timer.performWithDelay(1000, function() time(seconds) end)
end


function time(seconds)
	if(game.state == game.IDLE) then	return end
	
	seconds = seconds-1
	local min,sec = utils.getMinSec(seconds)
	timeLeftText.text = min .. ":" .. sec
	
	if(seconds == 0) then
		game.timerDone()
	else	
		timer.performWithDelay(1000, function() time(seconds) end)
	end
	
end
			
-----------------------------------------------------------------------------------------

function startComboTimer()
	display.remove(timeLeftText)
	timeLeftText = display.newText( game.scene, "0", 0, 0, FONT, 24 )
	timeLeftText:setTextColor( 255 )	
	timeLeftText.text = "0:00"
	timeLeftText:setReferencePoint( display.CenterReferencePoint )
	
	if(game.mode == game.COMBO) then
		timeLeftText.x = display.contentWidth * 0.7
	else
		timeLeftText.x = display.contentWidth * 0.5
	end
	
	timeLeftText.y = 20
	elements:insert(timeLeftText)

	game.timeCombo = 0
	timer.performWithDelay(1000, nextSecondCombo)
end


function nextSecondCombo()
	if(game.state == game.IDLE) then	return end
	
	game.timeCombo = game.timeCombo+1
	local min,sec = utils.getMinSec(game.timeCombo)
	timeLeftText.text = min .. ":" .. sec
	
	timer.performWithDelay(1000, nextSecondCombo)
end

-----------------------------------------------------------------------------------------

function centerText(text, y, fontSize)

	if(not text) then
		return
	end

	if(not y) then
		y = display.contentHeight/2
	end

	if(not fontSize) then
		fontSize = 45
	end

	finalText = display.newText( text, 0, 0, FONT, fontSize )
	finalText:setTextColor( 255 )	
	finalText.x = display.contentWidth/2
	finalText.y = y
	finalText.alpha = 0
	finalText:scale(0.5,0.5) 
	finalText:setReferencePoint( display.CenterReferencePoint )
	elements:insert(finalText)
	
	transition.to( finalText, { 
		time=1140, 
		alpha=1, 
		xScale=1,
		yScale=1,
		onComplete=function()
			transition.to( finalText, { time=1200, alpha=0 })
		end
	})
end