-- Set up initial registers
-- Object metatable will store all functions which have to do with created objects
local ObjectMetatable = {} --newproxy(true); Newproxy's ain't gonna work for now.
local ClassPropertyData = {} -- Holds "flags" on access properties
local ClassData = {} -- Holds actual Class Data
local ClassLibrary = {} -- Holds the classes
local ClassStates = {} -- Holds class state data
local ObjectData = {} -- Actual object data. The objects themselves are just tables, which are basically used as 'pointer' (as the table is the "index" (adress) in the ObjectData table (the memory))
local ObjectChildData = {} -- Seperate table. We don't want to accidentally wipe children

-- ClassPropertyData has to hold a table. Contents are:
-- ReadOnly - No write access to the data [bool]
-- Update - Once indexed, run the method - if available Class:Update(Property) and return it's results

-- ClassStates can have:
-- Uncreatable: If true, the class cannot be created. The Create function will error
-- Locked: A lock is final. Once Locked is set to true, the class cannot be edited in any way.
-- CreateLimit: This is a number. After this number is <= 0, the class will be Uncreateable
-- Overwrite: Makes it possible to overwrite indices. This is a "fool proof" prevention: it's realy easy to mess up methods and properties. You will get a warning via this. If you set it to true, it wont warn.

-- The only thing class metatable does is a redirect to ClassPropertyData
-- This has to be done - to fire __index we need the indices to be nil.
local ClassMetatable = {} -- Used for both the Class and ClassData tables

function ClassMetatable:__index(Index)
	print("Index operation in a class, index is: "..Index.. ", classname is: "..ClassData[self].ClassName)
	-- No special rules for indexing a class property
	-- The only reason is this redirect.
	-- This function is here to add debug hooks ("There was an index event in the Class .. ClassName .. on Index .. index")
	local Extends = ClassData[self].Extends
	return ClassData[self][Index] or (Extends and ClassLibrary[Extends][Index])
end

function ClassMetatable:__newindex(Index, Value)
	print("SET operation in a class, index is: "..Index.. ", classname is: "..ClassData[self].ClassName .. " value is: "..tostring(Value))
	-- Check if locked
	-- Locked is the ultimate prevention to make sure you don't edit the classes once you have created them
	if ClassStates[self.ClassName] and ClassStates[self.ClassName].Locked then
		-- TODO: Debug messages
		return
	elseif Index == "Uncreatable" then
		if not ClassStates[self.ClassName] then 
			ClassStates[self.ClassName] = {}
		end
		ClassStates[self.ClassName].Uncreatable = true -- expected value 
		ClassData[self]["Uncreatable"] = true -- For the reference.
	elseif Index == "Locked" then 
		if not ClassStates[self.ClassName] then 
			ClassStates[self.ClassName] = {}
		end
		ClassStates[self.ClassName].Locked = true 
		ClassData[self]["Locked"] = true
	else
		if ClassStates[self.ClassName] and ClassStates[self.ClassName].Overwrite and not ClassStates[self.ClassName].Locked then
			ClassData[self][Index] = Value
		elseif not ClassData[self][Index] then
			if ClassStates[self.ClassName] and ClassStates[self.ClassName].Locked then 
				return -- Class is locked, cannot edit.
			end 
			ClassData[self][Index] = Value
		end
	end
end

-- Utility function. Returns the Class which holds the Property
-- This is the only ugly fix
ClassMetatable.GetPropertyRoot = function(Class, Property)
local found, Current, Previous = nil, Class, Class
repeat
	found = ClassData[Current][Property]
	Previous = Current
	Current = Current.Extends and ClassLibrary[Current.Extends.ClassName]
until found or not Current
return Previous
end

