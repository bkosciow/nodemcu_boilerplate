NET_AP = "---"
NET_PASSWORD = "---"
PROTOCOL = "iot:1"

if file.exists('parameters-device.lc') then  
    dofile("parameters-device.lc")        
else
    dofile("parameters-device.lua")        
end
