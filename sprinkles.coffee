argv = require('yargs').argv
fs = require('fs')
sh = require('execSync')
Cylon = require("cylon")

Cylon.api(host: argv.hostIp || "127.0.0.1", port: "44864")

sprinkles = Cylon.robot(
  name: "Sprinkles"

  connection:
    name: "arduino"
    adaptor: "firmata"
    port: argv.arduinoPort || "/dev/ttyACM0"

  devices: [
    { group: "sprinkler", name: "sprinklers back left", driver: "led", pin: argv.sprinklersBackLeftPin || 8 },
    { group: "sprinkler", name: "sprinklers back right", driver: "led", pin: argv.sprinklersBackRightPin || 10 },
    { group: "sprinkler", name: "sprinklers front", driver: "led", pin: argv.sprinklersFrontPin || 12 },

    { group: "sensor", name: "brightness", driver: "analogSensor", pin: argv.brightnessPin || 0 },
    { group: "sensor", name: "humidity back", driver: "analogSensor", pin: argv.humidityBackPin || 2 },
    { group: "sensor", name: "humidity front", driver: "analogSensor", pin: argv.humidityFrontPin || 4 }
  ]

  commands: ['averageSamples', 'eraseLogs']

  eraseLogs: ->
    for sensor in this.analogSensors()
      fs.truncate(this.logFileName(sensor.name))
    return

  work: (my) ->
    every((argv.sampleInterval || 2).seconds(), this.sample.bind(my))

  analogSensors: ->
    (sensor for sensor_name, sensor of this.devices when sensor.driver.group == 'sensor')

  averageSamples: ->
    averages = {}

    for sensor in this.analogSensors()
      result = sh.exec("tail -n 10 #{this.logFileName(sensor.name)}", { timeout: 1000 })
      data = (line.split(',') for line in result.stdout.split("\n") when line)
      averages[sensor.name] = data.map((item) -> parseInt(item[1])).reduce((a, sum) -> a + sum) / data.length

    return averages


  logFileName: (sensor_name) ->
    logs_dir = argv.logsDir || 'logs'
    "#{logs_dir}/#{this.name}-#{sensor_name}.log"

  sample: () ->
    for sensor in this.analogSensors()
      line = "#{new Date().getTime()},#{sensor.analogRead()}"
      fs.appendFile(this.logFileName(sensor.name), line + "\n")
)

sprinkles.start()
