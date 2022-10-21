/*
--TABLE NAMING CONVENTION--
sensors_dailyavg{year}
*/

--note respective year suffix for all operations 

drop table if exists sensors_dailyavg2022; --delete a table if it exists to create a new one with different structure
 
create table sensors_dailyavg2022(			
  location varchar(255) not null,		 	
  location_id int not null,					
  date date not null,
  _day int not null,
  _month int not null,
  _year int not null,
  parameter varchar(255) not null, --type of measurement e.g PM 1, HUMIDITY...
  day_avg float not null, --avg value of measurement for a particular day
  constraint fk_sensorlocation foreign key(location_id) references sensors_sensorlocation(id)  
);



select * from sensors_dailyavg;			  -- view the table created

