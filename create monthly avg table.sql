drop table if exists sensors_monthlyavg;  -- deletes table if it already exists

create table sensors_monthlyavg( 		  -- creating a table with the name sensors_monthlyavg
  --id SERIAL primary key,				  -- optional column to number the rows seriallly, and making the column a primary key 
   location varchar(255) not null,		  -- column name with the data type it would hold and its bit length, not null meaning the column cannot be empty
  location_id int not null,
  _month int not null,
  _year int not null,
  measurement varchar(255) not null,
  day_avg int not null,
 constraint fk_sensorlocation foreign key(location_id) references sensors_sensorlocation(id)   -- setting a foreign key and referiencing the table(column) it connects to
);
--alter sequence sensors_monthlyavg_id_seq restart with 1;



select * from sensors_monthlyavg;  -- view the table created

