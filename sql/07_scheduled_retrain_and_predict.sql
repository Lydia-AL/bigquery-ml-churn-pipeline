-- ============================================================================
-- Scheduled retraining and prediction pipeline
-- ============================================================================
--
-- Suggested schedule: once a week.
--
-- Assumption used for this exercise:
-- the training and prediction tables are refreshed before this query runs.
--
-- In a production use case, predictions would normally be generated on
-- new unlabeled customer records rather than on the fixed test dataset.

-- Step 1: retrain the churn model
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


-- Step 2: generate predictions
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
