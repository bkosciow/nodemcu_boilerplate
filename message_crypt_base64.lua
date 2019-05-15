local cryptor = {}
cryptor.name="message.base64"

cryptor.encrypt = function(message)
    ok, json = pcall(sjson.encode, message)     
    if ok then        
        b64 = encoder.toBase64(json)
        message["event"] = cryptor.name
        message["parameters"] = {b64}
        message["response" ] = ""
    end

    return message
end

cryptor.decrypt = function(message)    
    if type(message['parameters']) ~= 'table' or type(message['parameters'][1]) ~= "string" then
        print("decrypt check failed")
        return nil
    end    

    msg = encoder.fromBase64(message['parameters'][1])
    ok, json = pcall(sjson.decode, msg)
    if not ok or not network_message.validateMessage(json) then
        json = nil
    end
    
    return json
end

return cryptor