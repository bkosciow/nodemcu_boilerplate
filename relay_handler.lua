local relay_handler = {}
relay_handler.__index = relay_handler

setmetatable(relay_handler, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function relay_handler.new(channels)
    local self = setmetatable({}, relay_handler)
    self.channels = channels
    relay_handler.init(self)
    return self
end    

function relay_handler:init()
    for k, v in pairs(self.channels) do
        gpio.mode(v, gpio.OUTPUT, gpio.PULLUP)
    end
end

function relay_handler:handle(socket, message, port, ip)
    response = false
    if message ~= nil and message.event ~= nil and type(message['parameters']) == 'table' and message.parameters.channel ~= nil then
        channel = self.channels[message.parameters.channel + 1]
        if message.event == 'channel.on' and channel ~= nil then
            gpio.write(channel, gpio.LOW)
            response = true
        end
        if message.event == 'channel.off' and channel ~= nil then
            gpio.write(channel, gpio.HIGH)
            response = true
        end
        if message.event == 'channel.states' then
            message = network_message.prepareMessage()
            states = {}
            for k,v in pairs(self.channels) do
                states[k] = gpio.read(v) == 0 and 1 or 0
            end    
            message.response = states
            network_message.sendMessage(socket, message, port, ip)
            response = true
        end
    end           
end
    
return relay_handler  