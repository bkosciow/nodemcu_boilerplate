local sensor = {}

sensor.pin = nil
sensor.addr = nil
sensor.device_id = {0x10, 0x28}

sensor.init = function(pin)
    sensor.pin = pin
    ow.setup(sensor.pin) 
    count = 0
    repeat
      count = count + 1
      addr = ow.reset_search(pin)
      addr = ow.search(pin)
      tmr.wdclr()
    until (addr ~= nil) or (count > 100)
    if addr == nil then
        print("Device not found")
    else
        sensor.addr = addr
        crc = ow.crc8(string.sub(sensor.addr,1,7))
        if crc == sensor.addr:byte(8) then
            --if (sensor.addr:byte(1) ~= 0x10) and (sensor.addr:byte(1) ~= 0x28) then
            if (not sensor.is_device(sensor.addr:byte(1))) then
                print("Device is not a DS18B20 family device.")
                sensor.addr = nil
            end
        else
            print("CRC invalid - not a device ?")
            sensor.addr = nil
        end
    end

    return sensor.addr
end

sensor.is_device = function(data)
    for i, v in ipairs(sensor.device_id) do        
        if v == data then
            return true
        end
    end

    return false
end

sensor.get_temperature = function(round)
    ow.reset(sensor.pin)
    ow.select(sensor.pin, sensor.addr)
    ow.write(sensor.pin, 0x44, 1)
    present = ow.reset(sensor.pin)
    ow.select(sensor.pin, sensor.addr)
    ow.write(sensor.pin,0xBE,1)
    data = string.char(ow.read(sensor.pin))
    for i = 1, 8 do
        data = data .. string.char(ow.read(sensor.pin))
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

return sensor;