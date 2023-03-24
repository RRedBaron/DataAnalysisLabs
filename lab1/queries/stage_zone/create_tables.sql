USE winter_olympics_stage;

DROP TABLE IF EXISTS discipline_details;
DROP TABLE IF EXISTS regions;
DROP TABLE IF EXISTS events_medals;
DROP TABLE IF EXISTS olympic_events;

CREATE TABLE IF NOT EXISTS discipline_details (
    id INT NOT NULL AUTO_INCREMENT,
    event_number VARCHAR(10),
    event_year YEAR,
    discipline VARCHAR(255),
    category VARCHAR(255),
    `date` VARCHAR(30),
    n_participants INT,
    n_country_participants INT,
    gold_medalist VARCHAR(255),
    gold_country VARCHAR(255),
    silver_medalist VARCHAR(255),
    silver_country VARCHAR(255),
    bronze_medalist VARCHAR(255),
    bronze_country VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS events_medals (
    id INT NOT NULL AUTO_INCREMENT,
    event_number VARCHAR(10),
    event_year YEAR,
    country VARCHAR(255),
    gold INT,
    silver INT,
    bronze INT,
    total INT,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS olympic_events (
    id INT NOT NULL AUTO_INCREMENT,
    event_city VARCHAR(255),
    event_country VARCHAR(255),
    event_number VARCHAR(10),
    event_year YEAR,
    opening_ceremony VARCHAR(30),
    closing_ceremony VARCHAR(30),
    n_participants INT,
    n_countries INT,
    n_medals INT,
    n_disciplines INT,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS regions (
    id INT NOT NULL AUTO_INCREMENT,
    ioc VARCHAR(5),
    country VARCHAR(255),
    PRIMARY KEY (id)
);