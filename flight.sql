DROP TABLE a4_airport;
DROP TABLE a4_plane;
DROP TABLE a4_crew_member;
DROP TABLE a4_flight;
DROP TABLE a4_aircraft;
DROP TABLE a4_flight_crew;

CREATE TABLE a4_airport
	(code CHAR(4) NOT NULL,
  	 city VARCHAR(80) NOT NULL,
  	 country VARCHAR(80) NOT NULL,
PRIMARY KEY (code));

CREATE TABLE a4_plane
	(registration_numb INT NOT NULL,
	year_made YEAR,
	manufacturer VARCHAR(80),
	model VARCHAR(80),
PRIMARY KEY (registration_numb));

CREATE TABLE a4_crew_member
	(id INT NOT NULL,
	f_name VARCHAR(80) NOT NULL,
	l_name VARCHAR(80) NOT NULL,
PRIMARY KEY (id));

CREATE TABLE a4_flight
	(id INT NOT NULL,
	flight_number INT NOT NULL,
  	dep_location CHAR(4),
  	arr_location CHAR(4),
  	flight_date DATE NOT NULL,
  	dep_time TIME NOT NULL,
  	arr_time TIME NOT NULL,
	domestic BOOLEAN NOT NULL DEFAULT 0,
PRIMARY KEY (id),
FOREIGN KEY (dep_location) REFERENCES a4_airport(code),
FOREIGN KEY (arr_location) REFERENCES a4_airport(code));

CREATE TABLE a4_aircraft
	(flight_id INT NOT NULL,
	plane_id INT NOT NULL,
FOREIGN KEY (flight_id) REFERENCES a4_flight(id),
FOREIGN KEY (plane_id) REFERENCES a4_plane(registration_numb));

CREATE TABLE a4_flight_crew
	(flight_id INT NOT NULL,
	crew_id INT NOT NULL,
	job ENUM('Pilot', 'Co-Pilot', 'Navigator', 'Attendant'),
FOREIGN KEY (flight_id) REFERENCES a4_flight(id),
FOREIGN KEY (crew_id) REFERENCES a4_crew_member(id));


INSERT INTO a4_airport VALUES ('RDU', 'Raleigh/Durham', 'United States');
INSERT INTO a4_airport VALUES ('JFK', 'New York', 'United States');
INSERT INTO a4_airport VALUES ('SYD', 'Sydney', 'Australia');
INSERT INTO a4_plane VALUES (1, '1999', 'Boeing', '777');
INSERT INTO a4_plane VALUES (2, '2005', 'Airbus', 'A-380');
INSERT INTO a4_crew_member VALUES (1, 'Brian', 'Zimorowicz');
INSERT INTO a4_crew_member VALUES (27, 'Big', 'Bird');
INSERT INTO a4_crew_member VALUES (23, 'Michael', 'Jordan');
INSERT INTO a4_flight VALUES (1, 50, 'RDU', 'JFK', '2014-10-16', '08:00:00', '09:30:00', 1);
INSERT INTO a4_flight VALUES (2, 50, 'RDU', 'DFW', '2014-10-16', '08:00:00', '09:30:00', 1);
INSERT INTO a4_flight VALUES (3, 100, 'RDU', 'DFW', '2013-10-16', '08:00:00', '09:30:00', 1);
INSERT INTO a4_flight VALUES (4, 200, 'JFK', 'SYD', '2013-11-17', '08:00:00', '09:30:00', 0);
INSERT INTO a4_flight VALUES (5, 200, 'JFK', 'SYD', '2009-11-17', '08:00:00', '09:30:00', 0);
INSERT INTO a4_flight VALUES (6, 20, 'JFK', 'RDU', '2013-11-16', '08:00:00', '09:30:00', 1);
INSERT INTO a4_flight VALUES (7, 20, 'JFK', 'RDU', '2013-11-17', '08:00:00', '09:30:00', 1);
INSERT INTO a4_flight VALUES (8, 20, 'JFK', 'RDU', '2013-11-18', '08:00:00', '09:30:00', 1);

