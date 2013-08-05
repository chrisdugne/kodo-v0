-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

local fires = {}
local elements = {}

-----------------------------------------------------------------------------------------

function initView(view)
	reset(view)
	cleanupFires()
end

------------------------------------------------------------------------------------------

function reset(view)
	local back = display.newImage( view, "assets/images/stars.jpg")  
	back:scale(0.7,0.7)
	back.x = display.viewableContentWidth/2  
	back.y = display.viewableContentHeight/2  
end

------------------------------------------------------------------------------------------

function buildButton(view, title, color, titleSize, x, y, action, lock, condition )

	local colors={{255, 255, 255}, {255, 70, 70}}

	local planet = display.newImage( "assets/images/game/planet.".. color ..".png")
	planet:scale(display.contentHeight/1000,display.contentHeight/1000)
	planet.x = x
	planet.y = y
	planet.alpha = 0
	planet.color = color
	view:insert(planet)
	
	
	local text = display.newText( title, 0, 0, FONT, titleSize )
	text:setTextColor( 0 )	
	text.x = x
	text.y = y
	text.alpha = 0
	view:insert(text)
	
	transition.to( planet, { time=2000, alpha=1 })
	transition.to( text, { time=2000, alpha=1 })
	
	if(lock and condition) then
   	local lock = display.newImage("assets/images/hud/lock.png")
   	lock:scale(0.50,0.50)
   	lock.x = x
   	lock.y = y
   	lock.alpha = 0
   	view:insert(lock)
   	transition.to( lock, { time=2000, alpha=0.6 })
   	planet:setFillColor(30,30,30)
   	
   	return planet, text, lock
   else
		planet:addEventListener	("touch", function(event) action() end)

   	local fire=CBE.VentGroup{
   		{
   			title="fire",
   			preset="burn",
   			color=colors,
   			build=function()
   				local size=math.random(24, 38)
   				return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
   			end,
   			onCreation=function()end,
   			perEmit=2,
   			emissionNum=0,
   			x=x,
   			y=y,
   			positionType="inRadius",
   			posRadius=38,
   			emitDelay=50,
   			fadeInTime=1500,
   			lifeSpan=250,
   			lifeStart=250,
   			endAlpha=0,
   			physics={
   				velocity=0.5,
   				xDamping=1,
   				gravityY=0.6,
   				gravityX=0
   			}
   		}
   	}
   	
   	table.insert(fires, fire)
		fire:start("fire")
		
   	return planet, text
	end

end

------------------------------------------------------------------------------------------

function buildSmallButton(view, title, color, titleSize, x, y, action, lock )

	local colors
	if(color == COLORS[1] or color == COLORS[5]) then
		colors={{0, 111, 255}, {0, 70, 255}}
	elseif(color == COLORS[2] or color == COLORS[6]) then
		colors={{181, 255, 111}, {120, 255, 70}}
	elseif(color == COLORS[3] or color == COLORS[7]) then
		colors={{255, 131, 111}, {255, 211, 70}}
	elseif(color == COLORS[4] or color == COLORS[8]) then
		colors={{255, 111, 0}, {255, 70, 0}}
	elseif(color == "white") then
		colors={{255, 111, 0}, {255, 70, 0}}
	else
		color = "white"
		colors={{255, 111, 0}, {255, 70, 0}}
	end

	local planet = display.newImage( "assets/images/game/planet.".. color ..".png")
	planet:scale(0.13,0.13)
	planet.x = x
	planet.y = y
	planet.alpha = 0
	planet.color = color
	view:insert(planet)
	
	local text = display.newText( title, 0, 0, FONT, titleSize )
	text:setTextColor( 0 )	
	text.x = x
	text.y = y-2
	text.alpha = 0
	view:insert(text)
	
	transition.to( planet, 	{ time=2000, alpha=1 })
	transition.to( text, 	{ time=2000, alpha=1 })
	
	if(lock) then
   	local lock = display.newImage("assets/images/hud/lock.png")
   	lock:scale(0.15,0.15)
   	lock.x = x
   	lock.y = y
   	lock.alpha = 0
   	view:insert(lock)
   	transition.to( lock, { time=2000, alpha=0.6 })
   	planet:setFillColor(30,30,30)
   	
   else
		planet:addEventListener	("touch", function(event) action() end)

   	local fire=CBE.VentGroup{
   		{
   			title="fire",
   			preset="burn",
   			color=colors,
   			build=function()
   				local size=math.random(31, 38) -- Particles are a bit bigger than ice comet particles
   				return display.newImageRect("CBEffects/textures/generic_particle.png", size, size)
   			end,
   			onCreation=function()end,
   			perEmit=1,
   			emissionNum=0,
   			x=x,
   			y=y,
   			positionType="inRadius",
   			posRadius=12,
   			emitDelay=500,
   			fadeInTime=1500,
   			lifeSpan=1000, -- Particles are removed sooner than the ice comet
   			lifeStart=250,
   			endAlpha=0,
   			physics={
   				velocity=0.4,
   				gravityY=0.3,
   				gravityX=0
   			}
   		}
   	}
   	
   	table.insert(fires, fire)
		fire:start("fire")
	end
end

------------------------------------------

function cleanupFires()	

	for fire = 1, #fires do 
		fires[fire]:destroy("fire")
	end
	
	while #fires > 0 do
   	table.remove(fires, 1)
	end
	
	collectgarbage("collect")
end
