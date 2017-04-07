local light_detector_handler = {}
light_detector_handler.__index = light_detector_handler

setmetatable(light_detector_handler, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function light_detector_handler.new(node)
    local self = setmetatable({}, light_detector_handler)
    self.node = node
   
    return self
end   

function light_detector_handler:handle(socket, message)
    response = false
    if message ~= nil and message.event ~= nil then
        if message.event == 'light.state' then
            message = network_message.prepareMessage()
            message.response = self.node:get_state()
            network_message.sendMessage(socket, message)
            response = true

        end
    end

    return response
end

return light_detector_handler