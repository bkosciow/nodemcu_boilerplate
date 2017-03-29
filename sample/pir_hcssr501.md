# PIR HCS SR 501

Module and handler for motion detector. Broadcasts two events: **pir.movement** and **pir.nomovement**.
Response to event **pir.move**

## Sample message:

    {
        "chip_id":1084612,
        "protocol":"iot:1",
        "node":"node-kitchen",
        "targets":["ALL"],
        "event":"pir.movement",
        "response":""
    }

## Read current state:

    {
        'protocol': 'iot:1',
        'node': 'computer',
        'chip_id': 'd45656b45afb58b1f0a46',
        'event': 'pir.move',
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
        "response":false
    }


## Sample code

In ths example sensor is wired to pin G3

        network_message = require "network_message"
        server_listener = require "server_listener"
        
        pir = require "pir_hcs_sr501"
        pir_handler = require "pir_hcs_sr501_handler"
        
        send_socket = net.createConnection(net.UDP, 0)
        
        sensor = pir(send_socket, 2) -- 2 is a pin no
        handler = pir_handler(sensor)
        
        -- add handlers to listener
        server_listener.add("pir", handler)

        -- run server
        server_listener.start(PORT)