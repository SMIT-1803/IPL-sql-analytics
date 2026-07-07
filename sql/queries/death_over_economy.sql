-- Death-over (16–20) bowling economy leaderboard, min 20 overs (runs conceded ÷ legal overs).
WITH parsed_data AS (
    SELECT
        player_key,
        player_name,
        (SUM(runs_off_bat) + SUM(wides) + SUM(noballs)) AS runs_conceded,
        (
            SUM(
                CASE
                    WHEN wides = 0
                    AND noballs = 0 THEN 1
                    ELSE 0
                END
            )
        ) AS legal_balls
    FROM
        fact_delivery
        JOIN dim_player ON fact_delivery.bowler_key = dim_player.player_key
    WHERE
        SPLIT_PART(ball, '.', 1) :: SMALLINT BETWEEN 15
        AND 19
        AND innings IN (1, 2)
    GROUP BY
        player_key,
        player_name
),
with_economy AS (
    SELECT
        *,
        ROUND(runs_conceded * 6.0 / legal_balls, 4) AS economy,
        ROUND(legal_balls / 6.0, 1) AS overs_bowled
    FROM
        parsed_data
)
SELECT
    player_name,
    runs_conceded,
    overs_bowled,
    economy,
    DENSE_RANK() OVER(
        ORDER BY
            economy
    ) AS bowler_rank
from
    with_economy
WHERE
    overs_bowled >= 20
ORDER BY
    economy;