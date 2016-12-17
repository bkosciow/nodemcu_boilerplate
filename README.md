#Boilerplate for NodeMCU

more on [https://koscis.wordpress.com/tag/nodemcu-boilerplate/](https://koscis.wordpress.com/tag/nodemcu-boilerplate/)

- init.lua - run automatically
- parameters.lua - project configuration (AP login, password, protocol version)
- parameters-device.lua - this unit configuration (like node name)
- wifi-init.lua - WiFi connection and keep alive timer
- main.lua - main code for app
- network_message.lua = module to decode and validate network packet to JSON message 

#Core

##init.lua
This one is simple. Quick check for D1 / GPIO5 state. 
If it is connected we gonna abort app and if not we start wifi-init.lua. 

##parameters*
Remove *.dist.* 
In parameters.lua keep project variables like access point login, some pin mapping, global names. 
In parameters-device.lua some configuration that belongs to this node. Like its name or some id

##wifi-init
Idea is simple, check if we are already connected and if not use timer to check status. 
After getting connection we launch main.lua and start keep-alive-timer.

I had few cases when net was gone and board didn't reconnect until rebooted. After few tries I ended with timer that checks connection and count failures in row. After reaching 10 or more it force unit reboot. Normally board would reconnect automatically before time is out.
In my case it was ok to reboot the device but keep in mind that may not be in yours.
Drawback is that we are taking one timer.

##main
This file is main app start file. In boilerplate we will just turn on buildin led.

# Modules 

##network_message
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

Module gives two functions: 

- decodeMessage(message) - decode and validate string into message. on fault returns nil
    [Sample](sample/network_message.decodeMessage.main.lua)

- prepareMessage() - returns table with set fields *protocol*, *node*, *chip_id*, *event=''*, *response=''*, *targets=['ALL']*
    [Sample](sample/network_message.prepareMessage.main.lua)

##[lcd_hd44870](sample/lcd_hd44870.md)
Module to utilize char display based on hd44870. 

- Default wiring:

        lcd_hd44870.pins = {
            RS= 7,
            E1= 6,
            E2= nil,
            DB4= 5,
            DB5= 3,
            DB6= 1,
            DB7= 2,
        }

- initialize with default pins and 16x2 size, without cursor:

        lcd = require("lcd_hd44870")
        lcd.lcd(16, 2)
        lcd.init()

[Read more](sample/lcd_hd44870.md)