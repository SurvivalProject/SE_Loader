local Event = {} 

Event.Disabled = false 

function Event:connect(func)
	if not self.CallList then 
		self.CallList = {}
	end 
	local Signal = {}
	function Signal:Disconnect()
		for i,v in pairs(self.CallList) do 
			if v == func then 
				table.remove(self.CallList, i)
				break 
			end 
		end 
	end 
	table.insert(self.CallList, func)
	return Signal
end 

function Event:Disable()
	self.Disabled = true 
end 

function Event:Enable()
	self.Disabled = false 
end 

function Event:DisconnectAll()
	if self.CallList then 
		self.CallList = {}
	end 
end

function Event:Fire(...)
	if not self.Disabled then 
		local arg = {...} -- No need to re-evaluate the args list for every function.
		local len = select('#', ...) -- Part of fix (https://github.com/SurvivalProject/SE_Loader/issues/8)
		for i,v in pairs(self.CallList or {}) do
			delay(0, function() v(unpack(arg, 1, len)) end) -- Part of fix (https://github.com/SurvivalProject/SE_Loader/issues/8)
		end
	end 
end 

RegisterNewProperty("Event", Event)

function CreateEvent(Class, PropName) -- Used for backwards compatibility
	local new = CreateProperty("Event")
	Class[PropName] = new 
	return new
end 
