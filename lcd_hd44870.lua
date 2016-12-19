local lcd_hd44870 = {}

lcd_hd44870.width = 0
lcd_hd44870.height = 0
lcd_hd44870.x = 0
lcd_hd44870.y = 0
lcd_hd44870.cursor_blink = 0
lcd_hd44870.cursor_visible = 0
lcd_hd44870.mode = 'direct'

lcd_hd44870.lines = {
    0x80, 0xc0, 0x94, 0xd4
}
lcd_hd44870.pins = {
    RS= 7,
    E1= 6,
    E2= nil,
    DB4= 5,
    DB5= 3,
    DB6= 1,
    DB7= 2,
}

lcd_hd44870.buffered = function(width, height, pins)    
    lcd_hd44870.lcd(width, height, pins)   
    lcd_hd44870.mode = 'buffered'
    lcd_hd44870.buffer = {}
    lcd_hd44870.screen = {}   
    for x=0, lcd_hd44870.width-1 do
        lcd_hd44870.buffer[x] = {}
        lcd_hd44870.screen[x] = {}
        for y=0, lcd_hd44870.height-1 do
            lcd_hd44870.buffer[x][y] = " "
            lcd_hd44870.screen[x][y] = " "
        end        
    end 
end  
    
lcd_hd44870.lcd = function(width, height, pins)
    lcd_hd44870.width = width
    lcd_hd44870.height = height
    lcd_hd44870.mode = 'direct'
    if pins ~= nil then
        lcd_hd44870.pins = pins
    end
end

lcd_hd44870.init = function ()
    if lcd_hd44870.width == 0 or lcd_hd44870.height == 0 then
        print("Initialize via lcd(width, height, [pins]) or buffered(..)")
        return
    end
    
    for k,v in pairs(lcd_hd44870.pins) do 
        gpio.mode(v, gpio.OUTPUT)
        gpio.write(v, gpio.LOW)
    end

    lcd_hd44870._init_lcd()
end

lcd_hd44870._init_lcd = function()
    gpio.write(lcd_hd44870.pins['RS'], gpio.LOW)
    lcd_hd44870._write4(3)
    tmr.delay(50)
    lcd_hd44870._write4(3)
    tmr.delay(50)
    lcd_hd44870._write4(3)
    tmr.delay(50)    
    lcd_hd44870._write4(2)
    
    lcd_hd44870.command(0x28)
    lcd_hd44870.command(0x08)
    lcd_hd44870.command(0x01)
    lcd_hd44870.command(0x06)
    lcd_hd44870.command(12 + (2*lcd_hd44870.cursor_visible) + lcd_hd44870.cursor_blink)
end

lcd_hd44870._write4 = function(ch)
    if bit.isset(ch, 0) then gpio.write(lcd_hd44870.pins['DB4'], gpio.HIGH) else gpio.write(lcd_hd44870.pins['DB4'], gpio.LOW) end        
    if bit.isset(ch, 1) then gpio.write(lcd_hd44870.pins['DB5'], gpio.HIGH) else gpio.write(lcd_hd44870.pins['DB5'], gpio.LOW) end        
    if bit.isset(ch, 2) then gpio.write(lcd_hd44870.pins['DB6'], gpio.HIGH) else gpio.write(lcd_hd44870.pins['DB6'], gpio.LOW) end       
    if bit.isset(ch, 3) then gpio.write(lcd_hd44870.pins['DB7'], gpio.HIGH) else gpio.write(lcd_hd44870.pins['DB7'], gpio.LOW) end

    lcd_hd44870._send()
end

lcd_hd44870._write8 = function(ch)
    lcd_hd44870._write4(bit.rshift(ch, 4))
    lcd_hd44870._write4(bit.band(ch, 0x0F))
end

lcd_hd44870.command = function(ch)
    gpio.write(lcd_hd44870.pins['RS'], gpio.LOW)
    lcd_hd44870._write8(ch)
end

lcd_hd44870.write = function(chars)
    if lcd_hd44870.mode == 'direct' then lcd_hd44870._write_direct(chars) end
    if lcd_hd44870.mode == 'buffered' then lcd_hd44870._write_buffered(chars) end
end

lcd_hd44870._write_direct = function(chars)
    gpio.write(lcd_hd44870.pins['RS'], gpio.HIGH)
    for i = 1, #chars do
        lcd_hd44870._write8(chars:byte(i))        
    end
    lcd_hd44870.x =  lcd_hd44870.x + #chars
end

lcd_hd44870._write_buffered = function(chars)    
    for i = 1, #chars do
        lcd_hd44870.buffer[lcd_hd44870.x + i - 1][lcd_hd44870.y] = chars:sub(i,i)
    end
    lcd_hd44870.x = lcd_hd44870.x + #chars
end

lcd_hd44870.flush = function()    
    current_xy = lcd_hd44870.get_xy()

    last_x = -1
    last_y = -1
    for y=0, lcd_hd44870.height-1 do              
        for x=0, lcd_hd44870.width-1 do
            if lcd_hd44870.buffer[x][y] ~= lcd_hd44870.screen[x][y] then               
                if last_x + 1 ~= x or last_y ~=y then                   
                    lcd_hd44870.set_xy(x, y) 
                end
                last_x = x
                last_y = y               
                gpio.write(lcd_hd44870.pins['RS'], gpio.HIGH)                
                lcd_hd44870._write8(lcd_hd44870.buffer[x][y]:byte(1))
                lcd_hd44870.screen[x][y] = lcd_hd44870.buffer[x][y]
            end
        end
    end   

    lcd_hd44870.set_xy(current_xy['x'], current_xy['y'])
end

lcd_hd44870._send = function()
    gpio.write(lcd_hd44870.pins['E1'], gpio.HIGH)
    tmr.delay(5)
    gpio.write(lcd_hd44870.pins['E1'], gpio.LOW)
end

lcd_hd44870.set_xy = function(x, y)
    lcd_hd44870.command(lcd_hd44870.lines[y + 1] + x)     
    lcd_hd44870.x = x
    lcd_hd44870.y = y
end

lcd_hd44870.get_xy = function()
    return {
        x = lcd_hd44870.x, 
        y = lcd_hd44870.y
    }   
end

lcd_hd44870.clear = function() 
    if lcd_hd44870.mode == 'buffered' then
        for x=0, lcd_hd44870.width-1 do
            lcd_hd44870.buffer[x] = {}
            for y=0, lcd_hd44870.height-1 do
                lcd_hd44870.buffer[x][y] = " "
            end
        end 
    end        
end 

return lcd_hd44870