-- Configuration Loader Module
-- "Remembering things so you don't have to" =))

local config_loader = {}

-- Default configuration
local default_config = {
    -- Reactor settings
    max_temperature = 1200,  -- Kelvin
    emergency_shutdown_temp = 1500,
    
    -- Monitoring intervals
    scan_interval = 1,  -- seconds
    data_log_interval = 10,
    
    -- Alarm thresholds
    temp_warning = 800,
    temp_critical = 1000,
    
    -- Network settings
    plc_timeout = 5,  -- seconds
    
    -- Debug mode
    debug = true  -- Set to false in production!
}

function config_loader.load()
    print(" Loading configuration...")
    
    if default_config.debug then
        print(" DEBUG MODE: Enabled - Expect extra messages! =))")
    end
    
    return default_config
end

function config_loader.get(key)
    return default_config[key]
end

function config_loader.set(key, value)
    default_config[key] = value
    print(" Config updated: " .. key .. " = " .. tostring(value))
end

-- Auto-load config when module is required
config = config_loader.load()

return config_loader
