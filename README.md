- init.lua - run automatically
- parameters.lua - project configuration (AP login and password)
- parameters-device.lua - this unit configuration (like node name)
- wifi-init.lua - WiFi connection and keep alive timer
- main.lua - main code for app

##init.lua
This one is simple. Quick check for D1 / GPIO5 state. 
If it is connected we gonna abort app and if not we start wifi-init.lua. 

##parameters*
Remove *.dist.* 
In parameters.lua keep project variables like access point login, some pin mapping, global names. 
In parameters-device.lua some configuration that belongs to this node. Like its name or some id

##wifi-init.lua
Idea is simple, check if we are already connected and if not use timer to check status. 
After getting connection we launch main.lua and start keep-alive-timer.

I had few cases when net was gone and board didn't reconnect until rebooted. After few tries I ended with timer that checks connection and count failures in row. After reaching 10 or more it force unit reboot. Normally board would reconnect automatically before time is out.
In my case it was ok to reboot the device but keep in mind that may not be in yours.
Drawback is that we are taking one timer.

##main.lua
This file is main app start file. In boilerplate we will just turn on buildin led.
