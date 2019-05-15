local network_message = {}
network_message.encryptor = nil
network_message.decryptors = {}

network_message.addDecryptor = function(decryptor)        
    network_message.decryptors[decryptor.name] = decryptor
end
            
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
    json = network_message.decrypt(message)
    
    return json
end

network_message.decrypt = function(message)
    ok, json = pcall(sjson.decode, message)
    if not ok or not network_message.validateMessage(json) then
        json = nil
    else
        if json["event"]:len() > 8 and json['event']:sub(0, 8) == "message." then
            print ("enrypted via "..json['event'])
            if network_message.decryptors[json['event']] ~= nil then
                json = network_message.decryptors[json['event']].decrypt(json)                
            else
                print("decoder not found")
                json = nil
            end
        elseif not PROTOCOL_ALLOW_UNENCRYPTED then
            print("unencrypted message dropped")
            json = nil
        end
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

network_message.sendMessage = function(socket, message, port, ip)
    json = network_message.encrypt(message)
    if json then
        print(json)        
        if port == nil then port = PORT end
        if ip == nil then ip =  wifi.sta.getbroadcast() end        
        socket:send(port, ip, json)  
        return true 
    end   
    
    return false
end    

network_message.encrypt = function(message)
    if network_message.encryptor then
        message = network_message.encryptor.encrypt(message)
    end
    ok, json = pcall(sjson.encode, message) 
    if ok then        
        return json
    end

    return nil
end

return network_message    
