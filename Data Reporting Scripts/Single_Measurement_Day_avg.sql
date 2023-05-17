select  								      		------------|			      		   ------------|
snt.location_id,											  --|--this section						 --|
extract(day from '${date}'::timestamp)as day,				  --|-SELECT relevant columns     	     --|
TO_CHAR('${date}'::timestamp,'Mon') as month,				  --|-FROM sensors_sensordatavalue  	 --|
extract(year from '${date}'::timestamp)as year,				  --|-while extracting DAY,MONTH,year	 --|
sdv.value_type measurement,					  				  --|-FROM timestamp			  		 --|
AVG(cast(value as double precision)) as day_avg,			  --|							  		 --|
snt.node_id													  --|							  		 --|--this two sections ARE combined toether
from sensors_sensordatavalue sdv					  ----------|							  		 --|
inner join 															  								 --|
(select 								      		----------|					  				     --|
		sd.id sensordata_id,								--|	--this section				  		 --|
		sd.sensor_id,       								--|---select and join relevant columns   --|
		sd."timestamp"  sensordata_tsp,				    	--|-- FROM 'sensors_sensordata' AND	     --|
		ss.node_id,										    --|--'sensors_sensor' tables USING their --| 
		sd.location_id									    --|--common columns UNDER tha name 'snt' --|
		from sensors_sensordata sd						    --|   								     --|
		inner join sensors_sensor ss on sd.sensor_id =ss.id --|									     --|
)snt												----------| 							  	     --|
on snt.sensordata_id=sdv.sensordata_id 			---			 -----		----	  	---	   ------------|
where 
	snt.sensor_id='${sensorId}' 
       and value_type='${valueType}'
       and value ~'(^\d+\.?\d+$)|(^\d+$)'
	and snt.sensordata_tsp
    between '${date}' and '${date}'::timestamp + interval '24 hours'
group by 
sdv.value_type,
snt.node_id,
snt.location_id, day,month,year
;


--Does not make sense for some mesurements like GPS data
