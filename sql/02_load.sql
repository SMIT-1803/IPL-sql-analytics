-- Load raw Cricsheet IPL ball-by-ball CSV into the staging table.
TRUNCATE staging_deliveries;

\copy staging_deliveries FROM 'data/all_matches.csv' WITH (FORMAT csv, HEADER true)