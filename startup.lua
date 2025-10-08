-- Digital SCADA for Mekanism - Startup File

print("====================================")
print("   DIGITAL SCADA FOR MEKANISM")
print("   Initializing... Please stand by")
print("====================================")

local GITHUB_BASE = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/main/"

local MODULES = {
    "scada/config_loader.lua",
    "scada/reactor_monitor.lua", 
    "scada/plc_communicator.lua",
    "scada/alarm_manager.lua",
    "scada/gui_controller.lua",
    "scada/utils.lua"
}

if not fs.exists("scada") then
    fs.makeDir("scada")
    print("Created scada directory!")
end

local function downloadModule(modulePath)
    local filename = modulePath
    local url = GITHUB_BASE .. modulePath
    
    print("Downloading: " .. filename)
    
    -- Xóa file cũ nếu tồn tại (tránh cache)
    if fs.exists(filename) then
        fs.delete(filename)
    end
    
    local success = shell.run("wget", url, filename)
    if not success then
        error("FAILED to download: " .. filename)
    end
    
    return true
end

local function loadModule(modulePath)
    local ok, err = pcall(dofile, modulePath)
    if not ok then
        print("ERROR loading " .. modulePath .. ": " .. err)
        return false
    end
    return true
end

print("\n📥 Downloading modules...")
for _, modulePath in ipairs(MODULES) do
    local success, err = pcall(downloadModule, modulePath)
    if not success then
        print("❌ Download failed: " .. err)
        print("💡 Check your internet connection!")
        return
    end
end

print("\n🔧 Loading modules...")
for _, modulePath in ipairs(MODULES) do
    if not loadModule(modulePath) then
        print("❌ System initialization FAILED!")
        return
    end
end

print("\n✅ All modules loaded successfully!")
print("\n🎯 SCADA System READY!")
print("Type 'scada.start()' to begin monitoring!")

-- Global SCADA object
scada = {}

function scada.start()
    print("\n🚀 Starting SCADA System...")
    
    if not config then
        config = require("scada/config_loader")
    end
    
    if reactor_monitor then
        reactor_monitor.init()
    end
    
    if alarm_manager then
        alarm_manager.init()
    end
    
    if gui_controller then
        gui_controller.init()
    end
    
    print("✅ SCADA System is now RUNNING!")
    print("💡 Use 'scada.status()' to check system status")
end

function scada.status()
    print("\n📊 SCADA System Status:")
    print("📍 Modules loaded: " .. #MODULES)
    print("🔧 System: OPERATIONAL")
    print("🎯 Ready to monitor reactors!")
end

print("\n====================================")
print("   INITIALIZATION COMPLETE!")
print("   Type 'scada.start()' to begin!")
print("====================================")
