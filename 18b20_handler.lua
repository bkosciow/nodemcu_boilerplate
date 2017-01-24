local Temp18b20_handler = {}
Temp18b20_handler.__index = Temp18b20_handler

setmetatable(Temp18b20_handler, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function Temp18b20_handler.new(node, round)
    local self = setmetatable({}, Temp18b20_handler)
    self.node = node
    self.round = round
    return self
end    

function Temp18b20_handler:handle(socket, message)
    response = false
    if message ~= nil and message.event ~= nil then
        if message.event == 'temperature.current' then
            r = self.round
            if type(message['parameters']) == 'table' and type(message.parameters['round'] ~= nil)then
                r = message.parameters['round'] 
            end
            message = network_message.prepareMessage()
            message.response = self.node:get_temperature(r)
            network_message.sendMessage(socket, message)
            response = true
        end 
    end

    return response
end

return Temp18b20_handler
