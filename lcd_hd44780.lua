local lcd_hd44780 = {}

lcd_hd44780.__index = lcd_hd44780
lcd_hd44780.lines = {
    0x80, 0xc0, 0x94, 0xd4
}

setmetatable(lcd_hd44780, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function lcd_hd44780.new(width, height, drv, mode, cursor_blink, cursor_visible)
    local self = setmetatable({}, lcd_hd44780)
    self.width = width
    self.height = height
    self.x = 0
    self.y = 0
    self.cursor_blink = cursor_blink
    self.cursor_visible = cursor_visible
    self.drv = drv
    self.mode = mode    
    return self
end    

function lcd_hd44780:buffered()
    self.buffer = {}
    self.screen = {}   
    for x=0, self.width-1 do
        self.buffer[x] = {}
        self.screen[x] = {}
        for y=0, self.height-1 do
            self.buffer[x][y] = " "
            self.screen[x][y] = " "
        end        
    end 
end  

function lcd_hd44780:init()
    if self.width == 0 or self.height == 0 then
        print("Initialize via lcd(width, height, [pins]) or buffered(..)")
        return
    end    
    if self.mode == 'buffered' then lcd_hd44780.buffered(self) end
    self.drv:init()      
    lcd_hd44780._init_lcd(self, 1)
    if lcd_hd44780.has_two_e(self) then lcd_hd44780._init_lcd(self, 2) end 
end

function lcd_hd44780:_init_lcd(enable)
    self.drv:command4(3, enable)
    tmr.delay(50)
    self.drv:command4(3, enable)
    tmr.delay(50)
    self.drv:command4(3, enable)
    tmr.delay(50)    
    self.drv:command4(2, enable)
    
    self.drv:command(0x28, enable)
    self.drv:command(0x08, enable)
    self.drv:command(0x01, enable)
    self.drv:command(0x06, enable)
    self.drv:command(12 + (2*self.cursor_visible) + self.cursor_blink, enable)
end

function lcd_hd44780:_get_line_addr(line)
    if line < 2 or lcd_hd44780.has_two_e(self) == false then
        return self.lines[line + 1]
    else
        return self.lines[line - 1]
    end
end

function lcd_hd44780:_add_x(len)
    self.x =  self.x + 1
    if self.x >= self.width then
        self.y = self.y + 1
        self.x = 0
        if self.y >= self.height then self.y = 0 end        
        self.drv:command(lcd_hd44780._get_line_addr(self, self.y), lcd_hd44780.detect_e(self))
    end
end

function lcd_hd44780:write(chars)
    if self.mode == 'direct' then 
        for i = 1, #chars do
            self.drv:write(chars:sub(i,i), lcd_hd44780.detect_e(self)) 
            lcd_hd44780._add_x(self, 1)
        end
    end
    if self.mode == 'buffered' then lcd_hd44780._write_buffered(self, chars) end
end

function lcd_hd44780:_write_buffered(chars)    
    for i = 1, #chars do
        self.buffer[self.x + i - 1][self.y] = chars:sub(i,i)
    end
    self.x = self.x + #chars
end

function lcd_hd44780:flush()    
    if self.mode == 'direct' then 
        print("Wrong mode for flush!")
    end
    current_xy = lcd_hd44780.get_xy(self)
    last_x = -1
    last_y = -1
    for y=0, self.height-1 do              
        for x=0, self.width-1 do
            if self.buffer[x][y] ~= self.screen[x][y] then               
                if last_x + 1 ~= x or last_y ~=y then                   
                    lcd_hd44780.set_xy(self, x, y) 
                end
                last_x = x
                last_y = y               
                self.drv:write(self.buffer[x][y]:sub(1,1), lcd_hd44780.detect_e(self))
                self.screen[x][y] = self.buffer[x][y]
            end
        end
    end   

    lcd_hd44780.set_xy(self, current_xy['x'], current_xy['y'])
end

function lcd_hd44780:set_xy(x, y)    
    self.x = x
    self.y = y
    self.drv:command(lcd_hd44780._get_line_addr(self, y) + x, lcd_hd44780.detect_e(self))
end

function lcd_hd44780:get_xy()
    return {
        x = self.x, 
        y = self.y
    }   
end

function lcd_hd44780:clear() 
    if self.mode == 'buffered' then
        for x=0, self.width-1 do
            self.buffer[x] = {}
            for y=0, self.height-1 do
                self.buffer[x][y] = " "
            end
        end 
    else
		drv:command(0x01, lcd_hd44780.detect_e(self))
		self.x = 0
		self.y = 0
	end
end 

function lcd_hd44780:detect_e()
    if lcd_hd44780.has_two_e(self) and self.y > 1 then return 2 else return 1 end    
end

function lcd_hd44780:has_two_e()
    if self.width >= 40 and self.height >= 3 then
        return true
    else
        return false
    end   
end

return lcd_hd44780
