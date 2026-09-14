










-- QUESTION 1:
-- How many legitimate vs fraudulent transactions are there?
-- ============================================================

SELECT
    "Actual_Label",
    COUNT(*) AS transaction_count
FROM fraud_predictions
GROUP BY "Actual_Label"
ORDER BY transaction_count DESC;


-- ============================================================
-- QUESTION 2:
-- What percentage of transactions are legitimate vs fraudulent?
-- ============================================================

SELECT
    "Actual_Label",
    COUNT(*) AS transaction_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM fraud_predictions
GROUP BY "Actual_Label"
ORDER BY transaction_count DESC;


-- ============================================================
-- QUESTION 3:
-- What is the average transaction amount for legitimate
-- vs fraudulent transactions?
-- ============================================================

SELECT
    "Actual_Label",
    ROUND(
        AVG("Original_Amount")::numeric,
        2
    ) AS average_transaction_amount
FROM fraud_predictions
GROUP BY "Actual_Label"
ORDER BY average_transaction_amount DESC;


-- ============================================================
-- QUESTION 4:
-- How many fraudulent transactions were correctly detected
-- vs missed?
-- ============================================================

SELECT
    "Actual_Label",
    "Predicted_Label",
    COUNT(*) AS transaction_count
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud'
GROUP BY
    "Actual_Label",
    "Predicted_Label"
ORDER BY transaction_count DESC;


-- ============================================================
-- QUESTION 5:
-- What percentage of fraudulent transactions were correctly
-- detected?
-- ============================================================

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Predicted_Label" = 'Fraud' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fraud_detection_rate
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud';


-- ============================================================
-- QUESTION 6:
-- How many legitimate transactions were incorrectly flagged
-- as fraud?
-- ============================================================

SELECT
    "Actual_Label",
    "Predicted_Label",
    COUNT(*) AS transaction_count
FROM fraud_predictions
WHERE "Actual_Label" = 'Legitimate'
  AND "Predicted_Label" = 'Fraud'
GROUP BY
    "Actual_Label",
    "Predicted_Label";


-- ============================================================
-- QUESTION 7:
-- What percentage of legitimate transactions were incorrectly
-- flagged as fraud?
-- ============================================================

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Predicted_Label" = 'Fraud' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS false_positive_rate
FROM fraud_predictions
WHERE "Actual_Label" = 'Legitimate';


-- ============================================================
-- QUESTION 8:
-- What is the average transaction amount for transactions
-- predicted as fraud?
-- ============================================================

SELECT
    ROUND(
        AVG("Original_Amount")::numeric,
        2
    ) AS average_predicted_fraud_amount
FROM fraud_predictions
WHERE "Predicted_Label" = 'Fraud';


-- ============================================================
-- QUESTION 9:
-- What is the average transaction amount for transactions
-- predicted as legitimate?
-- ============================================================

SELECT
    ROUND(
        AVG("Original_Amount")::numeric,
        2
    ) AS average_predicted_legitimate_amount
FROM fraud_predictions
WHERE "Predicted_Label" = 'Legitimate';


-- ============================================================
-- QUESTION 10:
-- What is the average fraud probability for transactions
-- that were actually fraudulent?
-- ============================================================

SELECT
    ROUND(
        AVG("Fraud_Probability")::numeric,
        4
    ) AS average_fraud_probability
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud';


-- ============================================================
-- QUESTION 11:
-- What are the highest-value fraudulent transactions?
-- ============================================================

SELECT
    "Time",
    "Original_Amount",
    "Fraud_Probability",
    "Predicted_Label"
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud'
ORDER BY "Original_Amount" DESC
LIMIT 10;


-- ============================================================
-- QUESTION 12:
-- Which transactions have the highest fraud probability?
-- ============================================================

SELECT
    "Original_Amount",
    "Actual_Label",
    "Predicted_Label",
    ROUND(
        "Fraud_Probability"::numeric,
        4
    ) AS fraud_probability
FROM fraud_predictions
ORDER BY "Fraud_Probability" DESC
LIMIT 10;


-- ============================================================
-- QUESTION 13:
-- How many transactions fall into different fraud-risk levels?
-- ============================================================

SELECT
    CASE
        WHEN "Fraud_Probability" < 0.20
            THEN 'Low Risk'
        WHEN "Fraud_Probability" < 0.50
            THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_level,
    COUNT(*) AS transaction_count
FROM fraud_predictions
GROUP BY risk_level
ORDER BY transaction_count DESC;


