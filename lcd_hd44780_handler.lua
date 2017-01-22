local handler = {}

handler.lcd = nil

handler.handle = function(socket, message)   
    response = false
    if message ~= nil and message.event ~= nil then        
        if message.event == 'lcd.cmd' then
            handler.lcd.drv.command(
                message.parameters.data,
                message.parameters.enable + 1
            )
            response = true
        end
        if message.event == 'lcd.char' then
            handler.lcd.drv.write(
                message.parameters.data,
                message.parameters.enable + 1
            )
            response = true
        end
        if message.event == 'lcd.content' then          
            for k,v in pairs(message.parameters.content) do
                handler.lcd.set_xy(0, k-1)
                handler.lcd.write(v)
            end
            if handler.lcd.mode == 'buffered' then
                handler.lcd.flush()
            end
            response = true
        end
    end

    return response
end


return handler;
