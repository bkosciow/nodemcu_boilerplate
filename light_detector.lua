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
    self.current_state = 0
    self.socket = socket
    gpio.mode(self.pin, gpio.INPUT)
    if interval == nil then interval = 1000 end

    self.tmr:register(interval, tmr.ALARM_AUTO, function()
        self.current_state = gpio.read(self.pin)
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
