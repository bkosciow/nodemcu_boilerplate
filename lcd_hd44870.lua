local lcd_hd44870 = {}

lcd_hd44870.width = 0
lcd_hd44870.height = 0
lcd_hd44870.x = 0
lcd_hd44870.y = 0
lcd_hd44870.cursor_blink = 0
lcd_hd44870.cursor_visible = 0

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

lcd_hd44870.lcd = function(width, height, pins)
    lcd_hd44870.width = width
    lcd_hd44870.height = height
    if pins ~= nil then
        lcd_hd44870.pins = pins
    end
end

lcd_hd44870.init = function ()
    if lcd_hd44870.width == 0 or lcd_hd44870.height == 0 then
        print("Initialize via lcd(width, height, [pins])")
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

lcd_hd44870.write = function(string)
    gpio.write(lcd_hd44870.pins['RS'], gpio.HIGH)
    for i = 1, #string do
        lcd_hd44870._write8(string:byte(i))        
    end
    lcd_hd44870.x =  lcd_hd44870.x + #string
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

return lcd_hd44870
