-- This file loads every class of for the Server --

-- To make sure everything WORKS - ALWAYS Import the Default classes

-- // Default Classess -- \\

Import "SE_ReleaseData" -- Contains important release data (or not)
Import "SE_Import" -- Update the small Import function with a better one
Import "SE_Class" -- Load the Class system 
Import "SE_System" -- Setup the System object
Import "SE_Enum" -- Load enums
Import "SE_Property" -- Load properties
Import "SE_Event" -- Load the special Event property 

if LOAD_EXTRA_CLASSES then 
	Import "BaseClasses/RGBPart"
	Import "BaseClasses/SE_Vector"
	Import "BaseClasses/Server/RespawnService"
end 

loaddone() -- Call the load done report function, located in the ReleaseData
loaddone = nil

-- // User Classes -- \\