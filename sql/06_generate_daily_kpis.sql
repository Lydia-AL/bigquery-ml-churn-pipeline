-- ============================================================================
-- Scheduled Query example: generate daily retail KPIs
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS
  `YOUR_PROJECT_ID.retail_bq_ops`

OPTIONS (
  location = "europe-west9"
);


CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.retail_bq_ops.daily_kpis` AS

WITH calibrated_orders AS (
  SELECT
    DATE_SUB(
      CURRENT_DATE(),
      INTERVAL CAST(
        ABS(
          MOD(
            FARM_FINGERPRINT(CAST(customer_id AS STRING)),
            30
          )
        ) AS INT64
      ) DAY
    ) AS order_date,

    total_orders
      * (
        40
        + ABS(
            MOD(
              FARM_FINGERPRINT(CAST(customer_id AS STRING)),
              20
            )
          )
      ) AS pseudo_revenue

  FROM
    `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_raw`
)

SELECT
  order_date,
  SUM(pseudo_revenue) AS total_revenue,
  COUNT(*) AS activity_signals

FROM calibrated_orders

GROUP BY order_date

ORDER BY order_date;
