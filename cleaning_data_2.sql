-- Ch. 2

-- Using a fill-in value. COALESCE

UPDATE
  parking_violation
SET
  -- Replace NULL vehicle_body_type values with `Unknown`
  vehicle_body_type = COALESCE(vehicle_body_type, 'Unknown');

SELECT COUNT(*) FROM parking_violation WHERE vehicle_body_type = 'Unknown';

-- Analyzing incomplete records
SELECT
  -- Define the SELECT list: issuing_agency and num_missing
  issuing_agency,
  COUNT(*) AS num_missing
FROM
  parking_violation
WHERE
  -- Restrict the results to NULL vehicle_body_type values
  vehicle_body_type ISNULL
  -- Group results by issuing_agency
  GROUP BY issuing_agency
  -- Order results by num_missing in descending order
  ORDER BY num_missing DESC;

-- Duplicate parking violations
-- Use ROW_NUMBER() to define duplicate window
ROW_NUMBER() OVER(
    PARTITION BY
        plate_id,
        issue_date,
        violation_time,
        house_number,
        street_name
-- Modify ROW_NUMBER() value to define duplicate column
  ) - 1 AS duplicate,
plate_id,
issue_date,
violation_time,
house_number,
street_name
FROM
parking_violation;

SELECT
	-- Include all columns
   *
FROM (
	SELECT
  		summons_number,
  		ROW_NUMBER() OVER(
        	PARTITION BY
            	plate_id,
          		issue_date,
          		violation_time,
          		house_number,
          		street_name
      	) - 1 AS duplicate,
      	plate_id,
      	issue_date,
      	violation_time,
      	house_number,
      	street_name
	FROM
		parking_violation
) sub
WHERE
	-- Only return records where duplicate is 1 or more
	duplicate > 0;



  SELECT
  	-- Include SELECT list columns
  	summons_number,
  	min(fee) AS fee
  FROM
  	parking_violation
  GROUP BY
  	-- Define column for GROUP BY
  	summons_number
  HAVING
  	-- Restrict to summons numbers with count greater than 1
  	COUNT(summons_number) > 1;


-- Detecting invalid values with regular expressions
SELECT
  summons_number,
  plate_id,
  registration_state
FROM
  parking_violation
WHERE
  -- Define the pattern to use for matching
  registration_state  NOT SIMILAR TO '[A-Z]{2}';

  SELECT
    summons_number,
    plate_id,
    plate_type
  FROM
    parking_violation
  WHERE
    -- Define the pattern to use for matching
    plate_type NOT SIMILAR TO '[A-Z]{3}';

    SELECT
      summons_number,
      plate_id,
      vehicle_make
    FROM
      parking_violation
    WHERE
      -- Define the pattern to use for matching
      vehicle_make NOT SIMILAR TO '[A-Z, /, \s]{3}';

-- dentifying out-of-range vehicle model years NOT BETWEEN

SELECT
  -- Define the columns to return from the query
  summons_number,
  plate_id,
  vehicle_year
FROM
  parking_violation
WHERE
  -- Define the range constraint for invalid vehicle years
  vehicle_year NOT BETWEEN 1970 AND 2021;

-- Identifying invalid parking violations
SELECT
  -- Specify return columns
  summons_number,
  violation_time,
  from_hours_in_effect,
  to_hours_in_effect
FROM
  parking_violation
WHERE
  -- Condition on values outside of the restricted range
  violation_time NOT BETWEEN from_hours_in_effect AND to_hours_in_effect;

  SELECT
    summons_number,
    violation_time,
    from_hours_in_effect,
    to_hours_in_effect 
  FROM
    parking_violation
  WHERE
    -- Exclude results with overnight restrictions
    from_hours_in_effect < to_hours_in_effect AND
    violation_time NOT BETWEEN from_hours_in_effect AND to_hours_in_effect;

-- Invalid violations with overnight parking restrictions

SELECT
  summons_number,
  violation_time,
  from_hours_in_effect,
  to_hours_in_effect
FROM
  parking_violation
WHERE
  -- Ensure from hours greater than to hours
  from_hours_in_effect > to_hours_in_effect AND
  -- Ensure violation_time less than from hours
  violation_time < from_hours_in_effect AND
  -- Ensure violation_time greater than to hours
  violation_time > to_hours_in_effect;
