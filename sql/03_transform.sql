BEGIN;

TRUNCATE fact_delivery, dim_match, dim_venue, dim_player, dim_team;

INSERT INTO dim_venue(venue_name)
SELECT DISTINCT venue
FROM staging_deliveries
WHERE venue is NOT NULL AND venue!='';


INSERT INTO dim_player(player_name)
SELECT striker
FROM staging_deliveries
WHERE striker is NOT NULL AND striker!=''
UNION
SELECT non_striker
FROM staging_deliveries
WHERE non_striker is NOT NULL AND non_striker!=''
UNION
SELECT bowler
FROM staging_deliveries
WHERE bowler is NOT NULL AND bowler!=''
UNION
SELECT player_dismissed
FROM staging_deliveries
WHERE player_dismissed is NOT NULL AND player_dismissed!='';


INSERT INTO dim_team(team_name)
SELECT batting_team
from staging_deliveries
WHERE batting_team is NOT NULL AND batting_team!=''
UNION
SELECT bowling_team
from staging_deliveries
WHERE bowling_team is NOT NULL AND bowling_team!='';


INSERT INTO dim_match(
    match_id,
    venue_key,
    start_date,
    season
)
SELECT DISTINCT match_id::BIGINT, venue_key, start_date::date, (SUBSTRING(start_date FOR 4))::INT
FROM staging_deliveries
JOIN dim_venue ON staging_deliveries.venue = dim_venue.venue_name;


INSERT INTO fact_delivery(
    match_id,
    batting_team_key,
    bowling_team_key,
    wicket_type,
    player_dismissed_key,
    striker_key,
    non_striker_key,
    bowler_key,
    innings,
    ball,
    runs_off_bat,
    wides,
    noballs,
    byes,
    legbyes
)
SELECT 
    stage.match_id::BIGINT,
    batting.team_key,
    bowling.team_key,
    NULLIF(stage.wicket_type,''),
    player_dismissed.player_key,
    striker.player_key,
    non_striker.player_key,
    bowler.player_key,
    stage.innings::SMALLINT,
    stage.ball::text,
    stage.runs_off_bat::SMALLINT,
    COALESCE(NULLIF(stage.wides,'')::SMALLINT,0),
    COALESCE(NULLIF(stage.noballs,'')::SMALLINT,0),
    COALESCE(NULLIF(stage.byes,'')::SMALLINT,0),
    COALESCE(NULLIF(stage.legbyes,'')::SMALLINT,0)
FROM staging_deliveries as stage
JOIN dim_team as batting ON stage.batting_team = batting.team_name
JOIN dim_team as bowling ON stage.bowling_team = bowling.team_name
JOIN dim_player as striker ON stage.striker = striker.player_name
JOIN dim_player as non_striker ON stage.non_striker = non_striker.player_name
JOIN dim_player as bowler ON stage.bowler = bowler.player_name
LEFT JOIN dim_player as player_dismissed ON stage.player_dismissed = player_dismissed.player_name
;

COMMIT;