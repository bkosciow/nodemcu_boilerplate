# DHT 11

Responds for event **dht.readings** with humidity and temperature.

May broadcast **dht.status** if socket is set.

## Sample message broadcasted periodically 

    {
        "chip_id":1084612,
        "protocol":"iot:1",
        "node":"node-kitchen",
        "parameters":{
            "humi":33,
            "temp":24
        },
        "targets":["ALL"],
        "event":"dht.status",
        "response":""
    }

## Ask for data

    {
        'protocol': 'iot:1',
        'node': 'computer',
        'chip_id': 'd45656b45afb58b1f0a46',
        'event': 'dht.readings',
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
        "response":{
            "humi":27,
            "temp":25
        }
    }
    
## Sample code
    
    network_message = require "network_message"
    server_listener = require "server_listener" 
    
    send_socket = net.createConnection(net.UDP, 0)
    dht11 = require "dht11"
    dht11_handler = require "dht11_handler"
    
    mydht = dht11(5) --, send_socket, 10000)
    a = mydht:get_readings()
    print(a['humi'], a['temp'])
    
    dht_handler = dht11_handler(mydht)
    
    server_listener.add("dht", dht_handler)
    server_listener.start(PORT)
    