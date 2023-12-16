--------------------------------------------------------------------------------
--
-- rbx-arduino (./init.luau)
--
-- plainenglish
-- December 2023
--
-- A library to communiate to an Arduino Leonardo / Micro over a USB connection
-- by emulating an XInput (Xbox) gamepad.
-- Works both Studio and Live environments.
--
--------------------------------------------------------------------------------

--[[
Note to self:
- Enum.VibrationMotor.Large = RumbleLeft
- Enum.VibrationMotor.Small = RumbleRight
]]

local SAFE_SEND_DELAY = 0.015;
local TX_CLOCK_SIGNAL = Enum.VibrationMotor.Large;
local TX_BYTE_SIGNAL = Enum.VibrationMotor.Small;

local user_input_service = game:GetService("UserInputService");
local haptic_service = game:GetService("HapticService");


--------------------------------------------------------------------------------
-- 
-- byte_to_vibration_value
--
-- Returns a vibration value for the specified byte.
--
--------------------------------------------------------------------------------
function byte_to_vibration_value(byte : number) : number
	return byte/255/2; --0.5 = Full power, for some reason.
end


--------------------------------------------------------------------------------
--
-- new_arduino
--
-- Creates an arduino interface.
--
--------------------------------------------------------------------------------
function new_arduino(gamepad : Enum.UserInputType?)
	gamepad = gamepad or Enum.UserInputType.Gamepad1;
	local send_queue = {};
	--local rx_queue = {};
	
	local send_enabled = false;
	
	----------------------------------------------------------------------------
	--
	-- send_byte_internal
	--
	-- Sends a byte internally. This does *not* respect the queue, and may
	-- result in incorrect ordering if used incorrectly. Use send_byte instead.
	--
	----------------------------------------------------------------------------
	local function send_byte_internal(byte : number)
		haptic_service:SetMotor(gamepad, TX_BYTE_SIGNAL, byte_to_vibration_value(byte));	
		haptic_service:SetMotor(gamepad, TX_CLOCK_SIGNAL, 1);	
		
	
		task.wait(SAFE_SEND_DELAY);
		
		haptic_service:SetMotor(gamepad, TX_BYTE_SIGNAL, 0);	
		haptic_service:SetMotor(gamepad, TX_CLOCK_SIGNAL, 0);
	end
	
	
	----------------------------------------------------------------------------
	--
	-- send_byte
	--
	-- Adds a byte to the send queue.
	--
	----------------------------------------------------------------------------
	local function send_byte(byte : number) 
		table.insert(send_queue, byte);
	end
	
	
	----------------------------------------------------------------------------
	--
	-- send_string
	--
	-- Sends a string.
	--
	----------------------------------------------------------------------------
	local function send_string(data : string) 
		print(data);
		data = data .. "\n";
		local bytes = string.split(data, "");
		for i, v in pairs(bytes) do
			send_byte(string.byte(v));
		end
	end

	
	----------------------------------------------------------------------------
	--
	-- send_complete
	--
	-- Returns true if the send queue is empty.
	--
	----------------------------------------------------------------------------
	local function send_complete()
		return table.maxn(send_queue) == 0;
	end
	
	
	----------------------------------------------------------------------------
	--
	-- send_command
	--
	-- Issues a fully formed command.
	--
	----------------------------------------------------------------------------
	local function send_command(command, ...)
		local args = {...};
		
		local cmd = command .. ";" .. table.concat(args, ";");
		send_string(cmd);
	end
	
	
	----------------------------------------------------------------------------
	--
	-- read_byte
	--
	-- Reads a byte from the RX Queue.
	--
	----------------------------------------------------------------------------
	--[[local function read_byte() : number?
		local ret_val = rx_queue[1];
		
		if not ret_val then
			return;
		end
		
		table.remove(ret_val, 1);
		return ret_val;
	end]]
	
	
	----------------------------------------------------------------------------
	-- TX Queue:
	task.spawn(function()
		while task.wait(SAFE_SEND_DELAY) do
			if send_enabled and not send_complete() then
				send_byte_internal(send_queue[1]);
				table.remove(send_queue, 1);
			end
		end
	end);
	
	
	----------------------------------------------------------------------------
	-- RX Queue:	
	--[[user_input_service.InputChanged:Connect(function(input : InputObject, gpe : boolean)
		if input.UserInputType == gamepad then
			print(input.KeyCode)
			if input.KeyCode == Enum.KeyCode.ButtonR2 then
				table.insert(rx_queue, math.round(input.Position.Z * 255));
			end
		end
	end);]]
	
	
	----------------------------------------------------------------------------
	-- Export:
	return {
		--send_byte = send_byte,
		send_line = send_string,
		send_complete = send_complete,
		
		begin = function()
			send_enabled = true;
		end,
		
		stop = function()
			send_enabled = false;
		end,
		
		builtin = {
			pin_mode = function(pin : number, mode : number)
				send_command("PM", pin, mode);
			end,
			
			digital_write = function(pin : number, value : number)
				send_command("DW", pin, value);
			end,
			
			analog_write = function(pin : number, value : number)
				send_command("AW", pin, value);
			end,
			
			--[[echo = function(value : number)
				send_command("EC", value);
			end,]]
		}
	}	
end


--------------------------------------------------------------------------------
-- Export:
return {
	new = new_arduino,
	enum = {
		mode = {
			INPUT = 0x00,
			OUTPUT = 0x01,
			INPUT_PULLUP = 0x02
		},
		
		value = {
			LOW = 0x00,
			HIGH = 0x01,
		},
	}
};