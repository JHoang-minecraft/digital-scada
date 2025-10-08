-- Digital SCADA for Mekanism - Startup File

print("SCADA SYSTEM STARTING")

shell.run("wget", "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/scada/config_loader.lua", "config_loader.lua")
shell.run("config_loader.lua")

shell.run("wget", "https://raw.githubusercontent.com/JHoang-minecraft/digital-scada/refs/heads/main/Reactors%20Controller/reactor_monitor.lua", "reactor_monitor.lua")
shell.run("reactor_monitor.lua")

print("SCADA SYSTEM READY")