-- ============================================================
-- QUESTION 14:
-- What is the actual fraud rate within each predicted
-- risk level?
-- ============================================================

SELECT
    CASE
        WHEN "Fraud_Probability" < 0.20
            THEN 'Low Risk'
        WHEN "Fraud_Probability" < 0.50
            THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_level,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN "Actual_Label" = 'Fraud'
                THEN 1
            ELSE 0
        END
    ) AS actual_frauds,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS actual_fraud_rate

FROM fraud_predictions
GROUP BY risk_level
ORDER BY actual_fraud_rate DESC;


-- ============================================================
-- QUESTION 15:
-- What is the fraud rate for high-value transactions?
-- High-value = above the average transaction amount.
-- ============================================================

SELECT
    CASE
        WHEN "Original_Amount" >
            (
                SELECT AVG("Original_Amount")
                FROM fraud_predictions
            )
        THEN 'High Value'
        ELSE 'Normal Value'
    END AS transaction_value_group,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN "Actual_Label" = 'Fraud'
                THEN 1
            ELSE 0
        END
    ) AS fraud_transactions,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fraud_rate

FROM fraud_predictions
GROUP BY transaction_value_group
ORDER BY fraud_rate DESC;


-- ============================================================
-- QUESTION 16:
-- What is the overall model performance based on actual
-- vs predicted outcomes?
-- ============================================================

SELECT
    "Actual_Label",
    "Predicted_Label",
    COUNT(*) AS transaction_count
FROM fraud_predictions
GROUP BY
    "Actual_Label",
    "Predicted_Label"
ORDER BY
    "Actual_Label",
    "Predicted_Label";

	-- ============================================================
-- QUESTION 17:
-- What percentage of transactions predicted as fraud
-- were actually fraudulent?
-- ============================================================

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                 AND "Predicted_Label" = 'Fraud'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN "Predicted_Label" = 'Fraud'
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS precision_percentage
FROM fraud_predictions;

-- ============================================================
-- QUESTION 18:
-- What is the F1 score of the fraud detection model?
-- ============================================================

WITH metrics AS (
    SELECT
        SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                 AND "Predicted_Label" = 'Fraud'
                THEN 1 ELSE 0
            END
        ) AS true_positive,

        SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                 AND "Predicted_Label" = 'Legitimate'
                THEN 1 ELSE 0
            END
        ) AS false_negative,

        SUM(
            CASE
                WHEN "Actual_Label" = 'Legitimate'
                 AND "Predicted_Label" = 'Fraud'
                THEN 1 ELSE 0
            END
        ) AS false_positive

    FROM fraud_predictions
)

SELECT
    ROUND(
        (
            2.0 * true_positive
            /
            NULLIF(
                (2 * true_positive)
                + false_positive
                + false_negative,
                0
            )
        )::numeric,
        4
    ) AS f1_score
FROM metrics;

-- ============================================================
-- QUESTION 18:
-- What is the F1 score of the fraud detection model?
-- ============================================================

WITH metrics AS (
    SELECT
        SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                 AND "Predicted_Label" = 'Fraud'
                THEN 1 ELSE 0
            END
        ) AS true_positive,

        SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                 AND "Predicted_Label" = 'Legitimate'
                THEN 1 ELSE 0
            END
        ) AS false_negative,

        SUM(
            CASE
                WHEN "Actual_Label" = 'Legitimate'
                 AND "Predicted_Label" = 'Fraud'
                THEN 1 ELSE 0
            END
        ) AS false_positive

    FROM fraud_predictions
)

SELECT
    ROUND(
        (
            2.0 * true_positive
            /
            NULLIF(
                (2 * true_positive)
                + false_positive
                + false_negative,
                0
            )
        )::numeric,
        4
    ) AS f1_score
FROM metrics;

-- ============================================================
-- QUESTION 19:
-- How many transactions did the model predict as fraudulent?
-- ============================================================

SELECT
    "Predicted_Label",
    COUNT(*) AS transaction_count
FROM fraud_predictions
GROUP BY "Predicted_Label"
ORDER BY transaction_count DESC;

-- ============================================================
-- QUESTION 20:
-- Among transactions flagged as fraud, what percentage
-- were actually fraudulent?
-- ============================================================

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS confirmed_fraud_percentage
FROM fraud_predictions
WHERE "Predicted_Label" = 'Fraud';

-- ============================================================
-- QUESTION 21:
-- What are the highest-value fraudulent transactions
-- that the model failed to detect?
-- ============================================================

