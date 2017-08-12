local RC522 = {}
RC522.__index = RC522
RC522.mode_idle = 0x00
RC522.mode_auth = 0x0E
RC522.mode_transrec = 0x0C
RC522.mode_reset = 0x0F
RC522.mode_crc = 0x03
RC522.act_anticl = 0x93
RC522.reg_tx_control = 0x14
RC522.length = 16
RC522.num_write = 0
RC522.pin_ss = nil
RC522.pin_rst = nil
RC522.rc_timer = tmr.create()
RC522.last = ''
function RC522.dev_write(address, value)
    gpio.write(RC522.pin_ss, gpio.LOW)
    RC522.num_write = spi.send(1, bit.band(bit.lshift(address,1), 0x7E), value)
    gpio.write(RC522.pin_ss, gpio.HIGH)
end
function RC522.appendHex(t)
  strT = ""
  for i,v in ipairs(t) do
    strT = strT..string.format("%X", t[i])
  end
  return strT
end

function RC522.dev_read(address)
    local val = 0;
    gpio.write(RC522.pin_ss, gpio.LOW)
    spi.send(1,bit.bor(bit.band(bit.lshift(address,1), 0x7E), 0x80))
    val = spi.recv(1,1)
    gpio.write(RC522.pin_ss, gpio.HIGH)
    return string.byte(val)
end

function RC522.set_bitmask(address, mask)
    local current = RC522.dev_read(address)
    RC522.dev_write(address, bit.bor(current, mask))
end

function RC522.clear_bitmask(address, mask)
    local current = RC522.dev_read(address)
    RC522.dev_write(address, bit.band(current, bit.bnot(mask)))
end

function RC522.getFirmwareVersion()
  return RC522.dev_read(0x37)
end

function RC522.request()
    req_mode = { 0x26 }
    err = true
    back_bits = 0
    RC522.dev_write(0x0D, 0x07)
    err, back_data, back_bits = RC522.card_write(RC522.mode_transrec, req_mode)
    if err or (back_bits ~= 0x10) then
        return false, nil
     end
    return true, back_data
end

function RC522.card_write(command, data)
    back_data = {}
    back_length = 0
    local err = false
    local irq = 0x00
    local irq_wait = 0x00
    local last_bits = 0
    n = 0
    if command == RC522.mode_auth then
        irq = 0x12
        irq_wait = 0x10
    end   
    if command == RC522.mode_transrec then
        irq = 0x77
        irq_wait = 0x30
    end
    RC522.dev_write(0x02, bit.bor(irq, 0x80))
    RC522.clear_bitmask(0x04, 0x80) 
    RC522.set_bitmask(0x0A, 0x80) 
    RC522.dev_write(0x01, RC522.mode_idle)
    for i,v in ipairs(data) do
        RC522.dev_write(0x09, data[i])
    end
    RC522.dev_write(0x01, command)
    if command == RC522.mode_transrec then
        RC522.set_bitmask(0x0D, 0x80)
    end
    i = 25
    while true do
        tmr.delay(1)
        n = RC522.dev_read(0x04)
        i = i - 1
        if  not ((i ~= 0) and (bit.band(n, 0x01) == 0) and (bit.band(n, irq_wait) == 0)) then
            break
        end
    end    
    RC522.clear_bitmask(0x0D, 0x80)
    if (i ~= 0) then
        if bit.band(RC522.dev_read(0x06), 0x1B) == 0x00 then
            err = false            
            if (command == RC522.mode_transrec) then
                n = RC522.dev_read(0x0A)
                last_bits = bit.band(RC522.dev_read(0x0C),0x07)
                if last_bits ~= 0 then
                    back_length = (n - 1) * 8 + last_bits
                else
                    back_length = n * 8
                end
                if (n == 0) then
                    n = 1
                end 
                if (n > RC522.length) then
                    n = RC522.length
                end                
                for i=1, n do
                    xx = RC522.dev_read(0x09)
                    back_data[i] = xx
                end
              end
        else
            err = true
        end
    end
    return  err, back_data, back_length 
end

function RC522.anticoll()
    back_data = {}
    serial_number = {}
    serial_number_check = 0    
    RC522.dev_write(0x0D, 0x00)
    serial_number[1] = RC522.act_anticl
    serial_number[2] = 0x20
    err, back_data, back_bits = RC522.card_write(RC522.mode_transrec, serial_number)
    if not err then
        if table.maxn(back_data) == 5 then
            for i, v in ipairs(back_data) do
                serial_number_check = bit.bxor(serial_number_check, back_data[i])
            end           
            if serial_number_check ~= back_data[4] then
                err = true
            end
        else
            err = true
        end
    end   
    return error, back_data
end 

function RC522.calculate_crc(data)
    RC522.clear_bitmask(0x05, 0x04)
    RC522.set_bitmask(0x0A, 0x80)
    for i,v in ipairs(data) do
        RC522.dev_write(0x09, data[i])
    end    
    RC522.dev_write(0x01, RC522.mode_crc)
    i = 255
    while true do
        n = RC522.dev_read(0x05)
        i = i - 1
        if not ((i ~= 0) and not bit.band(n,0x04)) then
            break
        end
    end
    ret_data = {}
    ret_data[1] = RC522.dev_read(0x22)
    ret_data[2] = RC522.dev_read(0x21)
    return ret_data
end

function RC522.init(callback)
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
    gpio.mode(RC522.pin_rst,gpio.OUTPUT)
    gpio.mode(RC522.pin_ss,gpio.OUTPUT)
    gpio.write(RC522.pin_rst, gpio.HIGH) 
    gpio.write(RC522.pin_ss, gpio.HIGH)
    RC522.dev_write(0x01, RC522.mode_reset)
    RC522.dev_write(0x2A, 0x8D)
    RC522.dev_write(0x2B, 0x3E)
    RC522.dev_write(0x2D, 30)
    RC522.dev_write(0x2C, 0)
    RC522.dev_write(0x15, 0x40)
    RC522.dev_write(0x11, 0x3D)
    current = RC522.dev_read(RC522.reg_tx_control)
    if bit.bnot(bit.band(current, 0x03)) then
        RC522.set_bitmask(RC522.reg_tx_control, 0x03)
    end
    print("RC522 Firmware Version: 0x"..string.format("%X", RC522.getFirmwareVersion()))
    RC522.rc_timer:register(100, tmr.ALARM_AUTO, function()
        isTagNear, cardType = RC522.request()
        if isTagNear == true then
            RC522.rc_timer:stop()
            err, serialNo = RC522.anticoll()
            serialNo = RC522.appendHex(serialNo)
            if RC522.last == "" and serialNo:len() > 9 then
                message = network_message.prepareMessage() 
                message.event = 'rc522.read'
                message.parameters = {['id'] = serialNo}
                network_message.sendMessage(send_socket, message)
                RC522.last = serialNo
                if callback ~= nil then callback(serialNo) else RC522.last="" end
            end 
            buf = {}
            buf[1] = 0x50 
            buf[2] = 0
            crc = RC522.calculate_crc(buf)
            table.insert(buf, crc[1])
            table.insert(buf, crc[2])
            err, back_data, back_length = RC522.card_write(rc522.mode_transrec, buf)
            RC522.clear_bitmask(0x08, 0x08)
            RC522.rc_timer:start()
        end
    end)
    RC522.rc_timer:start()
end

return RC522
