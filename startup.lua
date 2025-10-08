-- Digital SCADA for Mekanism - Startup File  


print("====================================")
print("   DIGITAL SCADA FOR MEKANISM")
print("   Initializing... Please stand by")
print("====================================")

-- HÀM TẢI CONFIG DÙNG WGET TRỰC TIẾP
local function downloadConfig()
    print("📥 Downloading CONFIG...")
    
    -- DÙNG WGET COMMAND TRỰC TIẾP
    local success = shell.run("wget", "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/config_loader.lua", "config_temp.lua")
    
    if success then
        -- CHẠY FILE TẢI VỀ
        shell.run("config_temp.lua")
        print("✅ CONFIG loaded successfully!")
        return true
    else
        print("❌ Failed to download CONFIG")
        return false
    end
end

-- MAIN
print("🎯 Starting SCADA...")
downloadConfig()

-- KIỂM TRA KẾT QUẢ
if config then
    print("⚙️ Config loaded: Max Temp = " .. (config.max_temperature or "N/A") .. "K")
else
    -- CONFIG MẶC ĐỊNH NẾU TẢI THẤT BẠI
    print("🔄 Using default config...")
    config = {
        max_temperature = 1200,
        emergency_shutdown_temp = 1500,
        debug = true
    }
end

print("🎯 SCADA System READY!")
print("====================================")
