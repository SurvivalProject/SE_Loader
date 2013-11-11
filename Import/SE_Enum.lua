-- TODO
-- Unuglyfy code
-- CAMELCASE

SE_Enum = {}

local Meta = {}
Meta.__index = function(source, index)
	return Meta[index]
end

Meta.__newindex = function(source, index, value)
	if Meta[index] then
		-- already exists		
	else
		Meta[index]= value
	end
end

setmetatable(SE_Enum, Meta)

local enum_meta = {}

function enum_meta:IsEqual(to)
	return self == to or self.name == to
end

enum_meta.__newindex = function(source, index, value)
	return
end
enum_meta.__index = function(source, index)
	return enum_meta[index]
end
	
enum_meta.__tostring = function(source)
	return source.name
end


local function make(enum, name)
	local enum = {name = name}
return	setmetatable(enum, enum_meta)
end
	

function SE_Enum.make(enum_name, enum_data)
	if type(enum_name) == "string" and type(enum_data) == "table" then
		SE_Enum[enum_name] = {}
		for i,v in pairs(enum_data) do
			SE_Enum[enum_name][v] = make(enum_data, v)
		end
	end
end

-- How to make an enum:
-- local enum = {"Sine", "Cosine"}
--SE_Enum.make("Sines", enum)
-- index: SE_Enum.Sines.Sine