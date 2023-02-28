-- We have 3 databases : [dbo][calender], [dbo].[listings_details 2], [dbo].[reviews_details]. 



------------------------------------------------------------------------------------

-- DATA CLEANING OF '[dbo][calender]' TABLE

SELECT TOP (1000) [listing_id]
      ,[date]
      ,[available]
      ,[price]
FROM [Airbnb].[dbo].[calendar]

-- 1. Converting 'price' column into 'money' datatype

SELECT SUBSTRING([price],CHARINDEX('$', [price])+1, LEN([price]))
FROM [dbo].[calendar]

UPDATE [dbo].[calendar]
SET price = SUBSTRING([price],CHARINDEX('$', [price])+1, LEN([price]))

ALTER TABLE [dbo].[calendar]
ALTER COLUMN price money;

-- 2. Removing duplicate values (IF exists)

WITH cte AS(
SELECT *,
    ROW_NUMBER() OVER(
                    PARTITION BY
                    [listing_id]
                    ,[date]
                    ,[available]
                    ,[price] 
                    ORDER BY listing_id ) AS row_num
FROM [dbo].[calendar] 
)

SELECT COUNT(*) AS no_of_duplicates
FROM cte
WHERE row_num > 1

-- ** no duplicates as COUNT(*) = 0 **--

------------------------------------------------------------------------------------
-- DATA CLEANING OF '[dbo][listings_details 2]' TABLE

SELECT TOP (1000) [id]
      ,[listing_url]
      ,[last_scraped]
      ,[scrape_id]
      ,[name]
      ,[summary]
      ,[space]
      ,[description]
      ,[neighborhood_overview]
      ,[neighbourhood_group_cleansed]
      ,[notes]
      ,[transit]
      ,[access]
      ,[interaction]
      ,[house_rules]
      ,[picture_url]
      ,[thumbnail_url]
      ,[medium_url]
      ,[xl_picture_url]
      ,[host_id]
      ,[host_url]
      ,[host_name]
      ,[host_since]
      ,[host_location]
      ,[host_about]
      ,[host_response_time]
      ,[host_response_rate]
      ,[host_is_superhost]
      ,[host_acceptance_rate]
      ,[host_thumbnail_url]
      ,[host_picture_url]
      ,[host_neighbourhood]
      ,[host_listings_count]
      ,[host_total_listings_count]
      ,[host_verifications]
      ,[host_has_profile_pic]
      ,[host_identity_verified]
      ,[street]
      ,[neighbourhood]
      ,[neighbourhood_cleansed]
      ,[city]
      ,[state]
      ,[zipcode]
      ,[market]
      ,[smart_location]
      ,[country_code]
      ,[country]
      ,[latitude]
      ,[longitude]
      ,[is_location_exact]
      ,[property_type]
      ,[room_type]
      ,[accommodates]
      ,[bathrooms]
      ,[bedrooms]
      ,[beds]
      ,[bed_type]
      ,[amenities]
      ,[square_feet]
      ,[price]
      ,[weekly_price]
      ,[monthly_price]
      ,[security_deposit]
      ,[cleaning_fee]
      ,[guests_included]
      ,[extra_people]
      ,[minimum_nights]
      ,[maximum_nights]
      ,[calendar_updated]
      ,[has_availability]
      ,[availability_30]
      ,[availability_60]
      ,[availability_90]
      ,[availability_365]
      ,[calendar_last_scraped]
      ,[number_of_reviews]
      ,[first_review]
      ,[last_review]
      ,[review_scores_rating]
      ,[review_scores_accuracy]
      ,[review_scores_cleanliness]
      ,[review_scores_checkin]
      ,[review_scores_communication]
      ,[review_scores_location]
      ,[review_scores_value]
      ,[requires_license]
      ,[license]
      ,[jurisdiction_names]
      ,[instant_bookable]
      ,[is_business_travel_ready]
      ,[cancellation_policy]
      ,[require_guest_profile_picture]
      ,[require_guest_phone_verification]
      ,[calculated_host_listings_count]
      ,[reviews_per_month]
FROM [Airbnb].[dbo].[listings_details 2]

-- 1. Remove columns : scrape_id, experiences_offered, thumbnail_url, medium_url, xl_picture_url, host_acceptance_rate, neighbourhood_group_cleansed

ALTER TABLE [dbo].[listings_details 2]
DROP COLUMN [scrape_id], 
            [experiences_offered], 
            [thumbnail_url], 
            [medium_url], 
            [xl_picture_url], 
            [host_acceptance_rate], 
            [neighbourhood_group_cleansed]

-- 2. Converting 'price', 'weekly_price', 'monthly_price', 'security_deposit', 'cleaning_fee' and 'extra_people' columns into 'money' datatype