-- Function run on x[y] when the index y is nil in x
function ObjectMetatable:__index(Index)
	print("Object index: "..Index.." in "..ObjectData[self].ClassName)
	-- Return either the linked object data (ObjectData) or try to get the "default" value from the Class data. (This index operation finds the dafault in the next)
	local ClassName = ObjectData[self].ClassName
	local Property = ObjectData[self][Index] or ClassLibrary[ClassName][Index]
	if Property then
		local PUpdate = ObjectData[self]["PropertyUpdate"] or ClassLibrary[ObjectData[self]["ClassName"]]["PropertyUpdate"]
		local Class = ClassLibrary[ClassName]
		local PropertyClass = ClassMetatable.GetPropertyRoot(Class, Index)
		if type(Property) == "table" and ObjectData[self][Index] == nil and Index ~= "Parent" then
			if Property.Type == "SE_Instance" then
				local ClassName = Property.ClassName
				ObjectData[self][Index] = Create( ClassName ) --
			elseif Property.Type == "Property" then
				ObjectData[self][Index] = Property:Clone()
			else
				-- Its a regular table. 2 cases: filled (list-like) or empty
				local IsFilled = next(Property)
				if IsFilled then
					local New = {}
					local Meta = {}
					Meta.__index = Property
					Property = New -- Make sure it returns our link table, not the real table.
					setmetatable(New, Meta)
					ObjectData[self][Index] = New -- Replace it with our link table
				else
					-- Just create a new empty table.
					Property = {}
					ObjectData[self][Index] = Property
				end
			end
		end
		if PUpdate and ClassPropertyData[PropertyClass] and ClassPropertyData[PropertyClass][Index] and ClassPropertyData[PropertyClass][Index].Update then
			return PUpdate(self, Index) -- Manual method call
		end

		return Property
	else -- Hrm. The thing we are trying to find is probably NOT a Property, but a Child!
		print("!!childindex")
		local Children = ObjectChildData[self]
		print(Children)
		return (Children and Children[Index] and Children[Index][1]) -- Return the first child if available
	end
end

-- Utility function. Remove Child from the Child Table of Parent (This block of code is used twice, to save lines, this funcion is made)
ObjectMetatable.RemoveChild = function(Child, Parent)
	local ChildTable = ObjectChildData[Parent][Child.Name]
	-- Remove the reference to this object on the "old parent"
	if #ChildTable == 1 then
		ObjectChildData[Parent][Child.Name] = nil
	else
		local found
		for i = 1, #ChildTable do
			if ChildTable[i] == Child then
				found = i
				break
			end
		end
		table.remove(ChildTable, found)
	end
end

-- Function run on x[y] = z when the index y is nil in x
function ObjectMetatable:__newindex(Index, Value)
	print("Object SET: "..Index.." in "..ObjectData[self].ClassName.. " value is "..tostring(Value))
	if Index == "Parent" then
		print("! parent loop, parentx = ".. Value.Type, self == System, Value.Type and (not (self == System)), Value.Type and true)
		if Value.Type and (not (self == System)) then
		print("! in block!?")
			if self.Parent then
				ObjectMetatable.RemoveChild(self, self.Parent)
			end
			print(type(Value), Value.Type, "FFFFTHIS", type(Value) == "table", Value.Type == "SE_Class", (type(Value) == "table" and (Value.Type == "SE_Class")))
			if (type(Value) == "table" and (Value.Type == "SE_Class")) then
				ObjectData[self].Parent = Value
				if ObjectChildData[Value] == nil then
					ObjectChildData[Value] = {}
				end
				if ObjectChildData[Value][self.Name] == nil then
					ObjectChildData[Value][self.Name] = {}
				end
				print("!!!childadddddddd complete")
				table.insert(ObjectChildData[Value][self.Name], self)
			end
		else
			-- Not an SE_Class or SYSTEM
			return
		end
	elseif Index == "Name" then
		-- This is tricky. The children can be found via it's name, so changing the name will get problems if we don't change some things.
		-- Find the child table in the parent
		if self.Parent then
			ObjectMetatable.RemoveChild(self, self.Parent)
			if ObjectChildData[self.Parent][Value] == nil then
				ObjectChildData[self.Parent][Value] = {}
			end
			table.insert(ObjectChildData[self.Parent][Value], self)
		end
		ObjectData[self].Name = Value
	elseif Index == "Extends" then
		if type(Value) == "table" then
			local PropRoot = ClassMetatable.GetPropertyRoot(ClassLibrary[self.ClassName], Value)
			if ClassPropertyData[PropRoot] and ClassPropertyData[PropRoot][Value] and not ClassPropertyData[PropRoot][Value].ReadOnly then
				ObjectData[self][Index] = Value.ClassName
			end
		end
	elseif Index == "ClassName" or Index == "Type" then
		-- No. Just no. Watcha doing, changing the classname? Hax.
		return -- Get out of here, right now
	else
		-- Only check we need here is the check to see if the value is not read Only
		local PropRoot = ClassMetatable.GetPropertyRoot(ClassLibrary[self.ClassName], Value)
		local Block = ClassPropertyData[PropRoot] and ClassPropertyData[PropRoot][Value] and not ClassPropertyData[PropRoot][Value].ReadOnly
		if not Block  then
			print("passed test, set")
			ObjectData[self][Index] = Value
		end
	end
