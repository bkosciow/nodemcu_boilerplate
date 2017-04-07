gpio.mode(CHANNEL_0, gpio.OUTPUT, gpio.PULLUP)
gpio.mode(CHANNEL_1, gpio.OUTPUT, gpio.PULLUP)

svr = net.createServer(net.UDP)

svr:on("receive", function(socket, message)

    print ("in")
    network_message = require "network_message"
    
    message = network_message.decodeMessage(message)

    if message['event'] ~= nil then
        print(message['event'])
        if message['event'] == "channel1.on" then
            gpio.write(CHANNEL_0, gpio.LOW)
        elseif message['event'] == "channel2.on" then
            gpio.write(CHANNEL_1, gpio.LOW)
        elseif message['event'] == "channel1.off" then
            gpio.write(CHANNEL_0, gpio.HIGH)
        elseif message['event'] == "channel2.off" then
            gpio.write(CHANNEL_1, gpio.HIGH)
        end
    end
    
end)

svr:listen(5053)    

