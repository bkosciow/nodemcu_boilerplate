local network_message = {}
network_message.validateMessage = function(json)                
    if json == nil or json['protocol'] ~= PROTOCOL or type(json['targets']) ~= 'table' then
        return false
     end    

     isTarget = false
     for k,v in pairs(json['targets']) do
        if v == NODE_ID or v == 'ALL' then isTarget = true end
     end

    return isTarget
end
    
network_message.decodeMessage = function(message)        
    ok, json = pcall(cjson.decode, message)
    if not ok or not network_message.validateMessage(json) then
        json = nil
    end
    
    return json
end

network_message.prepareMessage = function()
    data = {}
    data.protocol = PROTOCOL
    data.node = NODE_ID
    data.chip_id = node.chipid()
    data.event = ''
    data.response = ''
    data.targets = {'ALL'}

    return data
end

network_message.sendMessage = function(socket, message)
    ok, json = pcall(cjson.encode, message)
    if ok then
        print(json)        
        socket:send(json)  
        return true 
    end   
    
    return false
end    

return network_message    
