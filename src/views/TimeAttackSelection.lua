-----------------------------------------------------------------------------------------
--
-- TimeAttackSelection
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local timeAttackLevels

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	timeAttackLevels = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()
	utils.emptyGroup(timeAttackLevels)
	viewManager.initView(self.view);

	game.scene = self.view
	hud.initHUD()
	hud.initTopRightText()
	hud.refreshTopRightText("Time Attack")
	hud.setExit(self.exitSelection)
	
	viewManager.buildButton(timeAttackLevels, T "Tutorial", 	COLORS[1], 22, display.contentWidth/5, 	display.contentHeight*0.4, function() self:openLevel(1)	end			)
	viewManager.buildButton(timeAttackLevels, "2 min",	 		COLORS[2], 22, 2*display.contentWidth/5, 	display.contentHeight*0.6, function() self:openLevel(2)	end, 	true,	(not GLOBALS.savedData.timeAttackAvailable))
	viewManager.buildButton(timeAttackLevels, "5 min", 		COLORS[3], 22, 3*display.contentWidth/5, 	display.contentHeight*0.4, function() self:openLevel(3)	end, 	true,	(not GLOBALS.savedData.timeAttackAvailable))
	viewManager.buildButton(timeAttackLevels, "8 min", 		COLORS[4], 22, 4*display.contentWidth/5, 	display.contentHeight*0.6, function() self:openLevel(4)	end, 	true,	(not GLOBALS.savedData.timeAttackAvailable))

	self.view:insert(timeAttackLevels)
end

------------------------------------------

function scene:exitSelection()
	for i = timeAttackLevels.numChildren,1,-1  do
		hud.explode(timeAttackLevels[i], 2, 2000, timeAttackLevels[i].color)
	end
	
	hud.explodeHUD()
	viewManager.cleanupFires()
	
	musicManager.playSpace()
end

------------------------------------------

function scene:openLevel( level )
	game.level = level
	self:exitSelection()
	timer.performWithDelay(1500, router.openPlayground)
end

------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene();
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