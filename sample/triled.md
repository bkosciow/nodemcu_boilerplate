# TRILED module

Controls LED with common **anode** or may control up to three LEDs. Can toggle color or blink once or in sequence.  



## init
    triled = require "triled"
    
    triled.pin_red = 2
    triled.pin_green = 1
    triled.pin_blue = 8
    triled.init()
    
Set pins and calls init function.
    
## usage

Enable red/green/blue:
    
    triled.red(true)   
    triled.green(true)
    triled.blue(true)

Disable:

    triled.red(false)   
    triled.green(false)
    triled.blue(false)


Blink two times and disable:

    triled.blink_green(2)
    
Blink two times, pause and resume sequence    

    triled.blink_blue(2, true)
    
Clear timers, disable all leds:
    
    triled.clear()    
