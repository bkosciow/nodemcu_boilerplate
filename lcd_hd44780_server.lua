local server = {}
server.lcd = nil

network_message = require "network_message"

server.svr = net.createServer(net.UDP)
server.svr:on('receive', function(socket, message)
    message = network_message.decodeMessage(message)
    if message ~= nil and message.event ~= nil then        
        if message.event == 'lcd.cmd' then
            server.lcd.drv.command(
                message.parameters.data,
                message.parameters.enable + 1
            )
        end
        if message.event == 'lcd.char' then
            server.lcd.drv.write(
                message.parameters.data,
                message.parameters.enable + 1
            )
        end
        if message.event == 'lcd.content' then            
            for k,v in pairs(message.parameters.content) do
                server.lcd.set_xy(0, k-1)
                server.lcd.write(v)
            end
            if server.lcd.mode == 'buffered' then
                server.lcd.flush()
            end
        end

    end
end)  

server.svr:listen(PORT)

return server
