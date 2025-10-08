-- Digital SCADA for Mekanism - Startup File

print("====================================")
print("   DIGITAL SCADA FOR MEKANISM")
print("   Initializing... Please stand by")
print("====================================")

-- CHỈ TẢI NHỮNG FILE CÓ THẬT TRÊN GITHUB
local MODULES = {
    "scada/config_loader.lua",
}

-- TẢI VÀ CHẠY TỪNG MODULE
for i, module in ipairs(MODULES) do
    print("Downloading " .. module)
    
    -- TẢI FILE TỪ GITHUB
    local success = shell.run("wget", "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/" .. module, module)
    
    if success then
        -- CHẠY FILE VỪA TẢI
        shell.run(module)
        print("SUCCESS: " .. module .. " loaded!")
    else
        print("ERROR: Failed to download " .. module)
    end
end

-- KIỂM TRA KẾT QUẢ
if config then
    print("CONFIG LOADED SUCCESSFULLY!")
    print("Max Temperature: " .. config.max_temperature .. "K")
    print("Emergency Temp: " .. config.emergency_shutdown_temp .. "K") 
else
    print("Using default config...")
    config = {
        max_temperature = 1200,
        emergency_shutdown_temp = 1500
    }
end

print("====================================")
print("   SCADA SYSTEM READY!")
print("====================================")
