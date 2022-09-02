select 
snt.location_id,
extract(day from '${date}'::timestamp)as day,
TO_CHAR('${date}'::timestamp,'Mon') as month,
extract(year from '${date}'::timestamp)as year,
sdv.value_type measurement,
AVG(cast(value as double precision)) as day_avg,
snt.node_id
from sensors_sensordatavalue sdv
inner join 
(select 
		sd.id sensordata_id,
		sd.sensor_id,
		sd."timestamp"  sensordata_tsp,
		ss.node_id,
		sd.location_id
		from sensors_sensordata sd
		inner join sensors_sensor ss on sd.sensor_id =ss.id 		
)snt
on snt.sensordata_id=sdv.sensordata_id 
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
