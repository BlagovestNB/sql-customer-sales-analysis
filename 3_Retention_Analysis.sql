WITH RECURSIVE customer_last_purchase AS (
	SELECT
		customerkey,
		cleaned_name,
		orderdate,
		ROW_NUMBER() OVER (
			PARTITION BY customerkey
			ORDER BY orderdate DESC
	) AS rn,
		first_purchase_date,
		cohort_year 
	FROM cohort_analysis
),

churned_customers AS (
SELECT
	customerkey,
	cleaned_name,
	orderdate AS last_purchase_date,
	CASE
		WHEN 
		(SELECT MAX(orderdate) FROM customer_last_purchase) - INTERVAL '6 months' > orderdate
		THEN 'Churned'
		ELSE 'Active'
	END AS customer_ststus,
	cohort_year
FROM customer_last_purchase

WHERE rn = 1
	AND (SELECT MAX(orderdate) FROM customer_last_purchase) - INTERVAL '6 months' > first_purchase_date
)

SELECT
	cohort_year,
	customer_ststus,
	COUNT(customerkey) AS customers,
	SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year) total_customers,
	ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year), 2) AS status_percentage
FROM churned_customers

GROUP BY 
	cohort_year,
	customer_ststus
