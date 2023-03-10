-- Extracting time units with SUBSTRING()
SELECT
  SUBSTRING(violation_time FROM 1 FOR 2) AS hour,
  -- Define minute column
  SUBSTRING(violation_time FROM 3 FOR 2) AS minute
FROM
  parking_violation;

-- Extracting house numbers from a string
SELECT
  house_number,
  -- Extract the substring after '-'
  SUBSTRING(
    -- Specify the column of the original house number
    house_number
    -- Calculate the position that is 1 beyond '-'
    FROM STRPOS(house_number, '-') + 1
    -- Calculate number characters from dash to end of string
    FOR LENGTH(house_number) - STRPOS(house_number, '-')
  ) AS new_house_number
FROM
  parking_violation;

-- Splitting house numbers with a delimiter
SELECT
  -- Split house_number using '-' as the delimiter
  SPLIT_PART(house_number, '-', 2) AS new_house_number
FROM
  parking_violation
WHERE
  violation_county = 'Q';

-- Mapping parking restrictions
SELECT
  -- Label daily parking restrictions for locations by day
  ROW_NUMBER() OVER(
    PARTITION BY
        street_address, violation_county
    ORDER BY
        street_address, violation_county
  ) AS day_number,
  *
FROM (
  SELECT
    street_address,
    violation_county,
    REGEXP_SPLIT_TO_TABLE(days_parking_in_effect, '') AS daily_parking_restriction
  FROM
    parking_restriction
) sub;

-- Selecting data for a pivot table
SELECT
	-- Include the violation code in results
	violation_code,
    -- Include the issuing agency in results
    issuing_agency,
    -- Number of records with violation code/issuing agency
    count(*)
FROM
	parking_violation
WHERE
	-- Restrict the results to the agencies of interest
	issuing_agency IN ('P', 'S', 'K', 'V')
GROUP BY
	-- Define GROUP BY columns to ensure correct pair count
	violation_code, issuing_agency
ORDER BY
	violation_code, issuing_agency;

-- Using FILTER to create a pivot table
SELECT
	violation_code,
    -- Define the "Police" column
	COUNT(issuing_agency) FILTER (WHERE issuing_agency = 'P') AS "Police",
    -- Define the "Sanitation" column
	COUNT(issuing_agency) FILTER (WHERE issuing_agency = 'S') AS "Sanitation",
    -- Define the "Parks" column
	COUNT(issuing_agency) FILTER (WHERE issuing_agency = 'K') AS "Parks",
    -- Define the "Transportation" column
	COUNT(issuing_agency) FILTER (Where issuing_agency = 'V') AS "Transportation"
FROM
	parking_violation
GROUP BY
	violation_code
ORDER BY
	violation_code
