-- ============================================================================
-- Generate churn predictions on the test dataset
-- ============================================================================

CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.retail_bq_ml.churn_predictions_test` AS

SELECT
  test.customer_id,

  prediction.predicted_churned,

  (
    SELECT probability.prob
    FROM UNNEST(prediction.predicted_churned_probs) AS probability
    WHERE probability.label = 1
  ) AS churn_probability,

  test.churned AS actual_churned,

  test.lifetime_value,
  test.total_orders,
  test.refund_ratio,
  test.days_since_last_order,
  test.marketing_opt_in

FROM ML.PREDICT(
  MODEL `YOUR_PROJECT_ID.retail_bq_ml.churn_model`,

  (
    SELECT
      * EXCEPT (churned, dataset)

    FROM
      `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_test`
  )
) AS prediction

JOIN
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_test`
    AS test

ON prediction.customer_id = test.customer_id;
