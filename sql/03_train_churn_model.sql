-- ============================================================================
-- Train a logistic regression model with BigQuery ML
-- ============================================================================

CREATE OR REPLACE MODEL
  `YOUR_PROJECT_ID.retail_bq_ml.churn_model`

OPTIONS (
  model_type = 'logistic_reg',
  input_label_cols = ['churned']
) AS

SELECT
  lifetime_value,
  total_orders,
  refund_ratio,
  days_since_last_order,
  marketing_opt_in,
  churned

FROM
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_train`;
