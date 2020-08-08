local json = require "json"

--- This gives us the name of the disk, "disk", or "disk2" for example
local disk = fs.getDir(shell.getRunningProgram())

term.clear()
term.setCursorPos(1,1)

-- Draw logo :P
do
  local handle = fs.open(fs.combine(disk, "logo.txt"), "r")
  local lines = {}
  local line = handle.readLine()
  local w = 0
  while line do
    w = math.max(w, #line)
    lines[#lines + 1] = line
    line = handle.readLine()
  end

  local h = #lines
  local logo = window.create(term.current(), 1, 1, w, h)
  logo.setVisible(false)
  for i, v in pairs(lines) do
    logo.setCursorPos(1, i)
    logo.write(v)
  end

  logo.setVisible(true)
end


term.setCursorPos(1,7)

print("Booting live usb")
print("Press x to exit")

function checkEscape()
  local res = false
  function checkKey()
    while true do
      local _, key = os.pullEvent()
      if key == keys.x then
        res = true
        return
      end
    end
  end
  parallel.waitForAny(checkKey, function() os.sleep(1) end)
  return res
end

--- We might as well do it like this:
local function loadPlugins(disk)
  local plugins = {}
  for _,v in pairs(fs.find(fs.combine(disk, ".plugins/*.lua"))) do
    local plugin = {
      name = fs.getName(v):sub(1,-5),
      path = v,
      settings = {}
    }
    local settingsFile = fs.combine(disk, ".plugins/"..plugin.name..".plugin")
    if fs.exists(settingsFile) then
      local handle = fs.open(settingsFile, "r")
      plugin.settings = json.deode(handle.readAll())
      handle.close()
    end
    plugins[#plugins + 1] = plugin
  end
  return plugins
end

--- If x was pressed, just run the default shell
if checkEscape() then
  term.clear()
  term.setCursorPos(1,1)
  shell.run("multishell")
  os.shutdown()
end
--im pjals :) -I'm tomtrein

--- We'll store settings for livefloppy on the floppy itself
settings.load(fs.combine(disk, ".settings"))

local plugins = loadPlugins(disk)
for _,plugin in pairs(plugins) do
  local loadNow = plugin.settings.autoload
  if loadNow == nil or loadNow == true then
    dofile(plugin.path)
  end
end

--- Whether .root should be mounted
if settings.get("livefloppy.mountRoot", false) then
  fs.symlink(fs.combine(disk, "sda/.root"), "/")
  if settings.get("livefloppy.mountRoot.readOnly") then
    fs.readOnly(fs.combine(disk, "sda/.root"))
  end
end

fs.symlink(fs.combine(disk, "sda/rom"), "rom")
fs.symlink("/", fs.combine(disk, "sda"))

term.clear()
term.setCursorPos(1,1)
os.run({}, "rom/programs/advanced/multishell.lua")
os.shutdown()
