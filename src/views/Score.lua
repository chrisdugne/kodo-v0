-----------------------------------------------------------------------------------------
--
-- KamikazeSelection
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local scoreMenu

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	scoreMenu = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()
	utils.emptyGroup(scoreMenu)
	viewManager.initView(self.view);
	
	hud.setExit()
   
   local top = display.newRect(scoreMenu, 0, -display.contentHeight/5, display.contentWidth, display.contentHeight/5)
   top:setFillColor(0)
   
   local bottom = display.newRect(scoreMenu, 0, display.contentHeight, display.contentWidth, display.contentHeight/5)
   bottom:setFillColor(0)

   local board = display.newRoundedRect(scoreMenu, 0, 0, display.contentWidth/2, display.contentHeight/2, 20)
   board.x = display.contentWidth/2
   board.y = display.contentHeight/2
   board.alpha = 0
   board:setFillColor(0)
   scoreMenu.board = board
   
	transition.to( top, { time=500, y = top.contentHeight/2 })
	transition.to( bottom, { time=500, y = display.contentHeight - top.contentHeight/2 })  
	transition.to( board, { time=800, alpha=0.9, onComplete= function() self:displayContent() end})  

	self.view:insert(scoreMenu)
	
	if(game.position) then
		game.storeRecord()
   end
end

function scene:displayContent()

	local type = game:getGameType()
	local level = game.getLevel()
	local value = game.getTextValue()

	-----------------------------------------------------------------------------------------------
	-- Texts

	local title = display.newText( scoreMenu, type, 0, 0, FONT, 25 )
	title:setTextColor( 255 )	
	title.x = scoreMenu.board.x + 10 - scoreMenu.board.contentWidth/2 + title.contentWidth/2
	title.y = scoreMenu.board.y - scoreMenu.board.contentHeight/2 + title.contentHeight/2

	local level = display.newText( scoreMenu, level, 0, 0, FONT, 21 )
	level:setTextColor( 255 )	
	level.x = scoreMenu.board.x - 10 + scoreMenu.board.contentWidth/2 - level.contentWidth/2
	level.y = scoreMenu.board.y + 5 - scoreMenu.board.contentHeight/2 + level.contentHeight/2

	local time = display.newText( scoreMenu, value, 0, 0, FONT, 20 )
	time:setTextColor( 255 )	
	time.x = scoreMenu.board.x
	time.y = scoreMenu.board.y - scoreMenu.board.contentHeight/3 + time.contentHeight/2
	
	-----------------------------------------------------------------------------------------------
	-- Planets
	
	viewManager.buildButton(scoreMenu, "", "white", 22, scoreMenu.board.x, 														display.contentHeight*0.58, function() router.openSelection() end)
	
	-----------------------------------------------------------------------------------------------
	-- Icons

	local next = display.newImage("assets/images/hud/play.png")
	next:scale(0.50,0.50)
	next.x = scoreMenu.board.x
	next.y = display.contentHeight*0.58
	next.alpha = 0
	scoreMenu:insert(next)
	
	transition.to( next, { time=1200, alpha=1 })  
	   
end

------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene()
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