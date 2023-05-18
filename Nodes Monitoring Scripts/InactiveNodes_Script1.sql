----------Inactive nodes created by usman --------------------------------
with nodes as (
	-------a wrapper to holding  section 1 of the script together
	--
	with one as (
		select
			distinct on (ss.id) ss.id as sensorid,
			sn.uid as uid,
			sd.timestamp as sensors_last_active,
			--- section 1a starts
			ss.sensor_type_id AS sensor_type_ids,
			st.name AS sensor_names,
			sln.id as location
		from
			sensors_sensordata sd
			INNER JOIN sensors_sensor ss on ss.id = sd.sensor_id ------this section gets the most recent time stamp of all sensors that have sent data to the 
			INNER JOIN sensors_node sn ---data to the DB within the last 3hrs. i.e all sensors irrespective of time
			on sn.id = ss.node_id ------ take not that it is each individual sensor and not each node or kit
			INNER JOIN sensors_sensortype st on st.id = ss.sensor_type_id
			INNER JOIN sensors_sensorlocation sln on sn.location_id = sln.id --where sd.timestamp  BETWEEN NOW()- INTERVAL '3 hours' AND NOW()   --uncomment to filter by time, but its not required here
		group by
			ss.id,
			sn.uid,
			st.name,
			sd.timestamp,
			sln.id
		order by
			ss.id,
			sd.timestamp desc
	) --- section 1a ends
	--
	--select * from __
	select
		uid,
		array_agg(sensorid) as sensor_id,
		array_agg(sensors_last_active) as last_active,
		--- section 1b starts
		array_agg(sensor_type_ids) as sensor_type_ids,
		array_agg(sensor_names) as sensor_names,
		sl.location as location,
		sl.city as city,
		sl.country as country,
		sl.description as description
	from
		one -------this section aggragates the output of section 1 and groups them per node (sensor kit)
		inner join sensors_sensorlocation sl --------this means all sensors are grouped by the node (sensor kit) they belong to
		on one.location = sl.id
	group by
		uid,
		sl.location,
		sl.city,
		sl.country,
		sl.description
),
--- section 1b ends, section 1 as a whole ends here
--
----
actives as (
	-------a wrapper to holding  section 2 of the script together						
	with two as (
		select
			distinct on (ss.id) ss.id as sensorid,
			sn.uid as uid,
			sd.timestamp as sensors_last_active,
			--- section 2a starts
			ss.sensor_type_id AS sensor_type_ids,
			st.name AS sensor_names,
			sln.id as location
		from
			sensors_sensordata sd
			INNER JOIN sensors_sensor ss ------this section gets the most recent time stamp of all sensors that have sent   
			on ss.id = sd.sensor_id ---data to the DB within the last 3hrs. i.e active sensors within the last 3hrs
			INNER JOIN sensors_node sn ------ take not that it is each individual sensor and not each node or kit
			on sn.id = ss.node_id
			INNER JOIN sensors_sensortype st on st.id = ss.sensor_type_id
			INNER JOIN sensors_sensorlocation sln on sn.location_id = sln.id
		where
			sd.timestamp BETWEEN NOW() - INTERVAL '3 hours'
			AND NOW() --- filter to get only sensors that have sent data within the last 3 hours
		group by
			ss.id,
			sn.uid,
			st.name,
			sd.timestamp,
			sln.id
		order by
			ss.id,
			sd.timestamp desc
	) -----end of section 2a
	---
	--select * from __
	select
		uid,
		array_agg(sensorid) as sensor_id,
		array_agg(sensors_last_active) as last_active,
		-----start of section 2b
		array_agg(sensor_type_ids) as sensor_type_ids,
		array_agg(sensor_names) as sensor_names,
		sl.location as location,
		sl.city as city,
		sl.country as country,
		sl.description as description
	from
		two -------this section aggragates the output of section 1 and groups them per node/(sensor kit)
		inner join sensors_sensorlocation sl --------this means all sensors are grouped by the node(sensor kit) they belong to
		on two.location = sl.id
	group by
		uid,
		sl.location,
		sl.city,
		sl.country,
		sl.description
) -----end of section 2b, and section 2 as a whole
--
select
	*
from
	nodes -----section 3
where
	nodes.uid not in (
		select
			actives.uid
		from
			actives
	);

---- section 3 filters the active nodes within the last 3hrs from the table with all the nodes (irrespective of time)