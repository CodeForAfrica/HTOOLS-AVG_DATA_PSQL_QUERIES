with sensor_combined AS
(
select n.id as sensors_node_id, n.location_id as sensors_node_location_id,
	 d.sensor_id as sensorsdata_sensor_id, 
		date(d.timestamp) as sensorsdata_timestamp,
		v.value as sensors_datavalue_value , v.value_type as sensors_datavalue_valuetype,
		l.location as location
from sensors_node as n
full join sensors_sensor as s 
on n.id=s.node_id  
full join sensors_sensorlocation as l 
on n.location_id=l.id 
full join sensors_sensordata as d
on d.sensor_id = s.id
full join sensors_sensordatavalue as v 
on v.sensordata_id = d.id
full join sensors_sensortype as t
on t.id = s.sensor_type_id  
)
select location, DATE(sensorsdata_timestamp) as Date,
		EXTRACT(day FROM sensorsdata_timestamp) AS _day, EXTRACT(month FROM sensorsdata_timestamp) as _month, 
		EXTRACT(year FROM sensorsdata_timestamp) as _year,sensors_datavalue_valuetype as measurement,
		cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) as day_avg,
CASE 
	  WHEN sensors_datavalue_valuetype = 'P1' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 0 and 12 THEN '#299438'
	  WHEN sensors_datavalue_valuetype = 'P1' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 12.1 and 35.4 THEN '#FAD000'
	  WHEN sensors_datavalue_valuetype = 'P1' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 35.5 and 55.4 THEN '#FF9933'
	  WHEN sensors_datavalue_valuetype = 'P1' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 55.5 and 150.4 THEN '#DB4035'
	  WHEN sensors_datavalue_valuetype = 'P1' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 150.5 and 250.4 THEN '#4C00B0'
	  WHEN sensors_datavalue_valuetype = 'P1' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) > 250.4 THEN '#BB00BB'
      WHEN sensors_datavalue_valuetype = 'P2' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 0 and 54 THEN '#299438'
	  WHEN sensors_datavalue_valuetype = 'P2' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 55 and 154 THEN '#FAD000'
	  WHEN sensors_datavalue_valuetype = 'P2' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 155 and 254 THEN '#FF9933S'
	  WHEN sensors_datavalue_valuetype = 'P2' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 255 and 354 THEN '#DB4035'
	  WHEN sensors_datavalue_valuetype = 'P2' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) between 355 and 424 THEN '#4C00B0'
	  WHEN sensors_datavalue_valuetype = 'P2' and 
	  cast(AVG(cast(sensors_datavalue_value as double precision)) as decimal(10,2)) > 424 THEN '#964B00'
	  else 'NA' 
END as status
from sensor_combined
where sensors_datavalue_value ~'(^[0-9]+\.?[[0-9]*$)'
--	and sensors_node_id = 27
   	and sensorsdata_timestamp between now() - interval '12 months' and now()
   	and (sensors_datavalue_valuetype = 'P0' or sensors_datavalue_valuetype = 'P1' or sensors_datavalue_valuetype = 'P2')
group by sensorsdata_timestamp, sensors_node_id, sensors_node_location_id,
		sensors_datavalue_valuetype,sensorsdata_sensor_id, location, DATE(sensorsdata_timestamp)