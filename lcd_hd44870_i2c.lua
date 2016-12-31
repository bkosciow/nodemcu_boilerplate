local drv = {}
drv.port = 0
drv.addr = nil
drv.sda = 1
drv.scl = 2
drv._rs = 0
drv._buffer = nil
drv.pins = {
    RS= 4,
    E1= 5,
    E2= nil,
    DB4= 0,
    DB5= 1,
    DB6= 2,
    DB7= 3,
}

drv.init = function()
    i2c.setup(drv.port, drv.sda, drv.scl, i2c.SLOW)
    i2c.address(drv.port, drv.addr, i2c.TRANSMITTER)
end    

drv.command4 = function(ch, enable) 
    drv._rs = 0
    drv._write4(ch, enable)
end

drv.command = function(ch, enable)
    drv._rs = 0
    drv._write8(ch, enable)
end

drv._write4 = function(ch, enable)    
    drv._buffer = 0
    if bit.isset(ch, 0) then drv._buffer = drv._buffer + math.pow(2, drv.pins['DB4']) end        
    if bit.isset(ch, 1) then drv._buffer = drv._buffer + math.pow(2, drv.pins['DB5']) end        
    if bit.isset(ch, 2) then drv._buffer = drv._buffer + math.pow(2, drv.pins['DB6']) end       
    if bit.isset(ch, 3) then drv._buffer = drv._buffer + math.pow(2, drv.pins['DB7']) end
    drv._buffer = ch
    drv._send(enable)
end

drv._write8 = function(ch, enable) 
    drv._write4(bit.rshift(ch, 4), enable)
    drv._write4(bit.band(ch, 0x0F), enable)
end

drv._send = function(enable)   
    enable = "E"..enable
    i2c.start(drv.port)
    i2c.address(drv.port, drv.addr, i2c.TRANSMITTER)    
    i2c.write(drv.port, drv._buffer +  math.pow(2, drv.pins[enable]) + drv._rs)
    tmr.delay(5)
    i2c.write(drv.port, drv._buffer)
    i2c.stop(drv.port)
end

drv.write = function(ch, enable)
    drv._rs =  math.pow(2, drv.pins['RS'])
    drv._write8(ch:byte(1), enable)        
end

return drv