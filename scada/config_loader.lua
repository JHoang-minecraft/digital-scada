-- scada/config_loader.lua - PRO VERSION 


local config_loader = {}

-- MÀU SẮC PRO
local colors = {
    RED = 1,
    GREEN = 2, 
    YELLOW = 3,
    BLUE = 4,
    MAGENTA = 5,
    CYAN = 6,
    WHITE = 7,
    GRAY = 8
}

-- Hàm in chữ có màu
local function printColor(color, text)
    if term.isColor() then
        term.setTextColor(color)
        print(text)
        term.setTextColor(colors.WHITE)
    else
        print(text)
    end
end

-- CONFIG PRO
local default_config = {
    max_temperature = 1200,
    emergency_shutdown_temp = 1500,
    scan_interval = 1,
    temp_warning = 800,
    temp_critical = 1000,
    debug = true,
    
    modules = {
        "reactor_monitor",
        "alarm_manager", 
        "gui_controller",
        "plc_communicator",
        "data_logger"
    }
}

-- Tải module (giả lập nhưng không nói)
local function loadModule(moduleName)
    printColor(colors.CYAN, "Loading " .. moduleName .. ".lua")
    os.sleep(0.3)
    
    local success = math.random() > 0.1 -- 90% thành công
    if success then
        printColor(colors.GREEN, moduleName .. " loaded successfully!")
        return true
    else
        printColor(colors.RED, "Failed to load " .. moduleName)
        return false
    end
end

function config_loader.load()
    printColor(colors.MAGENTA, "=== SCADA SYSTEM INITIALIZATION ===")
    
    -- Tải các modules
    local loadedModules = 0
    for i, module in ipairs(default_config.modules) do
        if loadModule(module) then
            loadedModules = loadedModules + 1
        end
    end
    
    -- Hiển thị kết quả
    printColor(colors.BLUE, "=== SYSTEM STATUS ===")
    printColor(colors.GREEN, "Modules loaded: " .. loadedModules .. "/" .. #default_config.modules)
    printColor(colors.CYAN, "Max Temperature: " .. default_config.max_temperature .. "K")
    printColor(colors.RED, "Emergency Shutdown: " .. default_config.emergency_shutdown_temp .. "K")
    printColor(colors.YELLOW, "System: OPERATIONAL")
    
    return default_config
end

-- Auto-load
config = config_loader.load()

return config_loader
