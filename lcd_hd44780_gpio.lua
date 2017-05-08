local drv = {}
drv.__index = drv

setmetatable(drv, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function drv.new(pins)
    local self = setmetatable({}, drv)    
    if pins == nil then
        self.pins = {
             RS= 7,
            E1= 6,
            E2= nil,
            DB4= 5,
            DB5= 3,
            DB6= 1,
            DB7= 2,
        }
    else
        self.pins = pins
    end
    
    return self
end    

function drv:init()
    for k,v in pairs(self.pins) do 
        gpio.mode(v, gpio.OUTPUT)
        gpio.write(v, gpio.LOW)
    end
end    

function drv:command4(ch, enable)
    gpio.write(self.pins['RS'], gpio.LOW)
    drv._write4(self, ch, enable)
end

function drv:command(ch, enable, charMode)
    if (charMode) then gpio.write(self.pins['RS'], gpio.HIGH) else gpio.write(self.pins['RS'], gpio.LOW) end
    drv._write8(self, ch, enable)
end

function drv:_write4(ch, enable)    
    if bit.isset(ch, 0) then gpio.write(self.pins['DB4'], gpio.HIGH) else gpio.write(self.pins['DB4'], gpio.LOW) end        
    if bit.isset(ch, 1) then gpio.write(self.pins['DB5'], gpio.HIGH) else gpio.write(self.pins['DB5'], gpio.LOW) end        
    if bit.isset(ch, 2) then gpio.write(self.pins['DB6'], gpio.HIGH) else gpio.write(self.pins['DB6'], gpio.LOW) end       
    if bit.isset(ch, 3) then gpio.write(self.pins['DB7'], gpio.HIGH) else gpio.write(self.pins['DB7'], gpio.LOW) end

    drv._send(self, enable)
end

function drv:_write8(ch, enable) 
    drv._write4(self, bit.rshift(ch, 4), enable)
    drv._write4(self, bit.band(ch, 0x0F), enable)
end

function drv:_send(enable)
    enable = "E"..enable
    gpio.write(self.pins[enable], gpio.HIGH)
    tmr.delay(5)
    gpio.write(self.pins[enable], gpio.LOW)
end

function drv:write(ch, enable)
    gpio.write(self.pins['RS'], gpio.HIGH)
    drv._write8(self, ch:byte(i), enable)        
end

return drv
