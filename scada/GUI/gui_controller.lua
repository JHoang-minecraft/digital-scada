-- scada/gui_controller.lua - WITH STARTUP COMMAND
-- "Gõ 'startup' là chạy liền" =))

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
local reactorSide = nil

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
        if not gui.init("right") then
            if not gui.init("left") then
                gui.init("back")
            end
        end
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
                reactorSide = side
                monitor.setCursorPos(1, 5)
                monitor.setTextColor(colors.GREEN)
                monitor.write("✓ Reactor found on side: " .. side)
                break
            end
        end
        
        if reactorFound then
            -- KHỞI TẠO REACTOR MONITOR
            monitor.setCursorPos(1, 6)
            monitor.setTextColor(colors.CYAN)
            monitor.write("Initializing reactor monitor...")
            
            if reactor_monitor and reactor_monitor.init then
                local success = reactor_monitor.init(reactorSide)
                if success then
                    monitor.setCursorPos(1, 7)
                    monitor.setTextColor(colors.GREEN)
                    monitor.write("SUCCESS: Reactor monitor initialized!")
                    
                    monitor.setCursorPos(1, 8)
                    monitor.write("Launching control panel...")
                    
                    os.sleep(2)
                    gui.start() -- KHỞI CHẠY GUI CHÍNH
                    return true
                end
            else
                monitor.setCursorPos(1, 7)
                monitor.setTextColor(colors.RED)
                monitor.write("ERROR: Reactor monitor not available!")
            end
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

-- VẼ THÔNG SỐ REACTOR
local function drawReactorData()
    if not reactor_monitor or not reactor_monitor.getStatus then
        monitor.setCursorPos(2, 5)
        monitor.setTextColor(colors.RED)
        monitor.write("REACTOR MONITOR NOT AVAILABLE")
        return
    end
    
    local status = reactor_monitor.getStatus()
    if not status then
        monitor.setCursorPos(2, 5)
        monitor.setTextColor(colors.RED)
        monitor.write("UNABLE TO GET REACTOR STATUS")
        return
    end
    
    -- TRẠNG THÁI
    monitor.setCursorPos(2, 5)
    monitor.setTextColor(colors.WHITE)
    monitor.write("STATUS: ")
    monitor.setTextColor(status.active and colors.GREEN or colors.RED)
    monitor.write(status.active and "ACTIVE" or "INACTIVE")
    
    -- NHIỆT ĐỘ
    monitor.setTextColor(colors.WHITE)
    monitor.setCursorPos(2, 7)
    monitor.write("TEMPERATURE: ")
    
    local tempColor = colors.WHITE
    if status.temperature > 1000 then
        tempColor = colors.RED
    elseif status.temperature > 800 then
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
end

-- VÒNG LẶP CHÍNH GUI
function gui.start()
    isRunning = true
    print("GUI Control Panel Started - Press Ctrl+T to stop")
    
    while isRunning do
        -- VẼ GUI
        drawBackground()
        drawReactorData()
        
        -- XỬ LÝ INPUT (NON-BLOCKING)
        local timer = os.startTimer(1) -- UPDATE MỖI GIÂY
        local event = {os.pullEvent()}
        
        if event[1] == "key" then
            local key = event[2]
            if key == 59 then -- F1
                if reactor_monitor and reactor_monitor.activate then
                    reactor_monitor.activate()
                end
            elseif key == 60 then -- F2
                if reactor_monitor and reactor_monitor.scram then
                    reactor_monitor.scram()
                end
            elseif key == 61 then -- F3
                if reactor_monitor and reactor_monitor.emergencyShutdown then
                    reactor_monitor.emergencyShutdown()
                end
            end
        end
    end
end

function gui.stop()
    isRunning = false
    if monitor then
        monitor.setBackgroundColor(colors.BLACK)
        monitor.setTextColor(colors.WHITE)
        monitor.clear()
        monitor.setCursorPos(1, 1)
    end
end

-- TẠO COMMAND STARTUP TOÀN CỤC
function startup()
    if gui and gui.startup then
        print("Launching SCADA Control Panel...")
        gui.startup()
    else
        print("ERROR: GUI system not loaded!")
    end
end

print("GUI Controller loaded successfully!")
print("Type 'startup' to launch the control panel!")

return gui
