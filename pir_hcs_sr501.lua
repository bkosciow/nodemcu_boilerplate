local PIRHCSR501 = {}
PIRHCSR501.__index = PIRHCSR501
PIRHCSR501.states = {
    "pir.nomovement",
    "pir.movement"
}

setmetatable(PIRHCSR501, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function PIRHCSR501.new(socket, pin, callback)
    local self = setmetatable({}, PIRHCSR501)
    self.pin = pin
    gpio.mode(self.pin, gpio.INT)
    self.movement = gpio.read(self.pin)
    self.socket = socket
    self.callback = callback

    local function alarm(level)                    
        self.movement = level
        if self.socket ~= nil then
            message = network_message.prepareMessage()
            message.event = PIRHCSR501.states[self.movement + 1]
            network_message.sendMessage(self.socket, message)     
        end
        if self.callback ~= nil then
            self.callback(PIRHCSR501.states[self.movement + 1])
        end
    end

    gpio.trig(self.pin, "both", alarm)
     
    return self
end

function PIRHCSR501:get_state()

    return PIRHCSR501.states[self.movement + 1]
end

return PIRHCSR501
