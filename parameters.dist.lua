NET_AP = "---"
NET_PASSWORD = "---"
PROTOCOL = "iot:1"
PORT = 5053

if file.exists('parameters-device.lc') then  
    dofile("parameters-device.lc")        
else
    dofile("parameters-device.lua")        
end
