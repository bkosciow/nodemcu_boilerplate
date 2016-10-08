wifi.setmode(wifi.STATION)
wifi.sta.config(NET_AP, NET_PASSWORD)

WIFI_FAIL_COUNTER = 0

tmr.register(2, 5000, 1, function()
    if wifi.sta.status() ~= 5 then
        WIFI_FAIL_COUNTER = WIFI_FAIL_COUNTER + 1
        print ("fail = "..wifi.sta.status())
    else
        WIFI_FAIL_COUNTER = 0
    end
    if WIFI_FAIL_COUNTER > 10 then        
        print "Node reboot"
        node.restart()
    end       
end)

if wifi.sta.getip() == nil then
    tmr.alarm(1, 2000, 1, function() 
       if wifi.sta.getip() == nil then     
          print(" Wait for IP --> "..wifi.sta.status()) 
       else 
          print("New IP address is "..wifi.sta.getip()) 
          tmr.stop(1)            
          tmr.start(2)         
          if file.exists('main.lc') then  
            dofile("main.lc")        
          else
            dofile("main.lua")        
          end
       end 
    end)
end


