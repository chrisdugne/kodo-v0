-----------------------------------------------------------------------------------------
--
-- KamikazeSelection
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local podiums
local content

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	podiums = display.newGroup()
	content = display.newGroup()
	game.scene = podiums
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()

	utils.emptyGroup(content)
	utils.emptyGroup(podiums)
	viewManager.initView(self.view);
	
	position = 1
	moving = false
	
	hud.setExit()
   
   local top = display.newRect(podiums, 0, -display.contentHeight/5, display.contentWidth, display.contentHeight/5)
   top:setFillColor(0)
   
   local bottom = display.newRect(podiums, 0, display.contentHeight, display.contentWidth, display.contentHeight/5)
   bottom:setFillColor(0)

   local board = display.newRoundedRect(podiums, 0, 0, 3*display.contentWidth/4, display.contentHeight/2, 20)
   board.x = display.contentWidth/2
   board.y = display.contentHeight/2
   board.alpha = 0
   board:setFillColor(0)
   podiums.board = board
   
	transition.to( top, { time=500, y = top.contentHeight/2 })
	transition.to( bottom, { time=500, y = display.contentHeight - top.contentHeight/2 })  
	transition.to( board, { time=800, alpha=0.9, onComplete= function() self:buildContent() end})  

	if(IOS) then
   	local gamecenter = display.newImage(podiums, "assets/images/hud/gamecenter.png")
   	gamecenter:scale(0.25,0.25)
   	gamecenter.x = display.contentWidth - 110 
   	gamecenter.y = 110 
   	gamecenter:addEventListener ("touch", function(event) gameCenter.showLeaderBoards() end)
	end
	
	self.view:insert(podiums)
	self.view:insert(content)
end

function scene:buildContent()
	
	---------------------------------------------------------------------------------------------
	
	self:buildTable("Kodo !", 1, GLOBALS.savedData.scores.classic)
	
	---------------------------------------------------------------------------------------------

	self:move()
end

------------------------------------------

function scene:buildTable(title, position, data)
	local titleText = display.newText( content, title, 0, 0, FONT, 22 )
	titleText:setTextColor( 255 )
	titleText.x = podiums.contentWidth/2 + (position-1)*podiums.contentWidth
	titleText.y = 100
	
	local marginTop = 2*display.contentHeight/5
	
	for entry=1,10 do
		
		local i = math.floor((entry-1) /5)
		local j = (entry-1)%5
		
		local entryText = entry.."."
		if(data[entry]) then
			entryText = entryText .. "   " .. data[entry].value
		else
			entryText = entryText .. "    -------------"
		end
		
		local nameText = ""
		if(data[entry]) then
			nameText = data[entry].name 
		end
		
   	local entry = display.newText( content, entryText, 0, 0, FONT, 12 )
   	entry:setTextColor( 255 )
   	entry:setReferencePoint( display.CenterLeftReferencePoint )
   	entry.x = podiums.contentWidth/6 + i*podiums.contentWidth/3 + (position-1)*podiums.contentWidth + 15
   	entry.y = marginTop + j*20

   	local name = display.newText( content, nameText, 0, 0, FONT, 12 )
   	name:setTextColor( 255 )
   	name:setReferencePoint( display.CenterLeftReferencePoint )
   	name.x = podiums.contentWidth/6 + i*podiums.contentWidth/3 + (position-1)*podiums.contentWidth + 85
   	name.y = marginTop + j*20
	end
end

------------------------------------------

function scene:left()
	if(moving or position == 1) then return end
	position = position - 1
	self:move()
end

------------------------------------------

function scene:right()
	if(moving or position == 7) then return end
	position = position + 1
	self:move()
end

------------------------------------------

function scene:move()
	moving = true
	transition.to(content, {x = -display.contentWidth*(position-1), time=300, onComplete=function() moving = false end})
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