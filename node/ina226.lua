
local INA226_I2C_ADDRESS = 0x45 --0x40

local INA226_CONFIG_REGISTER_ADDR = 0x00
--local INA226_VSHUNT_REGISTER_ADDR = 0x01
local INA226_VBUS_REGISTER_ADDR = 0x02
--local INA226_POWER_REGISTER_ADDR = 0x03
--local INA226_CURRENT_REGISTER_ADDR = 0x04
--local INA226_CALIBRATE_REGISTER_ADDR = 0x05
--local INA226_MASK_ENA_REGISTER_ADDR = 0x06
--local INA226_ALERT_REGISTER_ADDR = 0x07
--local INA226_MANUFID_REGISTER_ADDR = 0xFE
--local INA226_DIEID_REGISTER_ADDR = 0xFF

local INA226_CONF_VBUS_DEF = {0x41, 0x22} -- default settings vbus triggered measurement (1 sample, 1.1ms conversion time)
local INA226_VBUS_DEF_DELAY = 1.1 * 1000 -- us

local i2c_start, i2c_stop, i2c_address, i2c_read, i2c_write, i2c_TRANSMITTER, i2c_RECEIVER =
		i2c.start, i2c.stop, i2c.address, i2c.read, i2c.write, i2c.TRANSMITTER, i2c.RECEIVER
local bit_lshift, bit_rshift, bit_bor, bit_band = bit.lshift, bit.rshift, bit.bor, bit.band
local string_byte = string.byte
local tmr_delay = tmr.delay


local read_reg
local write_reg

function write_reg(id, dev_addr, reg_addr, data)
	i2c_start(id)
	if not i2c_address(id, dev_addr, i2c_TRANSMITTER) then
		return nil
	end
	i2c_write(id, reg_addr)
	local c = i2c_write(id, data)
	i2c_stop(id)
	return c
end

function read_reg(id, dev_addr, reg_addr, n)
	i2c_start(id)
	if not i2c_address(id, dev_addr, i2c_TRANSMITTER) then
		return nil
	end
	i2c_write(id, reg_addr)
	i2c_stop(id)
	i2c_start(id)
	i2c_address(id, dev_addr, i2c_RECEIVER)
	local c = i2c_read(id, n)
	i2c_stop(id)
	return c
end

function readVBUS(self)
	write_reg(self.id, self.addr, INA226_CONFIG_REGISTER_ADDR, INA226_CONF_VBUS_DEF)
	tmr_delay(INA226_VBUS_DEF_DELAY)
	local buf = read_reg(self.id, self.addr, INA226_VBUS_REGISTER_ADDR, 2)
	if not buf then
        return nil
    end
	local h, l = string_byte(buf, 1, 2)
	return bit_bor(bit_lshift(h, 8), l) * 1.25
end


local ina226 = {
	id = 0,
	addr = INA226_I2C_ADDRESS,
	readVBUS = readVBUS,
}

return ina226
