require 'artoo/robot'
require 'optparse'
require 'pry'

options = {}

optparser = OptionParser.new do |opt|
  opt.on "-p", "--port PORT" do |value|
    options[:port] = value
  end
end
optparser.parse!

puts options.inspect


class Sprinkles < Artoo::Robot
  connection :arduino, :adaptor => :firmata

  device :board, :driver => :device_info
  device :status_led, driver: :led, pin: 13
  device :hygro_back_yard, pin: 2, driver: :analog_sensor, interval: 2, upper: 0, lower: 10000
  device :photores, pin: 0, driver: :analog_sensor, interval: 2, upper: 0, lower: 10000

  api host: '192.168.2.52', port: 44864

  attr_accessor :sensor_data

  def initialize params
    super

    #on photores, update: :on_update
    #on hygro_back_yard, update: :on_update
  end

  work do
    puts board.firmware_name

    counter = 1
    in_process = false

    every 5.seconds do

      if in_process
        puts "Skipping..."
      else
        in_process = true

	time = Time.now.to_s
	analog_devices = self.devices.select { |key, dev| dev.driver.additional_params[:driver] == :analog_sensor }
	puts analog_devices.inspect
        puts "#{counter}, #{time}]----------------------------------"
	puts analog_devices.collect { |key, dev| [dev.additional_params[:name], dev.previous_read] }.inspect
        counter += 1

        in_process = false
      end
    end
  end
end

Sprinkles.work!(Sprinkles.new(name: 'Sprinkles', connections: { arduino: { port: options[:port] } }))
