
USE Car_sales

-- Split 'ParseDate' colunm into date and hour

SELECT CONVERT(date, parse_date),
        DATEPART(hour, parse_date) AS new_hour,
        parse_date
FROM[dbo].[region25]

ALTER TABLE [dbo].[region25]
ADD dateOnly date;

UPDATE [dbo].[region25]
SET dateOnly = CONVERT(date, parse_date)

ALTER TABLE [dbo].[region25]
ADD hour int;

UPDATE [dbo].[region25]
SET hour =  DATEPART(hour, parse_date)

-- Remove 'LTR' from 'engineDisplacement' column and change the data type to FLOAT

SELECT engineDisplacement 
FROM [dbo].[region25]

UPDATE [dbo].[region25]
SET engineDisplacement = TRIM(LEFT(engineDisplacement, 3))

ALTER TABLE [dbo].[region25]
ALTER COLUMN engineDisplacement FLOAT;

-- Change 'Automatic' to 'AT' in 'transmission' column

SELECT transmission, COUNT(transmission)
FROM [dbo].[region25]
GROUP BY transmission
ORDER BY transmission

SELECT transmission,
        CASE WHEN transmission = 'Automatic' THEN 'AT'
        ELSE transmission
        END
FROM [dbo].[region25]

UPDATE [dbo].[region25]
SET transmission = CASE WHEN transmission = 'Automatic' THEN 'AT'
                    ELSE transmission
                    END

-- Remove unnecesarry columns

SELECT *
FROM [dbo].[region25]

ALTER TABLE [dbo].[region25]
DROP COLUMN [parse_date]


