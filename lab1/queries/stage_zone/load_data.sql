USE winter_olympics_stage;

TRUNCATE TABLE discipline_details;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\discipline_details.csv'
 INTO TABLE discipline_details
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS
 (event_number,
 event_year,
 discipline,
 category,
 `date`,
 n_participants,
 n_country_participants,
 gold_medalist,
 gold_country,
 silver_medalist,
 silver_country,
 bronze_medalist,
 bronze_country);

TRUNCATE TABLE events_medals;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\events_medals.csv'
 INTO TABLE events_medals
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS
(event_number,
event_year,
country,
gold,
silver,
bronze,
total);

TRUNCATE TABLE olympic_events;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_events.csv'
 INTO TABLE olympic_events
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS
( event_city,
 event_country,
 event_number,
 event_year,
 opening_ceremony,
 closing_ceremony,
 n_participants,
 n_countries,
 n_medals,
 n_disciplines);

TRUNCATE TABLE regions;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\noc_regions.csv'
 INTO TABLE regions
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS
    (ioc, country);

# Remove newline symbols from the names of countries

UPDATE regions SET country = REPLACE(REPLACE(country, '\r', ''), '\n', '');
UPDATE discipline_details SET bronze_country = REPLACE(REPLACE(bronze_country, '\r', ''), '\n', '');