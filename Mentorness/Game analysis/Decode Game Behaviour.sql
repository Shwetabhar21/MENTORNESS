use game_analysis;
-- Q1) 'P_ID' , 'Dev_ID' , 'PName' , 'Difficulty_level' of all players at level 0
select 'P_ID' , 'Dev_ID' , 'PName' , 'Difficulty_level' from player_details, level_details2
where level = 0;
-- Q2) Level1_code wise Avg_Kill_Count where lives_earned is 2 and atleast
--    3 stages are crossed
select 'L1_Code' , AVG(Kill_Count)
from player_details, level_details2
where Lives_Earned = 2
group by L1_Code
HAVING Count(distinct Stages_crossed) >= 3;
-- Q3) The total number of stages crossed at each diffuculty level
-- where for Level2 with players use zm_series devices. Arrange the result
-- in decsreasing order of total number of stages crossed.
select 'Difficulty' , SUM(Stages_crossed) 
from player_details, level_details2
where Level = 2 and Dev_ID IN ('zm_013' , 'zm_015' , 'zm_017')
group by 'Dev_ID' 
order by 'Stages_crossed' DESC;
-- Q4) Extract P_ID and the total number of unique dates for those players 
-- who have played games on multiple days.
select 'P_ID' , Count(distinct date (TimeStamp))
from player_details , level_details2
group by 'P_ID' 
HAVING Count(distinct date (TimeStamp)) > 1;
-- Q5) P_ID and level wise sum of kill_counts where kill_count
-- is greater than avg kill count for the Medium difficulty.
SELECT
    P_ID,
    Level,
    SUM(Kill_Count) AS levelwise_sum_kill_counts
FROM level_details2
WHERE
    Difficulty = 'Medium'
    AND Kill_Count > (
        SELECT AVG(Kill_Count)
        FROM level_details2
        WHERE Difficulty = 'Medium'
    )
GROUP BY
    P_ID, Level;
-- Q6) Level and its corresponding Level wise sum of lives earned 
-- excluding level 0. Arrange in asecending order of level.
SELECT
    Level,
    L1_Code,
    L2_Code,
    SUM(Lives_Earned) AS total_lives_earned
from player_details , level_details2
WHERE
    Level != 0
GROUP BY
    Level, L1_code, L2_Code
ORDER BY
    Level ASC;
-- Q7) Top 3 score based on each dev_id and Rank them in increasing order
-- using Row_Number. Display difficulty as well.
WITH RankedScores AS (
    SELECT
        Dev_ID,
        Score,
        Difficulty,
        ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY Score ASC) AS ScoreRank
    FROM player_details , level_details2
    )
SELECT
    Dev_ID,
    Score,
    Difficulty
FROM
    RankedScores
WHERE
    ScoreRank <= 3;
-- Q8) First_login datetime for each device id
SELECT Dev_ID,
    MIN(TimeStamp)
FROM player_details , level_details2
GROUP BY Dev_ID;
-- Q9) Find Top 5 score based on each difficulty level and Rank them in 
-- increasing order using Rank. Display dev_id as well.
WITH RankedScores AS (
    SELECT
        Dev_ID,
        Score,
        Difficulty,
        ROW_NUMBER() OVER (PARTITION BY Difficulty ORDER BY Score ASC) AS ScoreRank
    FROM player_details , level_details2
)
SELECT 
	Dev_ID,
    Score,
    Difficulty,
    ScoreRank 
FROM 
	RankedScores
WHERE 
	ScoreRank <= 5;
-- Q10) The device ID that is first logged in(based on start_datetime) 
-- for each player(p_id). Output should contain player id, device id and 
-- first login datetime.
SELECT
    P_ID,
    Dev_ID,
    MIN(timestamp) AS first_login_datetime
    FROM level_details2
GROUP BY Dev_ID , P_ID;
-- Q11) For each player and date, how many kill_count played so far by the player. 
-- That is, the total number of games played by the player until that date.
-- a) window function
SELECT
    P_ID,
    DATE(TimeStamp) AS date,
    SUM(Kill_Count) OVER (PARTITION BY P_ID ORDER BY TimeStamp) AS total_kill_counts_so_far
    FROM level_details2;
-- b) without window function
SELECT
    P_ID,
    DATE(TimeStamp) AS date,
    SUM(Kill_Count) AS total_kill_counts_so_far
    FROM level_details2
GROUP BY P_ID, DATE(TimeStamp);
-- Q12) The cumulative sum of stages crossed over `start_datetime` for each `P_ID`, 
-- excluding the most recent `start_datetime`.
SELECT
    P_ID,
    TimeStamp,
    Stages_crossed,
    SUM(Stages_crossed) OVER (PARTITION BY P_ID ORDER BY TimeStamp ASC ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS cumulative_stages_crossed
FROM level_details2;
-- Q13) The top 3 highest sums of scores for each `Dev_ID` and the corresponding `P_ID`.
WITH RankedScores AS (
    SELECT
        Dev_ID,
        P_ID,
        SUM(Score) AS total_score,
        ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY SUM(Score) DESC) AS Scorerank
    FROM level_details2
    GROUP BY Dev_ID, P_ID
)
SELECT
    Dev_ID,
    P_ID,
    total_score
FROM
    RankedScores
WHERE
    Scorerank <= 3;
 -- Q14) players who scored more than 50% of the average score, scored by the sum of 
-- scores for each `P_ID`.
    SELECT
    P_ID,
    SUM(Score) AS total_score
FROM
    level_details2
GROUP BY
    P_ID
HAVING
    SUM(Score) > 0.5 * (
        SELECT AVG(sum_score) FROM (
            SELECT
                SUM(Score) AS sum_score
            FROM
                level_details2
            GROUP BY
                P_ID
        ) AS avg_scores
    );
 -- Q15) Create a stored procedure to find the top `n` `headshots_count` based on each `Dev_ID` 
-- and rank them in increasing order using `Row_Number`. Display the difficulty as well.
WITH RankedHeadshots AS (
    SELECT
        Dev_ID,
        Difficulty,
        Headshots_Count,
        ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY Headshots_Count ASC) AS Scorerank
    FROM
level_details2)
SELECT
    Dev_ID,
    Difficulty,
    Headshots_Count,
    Scorerank
FROM
    RankedHeadshots
WHERE
    Scorerank <= 5;