local _time = os.clock()

local lfs = require "lfs"
local _xml = require "LuaXML"

local file_accept = {lua = true, txt = true}

assert(lfs, "LuaFileSystem could not be loaded! Please use LuaRocks to install LuaFileSystem (or use Lua for Windows)")
assert(_xml, "LuaXML could not be loaded! Please use LuaRocks to install LuaXML (or use Lua for Windows)")

local file = io.open("ProjectRBXM.rbxm", "w")
assert(file, "Cannot open the file - create it manually to fix?")

print("LFS - LuaXML - file initiated. Creating a rbxm file from the Import directory.")

local rbxm = xml.new("roblox")
rbxm["xmlns:xmime"]="http://www.w3.org/2005/05/xmlmime"
rbxm["version"]="4"
rbxm["xsi:noNameSpaceSchemaLocation"]="http://www.roblox.com/roblox.xsd"
rbxm["xmlns:xsi"]="http://www.w3.org/2001/XMLSchema-instance"

function scandir(path) -- returns a table with {directories = directory_list, file = lua_filelist} (lua files are "script files")
print("----")
print("scan "..path)
local out = {directories = {}, file = {}}
for dirname in lfs.dir(path) do
if lfs.attributes(path .. "\\"..dirname).mode == "file" and file_accept[dirname:sub(dirname:len()-2, dirname:len())] then
print("script source found: "..dirname)
table.insert(out.file, path.."\\"..dirname)
elseif lfs.attributes(path .. "\\"..dirname).mode == "directory" and dirname ~= "." and dirname ~= ".." then
print("directory found: "..dirname)
table.insert(out.directories, path.."\\"..dirname)
end
end
return out
end

function append_script(root, scriptname, scriptsource)
print("Add new script: "..scriptname)
local new = root:append("Item")
new["class"] = "Script" -- Local Script support should be added here (to immediately see which scripts are "client", and which are "Server"
local properties = new:append("Properties")
local source = properties:append("ProtectedString")
local name = properties:append("string")
source["name"] = "Source"
source[1] = scriptsource
name["name"] = "Name"
name[1] = scriptname
end

function append_model(root, modname)
print("Add new model: "..modname)
local new = root:append("Item")
new["class"] = "Model"
local properties = new:append("Properties")
local name = properties:append("string")
name["name"] = "Name"
name[1] = modname
return new
end

function make(xml_tag_current, dir_root)
local new = scandir(dir_root)
print("----")
for _,name in pairs(new.file) do
local open = io.open(name)
local text = open:read("*a")
local act_name = name:match("\\([^.\\]*)%.")
append_script(xml_tag_current, act_name, text)
end
for _, dirname in pairs(new.directories) do
local new_root = append_model(xml_tag_current, dirname:match("\\([^\\.]*)$"))
make(new_root, dirname)
end
end

-- Add "Include"
local true_root = append_model(rbxm, "Include")
append_model(true_root, "SurvivalEngine")
local user_root = append_model(true_root, "Source")
-- check what to load, arg[0] or lfs.currentdir()

if arg[0] ~= "DirToRBXM.lua" then
print("---(Call type is from normal Lua call)---")
local file_dir = arg[0]:match("(.*)\\DirToRBXM.lua")
make(user_root, file_dir.."\\Import")
else
print("---(Call type is other - trace current directory normally)---")
make(user_root, ".\\Import")
end


file:write(rbxm:str())
print("ProjectRBXM.rbxm file generated. Hit any key to quit... (took: "..math.floor((os.clock() - _time)*1000 + 0.5).. " ms)")
io.read()
