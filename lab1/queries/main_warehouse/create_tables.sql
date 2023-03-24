USE winter_olympics_main;

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE discipline_fact;
DROP TABLE athlete_dim;
DROP TABLE country_dim;
DROP TABLE country_performance_fact;
DROP TABLE date_dim;
DROP TABLE discipline_details_dim;
DROP TABLE event_place_dim;
DROP TABLE olympic_games_fact;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE IF NOT EXISTS discipline_details_dim (
    id INT NOT NULL AUTO_INCREMENT,
    discipline VARCHAR(255),
    category VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS athlete_dim (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS country_dim (
    id INT NOT NULL AUTO_INCREMENT,
    country VARCHAR(255),
    IOC VARCHAR(5),
    source_id int default null,
    start_date date default null,
    end_date date default null,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS date_dim (
    id INT NOT NULL AUTO_INCREMENT,
    year YEAR,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS event_place_dim (
    id INT NOT NULL AUTO_INCREMENT,
    country_id INT,
    city VARCHAR(80),
    PRIMARY KEY (id),
    FOREIGN KEY (country_id) REFERENCES country_dim (id)
);

CREATE TABLE IF NOT EXISTS olympic_games_fact (
    id INT NOT NULL AUTO_INCREMENT,
    place_id INT,
    date_id INT,
    event_number VARCHAR(10),
    n_participants INT,
    n_countries INT,
    n_disciplines INT,
    n_medals INT,
    PRIMARY KEY (id),
    FOREIGN KEY (place_id) REFERENCES event_place_dim (id),
    FOREIGN KEY (date_id) REFERENCES date_dim (id)
);

CREATE TABLE IF NOT EXISTS country_performance_fact (
    id INT NOT NULL AUTO_INCREMENT,
    country_id INT,
    event_id INT,
    date_id INT,
    gold INT,
    silver INT,
    bronze INT,
    total INT,
    PRIMARY KEY (id),
    FOREIGN KEY (country_id) REFERENCES country_dim (id),
    FOREIGN KEY (event_id) REFERENCES event_place_dim (id),
    FOREIGN KEY (date_id) REFERENCES date_dim (id)
);

CREATE TABLE IF NOT EXISTS discipline_fact (
    id INT NOT NULL AUTO_INCREMENT,
    discipline_details_id INT,
    event_id INT,
    gold_medalist_id INT,
    gold_country_id INT,
    silver_medalist_id INT,
    silver_country_id INT,
    bronze_medalist_id INT,
    bronze_country_id INT,
    PRIMARY KEY (id),
    FOREIGN KEY (discipline_details_id) REFERENCES discipline_details_dim (id),
    FOREIGN KEY (event_id) REFERENCES olympic_games_fact(id),
    FOREIGN KEY (gold_medalist_id) REFERENCES athlete_dim(id),
    FOREIGN KEY (gold_country_id) REFERENCES country_dim(id),
    FOREIGN KEY (silver_medalist_id) REFERENCES athlete_dim(id),
    FOREIGN KEY (silver_country_id) REFERENCES country_dim(id),
    FOREIGN KEY (bronze_medalist_id) REFERENCES athlete_dim(id),
    FOREIGN KEY (bronze_country_id) REFERENCES country_dim(id)
);