INSERT INTO a4_aircraft VALUES (1, 1);
INSERT INTO a4_aircraft VALUES (2, 1);
INSERT INTO a4_aircraft VALUES (3, 2);
INSERT INTO a4_aircraft VALUES (4, 1);
INSERT INTO a4_aircraft VALUES (5, 1);
INSERT INTO a4_aircraft VALUES (6, 2);
INSERT INTO a4_aircraft VALUES (7, 2);
INSERT INTO a4_aircraft VALUES (8, 2);
INSERT INTO a4_flight_crew VALUES (1, 1, 'Pilot');
INSERT INTO a4_flight_crew VALUES (1, 27, 'Co-Pilot');
INSERT INTO a4_flight_crew VALUES (2, 27, 'Pilot');
INSERT INTO a4_flight_crew VALUES (2, 1, 'Co-Pilot');
INSERT INTO a4_flight_crew VALUES (2, 23, 'Attendant');
INSERT INTO a4_flight_crew VALUES (3, 27, 'Pilot');
INSERT INTO a4_flight_crew VALUES (3, 23, 'Co-Pilot');
INSERT INTO a4_flight_crew VALUES (4, 27, 'Navigator');
INSERT INTO a4_flight_crew VALUES (6, 23, 'Pilot');
INSERT INTO a4_flight_crew VALUES (7, 23, 'Pilot');
INSERT INTO a4_flight_crew VALUES (8, 23, 'Pilot');
INSERT INTO a4_flight_crew VALUES (4, 23, 'Co-Pilot');


# A list of crew members (i.e., first and last name) that have landed at DFW in 2014.

SELECT DISTINCT CONCAT(c.f_name, ' ', c.l_name) AS 'crew members that have landed at DFW in 2014'
FROM a4_crew_member c, a4_flight_crew fc, a4_flight f 
WHERE fc.crew_id=c.id AND fc.flight_id=f.id
AND f.flight_date >= '2014-01-01' 
AND f.flight_date <= '2014-12-31' 
AND f.arr_location='DFW';


# The number of flight segments flown by a Boeing 777 in the United States since 2010.

SELECT COUNT(a.plane_id) AS 'number of flight segments flown by a Boeing 777 in the United States since 2010'
FROM a4_aircraft a, a4_plane p, a4_flight f
WHERE a.plane_id=p.registration_numb AND a.flight_id=f.id 
AND p.manufacturer='Boeing' 
AND p.model='777'
AND f.flight_date >='2010-01-01'
AND f.domestic = 1;


# A list of all crew members that have flown an Airbus A-380 more than 3 times as its pilot or co-pilot.

SELECT CONCAT(c.f_name, ' ', c.l_name) AS 'crew members that have flown an Airbus A-380 more than 3 times as its pilot or co-pilot'
FROM a4_crew_member c, a4_plane p, a4_flight_crew fc, a4_flight f, a4_aircraft a
WHERE a.plane_id=p.registration_numb AND a.flight_id=f.id AND fc.crew_id=c.id AND fc.flight_id=f.id
AND p.manufacturer='Airbus'
AND p.model='A-380'
GROUP BY c.f_name, c.l_name
HAVING (COUNT(c.l_name) > 3);


# The total amount of time that a crew member identified by the crew member ID 27 has spent flying as either a pilot or co-pilot in October 2014.

SELECT SEC_TO_TIME(SUM(TIME_TO_SEC(TIMEDIFF(f.arr_time, f.dep_time)))) AS 'total amount of time that a crew member identified by the crew member ID 27 has spent flying as either a pilot or co-pilot in October 2014'
FROM a4_flight_crew fc, a4_flight f
WHERE fc.flight_id=f.id
AND (fc.crew_id = 27)
AND (fc.job ='Pilot' OR fc.job='Co-Pilot')
AND (f.flight_date >= '2014-10-01' AND f.flight_date <= '2014-10-31');


# A list of crew members that have been an attendant for any segment of flight number 50.

SELECT DISTINCT CONCAT(c.f_name, ' ', c.l_name) AS 'crew members that have been an attendant for any segment of flight number 50'
FROM a4_crew_member c, a4_flight f, a4_flight_crew fc
WHERE fc.flight_id=f.id AND fc.crew_id=c.id
AND f.flight_number=50
AND fc.job = 'Attendant';