SELECT
    "Original_Amount",
    "Fraud_Probability",
    "Actual_Label",
    "Predicted_Label"
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud'
  AND "Predicted_Label" = 'Legitimate'
ORDER BY "Original_Amount" DESC
LIMIT 10;

-- ============================================================
-- QUESTION 22:
-- What are the highest-value legitimate transactions
-- incorrectly flagged as fraud?
-- ============================================================

SELECT
    "Original_Amount",
    "Fraud_Probability",
    "Actual_Label",
    "Predicted_Label"
FROM fraud_predictions
WHERE "Actual_Label" = 'Legitimate'
  AND "Predicted_Label" = 'Fraud'
ORDER BY "Original_Amount" DESC
LIMIT 10;

-- ============================================================
-- QUESTION 23:
-- How does the average fraud probability differ between
-- legitimate and fraudulent transactions?
-- ============================================================

SELECT
    "Actual_Label",
    ROUND(
        AVG("Fraud_Probability")::numeric,
        4
    ) AS average_fraud_probability
FROM fraud_predictions
GROUP BY "Actual_Label"
ORDER BY average_fraud_probability DESC;

-- ============================================================
-- QUESTION 24:
-- How does fraud rate vary across different transaction
-- amount ranges?
-- ============================================================

SELECT
    CASE
        WHEN "Original_Amount" < 10
            THEN 'Under $10'
        WHEN "Original_Amount" < 50
            THEN '$10 - $49'
        WHEN "Original_Amount" < 100
            THEN '$50 - $99'
        WHEN "Original_Amount" < 500
            THEN '$100 - $499'
        ELSE '$500+'
    END AS amount_range,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN "Actual_Label" = 'Fraud'
            THEN 1
            ELSE 0
        END
    ) AS fraud_transactions,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fraud_rate

FROM fraud_predictions
GROUP BY amount_range
ORDER BY fraud_rate DESC;

-- ============================================================
-- QUESTION 25:
-- How does actual fraud rate change as the model's
-- fraud probability increases?
-- ============================================================

SELECT
    CASE
        WHEN "Fraud_Probability" < 0.20
            THEN '0.00 - 0.19'
        WHEN "Fraud_Probability" < 0.40
            THEN '0.20 - 0.39'
        WHEN "Fraud_Probability" < 0.60
            THEN '0.40 - 0.59'
        WHEN "Fraud_Probability" < 0.80
            THEN '0.60 - 0.79'
        ELSE '0.80 - 1.00'
    END AS probability_range,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN "Actual_Label" = 'Fraud'
            THEN 1
            ELSE 0
        END
    ) AS actual_frauds,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Actual_Label" = 'Fraud'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS actual_fraud_rate

FROM fraud_predictions
GROUP BY probability_range
ORDER BY probability_range;

-- ============================================================
-- QUESTION 26:
-- What percentage of the total fraudulent transaction value
-- was successfully detected by the model?
-- ============================================================

SELECT
    ROUND(
        (
            100.0 * SUM(
                CASE
                    WHEN "Predicted_Label" = 'Fraud'
                    THEN "Original_Amount"
                    ELSE 0
                END
            )
            /
            NULLIF(
                SUM("Original_Amount"),
                0
            )
        )::numeric,
        2
    ) AS detected_fraud_value_percentage
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud';
-- ============================================================
-- QUESTION 27:
-- What is the total transaction value associated with
-- actual fraudulent transactions?
-- ============================================================

SELECT
    ROUND(
        SUM("Original_Amount")::numeric,
        2
    ) AS total_fraud_value
FROM fraud_predictions
WHERE "Actual_Label" = 'Fraud';

-- ============================================================
-- QUESTION 28:
-- What is the total value of legitimate transactions
-- incorrectly flagged as fraud?
-- ============================================================

SELECT
    ROUND(
        SUM("Original_Amount")::numeric,
        2
    ) AS false_positive_transaction_value
FROM fraud_predictions
WHERE "Actual_Label" = 'Legitimate'
  AND "Predicted_Label" = 'Fraud';

  -- ============================================================
-- QUESTION 13:
-- How can transactions be classified into Low, Medium,
-- and High Risk levels based on Fraud Probability?
-- ============================================================

ALTER TABLE fraud_predictions
ADD COLUMN IF NOT EXISTS "Risk_Level" VARCHAR(20);

UPDATE fraud_predictions
SET "Risk_Level" =
    CASE
        WHEN "Fraud_Probability" < 0.20 THEN 'Low Risk'
        WHEN "Fraud_Probability" < 0.50 THEN 'Medium Risk'
        ELSE 'High Risk'
    END;