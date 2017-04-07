local sound_sensor = {}
sound_sensor.__index = sound_sensor
sound_sensor.states = {
    "detect.sound",    
}

setmetatable(sound_sensor, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function sound_sensor.new(socket, pin, callback)
    local self = setmetatable({}, sound_sensor)
    self.pin = pin
    gpio.mode(self.pin, gpio.INT)   
    self.socket = socket
    self.callback = callback

    self.hold = false
    self.timer_reset = tmr.create()
    self.timer_reset:register(500, tmr.ALARM_SEMI, function()        
        self.hold = false
    end)

    local function alarm(level)           
        if (level == 1 and self.hold == false) then
            self.hold = true   
            print("PING "..level)
            if (self.socket ~= nil) then
                message = network_message.prepareMessage()
                message.event = sound_sensor.states[1]
                network_message.sendMessage(self.socket, message)     
            end
            if (self.callback) then
                self.callback(sound_sensor.states[1])
            end
            self.timer_reset:start()
        end
    end

    gpio.trig(self.pin, "up", alarm)
     
    return self
end

return sound_sensor