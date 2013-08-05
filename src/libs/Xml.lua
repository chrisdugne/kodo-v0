
--the module
module(..., package.seeall)

local function loadAttributes( element, s )
	string.gsub( s, "(%w+)=([\"'])(.-)%2", function ( w, _, a )
		element[w] = a
	end )
end

function parseXML( s )
	local stack = {}
	local top = {}
	table.insert( stack, top )
	local ni, c, label, xarg, empty
	local i, j = 1, 1
	while true do
		ni, j, c, label, xarg, empty = string.find(s, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
		if not ni then break end
		local text = string.sub(s, i, ni-1)
		if not string.find(text, "^%s*$") then
			top.value = text
		end

		if empty == "/" then -- empty element tag
			loadAttributes( top, xarg )

		elseif c == "" then -- start tag
			top = {}
			loadAttributes( top, xarg )
			table.insert( stack, top )

		else -- end tag
			local close = table.remove( stack )
			top = stack[ #stack ]

			if top[ label ] then
				if #top[ label ] ~= 0 then
					table.insert( top[ label ], close )
				else
					local node = top[ label ]
					local collection = {}
					table.insert( collection, node )
					table.insert( collection, close )
					top[ label ] = collection
				end
			else 
				top[ label ] = close
			end                                     
		end
		i = j+1
	end
	return stack[1]
end

---
-- if a list has 1 element, it wont be a table : call this to create a "list" with one element
-- o : object that should be table
function asTable(o)
	if(o ~= nil) then
		if(# o < 2) then
			return {o}
		else
			return o
		end
	else
		return {}
	end
end