SELECT TOP (1000) 
            SUBSTRING(price,CHARINDEX('$', price)+1, LEN(price)),
            SUBSTRING(weekly_price,CHARINDEX('$', weekly_price)+1, LEN(weekly_price)),
            SUBSTRING(monthly_price,CHARINDEX('$', monthly_price)+1, LEN(monthly_price)),
            SUBSTRING(security_deposit,CHARINDEX('$', security_deposit)+1, LEN(security_deposit)),
            SUBSTRING(cleaning_fee,CHARINDEX('$', cleaning_fee)+1, LEN(cleaning_fee)),
            SUBSTRING(extra_people, CHARINDEX('$', extra_people)+1, LEN(extra_people))

FROM [dbo].[listings_details 2]

UPDATE [dbo].[listings_details 2]
SET price = SUBSTRING(price,CHARINDEX('$', price)+1, LEN(price))

UPDATE [dbo].[listings_details 2]
SET weekly_price = SUBSTRING(weekly_price,CHARINDEX('$', weekly_price)+1, LEN(weekly_price))

UPDATE [dbo].[listings_details 2]
SET monthly_price = SUBSTRING(monthly_price,CHARINDEX('$', monthly_price)+1, LEN(monthly_price))

UPDATE [dbo].[listings_details 2]
SET security_deposit = SUBSTRING(security_deposit,CHARINDEX('$', security_deposit)+1, LEN(security_deposit))

UPDATE [dbo].[listings_details 2]
SET cleaning_fee = SUBSTRING(cleaning_fee,CHARINDEX('$', price)+1, LEN(cleaning_fee))

UPDATE [dbo].[listings_details 2]
SET extra_people = SUBSTRING(extra_people, CHARINDEX('$', extra_people)+1, LEN(extra_people))

ALTER TABLE [dbo].[listings_details 2]
ALTER COLUMN price money;

ALTER TABLE [dbo].[listings_details 2]
ALTER COLUMN weekly_price money;

ALTER TABLE [dbo].[listings_details 2]
ALTER COLUMN monthly_price money;

ALTER TABLE [dbo].[listings_details 2]
ALTER COLUMN security_deposit money;

ALTER TABLE [dbo].[listings_details 2]
ALTER COLUMN cleaning_fee money;

ALTER TABLE [dbo].[listings_details 2]
ALTER COLUMN extra_people money;

-- 3. Removing undefined 'zipcode' column values

UPDATE [dbo].[listings_details 2]
SET zipcode = CASE WHEN LEN(zipcode) NOT IN (6,7,4) AND LEN(zipcode) < 6 THEN NULL
                   WHEN zipcode = '[no name]' THEN NULL
                   ELSE zipcode
                   END

-- 4. Change states having 'no%' OR 'NH' to 'Noord-Holland'

UPDATE [dbo].[listings_details 2]
SET state =  CASE WHEN state LIKE 'no%' OR state = 'NH' THEN 'Noord-Holland'
             ELSE state
             END 

-- 5. Remove brackets in 'host_verfications', 'amenities', and 'jurisdiction_names' column

UPDATE [dbo].[listings_details 2]
SET host_verifications = TRIM('[]' FROM host_verifications)

UPDATE [dbo].[listings_details 2]
SET amenities = TRIM('{}' FROM amenities)

UPDATE [dbo].[listings_details 2]
SET jurisdiction_names = TRIM('{}' FROM jurisdiction_names)


------------------------------------------------------------------------------------

-- DATA EXPLORATORY ANALYSIS ([dbo].[calendar] & [dbo].[listings_details 2])

-- 1. Which listings were fully booked for the whole time-period?

SELECT listing_id
FROM [dbo].[calendar]
WHERE available = 'f'

EXCEPT

SELECT listing_id
FROM [dbo].[calendar]
WHERE available = 't'

-- 2. Top 5 days where the maximum listings was not booked ?

SELECT TOP(5) date, COUNT(*)
FROM [dbo].[calendar]
WHERE available = 't'
GROUP BY date
ORDER BY COUNT(*) DESC

-- 3. Top 5 hosts with locations having the highest revenue from daily price?

SELECT TOP(5) listing_id, 
              host_name, 
              longitude, 
              latitude, 
              AVG(ld.price) AS avg_price ,
              AVG(availability_365) AS unavailable_days, 
              AVG(ld.price)*(365 - AVG(availability_365)) AS revenue
FROM [dbo].[calendar] AS c
JOIN [dbo].[listings_details 2] AS ld
    ON c.listing_id = ld.id
    AND available = 'f'
GROUP BY listing_id, host_name, longitude, latitude
ORDER BY revenue DESC

-- 4. What was the monthly revenue generated (with a total revenue) from each house in the year 2019?

