local light_detector = {}
light_detector.__index = light_detector
light_detector.states = {
    "detect.light", "detect.dark"
}

setmetatable(light_detector, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function light_detector.new(socket, pin, interval)
    local self = setmetatable({}, light_detector)
    self.pin = pin
    self.tmr = tmr.create()
    self.last_state = nil
    self.current_state = nil
    gpio.mode(pin, gpio.INT)
    if interval == nil then interval = 500 end

    self.tmr:register(interval, tmr.ALARM_AUTO, function()
        self.current_state = gpio.read(pin)
        if self.last_state ~= self.current_state then
            self.last_state = self.current_state           
            message = network_message.prepareMessage()            
            message.event = light_detector.states[self.current_state + 1]           
            network_message.sendMessage(socket, message)
        end
    end)
    self.tmr:start()
    
    return self
end    

function light_detector:get_state()
    return light_detector.states[self.current_state + 1]
end
    
return light_detector