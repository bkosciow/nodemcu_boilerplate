local listener = {}

listener.handlers = {}
listener.svr = net.createServer(net.UDP)

listener.add = function(name, handler)
    listener.handlers[name] = handler
end

listener.start = function(port)
    listener.svr:on('receive', function(socket, message) 
        message = network_message.decodeMessage(message)
        if message ~= nil then
            for name, handler in pairs(listener.handlers) do   
                handler.handle(socket, message)                    
            end
        end      
    end)
    
    listener.svr:listen(port)
    print("server online")
end

return listener