-- ============================================================================
-- Evaluate the churn model on the held-out test dataset
-- ============================================================================

SELECT *
FROM ML.EVALUATE(
  MODEL `YOUR_PROJECT_ID.retail_bq_ml.churn_model`,

  (
    SELECT
      lifetime_value,
      total_orders,
      refund_ratio,
      days_since_last_order,
      marketing_opt_in,
      churned

    FROM
      `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_test`
  )
);
