-- Longest streak of consecutive dot balls faced by each batter (gaps-and-islands).
WITH numbered_balls AS (
    SELECT
        match_id,
        innings,
        player_key,
        player_name,
        ball,
        ROW_NUMBER() OVER (
            PARTITION BY player_key,
            match_id,
            innings
            ORDER BY
                SPLIT_PART(ball, '.', 1) :: int,
                SPLIT_PART(ball, '.', 2) :: int
        ) AS ball_seq,
        CASE
            WHEN runs_off_bat = 0
            AND wides = 0 THEN 1
            ELSE 0
        END AS is_dot
    FROM
        fact_delivery
        JOIN dim_player ON fact_delivery.striker_key = dim_player.player_key
    WHERE
        innings IN (1, 2)
),
numbered_dots AS (
    SELECT
        match_id,
        innings,
        player_name,
        ball_seq,
        ROW_NUMBER() OVER (
            PARTITION BY player_key,
            match_id,
            innings
            ORDER BY
                SPLIT_PART(ball, '.', 1) :: int,
                SPLIT_PART(ball, '.', 2) :: int
        ) AS dot_seq
    FROM
        numbered_balls
    WHERE
        is_dot = 1
),
streak_lengths AS (
    SELECT
        player_name,
        match_id,
        innings,
        ball_seq - dot_seq AS streak_id,
        COUNT(*) AS streak_length
    FROM
        numbered_dots
    GROUP BY
        player_name,
        match_id,
        innings,
        ball_seq - dot_seq
)
SELECT
    player_name,
    MAX(streak_length) AS longest_dot_streak
FROM
    streak_lengths
GROUP BY
    player_name
ORDER BY
    longest_dot_streak DESC;