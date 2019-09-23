local cryptor = {}
cryptor.name="message.aessha1"
cryptor.algorithm = "AES-CBC"
cryptor.encrypt = function(message)
    ok, json = pcall(sjson.encode, message)     
    if ok then        
        half1 = node.random(4294967295)
        half2 = node.random(4294967295)
        I = string.format('%8x', half1)
        V = string.format('%8x', half2)
        iv = I..V

        encrypted_iv = crypto.encrypt(cryptor.algorithm, ENCODER_AESSHA1_IVKEY, iv, ENCODER_AESSHA1_STATICIV)
        encrypted_data = crypto.encrypt(cryptor.algorithm, ENCODER_AESSHA1_DATAKEY, json, iv)
        hash = crypto.toHex(crypto.hmac('sha1', iv..json, ENCODER_AESSHA1_PASSPHRASE)) 
        message["event"] = cryptor.name
        message["parameters"] = {
            crypto.toHex(encrypted_iv), 
            crypto.toHex(encrypted_data), 
            hash
        }
        message["response" ] = ""
    end

    return message
end

cryptor.decrypt = function(message)    
    if type(message['parameters']) ~= 'table' or type(message['parameters'][1]) ~= "string" then
        print("decrypt check failed")
        return nil
    end    

    encrypted_iv = message['parameters'][1]
    encrypted_data = message['parameters'][2]
    hash = message['parameters'][3]
    
    iv = crypto.decrypt(cryptor.algorithm, ENCODER_AESSHA1_IVKEY, encoder.fromHex(encrypted_iv), ENCODER_AESSHA1_STATICIV)
    data = crypto.decrypt(cryptor.algorithm, ENCODER_AESSHA1_DATAKEY, encoder.fromHex(encrypted_data), iv)
    data = data:gsub("%z","")
    calculated_hash = crypto.toHex(crypto.hmac('sha1', iv..data, ENCODER_AESSHA1_PASSPHRASE))
    if calculated_hash ~= hash then
        print("hmac missmatch")
        return nil
    end
    ok, json = pcall(sjson.decode, data)
    if not ok or not network_message.validateMessage(json) then
        json = nil
    end
    
    return json
end

return cryptor
