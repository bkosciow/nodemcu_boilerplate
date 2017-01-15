local lcd_hd44870 = {}

lcd_hd44870.width = 0
lcd_hd44870.height = 0
lcd_hd44870.x = 0
lcd_hd44870.y = 0
lcd_hd44870.cursor_blink = 0
lcd_hd44870.cursor_visible = 0
lcd_hd44870.mode = 'direct'
lcd_hd44870.drv = nil

lcd_hd44870.lines = {
    0x80, 0xc0, 0x94, 0xd4
}

lcd_hd44870.buffered = function(drv, width, height)    
    lcd_hd44870.lcd(drv, width, height, pins)   
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
    
lcd_hd44870.lcd = function(drv, width, height)
    lcd_hd44870.width = width
    lcd_hd44870.drv = drv
    lcd_hd44870.height = height
    lcd_hd44870.mode = 'direct'
    
end

lcd_hd44870.init = function ()
    if lcd_hd44870.width == 0 or lcd_hd44870.height == 0 then
        print("Initialize via lcd(width, height, [pins]) or buffered(..)")
        return
    end    
    lcd_hd44870.drv.init()      
    lcd_hd44870._init_lcd(1)
    if lcd_hd44870.has_two_e() then lcd_hd44870._init_lcd(2) end 
end

lcd_hd44870._init_lcd = function(enable)
    lcd_hd44870.drv.command4(3, enable)
    tmr.delay(50)
    lcd_hd44870.drv.command4(3, enable)
    tmr.delay(50)
    lcd_hd44870.drv.command4(3, enable)
    tmr.delay(50)    
    lcd_hd44870.drv.command4(2, enable)
    
    lcd_hd44870.drv.command(0x28, enable)
    lcd_hd44870.drv.command(0x08, enable)
    lcd_hd44870.drv.command(0x01, enable)
    lcd_hd44870.drv.command(0x06, enable)
    lcd_hd44870.drv.command(12 + (2*lcd_hd44870.cursor_visible) + lcd_hd44870.cursor_blink, enable)
end

lcd_hd44870._get_line_addr = function(line)
    if line < 2 or lcd_hd44870.has_two_e() == false then
        return lcd_hd44870.lines[line + 1]
    else
        return lcd_hd44870.lines[line - 1]
    end
end

lcd_hd44870._add_x = function(len)
    lcd_hd44870.x =  lcd_hd44870.x + 1
    if lcd_hd44870.x >= lcd_hd44870.width then
        lcd_hd44870.y = lcd_hd44870.y + 1
        lcd_hd44870.x = 0
        if lcd_hd44870.y >= lcd_hd44870.height then lcd_hd44870.y = 0 end        
        lcd_hd44870.drv.command(lcd_hd44870._get_line_addr(lcd_hd44870.y), lcd_hd44870.detect_e())
    end
end

lcd_hd44870.write = function(chars)
    if lcd_hd44870.mode == 'direct' then 
        for i = 1, #chars do
            lcd_hd44870.drv.write(chars:sub(i,i), lcd_hd44870.detect_e()) 
            lcd_hd44870._add_x(1)
        end
    end
    if lcd_hd44870.mode == 'buffered' then lcd_hd44870._write_buffered(chars) end
end

lcd_hd44870._write_buffered = function(chars)    
    for i = 1, #chars do
        lcd_hd44870.buffer[lcd_hd44870.x + i - 1][lcd_hd44870.y] = chars:sub(i,i)
    end
    lcd_hd44870.x = lcd_hd44870.x + #chars
end

lcd_hd44870.flush = function()    
    if lcd_hd44870.mode == 'direct' then 
        print("Wrong mode for flush!")
    end
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
                lcd_hd44870.drv.write(lcd_hd44870.buffer[x][y]:sub(1,1), lcd_hd44870.detect_e())
                lcd_hd44870.screen[x][y] = lcd_hd44870.buffer[x][y]
            end
        end
    end   

    lcd_hd44870.set_xy(current_xy['x'], current_xy['y'])
end

lcd_hd44870.set_xy = function(x, y)    
    lcd_hd44870.x = x
    lcd_hd44870.y = y
    lcd_hd44870.drv.command(lcd_hd44870._get_line_addr(y) + x, lcd_hd44870.detect_e())         
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

lcd_hd44870.detect_e = function()
    if lcd_hd44870.has_two_e() and lcd_hd44870.y > 1 then return 2 else return 1 end    
end

lcd_hd44870.has_two_e = function()
    if lcd_hd44870.width >= 40 and lcd_hd44870.height >= 3 then
        return true
    else
        return false
    end   
end

return lcd_hd44870
