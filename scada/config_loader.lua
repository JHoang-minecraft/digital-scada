-- scada/config_loader.lua 

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
    debug = true
}

-- HÀM TẢI VÀ CHẠY MODULE - KHÔNG QUAN TÂM BIẾN TOÀN CỤC
local function loadAndRunModule(url, filename)
    printColor(colors.CYAN, "Loading " .. filename)
    
    -- TẢI VÀ CHẠY
    local success = shell.run("wget", url, filename)
    if success then
        shell.run(filename)
        printColor(colors.GREEN, "SUCCESS: " .. filename .. " executed!")
        return true
    else
        printColor(colors.RED, "FAILED: " .. filename)
        return false
    end
end

function config_loader.load()
    printColor(colors.MAGENTA, "=== SCADA SYSTEM INITIALIZATION ===")
    
    -- TẢI VÀ CHẠY CÁC MODULES - KHÔNG KIỂM TRA BIẾN
    loadAndRunModule(
        "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/Reactors%20Controller/reactor_monitor.lua",
        "reactor_monitor.lua"
    )
    
    loadAndRunModule(
        "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/GUI/gui_controller.lua", 
        "gui_controller.lua"
    )
    
    -- HIỂN THỊ THÔNG TIN ĐƠN GIẢN
    printColor(colors.BLUE, "=== SYSTEM READY ===")
    printColor(colors.CYAN, "Max Temperature: " .. default_config.max_temperature .. "K")
    printColor(colors.GREEN, "All modules downloaded and executed!")
    printColor(colors.MAGENTA, "Commands available:")
    printColor(colors.WHITE, " - reactor_monitor.init('right')")
    printColor(colors.WHITE, " - gui.start()")
    
    return default_config
end

shell.setAlias("startup", "lua", "gui.startup()")

print("Type 'startup' to launch the control panel!")

-- KHÔNG TẠO BIẾN TOÀN CỤC config NỮA
config_loader.load()

return config_loader
