libname nyc "C:\Users\rsharma3\Documents\GitHub\BRT\Group assignment"; run;


proc sql;
*Query 1: how many destinations served by each airport;

create table busyairports as
select ap.faa, ap.name, count(fl.flight) as total_flights, count(distinct fl.dest) as Destinations
from nyc.flights as fl, nyc.airports as ap
where fl.origin = ap.faa
group by 1, 2
;
quit;
run;


proc sql;
*Query 2: which destinations served by each airport;

create table nyc.destserved as
select origin, dest as destination, count(flight) as total_flights
from nyc.flights
group by 1, 2
;
quit;
run;

proc sql;
*Query 3: top 5 destinations from each airport;
create table nyc.topfivedestn as
select a.origin, a.destination, a.total_flights, 
		(select count(distinct b.total_flights)
			from nyc.destserved as b
			where b.total_flights >= a.total_flights
			and a.origin = b.origin) as rank
from nyc.destserved as a
where calculated rank <= 5 
group by 1, 2
order by 1 asc, 4 asc
;
quit;
run;


proc sql;

*Query 4: how many flights at each airport have delayed departure and by how many minutes;
create table nyc.departdelayairport as 
select fl.origin, 
		(select count(*)
			from nyc.flights as a
			where a.origin=fl.origin)as total_flights, 
		count(fl.flight)/ap.flight as percent_delay format=percent8.2, round(avg(fl.dep_delay),0.02) as mins_delay
from nyc.flights fl, (select origin, count(*) as flight from nyc.flights group by 1) as ap
where fl.dep_delay > 0
and fl.origin = ap.origin
group by 1
order by 4
;
quit;
run;


proc sql;
*Query 5: which carriers have the highest instance of departure delays;
create table nyc.delaycarrierseasons as
select fl.origin, fl.carrier, count(fl.flight) as flt_count, 
count(fl.flight)/ap.flight as per_del format=percent8.2, avg(fl.dep_delay) as del_dur
from nyc.flights fl, (select origin, count(*) as flight from nyc.flights group by 1) ap
where fl.dep_delay > 0
and fl.origin = ap.origin
group by 1, 2;
quit;
run;


proc sql;
*Query 6: which carriers have the highest instance of cancelled flights;
create table nyc.cancelled as 
select fl.origin, fl.carrier, count(fl.sched_dep_time) as cancelled_flights, 
count(fl.sched_dep_time)/ori.fli as perc format=percent7.2
from nyc.flights as fl, (select origin, count(flight) as fli
							from nyc.flights 
                            group by origin) as ori
where fl.origin = ori.origin 
and fl.sched_dep_time is not null and fl.dep_time is null
group by 1, 2
order by 1 asc, 4 desc ;
quit;
run;


proc sql;
*Query 7: which seasons are busiest for which airports;
create table nyc.airportseasons as
select ap.faa as origin, ap.name, (case 
								when (fl.month >=3 and fl.month <=5) then "Spring"
								when (fl.month >=6 and fl.month <=8) then "Summer"
								when (fl.month >=9 and fl.month <=11) then "Fall"
								else "Winter"
								end) as season,
	count(fl.flight) as total_flights, 
	count(fl.flight)/orn.flight as percent_delay format=percent8.2, avg(fl.dep_delay) as mins_delay
from nyc.flights as fl, nyc.airports as ap, (select origin, count(*) as flight from nyc.flights group by 1) as orn
where fl.origin = ap.faa
and fl.origin = orn.origin
and fl.dep_delay > 0
group by 1, 2, 3
order by 1 asc, 5 desc;
quit;
run;


proc sql;
*Query 8: pattern of flight delays depending on months;
create table nyc.Flights_Dep_delay as
select avg(f.dep_delay) as avg_delay, f.month, origin
    from nyc.flights as f
group by 2,3
order by 2;
quit;
run;

proc sql;
*Query 9: pattern of flight delays depending on the hour of departure;
create table nyc.Total_Delays as
select hour, count(*) as nbr_flights, avg(dep_delay) as Avg_Delays
from airport.flights
group by 1
order by 1;
quit;
run;

proc sql;
*Query 10: how humidity affects delays at airports;
create table nyc.airporthumid as
select f.origin, w.humid, count(f.flight) as flights, avg(f.dep_delay) as delay
from nyc.flights f,	
		nyc.weather w
where f.time_hour = w.time_hour
and w.humid is not null
group by 1, 2
order by 2;
quit;
run;

proc sql;
*Query 11: how dewpoint affects delays at airports;
create table nyc.airportdewp as
select f.origin, w.dewp, count(f.flight) as flights, avg(f.dep_delay) as delay
from nyc.flights f,
		nyc.weather w
where f.time_hour = w.time_hour
and w.dewp is not null
group by 1, 2
order by 2;
quit;
run;

proc sql;
*Query 12: how visibility affects delays at airports;
create table nyc.airportvisib as
select f.origin, w.visib, count(f.flight) as flights, avg(f.dep_delay) as delay
from nyc.flights f,	
		nyc.weather w
where f.time_hour = w.time_hour
group by 1, 2
order by 2;
quit;
run;

proc sql;
*Query 13: how precipitation affects delays at airports;
create table nyc.airportprecip as
select f.origin, w.precip, count(f.flight) as flights, avg(f.dep_delay) as delay
from nyc.flights f,	
		nyc.weather w
where f.time_hour = w.time_hour
and w.precip is not null
group by 1, 2
order by 2;
quit;
run;