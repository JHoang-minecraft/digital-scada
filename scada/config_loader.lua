-- scada/config_loader.lua - TẢI REACTOR_MONITOR THẬT
-- "Tập trung vào reactor monitor trước" =))

local config_loader = {}

-- MÀU SẮC
local colors = {
    RED = 1,
    GREEN = 2, 
    YELLOW = 3,
    BLUE = 4,
    MAGENTA = 5,
    CYAN = 6,
    WHITE = 7
}

local function printColor(color, text)
    if term.isColor() then
        term.setTextColor(color)
        print(text)
        term.setTextColor(colors.WHITE)
    else
        print(text)
    end
end

-- CONFIG ĐƠN GIẢN
local default_config = {
    max_temperature = 1200,
    emergency_shutdown_temp = 1500,
    scan_interval = 1,
    temp_warning = 800,
    temp_critical = 1000,
    debug = true,
    
    -- CHỈ TẢI REACTOR_MONITOR TRƯỚC
    reactor_monitor_url = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/Reactors%20Controller/reactor_monitor.lua"
}

-- HÀM TẢI REACTOR_MONITOR THẬT
local function loadReactorMonitor()
    printColor(colors.CYAN, "Loading Reactor Monitor...")
    
    -- TẢI TỪ URL THẬT
    local success = shell.run("wget", default_config.reactor_monitor_url, "reactor_monitor.lua")
    
    if success then
        -- CHẠY MODULE VỪA TẢI
        shell.run("reactor_monitor.lua")
        printColor(colors.GREEN, "Reactor Monitor loaded successfully!")
        return true
    else
        printColor(colors.RED, "Failed to load Reactor Monitor")
        return false
    end
end

function config_loader.load()
    printColor(colors.MAGENTA, "=== SCADA SYSTEM INITIALIZATION ===")
    
    -- TẢI REACTOR_MONITOR ĐẦU TIÊN
    local reactorLoaded = loadReactorMonitor()
    
    -- HIỂN THỊ KẾT QUẢ
    printColor(colors.BLUE, "=== SYSTEM STATUS ===")
    printColor(reactorLoaded and colors.GREEN or colors.RED, "Reactor Monitor: " .. (reactorLoaded and "LOADED" or "FAILED"))
    printColor(colors.CYAN, "Max Temperature: " .. default_config.max_temperature .. "K")
    printColor(colors.RED, "Emergency Shutdown: " .. default_config.emergency_shutdown_temp .. "K")
    
    if reactorLoaded then
        printColor(colors.GREEN, "System: READY for reactor control!")
    else
        printColor(colors.YELLOW, "System: LIMITED (reactor control unavailable)")
    end
    
    return default_config
end

-- Auto-load
config = config_loader.load()

return config_loader
