SDA, SCL = 3, 4
net.dns.setdnsserver(DNS0, 0)
i2c.setup(0, SDA, SCL, i2c.SLOW)
bmp280 = require('bme280').setup(0, nil, nil, nil, nil, 0)
ina226 = require("ina226")
htu21 = require("htu21df")
bmp280:startreadout(function(T, P)
	local H, V
	if htu21 then
		H = htu21:readHum()
	end
	if ina226 then
		V = ina226:readVBUS()
	end
	local t = {node_id=NODE_ID, secret=NODE_SECRET, temp=T, qfe=P, humi=H, volt=V}
	ok, json = pcall(sjson.encode, t)
	if ok then
		http.post(HOST,
			'Content-Type: application/json\r\n',
			json,
			function(code, data)
				if (code < 0) then
					print("HTTP request failed")
				else
					print(code, data)
				end
				wifi.sta.disconnect()
			end
		)
	else
		print("failed to encode!")
		wifi.sta.disconnect()
	end
end)
