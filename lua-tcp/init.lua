count = 0
tx_pin = 4

--wifi.sta.setip({ip="192.168.0.241",netmask="255.255.255.0",gateway="192.168.0.1"}) // StaticIP, bei Bedarf erste nach WLAN-Settings nachträglich updaten 
wifi.setmode(wifi.STATION)
wifi.sta.connect()

tmr.alarm(0, 150, 1, function()
  if (wifi.sta.getip() == nil) then
    count = count+1
    print("wait"..count)

    if (count == 50) then
      print("AP-Modus Start")
      gpio.mode(4,gpio.OUTPUT)
      gpio.write(4,gpio.LOW)
      tmr.delay(1000000)
      gpio.write(4,gpio.HIGH)
      tmr.delay(1000000)
      gpio.write(4,gpio.LOW)
      tmr.delay(1000000)
      gpio.write(4,gpio.HIGH)
      tmr.delay(1000000)
      gpio.write(4,gpio.LOW)
      tmr.delay(1000000)
      gpio.write(4,gpio.HIGH)
      tmr.delay(1000000)
      dofile("servernode.lua")    --  calls servernode.lua
      tmr.stop(0)
    end
  else
    tmr.stop(0)
    dofile("aktor.lua")
  end
end)
