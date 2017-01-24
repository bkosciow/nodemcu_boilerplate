local Temp18b20 = {}
Temp18b20.__index = Temp18b20
Temp18b20.device_id = {0x10, 0x28}

setmetatable(Temp18b20, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function Temp18b20.new(pin)
    local self = setmetatable({}, Temp18b20)
    self.pin = pin
    self.addr = nil    
    return self
end    

function Temp18b20:init()    
    ow.setup(self.pin) 
    count = 0
    repeat
      count = count + 1
      addr = ow.reset_search(self.pin)
      addr = ow.search(self.pin)
      tmr.wdclr()
    until (addr ~= nil) or (count > 100)
    if addr == nil then
        print("Device not found")
    else
        self.addr = addr
        crc = ow.crc8(string.sub(self.addr,1,7))
        if crc == self.addr:byte(8) then
            if (not Temp18b20.is_device(self.addr:byte(1))) then
                print("Device is not a DS18B20 family device.")
                self.addr = nil
            end
        else
            print("CRC invalid - not a device ?")
            self.addr = nil
        end
    end
end

function Temp18b20.is_device(data)
    for i, v in ipairs(Temp18b20.device_id) do        
        if v == data then
            return true
        end
    end

    return false
end

function Temp18b20:get_temperature(round)
    ow.reset(self.pin)
    ow.select(self.pin, self.addr)
    ow.write(self.pin, 0x44, 1)
    present = ow.reset(self.pin)
    ow.select(self.pin, self.addr)
    ow.write(self.pin,0xBE,1)
    data = string.char(ow.read(self.pin))
    for i = 1, 8 do
        data = data .. string.char(ow.read(self.pin))
    end    
    crc = ow.crc8(string.sub(data,1,8))
    if crc == data:byte(9) then
        t = (data:byte(1) + data:byte(2) * 256) * 625
        t1 = t / 10000
        t2 = t % 10000        
        if round ~= nil and round ~= false then return t1 else return t1.."."..t2 end
    else
        return nil
    end       
end

return Temp18b20