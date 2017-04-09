_WIFI_APS = {   
    {["bubus"]="whoknowsme"},
    {["bubus1"]="whoknowsme1"},
}
PROTOCOL = "iot:1"
PORT = 5053
CHANNELS = {2, 3, 4, 1}
if file.exists('parameters-device.lc') then  
    dofile("parameters-device.lc")        
else
    dofile("parameters-device.lua")        
end
