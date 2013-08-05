-----------------------------------------------------------------------------------------
--
-- KamikazeSelection
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local optionsMenu

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	optionsMenu = display.newGroup()
	game.scene = optionsMenu
	
	print("created")
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()
	print("ref")

	utils.emptyGroup(optionsMenu)
	viewManager.initView(self.view);

	hud.setBackToHome()
   
   local top = display.newRect(optionsMenu, 0, -display.contentHeight/5, display.contentWidth, display.contentHeight/5)
   top:setFillColor(0)
   
   local bottom = display.newRect(optionsMenu, 0, display.contentHeight, display.contentWidth, display.contentHeight/5)
   bottom:setFillColor(0)

   local board = display.newRoundedRect(optionsMenu, 0, 0, display.contentWidth*0.75, display.contentHeight/2, 20)
   board.x = display.contentWidth/2
   board.y = display.contentHeight/2
   board.alpha = 0
   board:setFillColor(0)
   optionsMenu.board = board
   
	transition.to( top, { time=500, y = top.contentHeight/2 })
	transition.to( bottom, { time=500, y = display.contentHeight - top.contentHeight/2 })  
	transition.to( board, { time=800, alpha=0.9, onComplete= function() self:displayContent() end})  

	self.view:insert(optionsMenu)
	
end

function scene:displayContent()

	-----------------------------------------------------------------------------------------------

	if(not GLOBALS.savedData.fullGame) then
		viewManager.buildButton(optionsMenu, T "Full version", "white", 12, display.contentWidth*0.77, 	display.contentHeight*0.38, 	router.openBuy)
	else
		thanksText = display.newText(optionsMenu, "Thank you for purchasing the full version !", 0, 0, 70, 100, FONT, 12 )
		thanksText.x = display.contentWidth*0.75
		thanksText.y = display.contentHeight*0.4
	end
	viewManager.buildButton(optionsMenu, "Reset", "white", 	21, display.contentWidth*0.77, 	display.contentHeight*0.61, function()	self:reset() end)
	
	-----------------------------------------------------------------------------------------------

	uralysText = display.newText(optionsMenu, "Created by ", 0, 0, FONT, 13 )
	uralysText.x = optionsMenu.board.x - optionsMenu.board.contentWidth/2 + uralysText.contentWidth/2 + 30
	uralysText.y = optionsMenu.board.y/2 + 25

	uralysImage = display.newImage(optionsMenu, "assets/images/others/logo.png")
	uralysImage.x = optionsMenu.board.x - optionsMenu.board.contentWidth/2 + uralysImage.contentWidth/2 + 100
	uralysImage.y = optionsMenu.board.y/2 + 25
	uralysImage:addEventListener	("touch", function(event) system.openURL( "http://www.uralys.com" ) end)

	-----------------------------------------------------------------------------------------------

	coronaImage = display.newImage(optionsMenu, "assets/images/others/corona.png")
	coronaImage:scale(0.3,0.3)
	coronaImage.x = optionsMenu.board.x - optionsMenu.board.contentWidth/2 + coronaImage.contentWidth/2 + 20
	coronaImage.y = optionsMenu.board.y/2 + 110
	coronaImage:addEventListener	("touch", function(event) system.openURL( "http://www.coronalabs.com" ) end)

	cbeffectsImage = display.newImage(optionsMenu, "assets/images/others/cbeffects.png")
	cbeffectsImage:scale(0.2,0.2)
	cbeffectsImage.x = optionsMenu.board.x - optionsMenu.board.contentWidth/2 + cbeffectsImage.contentWidth/2 + 130
	cbeffectsImage.y = optionsMenu.board.y/2 + 100
	cbeffectsImage:addEventListener	("touch", function(event) system.openURL( "http://gymbyl.com" ) end)

	velvetText = display.newText(optionsMenu, "Music by Velvet Coffee", 0, 0, FONT, 13 )
	velvetText.x = optionsMenu.board.x - optionsMenu.board.contentWidth/2 + velvetText.contentWidth/2 + 100
	velvetText.y = cbeffectsImage.y + 45
	velvetText:addEventListener	("touch", function(event) system.openURL( "https://soundcloud.com/velvetcoffee" ) end)

	playImage = display.newImage(optionsMenu, "assets/images/hud/play.png")
	playImage:scale(0.2,0.2)
	playImage.x = velvetText.x + 80
	playImage.y = velvetText.y
	playImage:addEventListener	("touch", function(event) system.openURL( "https://soundcloud.com/velvetcoffee" ) end)
end

------------------------------------------

function scene:reset()
   native.showAlert( T "Reset the game", T "Confirm now to erase your level progression and start the game again", { "OK", T "Cancel" }, function(event) self:confirmReset(event) end )
end

function scene:confirmReset( event )
    if "clicked" == event.action then
        local i = event.index
        if 1 == i then
         	game.initGameData()
            router.openAppHome()
        end
    end
end

-- Show alert with two buttons
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