-- Template to query the avarage PM values by location for specific period during the present day
-- Grafana time ranges prefered
-- Variables need to be configured prior

SELECT
    date_trunc('day', NOW()) AS day,   -- Grafana needs a time column for pie charts
    COALESCE(AVG(CASE WHEN v.value_type = 'P0' THEN CAST(v.value AS FLOAT) END), 0)::numeric(10,2) AS "PM 1",
    COALESCE(AVG(CASE WHEN v.value_type = 'P1' THEN CAST(v.value AS FLOAT) END), 0)::numeric(10,2) AS "PM 10",
    COALESCE(AVG(CASE WHEN v.value_type = 'P2' THEN CAST(v.value AS FLOAT) END), 0)::numeric(10,2) AS "PM 2.5"
FROM sensors_node n
JOIN sensors_sensor s          ON n.id = s.node_id
JOIN sensors_sensorlocation l  ON n.location_id = l.id
JOIN sensors_sensordata d      ON d.sensor_id = s.id
JOIN sensors_sensordatavalue v ON v.sensordata_id = d.id
WHERE v.value ~ '(^\d+\.?\d*$)|(^\d+$)'
  AND l.country = '${Country}'
  AND l.city = '${City}'
  AND l.location = '${Location}'
  AND v.value_type IN ('P0','P1','P2')
  AND d.timestamp BETWEEN to_timestamp(${__from:date:seconds}) AND to_timestamp(${__to:date:seconds})
  --AND d.timestamp >= date_trunc('day', NOW())
  --AND d.timestamp <= NOW()
GROUP BY 1;