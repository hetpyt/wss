
local MAX17043_I2C_ADDRESS = 0x32 --0x36
local MAX17043_REGISTER_VCELL = 0x02 --0x02-0x03
local MAX17043_REGISTER_SOC = 0x04 --0x04-0x05
local MAX17043_REGISTER_MODE = 0x06 --0x06-0x07
local MAX17043_REGISTER_VERSION = 0x08 --0x08-0x09
local MAX17043_REGISTER_CONFIG = 0x0C --0x0C-0x0D
local MAX17043_REGISTER_COMMAND = 0xFE --0xFE-0xFF

local MAX17043_MODE_QUICKSTART = {0x40, 0x00}
local MAX17043_COMMAND_POR = {0x00, 0x54}

local VCELL_FROM_POR_DELAY = 125 -- ms
local VCELL_FROM_SLEEP_DELAT = 500 -- ms

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

function readVCELL(self)
	local buf = read_reg(self.id, self.addr, MAX17043_REGISTER_VCELL, 2)
	if not buf then
        return nil
    end
	local h, l = string_byte(buf, 1, 2)
	local hl = bit_lshift(h, 8)
	hl = bit_rshift(bit_bor(hl, l), 4)
	return hl * 1.25
end

function readSOC(self)
    local buf = read_reg(self.id, self.addr, MAX17043_REGISTER_SOC, 2)
    if not buf then
        return nil
    end
    local h, l = string_byte(buf, 1, 2)
    return h
end


function isSleeping(self)
    local buf = read_reg(self.id, self.addr, MAX17043_REGISTER_CONFIG, 2)
    if not buf then
        return nil
    end
    return ( bit_band(string_byte(buf, 2), 0x80) == 0x80 )
end

function sleep(self)
    local buf = read_reg(self.id, self.addr, MAX17043_REGISTER_CONFIG, 2)
    if not buf then
        return
    end
    local h, l = string_byte(buf, 1, 2)
    -- 7 bit in l is sleep flag
    if bit_band(l, 0x80) == 0x80 then
        return
    end
    l = bit_bor(l, 0x80) -- set 7 bit
    if not write_reg(self.id, self.addr, MAX17043_REGISTER_CONFIG, {h, l}) then
        return
    end
end

function wake(self)
    local buf = read_reg(self.id, self.addr, MAX17043_REGISTER_CONFIG, 2)
    if not buf then
        return
    end
    local h, l = string_byte(buf, 1, 2)
    -- 7 bit in l is sleep flag
    if bit_band(l, 0x80) == 0 then
        return
    end
    l = bit_band(l, 0x7F) -- clear 7 bit
    if not write_reg(self.id, self.addr, MAX17043_REGISTER_CONFIG, {h, l}) then
        return
    end
end

function quickStart(self)
    -- send QS command
    write_reg(self.id, self.addr, MAX17043_REGISTER_MODE, MAX17043_MODE_QUICKSTART)
end

function reset(self)
    write_reg(self.id, self.addr, MAX17043_REGISTER_COMMAND, MAX17043_COMMAND_POR)
end

function version(self)
    local buf = read_reg(self.id, self.addr, MAX17043_REGISTER_VERSION, 2)
    if not buf then
        return nil
    end
    local h, l = string_byte(buf, 1, 2)
    local hl = bit_bor(bit_lshift(h, 8), l)
    return hl
end

local max17043 = {
	id = 0,
	addr = MAX17043_I2C_ADDRESS,
	readVCELL = readVCELL,
    readSOC = readSOC,
    isSleeping = isSleeping,
    sleep = sleep,
    wake = wake,
    quickStart = quickStart,
    reset = reset,
    version = version
}

return max17043
