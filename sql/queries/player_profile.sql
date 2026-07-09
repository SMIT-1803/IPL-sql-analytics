-- Player profile: full career batting card for a single player.

WITH career_stats AS (
    SELECT
        striker_key,
        COUNT(DISTINCT (match_id, innings)) AS innings_played,
        SUM(runs_off_bat) AS total_runs,
        SUM(
            CASE
                WHEN wides = 0 THEN 1
                ELSE 0
            END
        ) AS balls_faced,
        SUM(
            CASE
                WHEN runs_off_bat = 4 THEN 1
                ELSE 0
            END
        ) AS fours,
        SUM(
            CASE
                WHEN runs_off_bat = 6 THEN 1
                ELSE 0
            END
        ) AS sixes,
        SUM(
            CASE
                WHEN player_dismissed_key = striker_key THEN 1
                ELSE 0
            END
        ) AS dismissals
    FROM
        fact_delivery
    WHERE
        striker_key = %s
    GROUP BY
        striker_key
),
highest AS (
    SELECT
        MAX(innings_total) AS highest_score
    FROM
        (
            SELECT
                SUM(runs_off_bat) AS innings_total
            FROM
                fact_delivery
            WHERE
                striker_key = %s
                AND innings IN (1, 2)
            GROUP BY
                match_id,
                innings
        ) sub
),
player_info AS (
    SELECT
        player_name
    FROM
        dim_player
    WHERE
        player_key = %s
)
SELECT
    player_info.player_name,
    career_stats.innings_played,
    career_stats.total_runs,
    highest.highest_score,
    ROUND(
        career_stats.total_runs * 1.0 / NULLIF(career_stats.dismissals, 0),
        1
    ) AS batting_average,
    ROUND(
        career_stats.total_runs * 100.0 / NULLIF(career_stats.balls_faced, 0),
        1
    ) AS strike_rate,
    career_stats.fours,
    career_stats.sixes,
    career_stats.dismissals
FROM
    career_stats,
    highest,
    player_info;