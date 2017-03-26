local PIRHCSR501 = {}
PIRHCSR501.__index = PIRHCSR501

setmetatable(PIRHCSR501, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function PIRHCSR501.new(socket, pin, interval)
    local self = setmetatable({}, PIRHCSR501)
    self.pin = pin
    gpio.mode(pin, gpio.INT)
    self.tmr = tmr.create()
    self.movement = false
    if interval == nil then interval = 2000 end

    self.tmr:register(interval, tmr.ALARM_AUTO, function()
        if not self.movement then
            self.movement = true
            message = network_message.prepareMessage()            
            message.event = "pir.movement"           
            network_message.sendMessage(socket, message)
        end
    end)
    self.tmr:start()
    
    local function alarm(level)        
        if self.movement then
            self.movement = false
            message = network_message.prepareMessage()
            message.event = "pir.nomovement"
            network_message.sendMessage(socket, message)
        end
        self.tmr:stop()
        self.tmr:start()
    end

    gpio.trig(pin, "both", alarm)
    
    return self
end

function PIRHCSR501:get_state()

    return self.movement
end

return PIRHCSR501