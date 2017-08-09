print ("Booting..")
gpio.mode(0, gpio.INPUT, gpio.PULLUP)
gpio.mode(1, gpio.INPUT, gpio.PULLUP)
if gpio.read(0) == 0 then
    print("..aborted")
elseif gpio.read(1) == 0 then
    if file.exists('configurator.lc') then  
        dofile("configurator.lc")        
    else
        dofile("configurator.lua")        
    end  
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
