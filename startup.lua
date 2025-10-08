-- Digital SCADA for Mekanism - Startup File  

print("====================================")
print("   DIGITAL SCADA FOR MEKANISM")
print("   Initializing... Please stand by")
print("====================================")

-- BIẾN TOÀN CỤC
config = nil
reactor_monitor = nil

-- TẢI CONFIG_LOADER ĐẦU TIÊN
print("Downloading config_loader.lua")
local configSuccess = shell.run("wget", "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/config_loader.lua", "config_loader.lua")

if configSuccess then
    shell.run("config_loader.lua")
    print("SUCCESS: config_loader.lua loaded!")
else
    print("ERROR: Failed to download config_loader.lua")
end

-- TẢI REACTOR_MONITOR 
print("Downloading reactor_monitor.lua")
local reactorSuccess = shell.run("wget", "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/Reactors%20Controller/reactor_monitor.lua", "reactor_monitor.lua")

if reactorSuccess then
    shell.run("reactor_monitor.lua") 
    print("SUCCESS: reactor_monitor.lua loaded!")
else
    print("ERROR: Failed to download reactor_monitor.lua")
end

-- KIỂM TRA BIẾN TOÀN CỤC THẬT SỰ
print("====================================")
local hasConfig = (config ~= nil)
local hasReactorMonitor = (reactor_monitor ~= nil)

if hasConfig and hasReactorMonitor then
    print("SCADA SYSTEM: FULLY OPERATIONAL")
    print("Ready for reactor control!")
    
    -- TỰ ĐỘNG KHỞI ĐỘNG GIÁM SÁT
    if reactor_monitor.init then
        reactor_monitor.init("right")
        print("Reactor monitor initialized!")
    end
else
    print("SCADA SYSTEM: PARTIALLY LOADED")
    if not hasConfig then print(" - Config: MISSING") end
    if not hasReactorMonitor then print(" - Reactor Monitor: MISSING") end
    print("DEBUG: config = " .. tostring(config))
    print("DEBUG: reactor_monitor = " .. tostring(reactor_monitor))
end
print("====================================")
