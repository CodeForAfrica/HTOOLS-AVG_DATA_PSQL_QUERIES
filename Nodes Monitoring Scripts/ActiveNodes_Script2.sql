-----------active nodes created by usman------------
with actives as (
	-------a wrapper to hold section 1 and 2 of the script together
	with two as (
		select
			distinct on (ss.id) ss.id as sensorid,
			sn.uid as uid,
			sd.timestamp as sensors_last_active,
			--- section 1 starts
			ss.sensor_type_id AS sensor_type_ids,
			st.name AS sensor_names,
			sln.id as location
		from
			sensors_sensordata sd
			INNER JOIN sensors_sensor ss on ss.id = sd.sensor_id
			INNER JOIN sensors_node sn ------this section gets the most recent time stamp of all sensors that have sent  
			on sn.id = ss.node_id ---data to the DB within the last 3hrs
			INNER JOIN sensors_sensortype st ------ take not that it is each individual sensor and not each node or kit
			on st.id = ss.sensor_type_id
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
	) -----end of section 2
	---
	--select * from two   ---this part helps us track our results, uncomment to see the results of section 1
	select
		uid,
		array_agg(sensorid) as sensor_id,
		array_agg(sensors_last_active) as last_active,
		---- section 2 starts
		array_agg(sensor_type_ids) as sensor_type_ids,
		array_agg(sensor_names) as sensor_names,
		sl.location as location,
		sl.city as city,
		sl.country as country,
		sl.description as description
	from
		two -------this section aggragates the output of section 1 and groups them per node(sensor kit)
		inner join sensors_sensorlocation sl --------this means all sensors are grouped by the node(sensor kit) they belong to
		on two.location = sl.id
	group by
		uid,
		sl.location,
		sl.city,
		sl.country,
		sl.description
) ---- end of section 2 and the wrapper holding section 1 and 2 together
--
select
	*
from
	actives;

--- outputs the result of our secript