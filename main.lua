print ("core ready")

network_message = require "network_message"

--i2c_driver = require("lcd_hd44780_i2c")
gpio_driver = require "lcd_hd44780_gpio"
hd44780 = require("lcd_hd44780")
--server_listener = require "server_listener"
--message_crypt_base64 = require "message_crypt_base64"
--hd44780_handler = require "lcd_hd44780_handler"

--network_message.encryptor = message_crypt_base64
--network_message.addDecryptor(message_crypt_base64)
--setup LCD
--pins = {
--    RS= 4,
--    E1= 5,
--    E2= 6,
--    DB4= 0,
--    DB5= 1,
--    DB6= 2,
--    DB7= 3,
--}

--drv = i2c_driver(0x20, 4, 5, pins)
drv = gpio_driver()
lcd = hd44780(16, 2, drv, 'buffered', 0, 0)
lcd:init()

--lcd:write('Zombicide!')
--lcd:flush()

--lcd.init()
lcd:set_xy(0, 0)
lcd:write("the cat")
lcd:set_xy(0, 1)
lcd:write("and meows")

lcd:flush()
lcd:set_xy(10, 0)
lcd:write("purrs")

lcd:flush()


--attach lcd to handler
--lcd_handler = hd44780_handler(lcd)

-- add handlers to listener
--server_listener.add("lcd", lcd_handler)

print("ok")

-- run server
--server_listener.start(PORT)
