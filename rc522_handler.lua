local rc522_handler = {}
rc522_handler.__index = rc522_handler

setmetatable(rc522_handler, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function rc522_handler.new(callback)
    local self = setmetatable({}, rc522_handler)    
    self.callback = callback
    return self
end   

function rc522_handler:handle(socket, message)
    response = false
    if message ~= nil and message.event ~= nil then
        if message.event == 'rc522.response' then
            if self.callback ~= nil then
                self.callback('lrc522.response', message.parameters)
            end
            response = true
        end
    end

    return response
end

return rc522_handler 
