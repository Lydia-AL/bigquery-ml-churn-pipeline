-- ============================================================================
-- Split the synthetic customer dataset into training and testing datasets
-- ============================================================================

-- Approximately 80% of the rows are assigned to TRAIN
-- and 20% to TEST.
--
-- RAND() introduces a small variation around the exact 80/20 ratio.

CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_split` AS

SELECT
  *,

  CASE
    WHEN RAND() < 0.8 THEN 'TRAIN'
    ELSE 'TEST'
  END AS dataset

FROM
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_raw`;


CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_train` AS

SELECT *
FROM
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_split`

WHERE dataset = 'TRAIN';


CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_test` AS

SELECT *
FROM
  `YOUR_PROJECT_ID.retail_bq_ml.customer_behavior_split`

WHERE dataset = 'TEST';
