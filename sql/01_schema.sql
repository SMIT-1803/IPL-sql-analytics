-- Staging Table
DROP TABLE IF EXISTS staging_deliveries;
CREATE TABLE staging_deliveries (
    match_id text,
    season text,
    start_date text,
    venue text,
    innings text,
    ball text,
    actual_delivery text,
    batting_team text,
    bowling_team text,
    striker text,
    non_striker text,
    bowler text,
    runs_off_bat text,
    extras text,
    wides text,
    noballs text,
    byes text,
    legbyes text,
    penalty text,
    non_boundary text,
    wicket_type text,
    player_dismissed text,
    other_wicket_type text,
    other_player_dismissed text,
    fielder_1 text,
    fielder_2 text,
    fielder_3 text
);

-- Venue Dimension
DROP TABLE IF EXISTS dim_venue;
CREATE TABLE dim_venue (
    venue_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venue_name text NOT NULL UNIQUE
);

-- Player Dimension
DROP TABLE IF EXISTS dim_player;
CREATE TABLE dim_player (
    player_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    player_name text NOT NULL UNIQUE
);

-- Team Dimension
DROP TABLE IF EXISTS dim_team;
CREATE TABLE dim_team (
    team_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_name text NOT NULL UNIQUE
);

-- Match Dimension
DROP TABLE IF EXISTS dim_match;
CREATE TABLE dim_match (
    match_id BIGINT PRIMARY KEY,
    venue_key INT NOT NULL REFERENCES dim_venue(venue_key),
    start_date date NOT NULL,
    season INT NOT NULL
);

-- Fact Table
DROP TABLE if EXISTS fact_delivery;
CREATE TABLE fact_delivery (
    delivery_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    match_id BIGINT NOT NULL REFERENCES dim_match(match_id),
    batting_team_key INT NOT NULL REFERENCES dim_team(team_key),
    bowling_team_key INT NOT NULL REFERENCES dim_team(team_key),
    wicket_type text,
    player_dismissed_key INT REFERENCES dim_player(player_key),
    striker_key INT NOT NULL REFERENCES dim_player(player_key),
    non_striker_key INT NOT NULL REFERENCES dim_player(player_key),
    bowler_key INT NOT NULL REFERENCES dim_player(player_key),
    innings SMALLINT NOT NULL,
    ball text NOT NULL,
    runs_off_bat SMALLINT NOT NULL,
    wides SMALLINT NOT NULL DEFAULT 0,
    noballs SMALLINT NOT NULL DEFAULT 0,
    byes SMALLINT NOT NULL DEFAULT 0,
    legbyes SMALLINT NOT NULL DEFAULT 0
);