-------------------------------------

module(..., package.seeall)

-------------------------------------

local gameNetwork = require "gameNetwork"
local loggedIntoGC = false
local gameCenterOpened = false

---------------------------------------------------------------------

function init()
	if(not loggedIntoGC) then
		gameNetwork.init( "gamecenter", initCallback )
	end
end

-- called after the "init" request has completed
function initCallback( event )
	if event.data then
		loggedIntoGC = true
	else
		loggedIntoGC = false
	end
end

---------------------------------------------------------------------

function showLeaderBoards()
	if(gameCenterOpened) then return end
	gameCenterOpened = true
	gameNetwork.show( "leaderboards", { listener=onGameNetworkPopupDismissed } )
end

function onGameNetworkPopupDismissed(event)
	gameCenterOpened = false
end

---------------------------------------------------------------------
 ---Achievements
 -- classic.2min
 
function postAchievement(type)

	gameNetwork.request( "unlockAchievement", { achievement = {
			identifier="type",
		},
		listener=requestCallback
	})
end

---------------------------------------------------------------------
--- Scores
-- classic
-- timeattack.easy
-- timeattack.hard
-- timeattack.extreme
-- kamikaze.easy
-- kamikaze.hard
-- kamikaze.extreme

function postScore(board, value)
	gameNetwork.request( "setHighScore",
	{
		localPlayerScore = { category=board, value=value },
		listener=requestCallback
	}) 
end

function requestCallback( event )
end

---------------------------------------------------------------------