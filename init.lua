print ("Booting..")
gpio.mode(1, gpio.INPUT, gpio.PULLUP)
if gpio.read(1) == 0 then
    print("..aborted")
else    
    if file.exists('parameters.lc') then  
        dofile("parameters.lc")        
    else
        dofile("parameters.lua")        
    end
    tmr.alarm(1, 2000, 0, function()
        print ("..launch..")     
        if file.exists('wifi-init.lc') then  
            dofile("wifi-init.lc")        
        else
            dofile("wifi-init.lua")        
        end
    end)
end    
