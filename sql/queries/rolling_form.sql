-- Rolling batting form: 5-innings moving average of runs per batter (window frame).
WITH innings_scores AS (
    SELECT
        match.match_id,
        match.start_date AS match_date,
        player_name,
        SUM(runs_off_bat) AS runs,
        innings
    FROM
        fact_delivery
        JOIN dim_player ON fact_delivery.striker_key = dim_player.player_key
        JOIN dim_match AS match ON fact_delivery.match_id = match.match_id
    GROUP BY
        match.match_id,
        player_name,
        innings
)
SELECT
    *,
    ROUND(
        AVG(runs) OVER (
            PARTITION BY player_name
            ORDER BY
                match_date,
                match_id ROWS BETWEEN 4 PRECEDING
                AND CURRENT ROW
        ),
        1
    ) AS rolling_form_5
FROM
    innings_scores
ORDER BY
    player_name,
    match_date,
    match_id;