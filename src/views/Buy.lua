-----------------------------------------------------------------------------------------
--
-- KamikazeSelection
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local buyMenu

local statusText
local mainText
local secondText
local lockImage
local coffeeImage

local buyButton, textBuyButton
local restoreButton, textRestoreButton

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )

   if ( store.availableStores.apple ) then
       store.init( "apple", storeTransaction )
   elseif ( store.availableStores.google ) then
       store.init( "google", storeTransaction )
   end
	
	buyMenu = display.newGroup()
	game.scene = buyMenu
end


-----------------------------------------------------------------------------------------
--- STORE

function storeTransaction( event )
   print( "storeTransaction" )
   utils.tprint(event)

	local transaction = event.transaction

	if ( transaction.state == "purchased" ) then
		gameBought()

	elseif ( transaction.state == "restored" ) then
		gameBought()

	elseif ( transaction.state == "cancelled" ) then
		print( "cancelled")
		refreshStatus("Maybe next time...")

	elseif ( transaction.state == "failed" ) then
		print( "failed")
		refreshStatus("Transaction cancelled...")
	end

	--tell the store that the transaction is complete!
	--if you're providing downloadable content, do not call this until the download has completed
	store.finishTransaction( event.transaction )

end

-----------------------------------------------------------------------------------------

function scene:refreshScene()

	utils.emptyGroup(buyMenu)
	viewManager.initView(self.view);

	hud.setExit()
   
   local top = display.newRect(buyMenu, 0, -display.contentHeight/5, display.contentWidth, display.contentHeight/5)
   top:setFillColor(0)
   
   local bottom = display.newRect(buyMenu, 0, display.contentHeight, display.contentWidth, display.contentHeight/5)
   bottom:setFillColor(0)

   local board = display.newRoundedRect(buyMenu, 0, 0, 3*display.contentWidth/4, display.contentHeight/2, 20)
   board.x = display.contentWidth/2
   board.y = display.contentHeight/2
   board.alpha = 0
   board:setFillColor(0)
   buyMenu.board = board
   
	transition.to( top, { time=500, y = top.contentHeight/2 })
	transition.to( bottom, { time=500, y = display.contentHeight - top.contentHeight/2 })  
	transition.to( board, { time=800, alpha=0.9, onComplete= function() self:displayContent() end})  

	self.view:insert(buyMenu)
	
end

function scene:displayContent()

	-----------------------------------------------------------------------------------------------
	-- Texts

	display.remove(mainText)
	mainText = display.newText( buyMenu, T "The game is locked\n Get access to the full game for a coffee's price !", 0, 0, 170, 100, FONT, 14 )
	mainText:setTextColor( 255 )	
	mainText.x = buyMenu.board.x - 40
	mainText.y = buyMenu.board.y/2 + 60

	display.remove(lockImage)
	lockImage = display.newImage(buyMenu, "assets/images/hud/lock.png")
	lockImage:scale(0.40,0.40)
	lockImage.x = buyMenu.board.x - buyMenu.board.contentWidth/2 + 30
	lockImage.y = buyMenu.board.y/2 + 30
	lockImage:addEventListener	("touch", function(event) buy() end)

	display.remove(statusText)
	statusText = display.newText( buyMenu, "", 0, 0, FONT, 22 )
	statusText:setTextColor( 255 )	
	
	display.remove(coffeeImage)
	coffeeImage = display.newImage(buyMenu, "assets/images/hud/coffee.png")
	coffeeImage:scale(0.40,0.40)
	coffeeImage.x = buyMenu.board.x + 35
	coffeeImage.y = buyMenu.board.y + 15
	coffeeImage:addEventListener	("touch", function(event) buy() end)
	
	display.remove(secondText)
	secondText = display.newText( buyMenu, T "- Play all Levels\n- No more time limit", 0, 0, 170, 100, FONT, 14 )
	secondText:setTextColor( 255 )	
	secondText.x = buyMenu.board.x - buyMenu.board.contentWidth/2 + secondText.contentWidth + 13
	secondText.y = buyMenu.board.y + 85

	display.remove(buyButton)
	display.remove(textBuyButton)
	buyButton, textBuyButton = viewManager.buildButton(buyMenu, T "Buy",	"white", 26, buyMenu.board.x - buyMenu.board.contentWidth/2 + 45, 	display.contentHeight*0.61, function() buy() end)

	display.remove(restoreButton)
	display.remove(textRestoreButton)
	restoreButton, textRestoreButton = viewManager.buildButton(buyMenu, T "Restore", "white", 20, buyMenu.board.x + buyMenu.board.contentWidth/2 - 45, 	display.contentHeight*0.61, function() restore() end)

end

------------------------------------------

function buy()
	display.remove(lockImage)
	display.remove(mainText)
	display.remove(buyButton)
	display.remove(textBuyButton)
	display.remove(restoreButton)
	display.remove(textRestoreButton)
	display.remove(coffeeImage)
	display.remove(secondText)
	viewManager.cleanupFires()
	
	store.purchase( { "com.uralys.thelightningplanet.1.0" } )
	
	refreshStatus("Waiting for store...")

	-----------------------------
	-- DEV only : simulator
	
	if(system.getInfo("environment") == "simulator") then
		gameBought()
	end
end

------------------------------------------

function restore()
	display.remove(lockImage)
	display.remove(mainText)
	display.remove(buyButton)
	display.remove(textBuyButton)
	display.remove(restoreButton)
	display.remove(textRestoreButton)
	display.remove(coffeeImage)
	display.remove(secondText)
	viewManager.cleanupFires()
	
	store.restore(  )
	
	refreshStatus("Trying to restore...")

	-----------------------------
	-- DEV only : simulator
	
	if(system.getInfo("environment") == "simulator") then
		gameBought()
	end
end

------------------------------------------

function gameBought()
	GLOBALS.savedData.fullGame = true
   utils.saveTable(GLOBALS.savedData, "savedData.json")
	refreshStatus("Thank you !")
	timer.performWithDelay(1500, router.openAppHome)
end

------------------------------------------

function refreshStatus(message)
	if(statusText) then
   	statusText.text = message
   	statusText.x = buyMenu.board.x
   	statusText.y = buyMenu.board.y
   end
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