end

-- Mode. We dont want this here.
ObjectMetatable.__mode = nil
ObjectMetatable.__metatable = true -- We want the metatables to be private.

-- Fired once the classes is called
function ObjectMetatable:__call(...)
	if self.Call then
		return self:Call(...)
	end
end

-- Fired once tostring(Class), or in the regular print.
function ObjectMetatable:__tostring()
	if self.ToString then
		return self:ToString()
	else
		return self.Name
	end
end

-- Fired once #Class
function ObjectMetatable:__len()
	if self.Length then
		return self:Length()
	end
end

-- WILL NOT BE FIRED ON ROBLOX EVER
-- Fired once the userdata gets garbage collected.
-- That only happens when there are no references to the object.
-- This could be used on some kind of Destroy callback
--[[
function ObjectMetatable:__gc()

end --]]

-- Fired once -Class
function ObjectMetatable:__unm()
	if self.Unary then
		return self:Unary()
	end
end

-- In following arithmetic metatmethods, x can be anything.
-- Fired once Class + x
function ObjectMetatable:__add(other)
	if self.Add then
		return self:Add(other)
	end
end

-- Fired once Class - x
function ObjectMetatable:__sub(other)
	if self.Substract then
		return self:Substract(other)
	end
end

-- Fired once Class * x
function ObjectMetatable:__mul(other)
	if self.Multiply then
		return self:Multiply(other)
	end
end

-- Fired once Class / x
function ObjectMetatable:__div(other)
	if self.Divide then
		return self:Divide(other)
	end
end

-- Fired once Class % x (modulo)
function ObjectMetatable:__mod(other)
	if self.Mod then
		return self:Mod(other)
	end
end

-- Fired once Class ^ x
function ObjectMetatable:__pow(other)
	if self.Pow then
		return self:Pow(other)
	end
end

-- Fired once Class .. x
function ObjectMetatable:__concat(other)
	if self.Concentate then
		return self:Concentate(other)
	end
end

-- Fired once Class == other
function ObjectMetatable:__eq(other)
	if self.Equal then
		return self:Equal(other)
	end
end

-- Fired once Class <= other OR Class >= other
function ObjectMetatable:__le(other)
	if self.LSE then -- Larger or Smaller or Equal
		return self:LSE(other)
	end
end

-- Fired once Class < other OR Class > other
function ObjectMetatable:__lt(other)
	if self.LS then -- Larger or Smaller
		return self:LS(other)
	end
end

-- Global Help Functions with limited ClassLibrary access (indirect)
ClassHelper = {}

ClassHelper.GetClassVariables = function(ClassName, var)
local Root = ClassLibrary[ClassName]
local Out =  var or {}
for i,v in pairs(ClassData[Root]) do
	table.insert(Out, i)
end
if ClassData[Root].Extends then
	ClassHelper.GetClassVariables(ClassData[Root].Extends, Out)
end
return Out
end

function ClassHelper.ChangeClassState(Class, State, Value) -- Class is a string
local Class = ClassLibrary[Class]
local StateList = ClassStates[Class]
local SPossible = {Uncreatable = true, Overwrite = true, Locked = true, CreateLimit = true}
if SPossible[State] then
	if not StateList.Locked then
		StateList[State] = Value
	end
end
end

-- Because some base functions need to have direct access to the "secured"/hidden tables, the SE_Instance (root of everything) is located here.

local SE_Instance = {}

SE_Instance.Name = "Instance"
SE_Instance.Parent = nil
SE_Instance.ClassName = "SE_Instance"
SE_Instance.Archivable = true
SE_Instance.Extends = nil
SE_Instance.Type = "SE_Instance"

function SE_Instance:ClearAllChildren()
	for i,v in pairs(SE_Instance:GetChilden()) do
		v:Destroy()
	end
end

