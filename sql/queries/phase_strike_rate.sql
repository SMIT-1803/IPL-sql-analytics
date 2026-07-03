WITH parsed_data AS (
    SELECT
        SPLIT_PART(ball, '.', 1) :: SMALLINT AS over_num,
        runs_off_bat,
        wides
    FROM
        fact_delivery
    WHERE
        fact_delivery.innings IN (1, 2)
),
columns_ready AS (
    SELECT
        SUM(
            CASE
                WHEN wides = 0 THEN 1
                ELSE 0
            END
        ) AS balls_faced,
        SUM(runs_off_bat) AS runs_scored,
        CASE
            WHEN over_num BETWEEN 0
            AND 5 THEN 'Powerplay'
            WHEN over_num BETWEEN 6
            AND 14 THEN 'Middle'
            WHEN over_num BETWEEN 15
            AND 19 THEN 'Death'
        END AS over_section
    FROM
        parsed_data
    GROUP BY
        over_section
)
SELECT
    *,
    (runs_scored * 100.0 / balls_faced) AS strike_rate
from
    columns_ready
ORDER BY
    CASE
        over_section
        WHEN 'Powerplay' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Death' THEN 3
    END;


----------------------------    

WITH parsed_data AS (
    SELECT
        SPLIT_PART(ball, '.', 1) :: SMALLINT AS over_num,
        runs_off_bat,
        wides,
        season
    FROM
        fact_delivery
        JOIN dim_match ON fact_delivery.match_id = dim_match.match_id
    WHERE
        fact_delivery.innings IN (1, 2)
),
columns_ready AS (
    SELECT
        SUM(
            CASE
                WHEN wides = 0 THEN 1
                ELSE 0
            END
        ) AS balls_faced,
        SUM(runs_off_bat) AS runs_scored,
        CASE
            WHEN over_num BETWEEN 0
            AND 5 THEN 'Powerplay'
            WHEN over_num BETWEEN 6
            AND 14 THEN 'Middle'
            WHEN over_num BETWEEN 15
            AND 19 THEN 'Death'
        END AS over_section,
        season
    FROM
        parsed_data
    GROUP BY
        over_section,
        season
)
SELECT
    *,
    (runs_scored * 100.0 / balls_faced) AS strike_rate
from
    columns_ready
ORDER BY
    season,
    CASE
        over_section
        WHEN 'Powerplay' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Death' THEN 3
    END;