
select l.location, l.id as location_id ,					--selecting the neccesary columns
		 EXTRACT(month FROM date(d.timestamp)) as _month, 
		EXTRACT(year FROM date(d.timestamp)) as _year,v.value_type as measurement,
		cast(AVG(cast(v.value as double precision)) as decimal(10,2)) as month_avg		
into temp store																   -- this is a temporary storage location for the output of this query
from sensors_node as n
full join sensors_sensor as s 
on n.id=s.node_id  
full join sensors_sensorlocation as l 
on n.location_id=l.id 
full join sensors_sensordata as d												--this part OF the script combines ALL neccesary tables UNDER the name sensors_combined
on d.sensor_id = s.id
full join sensors_sensordatavalue as v 
on v.sensordata_id = d.id 
where v.value ~'(^[0-9]+\.?[[0-9]*$)'											--this line CONTAINS a regex that filters the 'sensors_datavalue_value' (values) COLUMN so we have ONLY VALUES FROM 00.00 TO 99.99
		--and sensors_node_id = 3												--this line can be used to limit the output to a particular sensor node (kit)
		--and v.value_type = 'P2'
		and d.timestamp between '2022-01-01' and '2022-08-31'					--this line filters the OUTPUT so ONLY VALUES FROM the CURRENT time TO a YEAR PRIOR (1 year interval)
		and (v.value_type = 'P0' or v.value_type = 'P1' or v.value_type != 'P2'   --this line filters the OUTPUT TO ONLY P0, P1 AND P2, temperature , humidity values
		or v.value_type = 'temperature' or v.value_type != 'humidity')
group by EXTRACT(year FROM date(d.timestamp)), n.id, l.id, EXTRACT(month FROM date(d.timestamp)),		-- this SECTION groups the VALUES FROM the selected columns so the SIMILAR VALUES IN EACH COLUMN ARE put together
		v.value_type, l.location;																		-- this also dtermine how the average FOR EACH measured value IS calculated



insert into sensors_monthlyavg(location,location_id, _month, _year, measurement, day_avg)				--pointing to the table we want to append the dat to (with its columna in bracket)
select *																								-- selecting all data from our temporary storage location
from store;

select * from sensors_monthlyavg;																			-- viewing our tabble


