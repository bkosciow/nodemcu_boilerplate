local scanner = {}

scanner.pins = {
    sda = 1,
    scl = 2
}

scanner.port = 0

scanner.scan = function()
    print("     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f")    
    i2c.setup(scanner.port, scanner.pins['sda'], scanner.pins['scl'], i2c.SLOW)    
    for addr = 0, 127 do        
        if addr == 0 or addr % 16 == 0 then
            if addr ~= 0 then print(row) end
            row = string.format("%02X", addr)..": "
        end        
        i2c.start(scanner.port)
        c = i2c.address(scanner.port, addr, i2c.TRANSMITTER)
        i2c.stop(scanner.port)
        if c == true then
            row = row..string.format("%02X", addr).." "
        else
            row = row.."-- "
        end
    end
    print(row)
end

return scanner