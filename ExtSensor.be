#-----------------------------------
class for an external sensor
    - sensor is subcribed be udpBroker
    - using his receive-handler the method loadMap is used to fill ExtSensore with data
    - telePeriod is supported
------------------------------------#
import string
import json
import tool
import webserver

class ExtSensor : DynClass

    var name
    var lastLogInfo
    var lastWarnInfo
    var lastLogProc
    var infoEnable
    var counter
    var lastTick
    var timeoutMS
    var enableSensorMsg

    #-
    callback          triggered,when web view has to be updated
    return            html, to be added to main-page
    prototype         def() .. return html end
    -#  
    var onBuildWebView

    # log with level INFO
    def info(proc,info)
        self.lastLogProc = proc
        self.lastLogInfo = info
        if self.infoEnable print("INFO "+self.name+"."+proc+" - "+info) end
    end

    # log with level WARN
    def warn(proc,info)
        self.lastLogProc = proc
        self.lastWarnInfo = info
        print("WARN "+self.name+"."+proc+" - "+info)
    end

    # load map and wire dynClasses with that
    def loadMap(vmap)
        var cproc="loadMap"
        super(self).loadMap(vmap)
        self.counter += 1
        self.lastTick = tasmota.millis() + self.timeoutMS
        if self.counter>1000 self.counter=0 end
        if self.infoEnable self.info(cproc,"counter:"+str(self.counter)) end
    end

    # returns true, if message is received within timeMS intervl, false otherwise
    def isAlive()
        return tasmota.millis() < self.lastTick
    end

    #  function     callback for tasmota driver mimic
    def web_sensor()
        var cproc="web_sensor"

        # if self.infoEnable self.info(cproc,"calling") end
        if !self.hasMembers() return  end

        # update web-view for this instance
        if self.onBuildWebView
            try
                # if self.infoEnable self.info(cproc,"executing") end
                var html = self.onBuildWebView()
                webserver.content_send(html)
            except .. as exname, exmsg
                self.warn(cproc, exname + " - " + exmsg)
            end   
        end
    end

    def getJsonCommand()
        return string.format('"%s":%s', self.name, self.toJson())
    end

    # callback from tasmota driver manager
    def json_append()
        var cproc='json_append'
        # if self.infoEnable self.info(cproc,"running") end
        if !self.enableSensorMsg return false end
        var ss = ","+self.getJsonCommand()
        if ss 
            tasmota.response_append(ss) 
            return true
        end
        return false
    end

    # register as tasmota driver
    def registerAsDriver()
        tasmota.add_driver(self)
    end

    def hasMembers()
        return size(self.xmap)>0
    end
    def deinit()
        tasmota.remove_driver(self)
    end

    def init(name)
        var cproc='init'

        self.counter=0
        self.timeoutMS=60000
        self.lastTick = tasmota.millis()
        self.enableSensorMsg=false

        super(self).init()
        if !name name="extSensor" end
        self.name = name

        self.infoEnable = true
        self.info(cproc,"created ExtSensor "+name)
        self.infoEnable = false
        self.registerAsDriver()

    end
end
