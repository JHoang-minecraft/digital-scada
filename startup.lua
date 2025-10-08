-- Digital SCADA for Mekanism - Startup File
-- Author: JHoang - "Because why not automate nuclear reactors?" =))

print("====================================")
print("   DIGITAL SCADA FOR MEKANISM")
print("   Initializing... Please stand by")
print("====================================")

-- Config đường dẫn GitHub - CHUẨN KHÔNG CẦN CHỈNH
local GITHUB_BASE = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada"

-- URL CONFIG THẬT - CÁI NÀY QUAN TRỌNG NÈ =))
local CONFIG_URL = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/config_loader.lua"

-- Danh sách modules cần tải
local MODULES = {
    "scada/config_loader.lua",
    "scada/reactor_monitor.lua", 
    "scada/plc_communicator.lua",
    "scada/alarm_manager.lua",
    "scada/gui_controller.lua",
    "scada/utils.lua"
}

-- Tạo folder scada nếu chưa có
if not fs.exists("scada") then
    fs.makeDir("scada")
    print("📁 Created scada directory!")
end

-- HÀM TẢI CONFIG ĐẦU TIÊN - QUAN TRỌNG!
local function downloadConfigFirst()
    print("📥 Downloading CONFIG...")
    
    -- DÙNG HTTP REQUEST TRỰC TIẾP
    local http = require("http")
    local request = http.get("https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/config_loader.lua")
    
    if request then
        local content = request.readAll()
        request.close()
        
        -- LƯU NỘI DUNG VÀO "FILE" TRONG COMPUTER
        local file = fs.open("scada/config_loader.lua", "w")
        file.write(content)
        file.close()
        
        print("✅ CONFIG downloaded successfully!")
        return true
    else
        print("❌ Failed to download CONFIG")
        return false
    end
end

-- Hàm download file từ GitHub
local function downloadModule(modulePath)
    local filename = modulePath
    local url = GITHUB_BASE .. modulePath
    
    -- Nếu là config thì bỏ qua (đã tải trước đó)
    if modulePath == "scada/config_loader.lua" then
        if fs.exists(filename) then
            print("✅ Config already downloaded")
            return true
        end
    end
    
    print("📥 Downloading: " .. filename)
    print("   From: " .. url)
    
    -- Xóa file cũ nếu tồn tại
    if fs.exists(filename) then
        fs.delete(filename)
    end
    
    -- Download với retry và timeout
    local success = false
    for i = 1, 3 do  -- Thử 3 lần
        print("   Attempt " .. i .. "...")
        success = shell.run("wget", "-T", "10", url, filename)
        if success then break end
        os.sleep(1)  -- Chờ 1 giây trước khi thử lại
    end
    
    if not success then
        error("❌ FAILED to download: " .. filename)
    end
    
    -- Verify file đã download
    if not fs.exists(filename) then
        error("❌ File not found after download: " .. filename)
    end
    
    print("✅ Downloaded: " .. filename)
    return true
end

-- Hàm load module sau khi download
local function loadModule(modulePath)
    if not fs.exists(modulePath) then
        print("❌ File not found: " .. modulePath)
        return false
    end
    
    local ok, err = pcall(dofile, modulePath)
    if not ok then
        print("❌ ERROR loading " .. modulePath .. ": " .. err)
        return false
    end
    
    print("✅ Loaded: " .. modulePath)
    return true
end

-- MAIN INITIALIZATION - BẮT ĐẦU TẠI ĐÂY
print("\n🎯 Starting download sequence...")

-- BƯỚC 1: TẢI CONFIG ĐẦU TIÊN
local configSuccess, configErr = pcall(downloadConfigFirst)
if not configSuccess then
    print("❌ CRITICAL: " .. configErr)
    print("💡 Make sure the config file exists at:")
    print("   " .. CONFIG_URL)
    return
end

-- BƯỚC 2: TẢI CÁC MODULE CÒN LẠI
print("\n📥 Downloading other modules...")
local downloadSuccess = true
for _, modulePath in ipairs(MODULES) do
    local success, err = pcall(downloadModule, modulePath)
    if not success then
        print("❌ Download failed: " .. err)
        downloadSuccess = false
        break
    end
end

if not downloadSuccess then
    print("\n💡 TIPS: Check if:")
    print("   - Repo exists: github.com/JHoang-minecraft/digital-scada")
    print("   - Files exist in 'scada' folder")
    print("   - Internet connection is working")
    return
end

-- VERIFY ALL FILES EXIST
print("\n🔍 Verifying downloaded files...")
for _, modulePath in ipairs(MODULES) do
    if not fs.exists(modulePath) then
        print("❌ File missing: " .. modulePath)
        print("💡 Download may have failed!")
        return
    else
        local size = fs.getSize(modulePath)
        print("✅ Verified: " .. modulePath .. " (" .. size .. " bytes)")
    end
end

print("\n🔧 Loading modules...")
local loadSuccess = true
for _, modulePath in ipairs(MODULES) do
    if not loadModule(modulePath) then
        loadSuccess = false
        break
    end
end

if not loadSuccess then
    print("❌ System initialization FAILED!")
    return
end

print("\n✅ All modules loaded successfully!")
print("\n🎯 SCADA System READY!")
print("Type 'scada.start()' to begin monitoring!")

-- Global SCADA object
scada = {}

function scada.start()
    print("\n🚀 Starting SCADA System...")
    
    -- Khởi tạo config
    if config_loader then
        config = config_loader.load()
        print("⚙️ Configuration loaded!")
    else
        print("❌ Config loader not found!")
        return
    end
    
    -- Khởi động các module
    if reactor_monitor then
        reactor_monitor.init()
        print("🔬 Reactor monitor started!")
    end
    
    if alarm_manager then
        alarm_manager.init()
        print("🚨 Alarm system activated!")
    end
    
    if gui_controller then
        gui_controller.init()
        print("🖥️ GUI controller ready!")
    end
    
    print("✅ SCADA System is now RUNNING!")
    print("💡 Use 'scada.status()' to check system status")
end

function scada.status()
    print("\n📊 SCADA System Status:")
    print("📍 Modules loaded: " .. #MODULES)
    print("🔧 System: OPERATIONAL")
    print("🎯 Ready to monitor reactors!")
    
    -- Hiển thị config nếu có
    if config then
        print("⚙️ Max Temperature: " .. config.max_temperature .. "K")
        print("🚨 Emergency Shutdown: " .. config.emergency_shutdown_temp .. "K")
    end
end

function scada.debug()
    print("\n🐛 DEBUG INFO:")
    print("GitHub Base: " .. GITHUB_BASE)
    print("Config URL: " .. CONFIG_URL)
    print("Modules to load: " .. #MODULES)
    for i, module in ipairs(MODULES) do
        local exists = fs.exists(module)
        local size = exists and fs.getSize(module) or 0
        print(i .. ". " .. module .. " - " .. (exists and "✅ " .. size .. " bytes" or "❌"))
    end
end

function scada.reload()
    print("\n🔄 Reloading SCADA System...")
    -- Có thể thêm logic reload ở đây
    print("✅ Reload complete!")
end

print("\n====================================")
print("   INITIALIZATION COMPLETE!")
print("   Type 'scada.start()' to begin!")
print("   Type 'scada.status()' for status")
print("   Type 'scada.debug()' for info")
print("====================================")

-- Auto-start nếu muốn
-- scada.start()
