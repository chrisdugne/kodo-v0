-------------------------------------

module(..., package.seeall)

-------------------------------------

local ads = require "ads"

---------------------------------------------------------------------

function init()
--	if(IOS) then
--   	print("init iAds")
--   	ads.init( "iads", "com.uralys.kodo", adListener )
--   end
--
--	if(ANDROID) then
--   	print("init AdMob")
--   	ads.init( "AdMob", "com.uralys.kodo", adListener )
--   end
end

function show()
--	print("----------------------------         show ad")
--	ads.show( "banner", { x=display.contentWidth/2, y=display.contentHeight - 20 } )
end

---------------------------------------------------------------------

function adListener( event )

	local msg = event.response
	if event.isError then
		-- Failed to receive an ad, we print the error message returned from the library.
		print(msg)
	end
end
