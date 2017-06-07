local drv = {}
drv.__index = drv

drv.port = 0

setmetatable(drv, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function drv.new(addr, sda, scl, pins)
    local self = setmetatable({}, drv)
    self.addr = addr
    self.sda = sda
    self.scl = scl
    self._rs = 0
    self._buffer = nil
    self._blon = true
    if pins == nil then
        self.pins = {
            RS= 4,
            E1= 5,
            E2= nil,
            DB4= 0,
            DB5= 1,
            DB6= 2,
            DB7= 3,
            BL= nil
        }
    else
        self.pins = pins
    end
    
    return self
end 

function drv:init()
    i2c.setup(drv.port, self.sda, self.scl, i2c.SLOW)
    i2c.address(self.port, self.addr, i2c.TRANSMITTER)
end    

function drv:command4(ch, enable) 
    self._rs = 0
    drv._write4(self, ch, enable) --?
end

function drv:command(ch, enable)
    self._rs = 0
    drv._write8(self, ch, enable)
end

function drv:_write4(ch, enable)    
    self._buffer = 0
    if bit.isset(ch, 0) then self._buffer = self._buffer + math.pow(2, self.pins['DB4']) end        
    if bit.isset(ch, 1) then self._buffer = self._buffer + math.pow(2, self.pins['DB5']) end        
    if bit.isset(ch, 2) then self._buffer = self._buffer + math.pow(2, self.pins['DB6']) end       
    if bit.isset(ch, 3) then self._buffer = self._buffer + math.pow(2, self.pins['DB7']) end
    drv._send(self, enable)
end

function drv:_write8(ch, enable) 
    drv._write4(self, bit.rshift(ch, 4), enable)
    drv._write4(self, bit.band(ch, 0x0F), enable)
end

function drv:_getblpin()
    if (self.pins['BL'] == nil or self._blon == false) then
        return 0
    else
        return math.pow(2, self.pins['BL'])
    end
end

function drv:_send(enable)  
    enable = "E"..enable
    i2c.start(self.port)
    i2c.address(self.port, self.addr, i2c.TRANSMITTER)
    i2c.write(self.port, self._buffer +  math.pow(2, self.pins[enable]) + self._rs + drv._getblpin(self))
    tmr.delay(5)
    i2c.write(self.port, self._buffer + drv._getblpin(self))
    i2c.stop(self.port)
end

function drv:write(ch, enable)
    self._rs =  math.pow(2, self.pins['RS'])
    self._write8(self, ch:byte(1), enable)        
end

function drv:backlight(on)
    self._blon = on
    i2c.start(self.port)
    i2c.address(self.port, self.addr, i2c.TRANSMITTER)
    i2c.write(self.port, drv._getblpin(self))
    i2c.stop(self.port)
end

function drv:setrs(high)
    if (high) then self._rs = math.pow(2, self.pins['RS']) else self._rs = 0 end
end

return drv
