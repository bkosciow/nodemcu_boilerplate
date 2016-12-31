local drv = {}

drv.pins = {
    RS= 7,
    E1= 6,
    E2= nil,
    DB4= 5,
    DB5= 3,
    DB6= 1,
    DB7= 2,
}

drv.gpio = function(pins)
    if pins ~= nil then
        drv.pins = pins
    end
end

drv.init = function()
    for k,v in pairs(drv.pins) do 
        gpio.mode(v, gpio.OUTPUT)
        gpio.write(v, gpio.LOW)
    end
end    

drv.command4 = function(ch, enable)
    gpio.write(drv.pins['RS'], gpio.LOW)
    drv._write4(ch, enable)
end

drv.command = function(ch, enable)
    gpio.write(drv.pins['RS'], gpio.LOW)
    drv._write8(ch, enable)
end

drv._write4 = function(ch, enable)    
    if bit.isset(ch, 0) then gpio.write(drv.pins['DB4'], gpio.HIGH) else gpio.write(drv.pins['DB4'], gpio.LOW) end        
    if bit.isset(ch, 1) then gpio.write(drv.pins['DB5'], gpio.HIGH) else gpio.write(drv.pins['DB5'], gpio.LOW) end        
    if bit.isset(ch, 2) then gpio.write(drv.pins['DB6'], gpio.HIGH) else gpio.write(drv.pins['DB6'], gpio.LOW) end       
    if bit.isset(ch, 3) then gpio.write(drv.pins['DB7'], gpio.HIGH) else gpio.write(drv.pins['DB7'], gpio.LOW) end

    drv._send(enable)
end

drv._write8 = function(ch, enable) 
    drv._write4(bit.rshift(ch, 4), enable)
    drv._write4(bit.band(ch, 0x0F), enable)
end

drv._send = function(enable)
    if enable == nil then print("no enable!!!") return end
    enable = "E"..enable
    gpio.write(drv.pins[enable], gpio.HIGH)
    tmr.delay(5)
    gpio.write(drv.pins[enable], gpio.LOW)
end

drv.write = function(ch, enable)
    gpio.write(drv.pins['RS'], gpio.HIGH)
    drv._write8(ch:byte(i), enable)        
end

return drv
