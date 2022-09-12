-- the aim of this script is to get the daily average for P0, P1, and P2 values withing a years interval (from the date the script is run to 365 days prior)
-- an colum is added to give color codes (hex format) to the values of the daily average depending on their valus using the US AQI standard chart
with sensor_combined AS                                                            -----------
(                                                                                          --|
select n.id as sensors_node_id, n.location_id as sensors_node_location_id,				   --|
	 d.sensor_id as sensorsdata_sensor_id, 												   --|	
		date(d.timestamp) as sensorsdata_timestamp,            							   --|	
		v.value as sensors_datavalue_value , v.value_type as sensors_datavalue_valuetype,  --|
		l.location as location                                                             --|
from sensors_node as n          							            				   --|
full join sensors_sensor as s           							             		   --|
on n.id=s.node_id            							            					   --|--this part OF the script combines 
full join sensors_sensorlocation as l           							   			   --|--ALL neccesary tables UNDER the name 
on n.location_id=l.id           							            				   --|--sensors_combined
full join sensors_sensordata as d          							  				  	   --|
on d.sensor_id = s.id				  				  				  				       --|
full join sensors_sensordatavalue as v 				  				  				       --|
on v.sensordata_id = d.id				  				  				  				   --|
full join sensors_sensortype as t				  				  				           --|
on t.id = s.sensor_type_id  				  				  				  			   --|
)				  				  				  				  				  ------------
select location, DATE(sensorsdata_timestamp) as Date,				  				  				  ----------|
		EXTRACT(day FROM sensorsdata_timestamp) AS _day, EXTRACT(month FROM sensorsdata_timestamp) as _month, --|- this part selects ONLY the relevant columns 
		EXTRACT(year FROM sensorsdata_timestamp) as _year,sensors_datavalue_valuetype as measurement,		  --|-FROM sensors_combined AND renames them while getting the avarage VALUES FOR EACH DAY 
		cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) as day_avg,		--------|-(this is dependent on how the groupby section below is structured)
CASE   				  	  				  	  				  	  				  	  				  	-------------------|
	  WHEN sensors_datavalue_valuetype = 'P1' and   				  	  				  	  				  	  		---|
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 0 and 12 THEN '#299438'		 --|
	  WHEN sensors_datavalue_valuetype = 'P1' and   				  	  				  	  				  	  		 --|
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 12.1 and 35.4 THEN '#FAD000' --|
	  WHEN sensors_datavalue_valuetype = 'P1' and   				  	  				  	  				  	  		 --|
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 35.5 and 55.4 THEN '#FF9933' --|  				  	  				  	  		
	  WHEN sensors_datavalue_valuetype = 'P1' and   				  	  				  	  				  	  		 --|
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 55.5 and 150.4 THEN '#DB4035'--|
	  WHEN sensors_datavalue_valuetype = 'P1' and   				  	  				  	  				  	  		 --|   				  	  				  	  				  	
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 150.5 and 250.4 THEN '#4C00B0'--|
	  WHEN sensors_datavalue_valuetype = 'P1' and   				  	  				  	  				  	  		 --|-- this SECTION creates a NEW COLUMN CALLED 'status' AND filles it
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) > 250.4 THEN '#BB00BB'				 --|--WITH color hex codes depending ON the VALUES IN the 'sensors_datavalue_valuetype'( measurement) 
      WHEN sensors_datavalue_valuetype = 'P2' and   				  	  				  	  				  	  		 --|--AND 'sensors_datavalue_value' (vales) colums 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 0 and 54 THEN '#299438'		 --|
	  WHEN sensors_datavalue_valuetype = 'P2' and   				  	  				  	  				  	  		 --| 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 55 and 154 THEN '#FAD000'	 --|
	  WHEN sensors_datavalue_valuetype = 'P2' and   				  	  				  	  				  	  		 --| 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 155 and 254 THEN '#FF9933S'	 --|
	  WHEN sensors_datavalue_valuetype = 'P2' and   				  	  				  	  				  	  		 --| 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 255 and 354 THEN '#DB4035'	 --|
	  WHEN sensors_datavalue_valuetype = 'P2' and   				  	  				  	  				  	  		 --| 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 355 and 424 THEN '#4C00B0'	 --|
	  WHEN sensors_datavalue_valuetype = 'P2' and   				  	  				  	  				  	  		 --| 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) > 424 THEN '#964B00'		 		 --|
	  else 'NA' 										 				  	  				  	  				  	  	 --| 
END as status					 				  	  				  	  				  	  	    		 --------------| 
from sensor_combined																						 ----------------| 
where sensors_datavalue_value ~'(^[0-9]+\.?[[0-9]*$)'  				  	  				  	  				  	  		   --|-this line CONTAINS a regex that filters the 'sensors_datavalue_value' (values) COLUMN so we have ONLY VALUES FROM 00.00 TO 99.99
--	and sensors_node_id = 27					 				  	  				  	  				  	  		       --|-this line can be used to limit the output to a particular sensor node (kit)
   	and sensorsdata_timestamp between now() - interval '12 months' and now() 				   				  	  		   --|-this line filters the OUTPUT so ONLY VALUES FROM the CURRENT time TO a YEAR PRIOR (1 year interval)
   	and (sensors_datavalue_valuetype = 'P0' or sensors_datavalue_valuetype = 'P1' or sensors_datavalue_valuetype = 'P2')   --|-this line filters the OUTPUT TO ONLY P0, P1 AND P2 calues
group by sensorsdata_timestamp, sensors_node_id, sensors_node_location_id,			  	  				  	  		       --|-- this SECTION groups the VALUES FROM the selected columns so the SIMILAR VALUES IN EACH COLUMN ARE put together
		sensors_datavalue_valuetype,sensorsdata_sensor_id, location, DATE(sensorsdata_timestamp)             ----------------|-- this also dtermine how the average FOR EACH measured value IS calculated