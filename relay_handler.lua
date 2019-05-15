local relay_handler = {}
relay_handler.__index = relay_handler

setmetatable(relay_handler, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function relay_handler.new(channels, callback)
    local self = setmetatable({}, relay_handler)
    self.channels = channels
    self.callback = callback
    relay_handler.init(self)
    return self
end    

function relay_handler:init()
    for k, v in pairs(self.channels) do
        gpio.mode(v, gpio.OUTPUT, gpio.PULLUP)
    end
end

function relay_handler:handle(socket, message)   
    response = false
    if message ~= nil and message.event ~= nil then
    
        if type(message['parameters']) == 'table' and message.parameters.channel ~= nil then
            channel = self.channels[message.parameters.channel + 1]
            if message.event == 'channel.on' and channel ~= nil then
                gpio.write(channel, gpio.LOW)
                response = true
                if self.callback ~= nil then
                    self.callback('channel.on', channel) 
                end
            end
            if message.event == 'channel.off' and channel ~= nil then
                gpio.write(channel, gpio.HIGH)
                response = true
                if self.callback ~= nil then
                    self.callback('channel.off', channel) 
                end
            end
        end
        if message.event == 'channel.states' then
            message = network_message.prepareMessage()
            states = {}
            for k,v in pairs(self.channels) do
                states[k] = gpio.read(v) == 0 and 1 or 0
            end    
            message.response = states
            message.event = "channels.response"
            network_message.sendMessage(socket, message)
            if self.callback ~= nil then
                self.callback('channel.states', states) 
            end
            response = true
        end
    end           
end
    
return relay_handler  
