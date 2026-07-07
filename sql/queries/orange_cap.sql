-- Orange Cap: highest run-scorer per IPL season (window RANK over a grouped aggregate).
WITH season_runs AS (
    SELECT
        player_name,
        SUM(runs_off_bat) AS runs,
        season
    FROM
        fact_delivery
        JOIN dim_player AS striker ON fact_delivery.striker_key = striker.player_key
        JOIN dim_match AS match ON fact_delivery.match_id = match.match_id
    GROUP BY
        player_name,
        season
),
ranked_runs AS (
    SELECT
        season_runs.player_name,
        season_runs.runs,
        season_runs.season,
        RANK() OVER(
            PARTITION BY season
            ORDER BY
                Runs DESC
        ) AS player_rank
    FROM
        season_runs
)
SELECT
    ranked_runs.player_name,
    ranked_runs.Runs,
    ranked_runs.season
FROM
    ranked_runs
WHERE
    player_rank = 1
ORDER BY
    season;