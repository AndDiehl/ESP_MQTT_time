-- initiate the mqtt client and set keepalive timer to 120sec
require("WIFI")
local ntp=require("ntptime")


local mqtt = mqtt.Client("nodemcu", 120)


local function publishTime()
    time=ntp.getTime()
    if time == nil then
        time="unknown"
    end
    mqtt:publish("time/time", time, 0, 0, 
        function(conn) 
            print("sent time") 
        end
    )
end


local function onMqttConnected(conn)
    print("connected")

   -- subscribe topic with qos = 0
    mqtt:subscribe("test/#", 0, onReceive)
    
    mqtt:publish("test/ESP","hello from ESP", 0, 0, 
        function(conn) 
            print("sent") 
        end
    )

    tmr.create():alarm(5000, tmr.ALARM_AUTO, publishTime)
    
end


local function onReceive(conn, topic, data) 
    -- publish a message with data = my_message, QoS = 0, retain = 0
    print("received message")

    if topic ~= nil then
        print(topic .. ":" )
    end
    if data ~= nil then
        print(data)
    end
end


local function onConnected()
    
    mqtt:on("connect", onMqttConnected)

    mqtt:on("message", onReceive)

    mqtt:on("offline", function(con) print ("offline") end)

    mqtt:connect("172.16.7.224", port, 0, onMqttConnected)
end

-- register event handling, start when connected
wifi.sta.eventMonReg(wifi.STA_GOTIP, onConnected)
wifi.sta.eventMonStart()


