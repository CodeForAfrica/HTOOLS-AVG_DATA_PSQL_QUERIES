
/*
This query gets the average day value of particular measurement in a particular sensor kit.

Measurements are restricted to those that would make sense to get the average value. 
E.g. Average GPS value of a stationary sensor kit does not make sense. 

*/

select l.location, l.id as location_id, date(d.timestamp) as Date,					-
		EXTRACT(day FROM date(d.timestamp)) AS _day, EXTRACT(month FROM date(d.timestamp)) as _month, 
		EXTRACT(year FROM date(d.timestamp)) as _year,v.value_type as measurement,
	    AVG(cast(v.value as float))::numeric(10,4) as day_avg,		
CASE  --rename value types to conventional names																						
	  WHEN v.value_type = 'P0' 																	
	  THEN 'PM 1'     
	  WHEN v.value_type = 'P1' 
	  THEN 'PM 2.5'
	  WHEN v.value_type = 'P2' 
	  THEN 'PM 10'
	  WHEN v.value_type = 'temperature' 
	  THEN 'TEMPERATURE'
	  WHEN v.value_type = 'humidity' 
	  THEN 'HUMIDITY'
--	  else '#NA' 
END as parameter
into temp dailavgtable_temp																							-- this is a temporary storage location for the output of this query
from sensors_node as n
full join sensors_sensor as s 
on n.id=s.node_id  
full join sensors_sensorlocation as l 
on n.location_id=l.id 
full join sensors_sensordata as d												                            
on d.sensor_id = s.id																						
full join sensors_sensordatavalue as v 
on v.sensordata_id = d.id 
where v.value ~'(^[0-9]+\.?[[0-9]*$)'																		--this line CONTAINS a regex that filters the 'sensors_datavalue_value' (values) COLUMN to valid integers and float values only
		--and sensors_node_id = 3																			--uncomment to limit the output to a particular sensor node (kit)
		and d.timestamp between '2022-01-01' and '2022-09-30'												--this line filters the OUTPUT so ONLY VALUES FROM the CURRENT time TO beginning of a paricular year
		and (v.value_type = 'P0' or v.value_type = 'P1' or v.value_type = 'P2'								--this line filters the OUTPUT TO ONLY P0, P1 AND P2, temperature , humidity values
		or v.value_type = 'temperature' or v.value_type = 'humidity')										
group by date(d.timestamp), n.id, l.id,																		-- this SECTION groups the VALUES FROM the selected columns so the SIMILAR VALUES IN EACH COLUMN ARE put together
		v.value_type, l.location;	



--------------------------------------------------------------------------------------------------------------------


select * from dailavgtable_temp;  --query the temporary table


-------------------INSERT RESULTS FROM TEMPORARY TABLE TO sensors_dailyavg[year] TABLE-------------------------------

insert into sensors_dailyavg2022(location, location_id, date, _day, _month, _year, parameter, day_avg)		--pointing to the table we want to append the data to (with its columns in parenthesis)
select location, location_id, date, _day, _month, _year, parameter, day_avg									-- selecting all data from our temporary storage location
from dailavgtable_temp;

-------------------------------------------------------------------------------------------------------------------

select * from sensors_dailyavg2022;  																		 -- viewing saved data to respective table


------------------ DELETE TEMPORARY TABLE WHEN DONE ---------------------------------------------------------------

drop table if exists dailavgtable_temp;