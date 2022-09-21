drop table if exists sensors_dailyavg;			-- deletes table if it already exists


create table sensors_dailyavg(				-- creating a table with the name sensors_dailyavg
  --id SERIAL primary key,				    -- optional column to number the rows seriallly, and making the column a primary key 
  location varchar(255) not null,		 	-- column name with the data type it would hold and its bit length, not null meaning the column cannot be empty
  location_id int not null,					
  date date not null,
  _day int not null,
  _month int not null,
  _year int not null,
  measurement varchar(255) not null,
  day_avg int not null,
  status varchar(255) not null,
 constraint fk_sensorlocation foreign key(location_id) references sensors_sensorlocation(id)   -- setting a foreign key and referiencing the table(column) it connects to
);
--alter sequence sensors_dailyavg_id_seq restart with 1;

--insert into sensors_dailyavg(location, location_id, date, _day, _month, _year, measurement, day_avg, status)
--values('abg', 1, '20222-09-21',21,09, 2022, 'po', 1.22, 'NA');

select * from sensors_dailyavg;			  -- view the table created

