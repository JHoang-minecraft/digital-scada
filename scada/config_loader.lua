-- scada/config_loader.lua - NOW WITH GUI SUPPORT
-- "Có giao diện đẹp rồi đó" =))

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

-- CONFIG
local default_config = {
    max_temperature = 1200,
    emergency_shutdown_temp = 1500,
    scan_interval = 1,
    temp_warning = 800,
    temp_critical = 1000,
    debug = true,
    
    -- URLs CỦA TẤT CẢ MODULES
    module_urls = {
        reactor_monitor = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/Reactors%20Controller/reactor_monitor.lua",
        gui_controller = "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/GUI/gui_controller.lua"
    }
}

-- HÀM TẢI MODULE THẬT
local function loadRealModule(moduleName)
    local url = default_config.module_urls[moduleName]
    if not url then
        printColor(colors.RED, "ERROR: No URL for " .. moduleName)
        return false
    end
    
    local filename = moduleName .. ".lua"
    printColor(colors.CYAN, "Loading " .. filename)
    
    -- TẢI TỪ URL
    local success = shell.run("wget", url, filename)
    
    if success then
        -- CHẠY MODULE
        shell.run(filename)
        printColor(colors.GREEN, "SUCCESS: " .. filename .. " loaded!")
        return true
    else
        printColor(colors.RED, "FAILED: " .. filename)
        return false
    end
end

function config_loader.load()
    printColor(colors.MAGENTA, "=== SCADA SYSTEM INITIALIZATION ===")
    
    -- TẢI TẤT CẢ MODULES
    local loadedCount = 0
    local totalModules = 0
    
    for moduleName, url in pairs(default_config.module_urls) do
        totalModules = totalModules + 1
        if loadRealModule(moduleName) then
            loadedCount = loadedCount + 1
        end
        os.sleep(0.5) -- TRÁNH REQUEST QUÁ NHANH
    end
    
    -- HIỂN THỊ KẾT QUẢ
    printColor(colors.BLUE, "=== SYSTEM STATUS ===")
    printColor(colors.GREEN, "Modules loaded: " .. loadedCount .. "/" .. totalModules)
    
    -- KIỂM TRA TỪNG MODULE
    if reactor_monitor then
        printColor(colors.GREEN, "✓ Reactor Monitor: READY")
    else
        printColor(colors.YELLOW, "✗ Reactor Monitor: MISSING")
    end
    
    if gui then
        printColor(colors.GREEN, "✓ GUI Controller: READY")
    else
        printColor(colors.YELLOW, "✗ GUI Controller: MISSING")
    end
    
    -- THÔNG TIN CONFIG
    printColor(colors.CYAN, "Max Temperature: " .. default_config.max_temperature .. "K")
    printColor(colors.RED, "Emergency Shutdown: " .. default_config.emergency_shutdown_temp .. "K")
    
    if loadedCount == totalModules then
        printColor(colors.GREEN, "System: FULLY OPERATIONAL")
        
        -- TỰ ĐỘNG KHỞI ĐỘNG REACTOR MONITOR
        if reactor_monitor and reactor_monitor.init then
            reactor_monitor.init("right")
            printColor(colors.GREEN, "Reactor monitor initialized!")
        end
        
        -- GỢI Ý KHỞI ĐỘNG GUI
        printColor(colors.MAGENTA, "Type 'gui.start()' to launch control panel!")
    else
        printColor(colors.YELLOW, "System: PARTIALLY LOADED")
    end
    
    return default_config
end

-- Auto-load
config = config_loader.load()

return config_loader
