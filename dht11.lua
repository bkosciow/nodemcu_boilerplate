local mydht = {}
mydht.__index = mydht

setmetatable(mydht, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function mydht.new(pin, socket, callback, interval)
    local self = setmetatable({}, mydht)
    self.pin = pin
    self.socket = socket
    self.callback = callback
    if interval == nil then interval = 1000*60 end

    if self.socket ~= nil then
        self.tmr = tmr.create()
        self.tmr:register(interval, tmr.ALARM_AUTO, function()
            local readings = mydht.get_readings(self)
            if readings['temp'] ~= nil then   
                if self.socket ~= nil then     
                    message = network_message.prepareMessage()            
                    message.event = "dht.status"
                    message.parameters = readings          
                    network_message.sendMessage(socket, message)
                end
                if self.callback ~= nil then
                    self.callback("dht.status", readings)
                end
            end
        end)
        self.tmr:start()    
    end        

    return self
end    

function mydht:get_readings()
    status, temp, humi, temp_dec, humi_dec = dht.read11(self.pin)
    if status ~= dht.OK then
        temp = nil
        humi = nil        
    end

    return {["temp"] = temp, ["humi"] = humi}
end
    
return mydht
