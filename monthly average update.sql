------ GETS AVERAGE VALUES FROM sensors_dailyavg[year] TABLE ---------------

select 	location,location_id, _month as Month, _year, parameter,
		AVG(cast(day_avg as float))::numeric(10,4) as month_avg		-- calculate the average monthly value with a resolution of 4 decimal places                   
into temp monthlyavgtable_temp										-- this is a temporary storage location for the output of this query
from sensors_dailyavg2022 
where date between '2022-01-01' and '2022-09-30'
group by  Month,location, location_id, parameter,_year
order by month asc;


-----------------------------------------------------------------

select * from monthlyavgtable_temp;      -- view temporary table

---------- INSERT INTO sensors_monthlyavg[year] TABLE----------------------------------------

insert into sensors_monthlyavg2022(location,location_id, Month, _year, parameter, month_avg)	--pointing to the table we want to append the data to (with its columnns in bracket)
select location,location_id, Month, _year, parameter, month_avg								    --selecting all data from our temporary storage location
from monthlyavgtable_temp;

----------------------------------------------------------------------------------------------

select * from sensors_monthlyavg2022;  	-- viewing saved data to respective table

------------ DELETE TEMPORARY TABLE WHEN DONE-------------------------------------------------
drop table if exists monthlyavgtable_temp;