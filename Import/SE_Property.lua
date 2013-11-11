local PropertyMeta = {}

local PropertyLibrary = {}

local DefaultProperty = {}

function DefaultProperty:Clone()
	local New = CreateProperty(self.PropertyName)
	for i,v in pairs(self) do 
		New[i] = v
	end
	return New 
end

function PropertyMeta:__index(Index)
	return PropertyLibrary[self.PropertyName][Index] or DefaultProperty[Index]
end 

function RegisterNewProperty(PropertyName, PropertyData)
	PropertyData.Type = "Property"
	PropertyData.PropertyName = PropertyName
	PropertyLibrary[PropertyName] = PropertyData 
end

function CreateProperty(PropertyName)
	local Property = {}
	Property.PropertyName = PropertyType
	Property.Type = "Property"
	return setmetatable(Property, PropertyMeta)
end 


