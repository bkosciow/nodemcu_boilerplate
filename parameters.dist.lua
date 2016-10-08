NET_AP = "---"
NET_PASSWORD = "---"


if file.exists('parameters-device.lc') then  
    dofile("parameters-device.lc")        
else
    dofile("parameters-device.lua")        
end
