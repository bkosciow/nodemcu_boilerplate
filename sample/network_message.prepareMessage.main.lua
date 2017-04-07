print ("core ready")

network_message = require "network_message" 
lock = false

srv=net.createConnection(net.UDP, 0)
srv:connect(SERVER_PORT, wifi.sta.getbroadcast())

function sendEvent(event)
    if lock then
        return
    else 
        lock = true
    end 
    
    data = network_message.prepareMessage()
    data.event = event
    
    ok, json = pcall(cjson.encode, data)
    if ok then
      print (json)
      srv:send(json)   
    end      
    tmr.alarm(0, BTN_TIMEOUT, 0, resetLock)  
end

function resetLock()
    lock = false
end

function btnDown()              
   sendEvent("event.down")                   
end  

function btnLeft()              
   sendEvent("event.left")                   
end  

function btnUp()              
   sendEvent("event.up")                   
end  

function btnRight()
   sendEvent("event.right")                   
end  

function btnAction1()
   sendEvent("event.action1")                   
end  

function btnAction2()
   sendEvent("event.action2")                   
end  
 

gpio.mode(1, gpio.INT, gpio.PULLUP)
gpio.mode(2, gpio.INT, gpio.PULLUP)
gpio.mode(6, gpio.INT, gpio.PULLUP)
gpio.mode(7, gpio.INT, gpio.PULLUP)

gpio.mode(3, gpio.INT, gpio.PULLUP)
gpio.mode(5, gpio.INT, gpio.PULLUP)


gpio.trig(1, 'down', btnDown)
gpio.trig(2, 'down', btnLeft)
gpio.trig(7, 'down', btnUp)
gpio.trig(6, 'down', btnRight)

gpio.trig(5, 'down', btnAction1)
gpio.trig(3, 'down', btnAction2)
