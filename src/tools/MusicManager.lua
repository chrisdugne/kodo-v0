-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

local mainMusic = audio.loadSound("assets/music/TheLightningPlanet.mp3")

local space = audio.loadSound("assets/music/space.mp3")
local planet = {
	audio.loadSound("assets/music/planet1.mp3"),
	audio.loadSound("assets/music/planet2.mp3"),
	audio.loadSound("assets/music/planet3.mp3")
}

local asteroid = {
	audio.loadSound("assets/music/asteroid1.mp3"),
	audio.loadSound("assets/music/asteroid2.mp3"),
	audio.loadSound("assets/music/asteroid3.mp3"),
}

local light = {
	audio.loadSound("assets/music/light1.mp3"),
	audio.loadSound("assets/music/light2.mp3"),
	audio.loadSound("assets/music/light3.mp3"),
	audio.loadSound("assets/music/light4.mp3"),
}

-----------------------------------------------------------------------------------------
--local options =
--{
--    channel=1,
--    loops=-1,
--    duration=30000,
--    fadein=5000,
--    onComplete=callbackListener
--}
-----------------------------------------------------------------------------------------

function playMusic()
	audio.play( mainMusic, {
		loops=-1,
	})

end

function playSpace()
	local channel = audio.play( space )
	audio.setVolume( 0.4, { channel=channel } )
end

function playPlanet()
	local sound = math.random(1,3)
	local channel = audio.play( planet[sound])
	audio.setVolume( 0.3, { channel=channel} )
end

function playAsteroid()
	local sound = math.random(1,3)
	local channel = audio.play( asteroid[sound])
	
	audio.setVolume( 0.45, { channel=channel} )
end

function playLight()
	local sound = math.random(1,4)
	local channel = audio.play( light[sound])
	
	audio.setVolume( 0.25, { channel=channel} )
end