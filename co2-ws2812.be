 #-
    CHANGELOG:
 
    DATE         REV  DESCRIPTION
    -----------  ---  ----------------------------------------------------------
    26-07-2024   0.3  Testing
     
    
    ToDo:   1)

	landish@gmail.com
 
-#

#- *************************************** -#
class FOCO2 : Driver

	var co2_colors 
   
	#- Berry co2 -#

	def co2i()
		# Read Sensor data
		import json
		import math
		var min_co2 = 400.0
		var max_co2 = 1500.0
		var sensors=json.load(tasmota.read_sensors())
		if !(sensors.contains('SCD40')) return end
		var co2 = sensors['SCD40']['CarbonDioxide']
		print("CarbonDioxide: ", co2)
		var co2_fixed = co2
		if (co2>max_co2) co2_fixed=max_co2 end
		if (co2<min_co2) co2_fixed=min_co2 end
		print("co2_fixed: ", co2_fixed)
		var co2_normalized = ((co2_fixed - min_co2)/(max_co2-min_co2)*1.0)
		print("co2_normalized: ", co2_normalized)
		#var curve=0.5+0.5*(1-co2_normalized*co2_normalized)
		
		var curve_RED=(1-(0.5+0.5*(1-3*math.pow(co2_normalized,2))))
		var curve_GREEN=(0.5+0.5*(1-8*math.pow(co2_normalized,2)))
		var curve_BLUE=(1-(0.5+0.5*(1-2*math.pow(co2_normalized,8))))
		if curve_RED>1 curve_RED=1 end
		if curve_GREEN>1 curve_GREEN=1 end
		if curve_BLUE>1 curve_BLUE=1 end
		if curve_RED<0 curve_RED=0 end
		if curve_GREEN<0 curve_GREEN=0 end
		if curve_BLUE<0 curve_BLUE=0 end
				
		print("Curve: ",curve_RED, curve_GREEN, curve_BLUE)
		var co2_color_RED=int(curve_RED*255)
		var co2_color_GREEN=int(curve_GREEN*255)
		var co2_color_BLUE=int(curve_BLUE*255)
		self.co2_colors = [co2_color_RED, co2_color_GREEN, co2_color_BLUE]
		print("self.co2_colors",self.co2_colors)
		return self.co2_colors
	end

	def every_second()
		if !self.co2i return nil end
		self.co2i()
	end
	
	def web_sensor()
		import string
		if !self.co2_colors return nil end               #- exit if not initialized -#	
		var msg = string.format(
				"{s}RED %.f"..
              "{s}GREEN %.f"..
              "{s}BLUE %.f"..,
              self.co2_colors[0],self.co2_colors[1],self.co2_colors[2])
		tasmota.web_send_decimal(msg)
		var msg_color = string.format(
				"Color (%.f,%.f,%.f)", self.co2_colors[0],self.co2_colors[1],self.co2_colors[2])
		# print(msg_color)
		tasmota.cmd(msg_color)
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
  
 