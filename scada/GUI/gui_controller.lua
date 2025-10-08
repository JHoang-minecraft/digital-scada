-- scada/gui_controller.lua - STARTUP COMMAND VERSION
-- "Màn hình khởi động đẹp lung linh" =))

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

-- HIỆN THỊ LOG KHỞI ĐỘNG
function gui.startup()
    print("Starting GUI Startup Sequence...")
    
    -- KHỞI TẠO MONITOR
    if not gui.init("top") then
        gui.init("right")
    end
    
    monitor.setBackgroundColor(colors.BLACK)
    monitor.clear()
    monitor.setTextColor(colors.CYAN)
    
    -- HIỆN THỊ LOGO/HEADER
    monitor.setCursorPos(1, 1)
    monitor.write("=== MEKANISM SCADA SYSTEM ===")
    monitor.setCursorPos(1, 2)
    monitor.write("Initializing GUI Startup Package...")
    
    -- BIỂU TƯỢNG LOADING
    local loadingChars = {"|", "/", "-", "\\"}
    local loadingIndex = 1
    local retryCount = 0
    local maxRetries = 10
    
    -- KIỂM TRA KẾT NỐI REACTOR
    while retryCount < maxRetries do
        -- HIỆN THỊ LOADING
        monitor.setCursorPos(1, 4)
        monitor.write("[" .. loadingChars[loadingIndex] .. "] Scanning for reactors...")
        
        loadingIndex = (loadingIndex % 4) + 1
        
        -- KIỂM TRA REACTOR
        local reactorFound = false
        local sides = {"right", "left", "front", "back", "top", "bottom"}
        
        for _, side in ipairs(sides) do
            if peripheral.getType(side) == "fissionReactorLogicAdapter" then
                reactorFound = true
                monitor.setCursorPos(1, 5)
                monitor.setTextColor(colors.GREEN)
                monitor.write("✓ Reactor found on side: " .. side)
                break
            end
        end
        
        if reactorFound then
            -- REACTOR ĐÃ KẾT NỐI
            monitor.setCursorPos(1, 7)
            monitor.setTextColor(colors.GREEN)
            monitor.write("SUCCESS: Reactor connection established!")
            monitor.setCursorPos(1, 8)
            monitor.write("Launching control panel...")
            
            os.sleep(2)
            gui.start() -- KHỞI CHẠY GUI CHÍNH
            return true
        else
            -- KHÔNG TÌM THẤY REACTOR
            retryCount = retryCount + 1
            monitor.setCursorPos(1, 5)
            monitor.setTextColor(colors.YELLOW)
            monitor.write("✗ No reactor found... Retrying in 5 seconds")
            monitor.setCursorPos(1, 6)
            monitor.write("Attempt " .. retryCount .. "/" .. maxRetries)
            
            os.sleep(5) -- CHỜ 5 GIÂY
        end
    end
    
    -- TIMEOUT - KHÔNG TÌM THẤY REACTOR
    monitor.setCursorPos(1, 7)
    monitor.setTextColor(colors.RED)
    monitor.write("ERROR: Reactor connection timeout!")
    monitor.setCursorPos(1, 8)
    monitor.write("Please check reactor connection and restart.")
    
    return false
end

-- VẼ BACKGROUND GUI CHÍNH
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

-- VẼ THÔNG SỐ REACTOR (giữ nguyên từ trước)
local function drawReactorData(status)
    -- ... (giữ nguyên code cũ)
end

-- VÒNG LẶP CHÍNH GUI
function gui.start()
    isRunning = true
    print("GUI Control Panel Started - Press Ctrl+T to stop")
    
    while isRunning do
        -- LẤY DỮ LIỆU REACTOR
        local status = nil
        if reactor_monitor and reactor_monitor.getStatus then
            status = reactor_monitor.getStatus()
        end
        
        -- VẼ GUI
        drawBackground()
        drawReactorData(status)
        
        -- XỬ LÝ INPUT
        local timer = os.startTimer(1) -- UPDATE MỖI GIÂY
        local event = {os.pullEvent()}
        if event[1] == "timer" and event[2] == timer then
            -- TIMEOUT, TIẾP TỤC VÒNG LẶP
        else
            -- XỬ LÝ PHÍM
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
print("Type 'gui.startup()' to launch the control panel!")

return gui
