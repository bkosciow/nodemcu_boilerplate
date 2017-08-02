# Boilerplate for NodeMCU

more on [https://koscis.wordpress.com/tag/nodemcu-boilerplate/](https://koscis.wordpress.com/tag/nodemcu-boilerplate/)

# Core

- init.lua - run automatically
- parameters.lua - project configuration (AP login, password, protocol version)
- parameters-device.lua - this unit configuration (like node name)
- wifi-init.lua - WiFi connection and keep alive timer
- main.lua - main code for app
- network_message.lua = module to decode and validate network packet to JSON message 

## init.lua
This one is simple. Quick check for D1 / GPIO5 state. 
If it is connected we will abort app and if not we start wifi-init.lua. 

## parameters*
Remove *.dist.* 
In parameters.lua keep project variables like access points login, some pin mapping, global names. 
In parameters-device.lua some configuration that belongs to this node. Like its name or some id

## wifi-init
Idea is simple, check if we are already connected and if not we iterate over APs and we use timer to check status. 
After getting connection we launch main.lua and start keep-alive-timer.

I had few cases when net was gone and board didn't reconnect until rebooted. After few tries I ended with timer that checks connection and count failures in row. After reaching 10 or more it force unit reboot. Normally board would reconnect automatically before time is out.
In my case it was ok to reboot the device but keep in mind that may not be in yours.

If you want to use wifi-init with triled use file *wifi-init-triled.lua*. Remember to rename it.

## main
This file is main app start file. In boilerplate we will just turn on buildin led.

# Modules 

## network_message
Module to work with JSON messages. For communication between nodes I use JSON messages. Such message looks like this:
 
    {
        protocol: "iot:1",
        event: "channel1.on",
        node: "computer",
        chip_id: "some id",
        response: "some response"
        targets: [
           "big-room-support-light"
        ]
    } 

Fields *protocol*, *event* or *response* are required. Server also check if its node name is in *targets* table. If you want to send message to all
nodes set *targets: ['ALL']*.

Module functions: 

- decodeMessage(message) - decode and validate string into message. on fault returns nil
    [Sample](sample/network_message.decodeMessage.main.lua)

- prepareMessage() - returns table with set fields *protocol*, *node*, *chip_id*, *event=''*, *response=''*, *targets=['ALL']*
    [Sample](sample/network_message.prepareMessage.main.lua)

- sendMessage(socket, message) - message is a table, function convert it to json string and send to socket

## Event listener (runs handlers)
Module to handle events. It start its own UDP server, receive packet. Next it transform it into message and
pass to registered handlers. Each handler reacts on supported events by executing some actions on its worker. 

Handler is a module that understand message and can execute events.

        server_listener = require "server_listener"
        (...)
        -- add handlers to listener
        server_listener.add("lcd", lcd_handler)
        server_listener.add("thermometer", temp_handler)
        
        -- run server
        server_listener.start(PORT)


See handlers and events in modules/workers.

## Worker [lcd_hd44780](sample/lcd_hd44780.md) + handler
Module to utilize char display based on hd44870. Works with 16x1 up to 40x4

- Default wiring GPIO:

        drv.pins = {
            RS= 7,
            E1= 6,
            E2= nil,
            DB4= 5,
            DB5= 3,
            DB6= 1,
            DB7= 2,
        }

- Default i2c:

        drv.pins = {
            RS= 4,
            E1= 5,
            E2= nil,
            DB4= 0,
            DB5= 1,
            DB6= 2,
            DB7= 3,
        }

- use with default pins and 16x2 size, direct

        hd44780 = require("lcd_hd44780")
        driver = require("lcd_hd44780_gpio")  <-- GPIO
        driver = require("lcd_hd44780_i2c")  <-- I2C
        
        drv = driver()
        drv = driver(0x20, 4, 5) <--i2c & default pins
        
        pins = {
            RS= 4,
            E1= 5,
            E2= 6,
            DB4= 0,
            DB5= 1,
            DB6= 2,
            DB7= 3,
        }
        drv = driver(0x20, 4, 5, pins) <--i2c & set pins
        
        lcd = hd44780(16, 2, drv, 'direct', 1, 1)
        lcd:init()
        lcd:write('Zombicide')
        lcd:set_xy(0, 1)
        lcd:write('Black Plague')

- use with default pins and 40x4 size, buffered
        
        hd44780 = require("lcd_hd44780")
        drviver = require("lcd_hd44780_gpio")  <-- GPIO
        drviver = require("lcd_hd44780_i2c")  <-- I2C
        
        drv = i2c_driver(0x20, 4, 5, pins)
        lcd = hd44780(40, 4, drv, 'buffered', 1, 1)
        lcd:init()
        lcd:set_xy(0, 0)
        lcd:write("The cat")
        lcd:set_xy(0, 1)
        lcd:write("and meows")
        
        lcd:flush()
        lcd:set_xy(10, 0)
        lcd:write("purrs")
        
        lcd:flush()


[Read more](sample/lcd_hd44780.md)

## i2c_scan
 
Scans for I2C devices. Default SDA = D1 and SCL = D2. Usage:
 
        i2cscan = require "i2c_scan"
        i2cscan.scan()    
        
Want to use different pins, set them before scan:
            
        i2cscan.pins = {
            sda = 1,
            scl = 2
        }
        i2cscan.scan()
        
Output is similar to this:
        
             0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        00: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        20: 20 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
        70: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --    
        
        
## Worker 18b20 temperature sensor + handler
         
         pin = 3 -- 1-wire bus
         temp = require "18b20"
         print(temp.get_temperature()) 
         
[Read more](sample/18b20.md)
         
## Worker and handler for relays

Controls the relays. CHANNELS is a table with gpios that are used to enable relay signals.
          
        CHANNELS = {2, 3, 4, 1}
        relay_handler = require "relay_handler"
        handler = relay_handler(CHANNELS)

        -- add handlers to listener
        server_listener.add("relay", handler)
        
[Read more](sample/relay.md)        

          
## Worker and handler for PIR HCS-SR501
          
Motion detector
        
        pir = require "pir_hcs_sr501"
        pir_handler = require "pir_hcs_sr501_handler"
        send_socket = net.createUDPSocket() 
        sensor = pir(send_socket, 2)
        handler = pir_handler(sensor)
        server_listener.add("pir", handler) 

[Read more](sample/pir_hcssr501.md)  

## Worker and handler for light detector, without callback

        light_sensor = require "light_detector"
        light_sensor_handler = require "light_detector_handle"
        send_socket = net.createUDPSocket() 
        light = light_sensor(send_socket, 4, nil, 1600)
        light_handler = light_sensor_handler(light)
        server_listener.add("light", light_handler)
        
[Read more](sample/light_detector.md)      

## Worker and handler for DHT11

        dht11 = require "dht11"
        dht11_handler = require "dht11_handler"
        mydht = dht11(5)
        dht_handler = dht11_handler(mydht)
        server_listener.add("dht", dht_handler)
        
[Read more](sample/dht11.md)

## Worker for sound detector
        
        sd = require "sound_detector"
        gpio.mode(3, gpio.OUTPUT, gpio.PULLUP)
        gpio.write(3, gpio.HIGH)
        local bum = false
        
        sound_detector = sd(send_socket, 1, function(event)
            if bum then
                gpio.write(3, gpio.HIGH)
            else
                gpio.write(3, gpio.LOW)                
            end
            bum = not bum
        end) 
        
[Read more](sample/sound_detector.md)
        
## Triled module

Module to control triled or any other with common anode.
        
        triled = require "triled"

        triled.pin_red = 2
        triled.pin_green = 1
        triled.pin_blue = 8
        triled.init()
        
        triled.red(true)
        triled.blink_green(2)
        triled.blink_blue(3, true)

If you want to use wifi-init with triled use file *wifi-init-triled.lua*. Remember to rename it.

[Read more](sample/triled.md)

## RFID - RC522 module and handler

        rc522_handler = require "rc522_handler"
        rc522 = require "rc522"
        handler = rc522_handler(function(event, params)   
            if last ~= nil and params.id == last then
                print(params.id)
                print(params.response)
                last = ""
            end
        end) 
        rc522.pin_ss = RC522_PIN_SS
        rc522.pin_rst = RC522_PIN_RST
        rc522.init(function(cardid) 
            print("Tag Found: "..cardid)
        end) 

[Read more](sample/rc522.md)

