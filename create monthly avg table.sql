--THIS TABLE STORES MONTHLY AVERAGE DATA QUERIED FROM sensors_dailyavg[year] TABLE

drop table if exists sensors_monthlyavg2022;  

create table sensors_monthlyavg2022( 		 
  location varchar(255) not null,
  location_id int not null,		 
  Month int not null,
  _year int not null,
  parameter varchar(255) not null, --type of measurement/value_type e.g. temperature, PM 2.5
  month_avg float not null,
  constraint fk_sensorlocation foreign key(location_id) references sensors_sensorlocation(id)   -- setting a foreign key and referiencing the table(column) it connects to
);
