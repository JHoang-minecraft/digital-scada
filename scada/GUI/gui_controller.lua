-- scada/gui_controller.lua - REACTOR CONTROL DASHBOARD
-- "Giao diện đẹp lung linh" =))

local gui = {}

-- MÀU SẮC
local colors = {
    RED = 1,
    GREEN = 2, 
    YELLOW = 3,
    BLUE = 4,
    MAGENTA = 5,
    CYAN = 6,
    WHITE = 7,
    BLACK = 0
}

-- BIẾN
local monitor = nil
local isRunning = false
local screenWidth, screenHeight = 0, 0

-- KHỞI TẠO MONITOR
function gui.init(monitorSide)
    if peripheral.getType(monitorSide) == "monitor" then
        monitor = peripheral.wrap(monitorSide)
        monitor.setTextScale(0.5)
        screenWidth, screenHeight = monitor.getSize()
        return true
    else
        -- DÙNG TERMINAL NẾU KHÔNG CÓ MONITOR
        screenWidth, screenHeight = term.getSize()
        monitor = term
        return false
    end
end

-- VẼ BACKGROUND
local function drawBackground()
    monitor.setBackgroundColor(colors.BLACK)
    monitor.clear()
    
    -- HEADER
    monitor.setBackgroundColor(colors.BLUE)
    monitor.setTextColor(colors.WHITE)
    for y = 1, 3 do
        monitor.setCursorPos(1, y)
        monitor.write(string.rep(" ", screenWidth))
    end
    
    monitor.setCursorPos(2, 2)
    monitor.write("MEKANISM REACTOR CONTROL PANEL")
    
    -- FOOTER
    monitor.setBackgroundColor(colors.GRAY)
    monitor.setCursorPos(1, screenHeight)
    monitor.write(string.rep(" ", screenWidth))
    monitor.setCursorPos(2, screenHeight)
    monitor.write("F1:Start  F2:Stop  F3:Emergency")
end

-- VẼ THÔNG SỐ REACTOR
local function drawReactorData(status)
    if not status then return end
    
    -- VÙNG THÔNG TIN CHÍNH
    monitor.setBackgroundColor(colors.BLACK)
    monitor.setTextColor(colors.WHITE)
    
    -- TRẠNG THÁI
    monitor.setCursorPos(2, 5)
    monitor.write("STATUS: ")
    monitor.setTextColor(status.active and colors.GREEN or colors.RED)
    monitor.write(status.active and "ACTIVE" or "INACTIVE")
    
    -- NHIỆT ĐỘ (QUAN TRỌNG NHẤT)
    monitor.setTextColor(colors.WHITE)
    monitor.setCursorPos(2, 7)
    monitor.write("TEMPERATURE: ")
    
    local tempColor = colors.WHITE
    if status.temperature > (config.temp_critical or 1000) then
        tempColor = colors.RED
    elseif status.temperature > (config.temp_warning or 800) then
        tempColor = colors.YELLOW
    else
        tempColor = colors.GREEN
    end
    
    monitor.setTextColor(tempColor)
    monitor.write(math.floor(status.temperature) .. " K")
    
    -- THANH NHIỆT ĐỘ
    monitor.setTextColor(colors.WHITE)
    monitor.setCursorPos(2, 8)
    monitor.write("[")
    
    local barWidth = screenWidth - 4
    local tempPercent = math.min(status.temperature / 2000, 1.0)
    local filledWidth = math.floor(barWidth * tempPercent)
    
    monitor.setBackgroundColor(tempColor)
    monitor.write(string.rep(" ", filledWidth))
    monitor.setBackgroundColor(colors.BLACK)
    monitor.write(string.rep(" ", barWidth - filledWidth))
    monitor.write("]")
    
    -- THÔNG SỐ KHÁC
    monitor.setBackgroundColor(colors.BLACK)
    monitor.setTextColor(colors.WHITE)
    
    monitor.setCursorPos(2, 10)
    monitor.write("BURN RATE: ")
    monitor.setTextColor(colors.CYAN)
    monitor.write(status.burnRate .. "/" .. status.maxBurnRate)
    
    monitor.setTextColor(colors.WHITE)
    monitor.setCursorPos(2, 11)
    monitor.write("FUEL: ")
    monitor.setTextColor(colors.GREEN)
    monitor.write(math.floor(status.fuelPercent * 100) .. "%")
    
    monitor.setTextColor(colors.WHITE)
    monitor.setCursorPos(2, 12)
    monitor.write("COOLANT: ")
    monitor.setTextColor(colors.BLUE)
    monitor.write(math.floor(status.coolantPercent * 100) .. "%")
    
    monitor.setTextColor(colors.WHITE)
    monitor.setCursorPos(2, 13)
    monitor.write("WASTE: ")
    monitor.setTextColor(colors.YELLOW)
    monitor.write(math.floor(status.wastePercent * 100) .. "%")
    
    -- CẢNH BÁO
    if status.temperature > (config.temp_warning or 800) then
        monitor.setBackgroundColor(colors.RED)
        monitor.setTextColor(colors.WHITE)
        monitor.setCursorPos(2, 15)
        monitor.write(" WARNING: HIGH TEMPERATURE! ")
    end
