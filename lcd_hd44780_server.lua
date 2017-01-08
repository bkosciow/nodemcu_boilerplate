local server = {}
server.lcd = nil

network_message = require "network_message"

server.svr = net.createServer(net.UDP)
server.svr:on('receive', function(socket, message)
    message = network_message.decodeMessage(message)
    if message ~= nil and message.event ~= nil then
        print(message.event..", "..message.parameters.data..", "..message.parameters.enable)
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
--        if message.event == "state" then     
--            data = network_message.prepareMessage()
--            data.response = states[last_state]   
--            network_message.sendMessage(socket, data)                            
--        end
    end
end)  

server.svr:listen(PORT)

return server