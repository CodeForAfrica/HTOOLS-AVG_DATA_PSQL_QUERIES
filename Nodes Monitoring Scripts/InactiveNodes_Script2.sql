
-----Created by Gideon----
-----procedure----
--1. Get sensor data whose timestamps do not fall between NOW and 12 hours before NOW and order with latest timestamp 
--2. Select first instance of sensor id with DISTINCT ON sensor id
--3. AGGREGATE sensor ids, timestamp and name associated with a node
--4  Filter out nodes that have at least one active sensor 

WITH inactive_nodes AS ( 
    SELECT --select all inactive sensors for a given period of time
        DISTINCT ON (sn.uid) sn.uid AS node_id,
        array_agg(sdata.sensor_id) AS sensors,
        array_agg(sdata."timestamp") AS sensors_last_active,
        array_agg(st.uid) AS sensor_type_ids,
        array_agg(st."name") AS sensor_names,
        sl."location",
        sl.city,
        sl.country
    FROM
        sensors_sensor ss
        INNER JOIN (
            SELECT
                DISTINCT ON (sd.sensor_id) sensor_id,
                sd."timestamp",
                sd.location_id
            FROM
                sensors_sensordata sd
            WHERE
                sd.timestamp NOT BETWEEN NOW() - INTERVAL '12 hours'
                AND NOW()
            ORDER BY
                sd.sensor_id,
                sd."timestamp" DESC
        ) AS sdata ON ss.id = sdata.sensor_id
        INNER JOIN sensors_node sn ON ss.node_id = sn.id
        INNER JOIN sensors_sensortype st ON ss.sensor_type_id = st.id
        INNER JOIN sensors_sensorlocation sl ON sl.id = sn.location_id
    GROUP BY
        sn.uid,
        sl."location",
        sl.city,
        sl.country
)
SELECT
    *
FROM
    inactive_nodes inactv
WHERE
    inactv.node_id NOT IN ( -- filter inactive node that have at least one active sensor
        SELECT
            DISTINCT ON (uid) uid
        FROM
            ( -- select node that has at least one active sensor
                SELECT
                    DISTINCT ON (sd.sensor_id) sd.sensor_id,
                    sn.uid
                FROM
                    sensors_sensordata sd
                    INNER JOIN sensors_sensor ss ON ss.id = sd.sensor_id
                    INNER JOIN sensors_node sn ON ss.node_id = sn.id
                WHERE
                    sd."timestamp" BETWEEN NOW() - INTERVAL '12 hours'
                    AND NOW()
                ORDER BY
                    sd.sensor_id
            ) AS active_sensors
    );