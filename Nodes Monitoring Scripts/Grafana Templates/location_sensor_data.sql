
-- Grafana template to query sensor data by location
SELECT sd."timestamp" AS time, sdv.value_type,CAST(sdv.value AS FLOAT)
FROM sensors_sensordatavalue sdv inner join sensors_sensordata sd
on sdv.sensordata_id =sd.id inner join sensors_sensor ss on
sd.sensor_id = ss.id inner join sensors_node sn on 
ss.node_id = sn.id inner join sensors_sensorlocation sl on sn.location_id =sl.id
where 
sl.country ='${Country}'
AND sl.city='${City}'
AND sl.LOCATION='${Location}'
AND sdv.value ~ '(^\d+\.?\d+$)|(^\d+$)'
AND sdv.value_type IN ('P0', 'P1', 'P2') -- Replace with desired value types
AND sd."timestamp" BETWEEN NOW() - INTERVAL '${Hours} hours' AND NOW() 
ORDER BY sd."timestamp" ASC
;