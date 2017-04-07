print ("core ready")

network_message = require "network_message"
server_listener = require "server_listener"

send_socket = net.createConnection(net.UDP, 0)

dht11 = require "dht11"
dht11_handler = require "dht11_handler"
mydht = dht11(5, send_socket, 5000)
dht_handler = dht11_handler(mydht)

pir = require "pir_hcs_sr501"
pir_handler = require "pir_hcs_sr501_handler"
motion = pir(send_socket, 2)
motion_handler = pir_handler(motion)

light_sensor = require "light_detector"
light_sensor_handler = require "light_detector_handle"
light = light_sensor(send_socket, 6, 2000)
light_handler = light_sensor_handler(light)

server_listener.add("dht", dht_handler)
server_listener.add("motion", motion_handler)
server_listener.add("light", light_handler)
server_listener.start(PORT)
