-- scada/reactor_monitor.lua - REAL REACTOR CONTROL
-- "Giờ thì thật rồi đó" =))

local reactor_monitor = {}

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

-- BIẾN TOÀN CỤC
local reactor = nil
local isMonitoring = false

function reactor_monitor.init(reactorSide)
    reactorSide = reactorSide or "right"
    reactor = peripheral.wrap(reactorSide)
    
    if not reactor then
        printColor(colors.RED, "REACTOR ERROR: Cannot find reactor on side " .. reactorSide)
        return false
    end
    
    printColor(colors.GREEN, "Reactor connected: " .. reactorSide)
    return true
end

function reactor_monitor.startMonitoring()
    if not reactor then
        printColor(colors.RED, "Reactor not initialized! Call init() first.")
        return
    end
    
    isMonitoring = true
    printColor(colors.CYAN, "Starting reactor monitoring...")
    
    while isMonitoring do
        local status = reactor_monitor.getStatus()
        reactor_monitor.displayStatus(status)
        
        -- KIỂM TRA AN TOÀN
        reactor_monitor.safetyCheck(status)
        
        os.sleep(config.scan_interval or 1)
    end
end

function reactor_monitor.getStatus()
    if not reactor then return nil end
    
    return {
        active = reactor.getStatus(),
        temperature = reactor.getTemperature(),
        damage = reactor.getDamagePercent(),
        burnRate = reactor.getBurnRate(),
        actualBurnRate = reactor.getActualBurnRate(),
        maxBurnRate = reactor.getMaxBurnRate(),
        heatingRate = reactor.getHeatingRate(),
        environmentalLoss = reactor.getEnvironmentalLoss(),
        
        -- FUEL
        fuel = reactor.getFuel(),
        fuelPercent = reactor.getFuelFilledPercentage(),
        fuelNeeded = reactor.getFuelNeeded(),
        fuelCapacity = reactor.getFuelCapacity(),
        
        -- COOLANT
        coolant = reactor.getCoolant(),
        coolantPercent = reactor.getCoolantFilledPercentage(),
        heatedCoolant = reactor.getHeatedCoolant(),
        heatedCoolantPercent = reactor.getHeatedCoolantFilledPercentage(),
        
        -- WASTE
        waste = reactor.getWaste(),
        wastePercent = reactor.getWasteFilledPercentage(),
        
        -- SAFETY
        forceDisabled = reactor.isForceDisabled()
    }
end

function reactor_monitor.displayStatus(status)
    if not status then return end
    
    printColor(colors.BLUE, "=== REACTOR STATUS ===")
    
    -- TRẠNG THÁI
    local statusColor = status.active and colors.GREEN or colors.RED
    printColor(statusColor, "Active: " .. tostring(status.active))
    
    -- NHIỆT ĐỘ
    local tempColor = colors.WHITE
    if status.temperature > (config.temp_critical or 1000) then
        tempColor = colors.RED
    elseif status.temperature > (config.temp_warning or 800) then
        tempColor = colors.YELLOW
    end
    printColor(tempColor, "Temperature: " .. math.floor(status.temperature) .. "K")
    
    -- BURN RATE
    printColor(colors.CYAN, "Burn Rate: " .. status.burnRate .. " / " .. status.maxBurnRate)
    printColor(colors.CYAN, "Actual Burn: " .. status.actualBurnRate)
    
    -- FUEL & COOLANT
    printColor(colors.GREEN, "Fuel: " .. math.floor(status.fuelPercent * 100) .. "%")
    printColor(colors.BLUE, "Coolant: " .. math.floor(status.coolantPercent * 100) .. "%")
    printColor(colors.YELLOW, "Waste: " .. math.floor(status.wastePercent * 100) .. "%")
    
    -- DAMAGE
    if status.damage > 0 then
        printColor(colors.RED, "Damage: " .. math.floor(status.damage * 100) .. "%")
    end
end

function reactor_monitor.safetyCheck(status)
    if not status then return end
    
    -- KIỂM TRA NHIỆT ĐỘ NGUY HIỂM
    if status.temperature > (config.emergency_shutdown_temp or 1500) then
        printColor(colors.RED, "CRITICAL TEMPERATURE! Emergency shutdown!")
        reactor_monitor.emergencyShutdown()
        return
    end
    
    -- KIỂM TRA NHIỆT ĐỘ CẢNH BÁO
    if status.temperature > (config.temp_warning or 800) then
        printColor(colors.YELLOW, "WARNING: High temperature!")
    end
    
    -- KIỂM TRA COOLANT THẤP
    if status.coolantPercent < 0.2 then
        printColor(colors.YELLOW, "WARNING: Low coolant!")
    end
    
    -- KIỂM TRA FUEL THẤP
    if status.fuelPercent < 0.1 then
        printColor(colors.YELLOW, "WARNING: Low fuel!")
    end
end

function reactor_monitor.emergencyShutdown()
    printColor(colors.RED, "!!! EMERGENCY SHUTDOWN ACTIVATED !!!")
    if reactor then
        reactor.scram()
        isMonitoring = false
    end
end

function reactor_monitor.activate()
    if reactor then
        reactor.activate()
        printColor(colors.GREEN, "Reactor activated")
    end
end

function reactor_monitor.scram()
    if reactor then
        reactor.scram()
        printColor(colors.YELLOW, "Reactor scrammed")
    end
end

function reactor_monitor.setBurnRate(rate)
    if reactor then
        reactor.setBurnRate(rate)
        printColor(colors.CYAN, "Burn rate set to: " .. rate)
    end
end

function reactor_monitor.stopMonitoring()
    isMonitoring = false
    printColor(colors.YELLOW, "Reactor monitoring stopped")
end

printColor(colors.GREEN, "Reactor Monitor loaded successfully!")

return reactor_monitor
