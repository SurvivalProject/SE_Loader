-- TODO: Add a "property already exists" Same for classes

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
	return rawget(PropertyLibrary[rawget(self, "PropertyName")],Index) or rawget(PropertyLibrary[rawget(self, "PropertyName")],"Extends") and PropertyLibrary[rawget(PropertyLibrary[rawget(self, "PropertyName")],"Extends")][Index]
end

function PropertyMeta:__newindex(Value, Index)
	if Value == "PropertyName" or Value == "Extends" then
		-- No, no, no.
		return
	else
	rawset(self, Value, Index)
	end
end

PropertyMeta.__metatable = true -- No, we dont want you messing with our metatables!

function RegisterNewProperty(PropertyName, PropertyData)
	PropertyData.__se_type = "Property"
	PropertyData.PropertyName = PropertyName
	if not PropertyData.Extends and PropertyName ~= "DefaultProperty" then
		PropertyData.Extends = "DefaultProperty"
	end
	if type(PropertyData.Extends) == "table" then
		PropertyData.Extends = PropertyData.Extends.PropertyName
	end
	setmetatable(PropertyData, PropertyMeta)
	PropertyLibrary[PropertyName] = PropertyData
end

RegisterNewProperty("DefaultProperty", DefaultProperty)

function CreateProperty(PropertyName)
	local Property = {}
	Property.PropertyName = PropertyName
	Property.__se_type = "Property"
	return setmetatable(Property, PropertyMeta)
end