 #-
    CHANGELOG:
 
    DATE         REV  DESCRIPTION
    -----------  ---  ----------------------------------------------------------
    26-07-2024   0.3  Testing
	29-07-2024   0.4  Add 3 different curves for RGB
	31-07-2024   0.45 fix light Color
     
    
    ToDo:   1)

	landish@gmail.com
 
-#

#- *************************************** -#
class FOCO2 : Driver

	var co2_colors 
   
	#- Berry co2 -#

	def co2i()
		#json for read data from tasmota
		#math for curves
		import json
		import math
		import string
		
		# Put here your sensor name
		var sensor_name = 'SCD40'
		var sensor_data = 'CarbonDioxide'
		
		# Put here your data range
		var min_co2 = 400.0
		var max_co2 = 1500.0
		
		# Read Sensor data
		var sensors=json.load(tasmota.read_sensors())
		if !(sensors.contains(sensor_name)) return end
		var co2 = sensors[sensor_name][sensor_data]
		
		# inline print-debug		
		# print(sensor_data, ": ", co2)
		var co2_fixed = co2
		if (co2>max_co2) co2_fixed=max_co2 end
		if (co2<min_co2) co2_fixed=min_co2 end
		
		# inline print-debug		
		# print("co2_fixed: ", co2_fixed)
				
		var co2_normalized = ((co2_fixed - min_co2)/(max_co2-min_co2)*1.0)
		# inline print-debug		
		# print("co2_normalized: ", co2_normalized)
				
		# Curves
		var curve_RED=(1-(0.5+0.5*(1-3*math.pow(co2_normalized,2))))
		var curve_GREEN=(0.5+0.5*(1-8*math.pow(co2_normalized,2)))
		var curve_BLUE=(1-(0.5+0.5*(1-2*math.pow(co2_normalized,8))))
		
		# check and fix range
		if curve_RED>1 curve_RED=1 end
		if curve_GREEN>1 curve_GREEN=1 end
		if curve_BLUE>1 curve_BLUE=1 end
		if curve_RED<0 curve_RED=0 end
		if curve_GREEN<0 curve_GREEN=0 end
		if curve_BLUE<0 curve_BLUE=0 end
		
		# inline print-debug		
		# print("Curve: ",curve_RED, curve_GREEN, curve_BLUE)
		var co2_color_RED=string.format('%02s',string.hex(int(curve_RED*255)))
		var co2_color_GREEN=string.format('%02s',string.hex(int(curve_GREEN*255)))
		var co2_color_BLUE=string.format('%02s',string.hex(int(curve_BLUE*255)))
		self.co2_colors = co2_color_RED + co2_color_GREEN + co2_color_BLUE
		print("self.co2_colors: #",self.co2_colors)
		return self.co2_colors
	end

	def every_second()
		if !self.co2i return nil end
		self.co2i()
		self.golight()
	end
	
	def golight()
		if !self.co2_colors return nil end               #- exit if not initialized -#	
		light.set({"rgb": self.co2_colors})
	end
	
	def web_sensor()
		import string
		if !self.co2_colors return nil end               #- exit if not initialized -#	
		#var msg = string.format(
		#		"{s}RED %.f"..
        #      "{s}GREEN %.f"..
        #      "{s}BLUE %.f"..,
        #      self.co2_colors)
		#tasmota.web_send_decimal(msg)

	end
  
	#- *************************************** -#
	def json_append()
		if !self.co2_colors return nil end
		import string
		var msg = string.format(",\"CO2 Color\":{\"RED\":%.f,\"GREEN\":%.f,\"BLUE\":%.f}",
              self.co2_colors[0],self.co2_colors[1],self.co2_colors[2])
		tasmota.response_append(msg)
	end
  
end


#- *************************************** -#
FOCO2 = FOCO2()
tasmota.add_driver(FOCO2)
  