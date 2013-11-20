local InputService = {}

InputService.KeyReg = {} -- key:byte() = IsUp [bool], time [double]

InputService.Button1IsDown = false
InputService.Button2IsDown = false
InputService.Button1LastEventTime = tick()
InputService.Button2LastEventTime = tick()

function InputService:Constructor()
	Mouse.KeyDown:connect(function(k) self:KeyDown(k) end)
	Mouse.KeyUp:connect(function(k) self:KeyUp(k) end)
	Mouse.Button1Down:connect(function(a,b) self:Button1Down(a,b) end)
	Mouse.Button2Down:connect(function(a,b) self:Button2Down(a,b) end)
	Mouse.Button1Up:connect(function(a,b) self:Button1Up(a,b) end)
	Mouse.Button2Up:connect(function(a,b) self:Button2Up(a,b) end)
end

function InputService:KeyDown(key)
	self.KeyReg[key:byte()] = {true, tick()}
end

function InputService:KeyUp(key)
	self.KeyReg[key:byte()] = {false, tick()}
end

function InputService:Button1Down()
	self.Button1IsDown = true
	self.Button1LastEventTime = tick()
end

function InputService:Button1Up()
	self.Button1IsDown = false
	self.Button1LastEventTime = tick()
end

function InputService:Button2Down()
	self.Button2IsDown = true
	self.Button2LastEventTime = tick()
end

function InputService:Button2Up()
	self.Button2IsDown = false
	self.Button2LastEventTime = tick()
end

function InputService:KeyIsDown(key)
	local use = key
	if type(key) == "string" then
		use = key:byte()
	end
	if not self.KeyReg[use] then
		return false
	end
	return self.KeyReg[use][1]
end

function InputService:KeyIsUp(key)
	return not InputService:KeyIsDown(key)
end

function InputService:KeyIsDownFor(key, time)
	if KeyIsDown(key) then
		local use = key
		if type(key) == "string" then
			use = key:byte()
		end
		return tick() - self.KeyReg[use][2] >= time
	else
		return false
	end
end

function InputService:KeyIsUpFor(key, time)
	if KeyIsUp(key) then
		local use = key
		if type(key) == "string" then
			use = key:byte()
		end
		return tick() - self.KeyReg[use][2] >= time
	else
		return false
	end
end

function InputService:MouseIsDown(button_number)
	return self["Button"..button_number.."IsDown"]
end

function InputService:MouseIsUp(button_number)
	return not self:MouseIsDown(button_number)
end

function InputService:MouseIsDownFor(button_number, time)
	if self:MouseIsDown(button_number) then
		return tick() - self["Button"..button_number.."LastEventTime"] >= time
	else
		return false
	end
end

function InputService:MouseIsUpFor(button_number, time)
	if self:MouseIsUp(button_number) then
		return tick() - self["Button"..button_number.."LastEventTime"] >= time
	else
		return false
	end
end

CreateClass("InputService", InputService)

-- Create it as service of System

local IS = Create "InputService"
IS.Name = "InputService"
IS.Parent = System