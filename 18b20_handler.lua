local handler = {}

handler.node = nil
handler.round = nil

handler.handle = function (socket, message)
    response = false
    if message ~= nil and message.event ~= nil then
        if message.event == 'temperature.current' then
            r = handler.round
            if type(message['parameters']) == 'table' and type(message.parameters['round'] ~= nil)then
                r = message.parameters['round'] 
            end
            message = network_message.prepareMessage()
            message.response = handler.node.get_temperature(r)
            network_message.sendMessage(socket, message)
            response = true
        end 
    end

    return response
end

return handler