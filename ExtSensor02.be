# --- this script is processed, after components are created

# ========= UdpBroker =======
# this is the fullTopic of the external controller 
extSensorTopic = "tele/tasmota_boiler_pm/SENSOR"

udpBroker = UdpBroker("broker")
lastExtSensorPayload=nil
extSensor=nil

# define the handler for the topic of interest
def UdpExtSensorHandler(topic,payload)
  lastExtSensorPayload = json.load(payload)

  # we are only interested on Energy-data
  if extSensor!=nil extSensor.loadMap(lastExtSensorPayload["ENERGY"]) end
end

# subscribe for the sensor messge
udpBroker.subscribe(extSensorTopic,UdpExtSensorHandler)

# ========= ExtSensor =======
#- we are intereste on the 'ENERGY' part of the sensor message

-#

extSensor = ExtSensor("ENERGY")
extSensor.infoEnable=true

# merge the external ENERGY-information in own sensor message
extSensor.enableSensorMsg=true

# extend UI with energy data
extSensor.onBuildWebView = 
def()
  var ss='<table style=width:100%%><thead><tr><th colspan=3>Power-Meter <small>(external sensor shelly 1PM)</small></th></tr></thead><tbody><tr><td>Voltage</td><td>%s</td><td>V</td></tr><tr><td>Current</td><td>%s</td><td>A</td></tr><tr><td>Active Power</td><td>%s</td><td>W</td></tr><tr><td>Apparent Power</td><td>%s</td><td>VA</td></tr><tr><td>Reactive Power</td><td>%s</td><td>VAr</td></tr><tr><td>Power Factor</td><td>%s</td><td></td></tr><tr><td>Energy Today</td><td>%s</td><td>kWh</td></tr><tr><td>Energy Yesterday</td><td>%s</td><td>kWh</td></tr><tr><td>Energy Total</td><td>%s</td><td>kWh</td></tr><tr><td>Message Counter</td><td>%s</td><td></td></tr></tbody></table>'
    var html=string.format(ss ,
    str(extSensor.Voltage),
    str(extSensor.Current),
    str(extSensor.Power), 
    str(extSensor.ApparentPower), 
    str(extSensor.ReactivePower), 
    str(extSensor.Factor),
    str(extSensor.Today),
    str(extSensor.Yesterday),
    str(extSensor.Total),
    str(extSensor.counter)
  )
  return html    
end
