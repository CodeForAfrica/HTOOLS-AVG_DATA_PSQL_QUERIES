
select l.location, l.id as location_id, date(d.timestamp) as Date,					--selecting the neccesary columns
		EXTRACT(day FROM date(d.timestamp)) AS _day, EXTRACT(month FROM date(d.timestamp)) as _month, 
		EXTRACT(year FROM date(d.timestamp)) as _year,v.value_type as measurement,
		cast(AVG(cast(v.value as double precision)) as decimal(10,2)) as day_avg,		
CASE 																									--this SECTION creates a NEW COLUMN CALLED 'status' AND filles it
	  WHEN v.value_type = 'P1' and 																		--WITH color hex codes depending ON the VALUES IN the 'sensors_datavalue_valuetype'( measurement) 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 0 and 12 THEN '#299438'     ----AND 'sensors_datavalue_value' (vales) colums 
	  WHEN v.value_type = 'P1' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 12.1 and 35.4 THEN '#FAD000'
	  WHEN v.value_type = 'P1' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 35.5 and 55.4 THEN '#FF9933'
	  WHEN v.value_type = 'P1' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 55.5 and 150.4 THEN '#DB4035'
	  WHEN v.value_type = 'P1' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 150.5 and 250.4 THEN '#4C00B0'
	  WHEN v.value_type = 'P1' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) > 250.4 THEN '#BB00BB'
      WHEN v.value_type = 'P2' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 0 and 54 THEN '#299438'
	  WHEN v.value_type = 'P2' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 55 and 154 THEN '#FAD000'
	  WHEN v.value_type = 'P2' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 155 and 254 THEN '#FF9933S'
	  WHEN v.value_type = 'P2' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 255 and 354 THEN '#DB4035'
	  WHEN v.value_type = 'P2' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) between 355 and 424 THEN '#4C00B0'
	  WHEN v.value_type = 'P2' and 
	  cast(AVG(cast(v.value as double precision)) as decimal(10,2)) > 424 THEN '#964B00'
	  else 'NA' 
END as status
into temp stored																							-- this is a temporary storage location for the output of this query
from sensors_node as n
full join sensors_sensor as s 
on n.id=s.node_id  
full join sensors_sensorlocation as l 
on n.location_id=l.id 																						--this part OF the script combines 
full join sensors_sensordata as d																			--ALL neccesary tables UNDER the name 
on d.sensor_id = s.id																						--sensors_combined
full join sensors_sensordatavalue as v 
on v.sensordata_id = d.id 
where v.value ~'(^[0-9]+\.?[[0-9]*$)'																		--this line CONTAINS a regex that filters the 'sensors_datavalue_value' (values) COLUMN so we have ONLY VALUES FROM 00.00 TO 99.99
		--and sensors_node_id = 3																			--this line can be used to limit the output to a particular sensor node (kit)
		--and v.value_type = 'P2'																			
		and d.timestamp between '2022-01-01' and '2022-08-31'												--this line filters the OUTPUT so ONLY VALUES FROM the CURRENT time TO a YEAR PRIOR (1 year interval)
		and (v.value_type = 'P0' or v.value_type = 'P1' or v.value_type != 'P2'
		or v.value_type = 'temperature' or v.value_type != 'humidity')										--this line filters the OUTPUT TO ONLY P0, P1 AND P2, temperature , humidity calues
group by date(d.timestamp), n.id, l.id,																		-- this SECTION groups the VALUES FROM the selected columns so the SIMILAR VALUES IN EACH COLUMN ARE put together
		v.value_type, l.location;																			-- this also dtermine how the average FOR EACH measured value IS calculated



insert into sensors_dailyavg(location, location_id, date, _day, _month, _year, measurement, day_avg, status)		--pointing to the table we want to append the dat to (with its columna in bracket)
select *																											-- selecting all data from our temporary storage location
from stored;

select * from sensors_dailyavg;  																					-- viewing our tabble


