use winter_olympics_stage;

INSERT INTO winter_olympics_main.discipline_details_dim (discipline, category)
SELECT DISTINCT discipline, category
FROM winter_olympics_stage.discipline_details;

INSERT INTO winter_olympics_main.athlete_dim (name)
SELECT DISTINCT medalist_name
FROM (SELECT gold_medalist AS medalist_name
      FROM winter_olympics_stage.discipline_details
      UNION
      SELECT silver_medalist AS medalist_name
      FROM winter_olympics_stage.discipline_details
      UNION
      SELECT bronze_medalist AS medalist_name
      FROM winter_olympics_stage.discipline_details) as medalists;

INSERT INTO winter_olympics_main.country_dim (country, IOC)
SELECT country, ioc
FROM winter_olympics_stage.regions;

INSERT INTO winter_olympics_main.date_dim (YEAR)
SELECT DISTINCT `year`
FROM (SELECT event_year as `year`
      FROM discipline_details
      UNION
      SELECT event_year as `year`
      FROM events_medals
      UNION
      SELECT event_year as `year`
      FROM olympic_events) as years;

INSERT INTO winter_olympics_main.event_place_dim (country_id, city)
SELECT DISTINCT winter_olympics_main.country_dim.id, olympic_events.event_city
FROM olympic_events
         JOIN winter_olympics_main.country_dim
              ON olympic_events.event_country = country_dim.country;

INSERT INTO winter_olympics_main.olympic_games_fact (place_id, date_id, event_number, n_participants, n_countries,
                                                     n_disciplines, n_medals)
SELECT ep.id AS place_id,
       dd.id AS date_id,
       o.event_number,
       o.n_participants,
       o.n_countries,
       o.n_disciplines,
       o.n_medals
FROM winter_olympics_stage.olympic_events o
         JOIN winter_olympics_main.event_place_dim ep ON o.event_city = ep.city
         JOIN winter_olympics_main.date_dim dd ON o.event_year = dd.year;

SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO winter_olympics_main.country_performance_fact (country_id, event_id, date_id, gold, silver, bronze, total)
SELECT cd.id as country_id, og.id as event_id, dd.id as date_id, em.gold, em.silver, em.bronze, em.total
FROM events_medals as em
         JOIN winter_olympics_main.country_dim cd on cd.country = em.country
         JOIN winter_olympics_main.olympic_games_fact og on og.event_number = em.event_number
         JOIN winter_olympics_main.date_dim dd on dd.year = em.event_year;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO winter_olympics_main.discipline_fact (discipline_details_id, event_id, gold_medalist_id, gold_country_id,
                                                  silver_medalist_id, silver_country_id, bronze_medalist_id,
                                                  bronze_country_id)
SELECT dd.id as discipline_details_id,
       og.id as event_id,
       adg.id as gold_medalist_id,
       cdg.id as gold_country_id,
       ads.id as silver_medalist_id,
       cds.id as silver_country_id,
       adb.id as bronze_medalist_id,
       cdb.id as bronze_country_id
FROM discipline_details as disciplines
         JOIN winter_olympics_main.discipline_details_dim dd
              ON (dd.category = disciplines.category AND dd.discipline = disciplines.discipline)
         JOIN winter_olympics_main.olympic_games_fact og
              ON og.event_number = disciplines.event_number
         JOIN winter_olympics_main.athlete_dim adg
              ON adg.name = disciplines.gold_medalist
         JOIN winter_olympics_main.country_dim as cdg
              ON cdg.IOC = disciplines.gold_country
         JOIN winter_olympics_main.athlete_dim ads
              ON ads.name = disciplines.silver_medalist
         JOIN winter_olympics_main.country_dim as cds
              ON cds.IOC = disciplines.silver_country
         JOIN winter_olympics_main.athlete_dim adb
              ON adb.name = disciplines.bronze_medalist
         JOIN winter_olympics_main.country_dim as cdb
              ON cdb.IOC = disciplines.bronze_country