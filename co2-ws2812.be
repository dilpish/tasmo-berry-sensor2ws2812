 #-
    CHANGELOG:
 
    DATE         REV  DESCRIPTION
    -----------  ---  ----------------------------------------------------------
    26-07-2024   0.3  Testing
	29-07-2024   0.4  Add 3 different curves for RGB
	31-07-2024   0.45 fix light Color
    31-07-2024   0.49 refact all var 4 all sensors
    01-08-2024   0.51 mqtt not working - temp disabled
     
    
    ToDo:   1)

	landish@gmail.com
 
-#

	#json for read data from tasmota
	#math for curves
	import json
	import math
	import string

#- *************************************** -#
class FOS2L : Driver

	var data_colors 
    var sensor_name
    var sensor_data
	var min_data
    var max_data
    var go_mqtt
    var go_gui
    
	#- Berry sensor2light -#

	def s2l()
		
        # send mqtt msg
        var go_mqtt=0
        # show color in Tasmota GUI
        var go_gui=1
        
        # Put here your sensor name
        var sensor_name = 'SCD40'
        var sensor_data = 'CarbonDioxide'
        
        self.sensor_name=sensor_name
        self.sensor_data=sensor_data
		
        # Put here your data range
        var min_data = 400.0
        var max_data = 1500.0
        
		# Read Sensor data
		var sensors=json.load(tasmota.read_sensors())
		if !(sensors.contains(sensor_name)) return end
		var sdata = sensors[sensor_name][sensor_data]
		
		# inline print-debug		
		# print(sensor_data, ": ", sdata)
		var data_fixed = sdata
		if (sdata>max_data) data_fixed=max_data end
		if (sdata<min_data) data_fixed=min_data end
		
		# inline print-debug		
		# print("data_fixed: ", data_fixed)
				
		var data_normalized = ((data_fixed - min_data)/(max_data-min_data)*1.0)
		# inline print-debug		
		# print("data_normalized: ", data_normalized)
				
		# Curves
		var curve_RED=(1-(0.5+0.5*(1-3*math.pow(data_normalized,2))))
		var curve_GREEN=(0.5+0.5*(1-8*math.pow(data_normalized,2)))
		var curve_BLUE=(1-(0.5+0.5*(1-2*math.pow(data_normalized,8))))
		
		# check and fix range
		if curve_RED>1 curve_RED=1 end
		if curve_GREEN>1 curve_GREEN=1 end
		if curve_BLUE>1 curve_BLUE=1 end
		if curve_RED<0 curve_RED=0 end
		if curve_GREEN<0 curve_GREEN=0 end
		if curve_BLUE<0 curve_BLUE=0 end
		
		# inline print-debug		
		# print("Curve: ",curve_RED, curve_GREEN, curve_BLUE)
		var data_color_RED=string.format('%02s',string.hex(int(curve_RED*255)))
		var data_color_GREEN=string.format('%02s',string.hex(int(curve_GREEN*255)))
		var data_color_BLUE=string.format('%02s',string.hex(int(curve_BLUE*255)))
		self.data_colors = data_color_RED + data_color_GREEN + data_color_BLUE
		# inline print-debug		
        # print("self.data_colors: #",self.data_colors)
		return self.data_colors
	end

	def every_second()
		if !self.s2l return nil end
		self.s2l()
		self.golight()
	end
	
	def golight()
		if !self.data_colors return nil end               #- exit if not initialized -#	
		light.set({"rgb": self.data_colors})
	end
	
	def web_sensor()
        if self.go_gui==0 return nil end
		if !self.data_colors return nil end               #- exit if not initialized -#	
		var msg = string.format(
                "{s}Sensor %s color: {m}<font color='%s'>#%s</font>{e}",
                 self.sensor_data,self.data_colors,self.data_colors)
		tasmota.web_send(msg)

	end
  
	#- *************************************** -#
	def json_append()
        if self.go_mqtt==0 return nil end
		if !self.data_colors return nil end
		#var msg = string.format(',\"%s\":{\"Color\":#%s}', self.sensor_name, self.data_colors)
        
        # NOT WORKING
        
        #var msg = string.format(',"Color":%s}', self.data_colors)
		#tasmota.response_append(msg)
	end
  
end


#- *************************************** -#
FOS2L = FOS2L()
tasmota.add_driver(FOS2L)
  