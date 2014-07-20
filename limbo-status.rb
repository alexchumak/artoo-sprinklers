require 'artoo'

connection :raspi, :adaptor => :raspi
device :led, :driver => :led, :pin => 11
device :board, :driver => :device_info

work do
	puts "Hi, I'm #{board.firmware_name}"

	every 1.second do
		led.toggle
	end
end
