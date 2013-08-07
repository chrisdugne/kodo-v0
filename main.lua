-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

APP_NAME 	= "Kodo"
APP_VERSION = "1.0"

-----------------------------------------------------------------------------------------

IOS 		= system.getInfo( "platformName" )  == "iPhone OS"
ANDROID 	= system.getInfo( "platformName" )  == "Android"

-----------------------------------------------------------------------------------------

IMAGE_CENTER		= "IMAGE_CENTER";
IMAGE_TOP_LEFT 	= "IMAGE_TOP_LEFT";

-----------------------------------------------------------------------------------------

GHOST 		= "ghost"
OCTOPUS 		= "octopus"
HORROR 		= "horror"
MONSTER 		= "monster"
NINJA 		= "ninja"
SKULL 		= "skull"
EYES			= "eyes"
BLINK 		= "blink"

COLORS = {GHOST, OCTOPUS, HORROR, MONSTER, NINJA, SKULL, EYES, BLINK}

-----------------------------------------------------------------------------------------

ASTEROID_CRASH_KAMIKAZE_PERCENT 	= 3
LIGHTNING_KAMIKAZE_PERCENT 		= 20

-----------------------------------------------------------------------------------------

if ANDROID then
   FONT = "Macondo-Regular"
else
	FONT = "Macondo"
end

-----------------------------------------------------------------------------------------
--- Corona's libraries
json 				= require "json"
storyboard 		= require "storyboard"
store	 			= require "store"

---- Additional libs
xml 				= require "src.libs.Xml"
utils 			= require "src.libs.Utils"
vector2D			= require "src.libs.Vector2D"
gameCenter		= require "src.libs.GameCenter"
adsManager		= require "src.libs.AdsManager"

-----------------------------------------------------------------------------------------
-- Translations

local translations = require("assets.Translations")
local LANG =  userDefinedLanguage or system.getPreference("ui", "language")
LANG = "fr"

function T(enText)
	return translations[enText][LANG] or enText
end

-----------------------------------------------------------------------------------------
---- Server access Managers

---- App Tools
router 			= require "src.tools.Router"
viewManager		= require "src.tools.ViewManager"
musicManager	= require "src.tools.MusicManager"

---- Game libs
hud				= require "src.game.HUD"
game				= require "src.game.Game"

--- tutorials
tutorialClassic		= require "src.game.tutorials.TutorialClassic"

-----------------------------------------------------------------------------------------
---- App globals

GLOBALS = {
	savedData = utils.loadTable("savedData.json")
}

---- Levels
CLASSIC_LEVELS		= require "src.game.levels.ClassicLevels"

-----------------------------------------------------------------------------------------

physics = require("physics") ; physics.start() ; physics.setGravity( 0,0 ) ; physics.setDrawMode( "normal" )
math.randomseed( os.time() )

------------------------------------------

CBE	=	require("CBEffects.Library")

------------------------------------------
	
if(not GLOBALS.savedData) then
	game.initGameData()
end

------------------------------------------

musicManager.playMusic()

------------------------------------------

router.openAppHome()

-----------------------------------------------------------------------------------------

function getColorNum(color)
	for i = 1, #COLORS do
		if(color == COLORS[i]) then
			return i
   	end
	end
end

function getRGB(color)
	if(color == BLUE) then
		return {0, 111, 255}
	elseif(color == GREEN) then
		return {0, 255, 120}
	elseif(color == RED) then
		return {255, 125, 120}
	elseif(color == YELLOW) then
		return {255, 255, 120}
	elseif(color == "white") then
		return {255, 255, 255}
	end
end

------------------------------------------
--- iOS Status Bar

display.setStatusBar( display.HiddenStatusBar ) 

------------------------------------------
--- ANDROID BACK BUTTON

local function onKeyEvent( event )

   local phase = event.phase
   local keyName = event.keyName
   print( event.phase, event.keyName )

   if ( "back" == keyName and phase == "up" ) then
      if ( storyboard.currentScene == "splash" ) then
         native.requestExit()
      else
--      	native.setKeyboardFocus( nil )
-- 		nothing
      end
   end

   return true  --SEE NOTE BELOW
end

--add the key callback
Runtime:addEventListener( "key", onKeyEvent )
