-----------------------------------------------------------------------------------------
--
-- router.lua
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function openAppHome()
	hud.explodeHUD()
	storyboard.gotoScene( "src.views.AppHome" )
end

---------------------------------------------

function openPlayground()
	storyboard.gotoScene( "src.views.Playground" )
end

---------------------------------------------

function openSelection()

	if(game.mode == game.CLASSIC) then
		openAppHome()
	end

	if(game.mode == game.COMBO) then
		openLevelSelection()
	end

	if(game.mode == game.KAMIKAZE) then
		openKamikazeSelection()
	end

	if(game.mode == game.TIMEATTACK) then
		openTimeAttackSelection()
	end
end

function openLevelSelection()
	storyboard.gotoScene( "src.views.LevelSelection" )
end

function openKamikazeSelection()
	storyboard.gotoScene( "src.views.KamikazeSelection" )
end

function openTimeAttackSelection()
	storyboard.gotoScene( "src.views.TimeAttackSelection" )
end

---------------------------------------------

function openOptions()
	storyboard.gotoScene( "src.views.Options" )
end

---------------------------------------------

function openPodiums()
	storyboard.gotoScene( "src.views.Podiums" )
end

---------------------------------------------

function openScore()
	storyboard.gotoScene( "src.views.Score" )
end

function openNewRecord()
	storyboard.gotoScene( "src.views.NewRecord" )
end

---------------------------------------------

function openBuy()
	storyboard.gotoScene( "src.views.Buy" )
end