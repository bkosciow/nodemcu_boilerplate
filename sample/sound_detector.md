# Sound detector

Module for a light detector. Broadcasts event: **detect.sound**

Constructor has 3 parameters. First is a socket, can e nil, second is pin, third is custom callback, can be nil.

## Sample message:

    {
        "chip_id":1084612,
        "protocol":"iot:1",
        "node":"node-kitchen",
        "targets":["ALL"],
        "event":"detect.sound",
        "response":""
    }

## Sample code

In ths example sensor is wired to pin G1. And callback is used to trigger G3

        network_message = require "network_message"
        server_listener = require "server_listener"
        
        sd = require "sound_detector"

        send_socket = net.createUDPSocket() 
        
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
