# Light detector

Module and handler for a light detector. Broadcasts two events: **detect.light** and **detect.dark**.
Response to event **state**

## worker

light = light_sensor(send_socket, 6, cb, 5000) - send_socket can be nil, 6 is a pin,  cb can be nil, 5000 (interval) can be omnited - default 1s,

## handler

light_sensor_handler(light, cb) - light required, cb can be null


## Sample message:

    {
        "chip_id":1084612,
        "protocol":"iot:1",
        "node":"node-kitchen",
        "targets":["ALL"],
        "event":"detect.light",
        "response":""
    }

## Read current state:

    {
        'protocol': 'iot:1',
        'node': 'computer',
        'chip_id': 'd45656b45afb58b1f0a46',
        'event': 'state',
        'targets': [
            'ALL'
        ]
    }
    
Response:
    
    {
        "chip_id":1084612,
        "protocol":"iot:1",
        "node":"node-kitchen",
        "targets":["ALL"],
        "event":"",
        "response":"detect.dark"
    }


## Sample code

In ths example sensor is wired to pin G2, no callback given, inteval 6s

        network_message = require "network_message"
        server_listener = require "server_listener"
        
        light_sensor = require "light_detector"
        light_sensor_handler = require "light_detector_handle"
        
        send_socket = net.createUDPSocket() 
        
        light = light_sensor(send_socket, 4, nil, 6000)
        light_handler = light_sensor_handler(light)
        
        -- add handlers to listener
        server_listener.add("light", light_handler)

        -- run server
        server_listener.start(PORT)


Worker callback:

        cb = function(event)
            print("event :"..event)
        end
        light = light_sensor(send_socket, 6, cb, 5000)

Handler callback:
        
        cb = function(event, par)
            print("event :"..event)
            print(par)
        end
        
        light_handler = light_sensor_handler(light, cb)
