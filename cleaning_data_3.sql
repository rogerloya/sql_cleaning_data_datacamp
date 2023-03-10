-- Type conversion with a CASE clause
SELECT
  CASE WHEN
          -- Use true when column value is 'F'
          violation_in_front_of_or_opposite = 'F' THEN true
       WHEN
          -- Use false when column value is 'O'
          violation_in_front_of_or_opposite = 'O' THEN false
       ELSE
          NULL
  END AS is_violation_in_front
FROM
  parking_violation;

-- Applying aggregate functions to converted values CAST BIGINT
SELECT
  -- Define the range_size from the max and min summons number
  MAX(summons_number::BIGINT) - MIN(summons_number::BIGINT) AS range_size
FROM
  parking_violation;

-- Cleaning invalid dates
SELECT
  -- Replace '0' with NULL
  NULLIF(date_first_observed, '0') AS date_first_observed
FROM
  parking_violation;


  SELECT
    -- Convert date_first_observed into DATE
    DATE(NULLIF(date_first_observed, '0')) AS date_first_observed
  FROM
    parking_violation;

-- Converting and displaying dates
SELECT
  summons_number,
  -- Convert issue_date to a DATE
  DATE(issue_date) AS issue_date,
  -- Convert date_first_observed to a DATE
  DATE(date_first_observed) AS date_first_observed
FROM
  parking_violation;

  SELECT
  summons_number,
  -- Display issue_date using the YYYYMMDD format
  TO_CHAR(issue_date, 'YYYYMMDD') AS issue_date,
  -- Display date_first_observed using the YYYYMMDD format
  TO_CHAR(date_first_observed, 'YYYYMMDD') AS date_first_observed
FROM (
  SELECT
    summons_number,
    DATE(issue_date) AS issue_date,
    DATE(date_first_observed) AS date_first_observed
  FROM
    parking_violation
) sub

-- Extracting hours from a time value
SELECT
  -- Convert violation_time to a TIMESTAMP
  TO_TIMESTAMP(violation_time, 'HH12MIPM')::TIME AS violation_time
FROM
  parking_violation
WHERE
  -- Exclude NULL violation_time
  violation_time IS NOT NULL;

  SELECT
    -- Populate column with violation_time hours
    EXTRACT('hour'FROM violation_time) AS hour,
    COUNT(*)
  FROM (
      SELECT
        TO_TIMESTAMP(violation_time, 'HH12MIPM')::TIME as violation_time
      FROM
        parking_violation
      WHERE
        violation_time IS NOT NULL
  ) sub
  GROUP BY
    hour
  ORDER BY
    hour

-- A parking violation report by day of the month
SELECT
  -- Convert issue_date to a DATE value
  DATE(issue_date) AS issue_date
FROM
  parking_violation;

-- A parking violation report by day of the month
SELECT
  -- Create issue_day from the day value of issue_date
  EXTRACT('day' FROM issue_date) AS issue_day,
  -- Include the count of violations for each day
  COUNT(*)
FROM (
  SELECT
    -- Convert issue_date to a `DATE` value
    DATE(issue_date) AS issue_date
  FROM
    parking_violation
) sub
GROUP BY
  issue_day
ORDER BY
  issue_day;
