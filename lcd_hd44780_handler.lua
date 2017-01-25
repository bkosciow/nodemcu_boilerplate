local hd44780_handler = {}
hd44780_handler.__index = hd44780_handler

setmetatable(hd44780_handler, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function hd44780_handler.new(lcd)
    local self = setmetatable({}, hd44780_handler)
    self.lcd = lcd
    return self
end   

function hd44780_handler:handle(socket, message)   
    response = false
    if message ~= nil and message.event ~= nil then        
        if message.event == 'lcd.cmd' then
            self.lcd.drv:command(
                message.parameters.data,
                message.parameters.enable + 1
            )
            response = true
        end
        if message.event == 'lcd.char' then
            self.lcd.drv:write(
                message.parameters.data,
                message.parameters.enable + 1
            )
            response = true
        end
        if message.event == 'lcd.content' then          
            for k,v in pairs(message.parameters.content) do
                self.lcd:set_xy(0, k-1)
                self.lcd:write(v)
            end
            if self.lcd.mode == 'buffered' then
                self.lcd:flush()
            end
            response = true
        end
    end

    return response
end


return hd44780_handler;
