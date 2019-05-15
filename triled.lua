local led = {}
led.pin_red = nil
led.pin_green = nil
led.pin_blue = nil
led.tick = 600
led.blink_pin = nil
led.freq = nil
led.freq_cnt = 0
led.timer_loop = nil
led.timer = tmr.create()
led.init = function()
    if (led.pin_green) then gpio.mode(led.pin_green,gpio.OUTPUT) end
    if (led.pin_blue) then gpio.mode(led.pin_blue,gpio.OUTPUT) end
    if (led.pin_red) then gpio.mode(led.pin_red,gpio.OUTPUT) end
    led.clear()
    led.timer:register(led.tick, tmr.ALARM_AUTO, function()        
        if gpio.read(led.blink_pin) == 1 and led.freq_cnt < led.freq then
            gpio.write(led.blink_pin, gpio.LOW)
        else
            gpio.write(led.blink_pin, gpio.HIGH)
            led.freq_cnt = led.freq_cnt + 1
            if led.freq_cnt > led.freq + 1 then
                if led.timer_loop then led.freq_cnt = 0 else led.timer:stop() end
            end
        end
    end)
end
led.red = function(status)
    if status then gpio.write(led.pin_red, gpio.LOW) else gpio.write(led.pin_red, gpio.HIGH) end        
end
led.green = function(status)
    if status then gpio.write(led.pin_green, gpio.LOW) else gpio.write(led.pin_green, gpio.HIGH) end      
end
led.blue = function(status)
    if status then gpio.write(led.pin_blue, gpio.LOW) else gpio.write(led.pin_blue, gpio.HIGH) end
end
led.clear = function()
    led.red(false)
    led.green(false)
    led.blue(false)
    led.timer:stop()
end    
led.blink_red = function(freq, loop)
    led.blink_pin = led.pin_red
    led.blink(freq, loop)
end
led.blink_green = function(freq, loop)
    led.blink_pin = led.pin_green    
    led.blink(freq, loop)
end
led.blink_blue = function(freq, loop)
    led.blink_pin = led.pin_blue    
    led.blink(freq, loop)
end
led.blink = function(freq, loop)
    led.freq = freq
    led.timer_loop = loop
    led.freq_cnt = 0
    led.clear()
    led.timer:start()
end
return led
