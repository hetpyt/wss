-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("credentials.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- the actual application is stored in 'application.lua'
        dofile("application.lua")
    end
end

wifi_got_ip_event = function(T)
	-- Note: Having an IP address does not mean there is internet access!
	-- Internet connectivity can be determined with net.dns.resolve().
	print("Wifi connection is ready! IP address is: "..T.IP)
	print("Startup will resume momentarily, you have 3 seconds to abort.")
	print("Waiting...")
	tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
end

wifi_disconnect_event = function(T)
	if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
		--the station has disassociated from a previously connected AP
		print("Disconnected. Go to dsleep")
		node.dsleep(10 * 60 * 1000 * 1000)
		return
	end
	print("\nWiFi connection to AP("..T.SSID..") has failed!")

	--There are many possible disconnect reasons, the following iterates through
	--the list and returns the string corresponding to the disconnect reason.
	for key,val in pairs(wifi.eventmon.reason) do
		if val == T.reason then
			print("Disconnect reason: "..val.."("..key..")")
			break
		end
	end
end


-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD, save=false})
