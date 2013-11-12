local SE_Version_Flags = {
	Release = true, -- Okay to use in games
	Debug_Data = true, -- There is debug garbage hanging around (debug messages)
	Version = "V0.991", -- Version number. Closing in on v1!
}

loaddone = function()
print("SE has done loading. The current version is: "..SE_Version_Flags.Version.."!")
end 