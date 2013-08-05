-----------------------------------------------------------------------------------------
-- Project: Utils for uralys.libs
--
-- Date: May 8, 2013
--
-- Version: 1.5
--
-- File name	: Utils.lua
-- 
-- Author: Chris Dugne @ Uralys - www.uralys.com
--
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------
--
--
function getMinSec(seconds)
	local min = math.floor(seconds/60)
	local sec = seconds - min * 60
	
	if(sec < 10) then
		sec = "0" .. sec
	end
	
	return min, sec
end

function getUrlParams(url)

	local index = string.find(url,"?")
	local paramsString = url:sub(index+1, string.len(url) )

	local params = {}

	fillNextParam(params, paramsString);

	return params;

end

function fillNextParam(params, paramsString)

	local indexEqual = string.find(paramsString,"=")
	local indexAnd = string.find(paramsString,"&")

	local indexEndValue
	if(indexAnd == nil) then 
		indexEndValue = string.len(paramsString) 
	else 
		indexEndValue = indexAnd - 1 
	end

	if ( indexEqual ~= nil ) then
		local varName = paramsString:sub(0, indexEqual-1)
		local value = paramsString:sub(indexEqual+1, indexEndValue)
		params[varName] = url_decode(value)

		if (indexAnd ~= nil) then
			paramsString = paramsString:sub(indexAnd+1, string.len(paramsString) )
			fillNextParam(params, paramsString)
		end

	end

end


-----------------------------------------------------------------------------------------

function split(value, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	value:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

-----------------------------------------------------------------------------------------

function emptyGroup( group )
	if(group ~= nil) then
		for i=group.numChildren,1,-1 do
			local child = group[i]
			child:removeSelf()
			child = nil
		end
	end
end

-----------------------------------------------------------------------------------------

function string.startsWith(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

function string.endsWith(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end

-----------------------------------------------------------------------------------------

function joinTables(t1, t2)

	local result = {}
	if(t1 == nil) then t1 = {} end
	if(t2 == nil) then t2 = {} end

	for k,v in pairs(t1) do
		result[k] = v 
	end 

	for k,v in pairs(t2) do
		result[k] = v 
	end 

	return result
end

-----------------------------------------------------------------------------------------

function imageName( url )
	local index = string.find(url,"/")

	if(index == nil) then 
		if(not string.endsWith(url, ".png")) then
			url = url .. ".png"
		end
		return url;
	else
		local subURL = url:sub(index+1, string.len(url))
		return imageName(subURL)
	end
end

-----------------------------------------------------------------------------------------

--a tester  https://gist.github.com/874792

function tprint (tbl, indent)
	if not tbl then print("Table nil") return end
	if type(tbl) ~= "table" then
		print(tostring(tbl))
	else
   	if not indent then indent = 0 end
   	for k, v in pairs(tbl) do
   		formatting = string.rep("  ", indent) .. k .. ": "
   		if type(v) == "table" then
   			print(formatting)
   			tprint(v, indent+1)
   		else
   			print(formatting .. tostring(v))
   		end
   	end
   end
end

-----------------------------------------------------------------------------------------

function postWithJSON(data, url, next)
	post(url, json.encode(data), next, "json")
end

--------------------------------------------------------

function post(url, data, next, type)

	if(next == nil) then 
		next = function() end
	end

	local headers = {}

	if(type == nil) then
		headers["Content-Type"] = "application/x-www-form-urlencoded"
	elseif(type == "json") then
		headers["Content-Type"] = "application/json"
	end

	local params = {}
	params.headers = headers
	params.body = data

	network.request( url, "POST", next, params)
end


--------------------------------------------------------

function isEmail(str)
	return str:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")
end

--------------------------------------------------------

function url_decode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

function urlEncode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

--------------------------------------------------------

function parseDate(str)
	_,_,y,m,d=string.find(str, "(%d+)-(%d+)-(%d+)")
	return tonumber(y),tonumber(m),tonumber(d)
end

function parseDateTime(str)
	local Y,M,D = parseDate(str)
	return os.time({year=Y, month=M, day=D})
end

--------------------------------------------------------

function saveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end
 
function loadTable(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         myTable = json.decode(contents);
         io.close( file )
         return myTable 
    end
    return nil
end