WITH customer_ltv AS (
	SELECT
		customerkey,
		cleaned_name,
		SUM(total_net_revenue) AS total_ltv
	FROM cohort_analysis
	
	GROUP BY
		customerkey,
		cleaned_name
),

customer_segmentation AS (
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
FROM customer_ltv
),

segment_values AS (
SELECT
	cl.*,
	CASE 
		WHEN cl.total_ltv < cs.ltv_25th_percentile THEN '1-Low_Value'
		WHEN cl.total_ltv <= cs.ltv_75th_percentile THEN '2-Mid_Value'
		ELSE '3-High_Value'
	END AS customer_segmentation
FROM customer_ltv cl,
	customer_segmentation cs
)

SELECT
	customer_segmentation,
	SUM(total_ltv) AS total_ltv,
	COUNT(customerkey) AS customer_count,
	SUM(total_ltv) / COUNT(customerkey) AS avg_ltv
FROM segment_values

GROUP BY
	customer_segmentation
ORDER BY
	customer_segmentation