end

-- VẼ NÚT ĐIỀU KHIỂN
local function drawControls()
    monitor.setBackgroundColor(colors.BLACK)
    monitor.setTextColor(colors.WHITE)
    
    monitor.setCursorPos(screenWidth - 20, 5)
    monitor.write("[F1] START REACTOR")
    
    monitor.setCursorPos(screenWidth - 20, 6)
    monitor.write("[F2] STOP REACTOR")
    
    monitor.setCursorPos(screenWidth - 20, 7)
    monitor.write("[F3] EMERGENCY STOP")
    
    monitor.setCursorPos(screenWidth - 20, 9)
    monitor.write("Burn Rate Control:")
    
    monitor.setCursorPos(screenWidth - 20, 10)
    monitor.write("[+] INCREASE")
    
    monitor.setCursorPos(screenWidth - 20, 11)
    monitor.write("[-] DECREASE")
end

-- XỬ LÝ INPUT
local function handleInput()
    local event, key = os.pullEvent("key")
    
    if key == 59 then -- F1
        if reactor_monitor then
            reactor_monitor.activate()
        end
    elseif key == 60 then -- F2
        if reactor_monitor then
            reactor_monitor.scram()
        end
    elseif key == 61 then -- F3
        if reactor_monitor then
            reactor_monitor.emergencyShutdown()
        end
    elseif key == 45 then -- +
        if reactor_monitor then
            -- TĂNG BURN RATE
        end
    elseif key == 46 then -- -
        if reactor_monitor then
            -- GIẢM BURN RATE
        end
    end
end

-- VÒNG LẶP CHÍNH
function gui.start()
    if not monitor then
        gui.init("top") -- THỬ KẾT NỐI MONITOR
    end
    
    isRunning = true
    print("GUI Started - Press Ctrl+T to stop")
    
    while isRunning do
        -- LẤY DỮ LIỆU REACTOR
        local status = nil
        if reactor_monitor and reactor_monitor.getStatus then
            status = reactor_monitor.getStatus()
        end
        
        -- VẼ GUI
        drawBackground()
        drawReactorData(status)
        drawControls()
        
        -- XỬ LÝ INPUT (NON-BLOCKING)
        local timer = os.startTimer(0.1)
        local event = {os.pullEvent()}
        if event[1] == "timer" and event[2] == timer then
            -- TIMEOUT, TIẾP TỤC VÒNG LẶP
        else
            handleInput(event[1], event[2])
        end
    end
end

function gui.stop()
    isRunning = false
    monitor.setBackgroundColor(colors.BLACK)
    monitor.setTextColor(colors.WHITE)
    monitor.clear()
    monitor.setCursorPos(1, 1)
end

print("GUI Controller loaded successfully!")

return gui
