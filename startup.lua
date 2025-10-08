-- Digital SCADA for Mekanism - Startup File

print("====================================")
print("   DIGITAL SCADA FOR MEKANISM")
print("   Initializing... Please stand by")
print("====================================")

-- URL CONFIG CHÍNH
local CONFIG_URL = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/config_loader.lua"

-- HÀM TẢI CONFIG SIÊU ĐƠN GIẢN
local function downloadConfig()
    print("📥 Downloading CONFIG...")
    
    -- DÙNG HTTP REQUEST TRỰC TIẾP
    local http = require("http")
    local request = http.get(CONFIG_URL)
    
    if request then
        local content = request.readAll()
        request.close()
        
        -- CHẠY LUÔN CONTENT, KHÔNG LƯU FILE
        local configFn, err = load(content, "config_loader", "t", _G)
        if configFn then
            configFn()
            print("✅ CONFIG loaded successfully!")
            return true
        else
            print("❌ ERROR loading config: " .. err)
            return false
        end
    else
        print("❌ Failed to download CONFIG")
        return false
    end
end

-- MAIN
local success, err = pcall(downloadConfig)
if not success then
    print("❌ CRITICAL: " .. err)
    return
end

-- NẾU CÓ CONFIG THÌ CHẠY TIẾP
if config then
    print("🎯 SCADA System READY!")
    print("⚙️ Max Temperature: " .. config.max_temperature .. "K")
    print("🚨 Emergency Temp: " .. config.emergency_shutdown_temp .. "K")
else
    print("❌ Config not loaded!")
end

print("====================================")