function SE_Instance:Clone()
	local new = Create( self.ClassName )
	--for _, Property in pairs(ClassHelper.GetClassVariables(self.ClassName)) do
	--	new[Property] = (not self.Property == ClassData[ClassLibrary[self.ClassName]][Property] or nil) and self[Property]
---end
	for i,v in pairs(ObjectData[self]) do
		new[i] = v
	end
	return new
end

function SE_Instance:Destroy()
	-- Why cant we blow it up using gc?
	for _, Property in pairs(ClassHelper.GetClassVariables(self.ClassName)) do
		self[Property] = nil
	end
	for i,v in pairs(self:GetChildren()) do
		v:Destroy()
	end
end

function SE_Instance:FindFirstChild(name, recursive)
	local found
	if ObjectData[self] and ObjectData[self][name] then
		return ObjectData[self][name][1]
	elseif recursive then
		for i,v in pairs(self:GetChildren()) do
			found = v:FindFirstChild(name, true)
			if found then
				break
			end
		end
	end
	return found
end

function SE_Instance:GetChildren()
	local ChildList = {}
	for ChildName,Children in pairs(ObjectChildData[self]) do
		for i, Child in pairs(Children) do
			table.insert(ChildList, Child)
		end
	end
	return ChildList
end

function SE_Instance:GetFullName()
	local str = self.Name
	local curr = self
	if curr == System then
		return str
	end
	repeat
		curr = curr.Parent
		str = curr.Name.."."..str
	until curr == System or not curr
	return str
end

function SE_Instance:IsA(ClassName)
	if self.ClassName == ClassName then
		return true
	else
		local found
		local curr = ClassLibrary[self.ClassName]
		repeat
			curr = curr.Extends
			if curr == ClassName then
				return true
			end
		until curr.Extends == nil
	end
	return false
end

function SE_Instance:IsAncestorOf(class)
	local curr = class
	if curr.Parent == self then
		return true
	end
	repeat
		curr = curr.Parent
		if curr.Parent == self then
			return true
		end
	until curr.Parent == nil
	return false
end

function SE_Instance:IsDescendantOf(class)
	return class:IsAncestorOf(self)
end

function SE_Instance:WaitForChild(Name)
	repeat wait() until self:FindFirstChild(Name)
	return self:FindFirstChild(Name)
end

-- Todo: Import SE_Event and

--[[AncestryChanged
Changed
ChildAdded
ChildRemoved
DescendantRemoving
--]]

function CreateClass(ClassName, ClassBase)
	local Class = ClassBase
	ClassData[Class] = {}
	ClassData[Class].Extends = ClassBase.Extends or "SE_Instance"
	if ClassName == "SE_Instance" then
		ClassData[Class].Extends = nil
	end
	if type(ClassData[Class].Extends) == "table" then
		ClassData[Class].Extends = ClassData[Class].Extends.ClassName
	end
	local DataTable = ClassData[Class]
	for i,v in pairs(ClassBase) do
		DataTable[i] = v
		ClassBase[i] = nil
	end
	ClassData[Class] = DataTable
	DataTable.Type = "SE_Class"
	ClassData[Class].ClassName = ClassName
	setmetatable(Class, ClassMetatable)
	Class.__metatable = true
	ClassLibrary[ClassName] = Class
	return Class
end

function Create(ClassName, Parent)
	if ClassStates[ClassName] and ClassStates[ClassName].Uncreatable then 
		return -- class is uncretable.
	end 
	if ClassLibrary[ClassName] then
		if ClassStates[ClassName].CreateLimit then 
			ClassStates[ClassName].CreateLimit = ClassStates[ClassName].CreateLimit - 1
			if ClassStates[ClassName].CreateLimit < 0 then 
				return  -- Class has completed it's max creatins
			end			
		local Object = {}
		setmetatable(Object, ObjectMetatable)
		ObjectData[Object] = {ClassName = ClassName} -- Reserve a table.
		if Parent then
			Object.Parent = Parent
		end
		if Object.Constructor then
			Object:Constructor()
		end
		return Object
	end
end

function Extends(ClassName, NewClassName) -- Bla = Extends(SE_Instance, "Bla")
local Name = ClassName
if type(ClassName) == "table" then
	Name = ClassName.ClassName
end
local O = {}
O.Extends = Name
return CreateClass(NewClassName, O)
end

CreateClass("SE_Instance", SE_Instance)
