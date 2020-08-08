--local sha256 = require("sha256")

local oldPullEventRaw = os.pullEventRaw
os.pullEvent = os.pullEventRaw

term.clear()
term.setCursorPos(1,1)
print("-- LiveFloppy creation tool --")
print()
--print("Password:")
--term.write("> ")
--do
--    local pass = read("*")
--    if sha256(pass) ~= settings.get("pass", nil) then
--        os.reboot()
--    end
--end

os.pullEventRaw = oldPullEventRaw

function runDisk()

    print("Please insert disk")
    os.pullEvent("disk")

    function checkEmpty()
        return #fs.list("disk") == 0
    end
    
    if not checkEmpty() then
        print("Disk not empty")
        return
    end
    
    print("Starting copy")
    for _,v in pairs(fs.list("livefloppy")) do
        fs.copy(fs.combine("livefloppy",v), fs.combine("disk", v))
    end
    print("Finished copy")
    
    fs.makeDir("disk/sda")
    fs.makeDir("disk/sda/rom")
    fs.makeDir("disk/sda/.root")
    
    print("Remove disk")
    os.pullEvent("disk_eject")
end

while true do
    runDisk()
end



