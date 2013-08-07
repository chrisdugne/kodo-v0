-----------------------------------------------------------------------------------------
--
-- AppHome.lua
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local menu
local screen
local introComplete = system.getInfo("environment") == "simulator"

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	
	menu = display.newGroup()
	screen = display.newGroup()

	-- true on dev only
	if(introComplete) then return end
	
   self:intro()
end

function scene:intro()

	utils.emptyGroup(screen)
	utils.emptyGroup(menu)

   local bottom = display.newRect(screen, 0, 0, display.contentWidth, display.contentHeight)
   bottom:setFillColor(0)
	
	viewManager.cleanupFires()

	local back = display.newImage( screen, "assets/images/stars.jpg")  
	back:scale(0.7,0.7)
	back.x = display.viewableContentWidth/2  
	back.y = display.viewableContentHeight/2  
	back.alpha = 0
	transition.to( back, { time=4000, alpha=1 })  
	screen.back = back

   light1()
   timer.performWithDelay(500, function()
      displayIntroText("Uralys presents", display.contentWidth/2, display.contentHeight/2, true)
   
      timer.performWithDelay(2500, function()
      	light2()
         displayIntroText("Kodo !", display.contentWidth/2, 45, false)

         timer.performWithDelay(2000, function()
         	utils.emptyGroup(screen)
         	self:refreshScene()
         end)
      end)
   end)
   
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()
	utils.emptyGroup(menu)
	viewManager.initView(self.view);
	viewManager.initBack()
	
	title = display.newText( "Kodo !", 0, 0, FONT, 45 )
	title:setTextColor( 255 )	
	title.x = display.contentWidth/2
	title.y = 45
	title:setReferencePoint( display.CenterReferencePoint )
	menu:insert(title)

	if(introComplete) then
   	title.alpha = 0
   	transition.to( title, { time=1800, alpha=1 })
   else  
   	title.alpha = 1
   	introComplete = true
   end	

	---------------------------------------------------------------
	
	viewManager.buildButton(menu, "", "white", 21, display.contentWidth/2, 	display.contentHeight*0.5, 	classic)
	
	local playIcon = display.newImage(menu, "assets/images/hud/play.png")
	playIcon:scale(0.7,0.7)
	playIcon.x = display.contentWidth/2 + 5
	playIcon.y = display.contentHeight/2
	playIcon.alpha = 0
	
	transition.to( playIcon, { time=2000, alpha=1 }) 

	---------------------------------------------------------------
	
	viewManager.buildSmallButton(
		menu, 
		"", 
		"white", 
		20,
		display.contentWidth - 30, 
		display.contentHeight - 30, 
		function() 
			self:openOptions() 
		end
	)

	local settingsIcon = display.newImage(menu, "assets/images/hud/settings.png")
	settingsIcon:scale(0.50,0.50)
	settingsIcon.x = display.contentWidth - 30 
	settingsIcon.y = display.contentHeight - 30 
	
	---------------------------------------------------------------

	viewManager.buildSmallButton(
		menu, 
		"", 
		"white", 
		20,
		display.contentWidth - 80, 
		display.contentHeight - 30, 
		function() 
			self:openPodiums() 
		end
	)

	local podiumIcon = display.newImage(menu, "assets/images/hud/podium.png")
	podiumIcon:scale(0.3,0.3)
	podiumIcon.x = display.contentWidth - 80 
	podiumIcon.y = display.contentHeight - 30 

	local borderSettings = display.newImage(menu, "assets/images/hud/borderSettings.png")
	borderSettings:scale(0.50,0.50)
	borderSettings.x = display.contentWidth - 80 
	borderSettings.y = display.contentHeight - 30 

	---------------------------------------------------------------
	
	game.introAsteroidBuilder()

	---------------------------------------------------------------
	
	self.view:insert(menu)
	
   if(IOS) then
   	timer.performWithDelay(600, gameCenter.init)
   end
   
	if(not GLOBALS.savedData.fullGame) then
   	timer.performWithDelay(600, adsManager.init)
	end
   
end

------------------------------------------

function scene:openOptions()
	router.openOptions()	
end

function scene:openPodiums()
	router.openPodiums()	
end

------------------------------------------

function classic()	
	game.mode = game.CLASSIC 
	router.openPlayground()
end

------------------------------------------
-- INTRO TOOLS
------------------------------------------

function light1()
	explode(	
   		display.contentWidth * 0.3,
   		display.contentHeight * 0.2,
   		3500
   	)

   explode(
   		display.contentWidth * 0.8,
   		display.contentHeight * 0.2,
   		3500
   	)

   explode(
   		display.contentWidth * 0.1,
   		display.contentHeight * 0.4,
   		3700
   	)

   explode(
   		display.contentWidth * 0.5,
   		display.contentHeight * 0.9,
   		3200
   	)
end

------------------------------------------

function light2()
	explode(	
   		display.contentWidth * 0.5,
   		display.contentHeight * 0.6,
   		3000
   	)

   explode(
   		display.contentWidth * 0.2,
   		display.contentHeight * 0.7,
   		2800
   	)

   explode(
   		display.contentWidth * 0.8,
   		display.contentHeight * 0.2,
   		3700
   	)

   explode(
   		display.contentWidth * 0.8,
   		display.contentHeight * 0.9,
   		3200
   	)
end

------------------------------------------

function explode(x, y, time)
   local fire=CBE.VentGroup{
   	{
   		title="fire",
   		preset="wisps",
   		color={{255,255,220},{255,255,120}},
   		x = x,
   		y = y,
   		emissionNum = 7,
   		fadeInTime = time,
   		physics={
   			gravityY=1.6,
   		}
   	}
   }
   fire:start("fire")
   
	timer.performWithDelay(time + 1000, function()
		fire:destroy("fire")
		fire = nil
	end)
end

------------------------------------------

function displayIntroText(text, x, y, fade)

	if(not text) then
		return
	end

	local introText = display.newText( screen, text, 0, 0, FONT, 45 )
	introText:setTextColor( 255 )	
	introText.x = x
	introText.y = y
	introText.alpha = 0
	introText:setReferencePoint( display.CenterReferencePoint )
	
	transition.to( introText, { time=1200, alpha=1, onComplete=function()
		if(fade) then
      	timer.performWithDelay(500, function()
      			transition.to( introText, { time=1000, alpha=0 })
			end)
		end
	end})
end

------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	if(introComplete) then
		self:refreshScene()
	end
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	viewManager.cleanupFires()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene