-- ============================================================================
-- Generate a synthetic customer dataset for churn prediction
-- ============================================================================

-- Replace YOUR_PROJECT_ID with your Google Cloud project ID.

CREATE SCHEMA IF NOT EXISTS `YOUR_PROJECT_ID.retail_bq_ml`
OPTIONS (
  location = "europe-west9"
);

CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_raw` AS

WITH customer_ids AS (
  SELECT customer_id
  FROM UNNEST(GENERATE_ARRAY(1, 10000)) AS customer_id
),

customer_features AS (
  SELECT
    customer_id,

    CAST(FLOOR(RAND() * 50) + 1 AS INT64) AS total_orders,

    CAST(FLOOR(RAND() * 200) + 1 AS INT64)
      AS days_since_last_order,

    RAND() AS refund_ratio,

    RAND() < 0.5 AS marketing_opt_in,

    ROUND(RAND() * 1500, 2) AS lifetime_value

  FROM customer_ids
),

labeled_customers AS (
  SELECT
    *,

    CASE
      WHEN (
        days_since_last_order * 0.03
        + refund_ratio * 2.0
        - total_orders * 0.02
        + IF(marketing_opt_in, -0.5, 0.4)
        + RAND() * 0.15
      ) > 1.0
      THEN 1
      ELSE 0
    END AS churned

  FROM customer_features
)

SELECT *
FROM labeled_customers;