WITH month_table AS 
(
SELECT TOP (1000) listing_id,
                DATEPART(MONTH, date) AS month, 
                COUNT(*) as days_booked,
                AVG(ld.price) AS avg_price,
                AVG(ld.price)*(COUNT(*)) AS revenue
FROM [dbo].[calendar] AS c
JOIN [dbo].[listings_details 2] AS ld
    ON c.listing_id = ld.id
    AND available = 'f'
    AND date BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY listing_id, DATEPART(MONTH, date)
ORDER BY listing_id, month
)

SELECT *, 
SUM(revenue) OVER(
    PARTITION BY listing_id
    ORDER BY month
    ROWS BETWEEN 
    11 PRECEDING AND CURRENT ROW
    ) AS revenue_ma
FROM month_table
ORDER BY listing_id, month

-- 5. Rank the listing_ids with host_name where the host do not have 'email' and 'phone' as verification parameter to verify themselves.

WITH review_table AS 
(
SELECT listing_id, 
       host_name, 
       host_verifications, 
       COUNT(*) AS days_booked, 
       AVG(ld.price) AS avg_price, 
       review_scores_rating
FROM [dbo].[calendar] AS c
JOIN [dbo].[listings_details 2] AS ld
    ON c.listing_id = ld.id
WHERE available = 'f'
    AND host_verifications NOT LIKE '%email%'
    AND host_verifications NOT LIKE '%phone%'
    AND date BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY listing_id, host_name, host_verifications, review_scores_rating
)

SELECT *,
DENSE_RANK() OVER(
    ORDER BY days_booked DESC,
             avg_price  DESC,
             review_scores_rating DESC
) AS ranking
FROM review_table

-- 6. Top 5 richest host in the year 2019

WITH host_table AS (
SELECT
        host_id,
        host_name,
        COUNT(*) as days_booked,
        AVG(ld.price) AS avg_price,
        AVG(ld.price)*(COUNT(*)) AS revenue
FROM [dbo].[calendar] AS c
JOIN [dbo].[listings_details 2] AS ld
    ON c.listing_id = ld.id
    AND available = 'f'
    AND date BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY listing_id, host_id, host_name
)

SELECT TOP(5) 
        host_id, 
        host_name, 
        COUNT(*) AS no_of_sites_owned,
        SUM(revenue) AS total_revenue
FROM host_table
GROUP BY host_id, host_name
ORDER BY total_revenue DESC

------------------------------------------------------------------------------------

-- DATA EXPLORATORY ANALYSIS ([dbo].[listings_details 2] & [dbo].[reviews_details])

--** QUICK VIEW AT [dbo].[reviews_details] TABLE **--

SELECT TOP (1000) [listing_id]
      ,[id]
      ,[date]
      ,[reviewer_id]
      ,[reviewer_name]
      ,[comments]
FROM [Airbnb].[dbo].[reviews_details]

-- 1. What were the negative comments of every reviewer (review_scores_value < 5) ?

SELECT  listing_id, 
        date, 
        reviewer_name, 
        comments
FROM [dbo].[reviews_details]
WHERE listing_id IN     
            (SELECT id
            FROM [dbo].[listings_details 2]
            WHERE review_scores_value < 5)
ORDER BY date

-- 2. What were the comments about 'cleanliness' having words such as 'clean' and 'dirty' where the average cleanliness score was less than 5?

SELECT  sub.id, 
        host_name, 
        date, 
        reviewer_name, 
        comments
FROM [dbo].[reviews_details], (SELECT id, host_name
                                FROM [dbo].[listings_details 2]  
                                WHERE review_scores_cleanliness < 5
                                ) AS sub
WHERE [dbo].[reviews_details].[listing_id] = sub.id
    AND (comments LIKE '%dirty%' OR comments LIKE '%clean%')


-- 3. What were the comments of the reviewers who had stayed at the same listing id more than 3 times?


WITH same_vistor AS 
(
SELECT  main.listing_id, 
        main.reviewer_id, 
        reviewer_name,
        date, 
        comments
FROM [dbo].[reviews_details] AS main, (
                                SELECT reviewer_id, listing_id
                                FROM [dbo].[reviews_details]
                                GROUP BY listing_id, reviewer_id
                                HAVING COUNT(*) > 3
                                ) AS sub                   
WHERE main.reviewer_id = sub.reviewer_id
    AND main.listing_id = sub.listing_id
)

SELECT  listing_id, 
        host_name, 
        reviewer_id, 
        reviewer_name, 
        date, 
        comments, 
        review_scores_accuracy, 
        review_scores_communication
FROM same_vistor
JOIN [dbo].[listings_details 2] AS ld 
    ON ld.id = same_vistor.listing_id
ORDER BY listing_id, date