Cylon = require("cylon")
Cylon.api(host: "192.168.2.52", port: "44864")

Cylon.robot(
  connection:
    name: "arduino"
    adaptor: "firmata"
    port: "/dev/ttyACM0"

  devices: [
    {
      name: "light_sensor"
      driver: "analogSensor"
      pin: 0
      interval: 5
    },
    {
      name: "front_yard_humidity"
      driver: "analogSensor"
      pin: 2
      interval: 10
    }
  ]

  values: {}

  work: (my) ->
    my.light_sensor.on "analogRead", (value) ->
      console.log "Light: " + value

    my.front_yard_humidity.on "analogRead", (value) ->
      console.log "Humidity: " + value
).start()
