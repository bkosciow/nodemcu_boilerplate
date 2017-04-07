# Light detector

Module and handler for a light detector. Broadcasts two events: **detect.light** and **detect.dark**.
Response to event **state**

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

In ths example sensor is wired to pin G2

        network_message = require "network_message"
        server_listener = require "server_listener"
        
        light_sensor = require "light_detector"
        light_sensor_handler = require "light_detector_handle"
        
        send_socket = net.createConnection(net.UDP, 0)
        
        light = light_sensor(send_socket, 4, 600)
        light_handler = light_sensor_handler(light)
        
        -- add handlers to listener
        server_listener.add("light", light_handler)

        -- run server
        server_listener.start(PORT)
