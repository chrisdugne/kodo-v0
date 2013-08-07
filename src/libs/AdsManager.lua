-------------------------------------

module(..., package.seeall)

-------------------------------------

local ads = require "ads"

---------------------------------------------------------------------

function init()
	if(IOS) then
   	print("init iAds")
   	ads.init( "iads", "684227637", adListener )
   end

	if(ANDROID) then
   	print("init AdMob")
   	ads.init( "AdMob", "a1520200cc38c3d", adListener )
   end
end

---------------------------------------------------------------------

function adListener( event )

	local msg = event.response
	if event.isError then
		-- Failed to receive an ad, we print the error message returned from the library.
		print(msg)
	end
end
