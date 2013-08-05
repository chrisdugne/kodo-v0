-----------------------------------------------------------------------------------------
--
-- KamikazeSelection
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local newRecordMenu

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	newRecordMenu = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()
	utils.emptyGroup(newRecordMenu)
	viewManager.initView(self.view);

	print("newRecord position " .. game.position)

	local top = display.newRect(newRecordMenu, 0, -display.contentHeight/5, display.contentWidth, display.contentHeight/5)
	top:setFillColor(0)

	local bottom = display.newRect(newRecordMenu, 0, display.contentHeight, display.contentWidth, display.contentHeight/5)
	bottom:setFillColor(0)

	local board = display.newRoundedRect(newRecordMenu, 0, 0, display.contentWidth/2, display.contentHeight/2, 20)
	board.x = display.contentWidth/2
	board.y = display.contentHeight/2
	board.alpha = 0
	board:setFillColor(0)
	newRecordMenu.board = board

	transition.to( top, { time=500, y = top.contentHeight/2 })
	transition.to( bottom, { time=500, y = display.contentHeight - top.contentHeight/2 })  
	transition.to( board, { time=800, alpha=0.9, onComplete= function() self:displayContent() end})  

	self.view:insert(newRecordMenu)
end

function scene:displayContent()

	local value = game.getTextValue()

	-----------------------------------------------------------------------------------------------
	-- Texts
	
	local position = game.position
	
	if(position == 1) then position = position .. "st"
	elseif(position == 2) then position = position .. "nd"
	elseif(position == 3) then position = position .. "rd"
	else position = position .. "th" end

	local title = display.newText( newRecordMenu, T(position) .. " !", 0, 0, FONT, 25 )
	title:setTextColor( 255 )	
	title.x = newRecordMenu.board.x + 10 - newRecordMenu.board.contentWidth/2 + title.contentWidth/2
	title.y = newRecordMenu.board.y - newRecordMenu.board.contentHeight/2 + title.contentHeight/2

	local level = display.newText( newRecordMenu, value, 0, 0, FONT, 18 )
	level:setTextColor( 255 )	
	level.x = newRecordMenu.board.x - 10 + newRecordMenu.board.contentWidth/2 - level.contentWidth/2
	level.y = newRecordMenu.board.y + 5 - newRecordMenu.board.contentHeight/2 + level.contentHeight/2

	-----------------------------------------------------------------------------------------------
	-- Planets

	viewManager.buildButton(newRecordMenu, "", "white", 22, newRecordMenu.board.x + newRecordMenu.board.contentWidth/2 - 50, 	display.contentHeight*0.58, router.openScore)

	-----------------------------------------------------------------------------------------------
	-- Icons

	local next = display.newImage("assets/images/hud/play.png")
	next:scale(0.50,0.50)
	next.x = newRecordMenu.board.x + newRecordMenu.board.contentWidth/2 - 50
	next.y = display.contentHeight*0.58
	next.alpha = 0
	newRecordMenu:insert(next)

	transition.to( next, { time=1200, alpha=1 })  

	------------------------------------------

	nameInput = native.newTextField( 
	display.contentWidth/4 + 20, 
	130, 
	140
	, 30 
	)

	nameInput:setTextColor( 0 )	
	nameInput.align = "center"
	nameInput.text = GLOBALS.savedData.user
	nameInput.font = native.newFont( FONT, 20 )
	nameInput:setReferencePoint( display.CenterReferencePoint )
	nameInput:addEventListener( "userInput", nameHandler )
	newRecordMenu:insert( nameInput )
end

------------------------------------------

function nameHandler( event )

	if ( "ended" == event.phase) then

	elseif ( "editing" == event.phase ) then
		if(#nameInput.text > 12) then
			nameInput.text = GLOBALS.savedData.user
		else 
			GLOBALS.savedData.user = nameInput.text
			utils.saveTable(GLOBALS.savedData, "savedData.json")
		end 

	elseif ( "submitted" == event.phase ) then
		native.setKeyboardFocus( nil )
	end
end 

------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene()
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	display.remove(nameInput)
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