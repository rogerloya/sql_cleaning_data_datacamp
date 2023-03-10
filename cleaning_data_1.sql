-- Ch. 1

-- Applying functions for string cleaning
SELECT
  -- Add 0s to ensure violation_location is 4 characters in length
  LPAD(violation_location, 4, '0') AS violation_location,
  -- Replace 'P-U' with 'TRK' in vehicle_body_type column
  REPLACE(vehicle_body_type, 'P-U', 'TRK') AS vehicle_body_type,
  -- Ensure only first letter capitalized in street_name
  INITCAP(street_name) AS street_name
FROM
  parking_violation;


-- Classifying parking violations by time of day
  SELECT
  	summons_number,
      CASE WHEN
      	summons_number IN (
            SELECT
    			summons_number
    		  FROM
    			parking_violation
    		  WHERE
              -- Match violation_time for morning values
    			violation_time SIMILAR TO '\d\d\d\dA'
      	)
          -- Value when pattern matched
          THEN 1
          -- Value when pattern not matched
          ELSE 0
      END AS morning
  FROM
  	parking_violation;

    SELECT
	summons_number,
	-- Replace uppercase letters in plate_id with dash
	REGEXP_REPLACE(plate_id, '[A-Z]', '-', 'g')
FROM
	parking_violation;

-- Matching inconsistent color names

  SELECT
    summons_number,
    vehicle_color
  FROM
    parking_violation
  WHERE
    -- Match SOUNDEX codes of vehicle_color and 'GRAY'
    DIFFERENCE(vehicle_color, 'GRAY') = 4;


-- Standardizing multiple colors
SELECT
	summons_number,
	vehicle_color,
    -- Include the DIFFERENCE() value for each color
	DIFFERENCE(vehicle_color, 'RED') AS "red",
	DIFFERENCE(vehicle_color, 'BLUE') AS "blue",
	DIFFERENCE(vehicle_color, 'YELLOW') AS "yellow"
FROM
	parking_violation
WHERE
	(
      	-- Condition records on DIFFERENCE() value of 4
		DIFFERENCE(vehicle_color, 'RED') = 4 OR
		DIFFERENCE(vehicle_color, 'BLUE') = 4 OR
		DIFFERENCE(vehicle_color, 'YELLOW') = 4
	)
