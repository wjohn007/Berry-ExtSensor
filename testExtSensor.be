import tool
import string

var sensorName='unittest'
var bc = ExtSensor(sensorName)
bc.infoEnable=true

# check basics
assert(!bc.extendSensorMsg,"basic.1")
assert(bc.counter==0,"basic.2")
assert(bc.timeoutMS==60000,"basic.3")
assert(bc.lastTick>0,"basic.4")
assert(bc.name==sensorName,"basic.5")
assert(!bc.onBuildWebView,"basic.6")

assert(!bc.hasMembers(),"basic.11")
assert(!bc.json_append(),"basic.12")

assert(bc.getJsonTeleperiod()==',"'+sensorName+'":{}',"basic.13")
assert(!bc.isAlive(),"basic.14")


# ------- check callback
var callDone=false
bc.onBuildWebView = def() callDone=true return "<h1>test</h2>" end
bc.xmap={}

# only done, if members exist
bc.web_sensor()
assert(!callDone,"callback.1")

assert(bc.handleWebSensor()=="","callback.1a")
assert(!callDone,"callback.2")

# load a map
var xmap = {"energy":{"voltage":230,"current":2.34}}
bc.loadMap(xmap)
assert(bc.energy.voltage==230,"callback.11")
assert(bc.energy.current==2.34,"callback.12")
assert(bc.hasMembers(),"callback.13")
assert(bc.isAlive(),"callback.15")
assert(bc.lastTick<tasmota.millis()+60000,"callback.16")
assert(bc.counter>0,"callback.17")

assert(bc.handleWebSensor()!="","callback.21")
assert(callDone,"callback.22")

assert(bc.getJsonTeleperiod()==',"unittest":{"energy":{"current":2.34,"voltage":230}}',"basic.23")

# check extendSensorMsg 
assert(!bc.json_append(),"callback.31")
bc.extendSensorMsg=true
assert(bc.json_append(),"callback.32")


# ===== housekeeping
bc.deinit()
bc=nil
