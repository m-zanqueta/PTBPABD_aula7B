DROP PROCEDURE IF EXISTS dbo.salaryHistogram

CREATE PROCEDURE dbo.salaryHistogram @numIntervalos INT AS
WITH stats AS (
    SELECT MIN(salary) AS salMin, MAX(salary) AS salMax FROM instructor
),
nums AS (
    SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
    UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
)
SELECT 
    CASE WHEN nums.n = 0 THEN ROUND(s.salMin, 0)
         ELSE ROUND(s.salMin + (nums.n * (s.salMax - s.salMin) / @numIntervalos), 0) 
    END AS valorMinimo,
    CASE WHEN nums.n = @numIntervalos - 1 THEN ROUND(s.salMax, 0)
         ELSE ROUND(s.salMin + ((nums.n + 1) * (s.salMax - s.salMin) / @numIntervalos) - 1, 0)
    END AS valorMaximo,
    COUNT(inst.salary) AS total
FROM nums
CROSS JOIN stats s
LEFT JOIN instructor inst
    ON inst.salary >= CASE WHEN nums.n = 0 THEN s.salMin 
                           ELSE ROUND(s.salMin + (nums.n * (s.salMax - s.salMin) / @numIntervalos), 0) END
    AND inst.salary <= CASE WHEN nums.n = @numIntervalos - 1 THEN s.salMax
                            ELSE ROUND(s.salMin + ((nums.n + 1) * (s.salMax - s.salMin) / @numIntervalos) - 1, 0) END
WHERE nums.n < @numIntervalos
GROUP BY 
    nums.n,
    s.salMin,
    s.salMax
ORDER BY nums.n

EXEC dbo.salaryHistogram 5