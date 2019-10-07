local relay_handler = {}
relay_handler.__index = relay_handler

setmetatable(relay_handler, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function relay_handler.new(channels, broadcast_changes, callback)
    local self = setmetatable({}, relay_handler)
    self.channels = channels
    self.callback = callback
    self.broadcast_changes = broadcast_changes
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
                if (self.broadcast_changes ~= nil) then
                    relay_handler.send_response(self, socket)
                end
                if self.callback ~= nil then
                    self.callback('channel.on', channel) 
                end
            end
            if message.event == 'channel.off' and channel ~= nil then
                gpio.write(channel, gpio.HIGH)
                response = true
                if (self.broadcast_changes ~= nil) then
                    relay_handler.send_response(self, socket)
                end
                if self.callback ~= nil then
                    self.callback('channel.off', channel) 
                end
            end
        end
                
        if message.event == 'channel.states' then
            relay_handler.init(self, socket)
            if self.callback ~= nil then
                self.callback('channel.states', states) 
            end
            response = true
        end
    end           
end

function relay_handler:toggle(socket, channel)
    states = relay_handler.get_states(self)
    if states[channel] == 1 then
        gpio.write(channel, gpio.HIGH)
    else
        gpio.write(channel, gpio.LOW)
    end
    if (self.broadcast_changes ~= nil) then
        relay_handler.send_response(self, socket)
    end
    
end

function relay_handler:get_states()
    states = {}
    for k,v in pairs(self.channels) do
        states[k] = gpio.read(v) == 0 and 1 or 0
    end 

    return states
end

function relay_handler:send_response(socket)

    message = network_message.prepareMessage()
    states = relay_handler.get_states(self)
        
    message.response = states
    message.event = "channels.response"
    network_message.sendMessage(socket, message)
end    

return relay_handler  
