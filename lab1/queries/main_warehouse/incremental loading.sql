use winter_olympics_main;

truncate table winter_olympics_stage.discipline_details;
truncate table winter_olympics_stage.events_medals;
truncate table winter_olympics_stage.regions;
truncate table winter_olympics_stage.olympic_events;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\discipline_details2.csv'
    INTO TABLE winter_olympics_stage.discipline_details
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

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\events_medals2.csv'
    INTO TABLE winter_olympics_stage.events_medals
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

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_events2.csv'
    INTO TABLE winter_olympics_stage.olympic_events
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (event_city,
     event_country,
     event_number,
     event_year,
     opening_ceremony,
     closing_ceremony,
     n_participants,
     n_countries,
     n_medals,
     n_disciplines);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\noc_regions2.csv'
    INTO TABLE winter_olympics_stage.regions
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (ioc, country);



INSERT INTO discipline_details_dim (discipline, category)
SELECT DISTINCT discipline, category
FROM winter_olympics_stage.discipline_details dd
WHERE NOT EXISTS(SELECT discipline, category
                 FROM discipline_details_dim ddd
                 WHERE dd.discipline = ddd.discipline
                   AND dd.category = ddd.category);

INSERT INTO athlete_dim (name)
SELECT DISTINCT medalist_name
FROM (SELECT gold_medalist AS medalist_name
      FROM winter_olympics_stage.discipline_details
      UNION
      SELECT silver_medalist AS medalist_name
      FROM winter_olympics_stage.discipline_details
      UNION
      SELECT bronze_medalist AS medalist_name
      FROM winter_olympics_stage.discipline_details) as medalists
WHERE NOT EXISTS(SELECT medalist_name FROM athlete_dim ad WHERE medalists.medalist_name = ad.name);


INSERT INTO country_dim (country, IOC)
SELECT DISTINCT country, ioc
FROM winter_olympics_stage.regions r
WHERE NOT EXISTS(SELECT country, IOC
                 FROM country_dim cd
                 WHERE cd.IOC = r.ioc
                   AND cd.country = r.country);

INSERT INTO date_dim (YEAR)
SELECT DISTINCT `year`
FROM (SELECT event_year as `year`
      FROM winter_olympics_stage.discipline_details
      UNION
      SELECT event_year as `year`
      FROM winter_olympics_stage.events_medals
      UNION
      SELECT event_year as `year`
      FROM winter_olympics_stage.olympic_events) as years
WHERE NOT EXISTS(SELECT year FROM date_dim dd WHERE dd.year = years.year);

INSERT INTO event_place_dim (country_id, city)
SELECT DISTINCT cd.id, oe.event_city
FROM winter_olympics_stage.olympic_events oe
         JOIN country_dim cd
              ON oe.event_country = cd.country
WHERE NOT EXISTS(SELECT country_id, city
                 FROM event_place_dim ed
                 WHERE oe.event_city = ed.city);

INSERT INTO olympic_games_fact (place_id, date_id, event_number, n_participants, n_countries,
                                n_disciplines, n_medals)
SELECT DISTINCT ep.id AS place_id,
                dd.id AS date_id,
                o.event_number,
                o.n_participants,
                o.n_countries,
                o.n_disciplines,
                o.n_medals
FROM winter_olympics_stage.olympic_events o
         JOIN event_place_dim ep ON o.event_city = ep.city
         JOIN date_dim dd ON o.event_year = dd.year
WHERE NOT EXISTS(SELECT og.place_id, og.date_id, og.event_number
                 FROM olympic_games_fact og
                 WHERE ep.id = og.place_id
                   AND dd.id = og.date_id
                   AND o.event_number = og.event_number);

SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO country_performance_fact (country_id, event_id, date_id, gold, silver, bronze, total)
SELECT DISTINCT cd.id as country_id, og.id as event_id, dd.id as date_id, em.gold, em.silver, em.bronze, em.total
FROM winter_olympics_stage.events_medals as em
         JOIN country_dim cd on cd.country = em.country
         JOIN olympic_games_fact og on og.event_number = em.event_number
         JOIN date_dim dd on dd.year = em.event_year
WHERE NOT EXISTS(SELECT cp.country_id, cp.event_id, cp.date_id
                 FROM country_performance_fact cp
                 WHERE cd.id = cp.country_id
                   AND og.id = cp.id
                   AND dd.id = cp.date_id);
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO discipline_fact (discipline_details_id, event_id, gold_medalist_id, gold_country_id,
                             silver_medalist_id, silver_country_id, bronze_medalist_id,
                             bronze_country_id)
SELECT DISTINCT dd.id  as discipline_details_id,
                og.id  as event_id,
                adg.id as gold_medalist_id,
                cdg.id as gold_country_id,
                ads.id as silver_medalist_id,
                cds.id as silver_country_id,
                adb.id as bronze_medalist_id,
                cdb.id as bronze_country_id
FROM winter_olympics_stage.discipline_details as disciplines
         JOIN discipline_details_dim dd
              ON (dd.category = disciplines.category AND dd.discipline = disciplines.discipline)
         JOIN olympic_games_fact og
              ON og.event_number = disciplines.event_number
         JOIN athlete_dim adg
              ON adg.name = disciplines.gold_medalist
         JOIN country_dim as cdg
              ON cdg.IOC = disciplines.gold_country
         JOIN athlete_dim ads
              ON ads.name = disciplines.silver_medalist
         JOIN country_dim as cds
              ON cds.IOC = disciplines.silver_country
         JOIN athlete_dim adb
              ON adb.name = disciplines.bronze_medalist
         JOIN country_dim as cdb
              ON cdb.IOC = disciplines.bronze_country
WHERE NOT EXISTS(SELECT df.event_id, df.discipline_details_id
                 FROM discipline_fact df
                 WHERE og.id = df.event_id
                 AND dd.id = df.discipline_details_id);