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
	table.inset(self.CallList, func)
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
		for i,v in pairs(self.CallList or {}) do
			local arglist = {...} -- What the heck lua syntax!? Y U NO PASS DEM
			delay(0, function() v(unpack(arglist)) end)
		end
	end 
end 

RegisterNewProperty("Event", Event)

function CreateEvent(Class, PropName) -- Used for backwards compatibility
	local new = CreateProperty("Event")
	Class[PropName] = new 
	return new
end 