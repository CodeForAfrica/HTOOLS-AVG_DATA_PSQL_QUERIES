--******active noodes*******--
WITH active_nodes AS (
SELECT
	DISTINCT ON
	(sd.sensor_id) sensor_id ,
	"timestamp",
	sn.location_id,
	ss.sensor_type_id,
	st."name",
	sn.uid
FROM
	sensors_sensordata sd
INNER JOIN sensors_sensor ss ON
	ss.id = sd.sensor_id
INNER JOIN sensors_node sn ON
	sn.id = ss.node_id
INNER JOIN sensors_sensortype st ON
	st.id = ss.sensor_type_id
WHERE
	timestamp BETWEEN NOW()- INTERVAL '3 hours' AND NOW() -- CHANGE INTERVAL TIME FOR DESIRED PRECISION 
ORDER BY
	sensor_id,
	"timestamp" DESC) 
SELECT
	gd.uid,
	gd.sensors,
	gd.sensors_last_active,
	gd.sensor_type_ids,
	gd.sensor_names,
	sl.LOCATION,
	sl.city,
	sl.country,
	sn2.description
FROM
	(
	SELECT  -- GROUP associated node uid data
		uid,
		array_agg(sensor_id) AS sensors ,
		array_agg("timestamp")AS sensors_last_active,
		array_agg(sensor_type_id) AS sensor_type_ids,
		array_agg("name") AS sensor_names
	FROM
		active_nodes
	GROUP BY
		uid
) AS gd -- TABLE alias AFTER GROUPING THE DATA 
INNER JOIN sensors_node sn2 ON
	sn2.uid = gd.uid
INNER JOIN sensors_sensorlocation sl ON
	sn2.location_id = sl.id
;