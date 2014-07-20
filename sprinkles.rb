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

  def initialize params
    super

    on hygro_back_yard, update: :on_update
    on hygro_back_yard, upper: :on_upper
    on hygro_back_yard, lower: :on_lower
  end

  def on_lower a, b
    puts "Lower #{a} #{b}"
  end

  def on_upper a, b
    puts "Upper #{a} #{b}"
  end

  def on_update(a, b, c)
    puts "Update"
  end

  work do
    puts board.firmware_name

    counter = 1
    in_process = false

    every 5.seconds do
      puts Time.now.to_s

      if in_process
        puts "Skipping..."
      else
        in_process = true

        puts "#{counter}]----------------------------------"
        counter += 1

        in_process = false
      end
    end
  end
end

Sprinkles.work!(Sprinkles.new(connections: { arduino: { port: options[:port] } }))
