WITH match_stats AS (
    -- Calculate match percentage for each foreign key relationship
    SELECT
        'fact_receipt.userId -> dim_user._id' AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN r.userid IS NOT NULL THEN 1 ELSE 0 END) AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN r.userid IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt AS r
    LEFT JOIN dim_user AS u ON r.userid = u._id

    UNION ALL

    SELECT
        'fact_receipt_item.receipt_id -> fact_receipt._id' AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN rri.receipt_id IS NOT NULL THEN 1 ELSE 0 END)
            AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN rri.receipt_id IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN fact_receipt AS r ON rri.receipt_id = r.receipt_id

    UNION ALL

    SELECT
        'fact_receipt_item.brandCode -> dim_brand.brandCode' AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN b.brandcode IS NOT NULL THEN 1 ELSE 0 END)
            AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN b.brandcode IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN dim_brand AS b ON rri.brandcode = b.brandcode
    WHERE rri.brandcode IS NOT NULL

    UNION ALL

    SELECT
        'fact_receipt_item.barcode -> dim_brand.barcode' AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN b.barcode IS NOT NULL THEN 1 ELSE 0 END) AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN b.barcode IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN dim_brand AS b ON rri.barcode = b.barcode


    UNION ALL

    SELECT
        'fact_receipt_item.rewardsProductPartnerId -> dim_brand.cpg_oid'
            AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN b.cpg_oid IS NOT NULL THEN 1 ELSE 0 END) AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN b.cpg_oid IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN dim_brand AS b ON rri.rewardsproductpartnerid = b.cpg_oid

    UNION ALL

    SELECT
        'fact_receipt_item.originalMetaBriteBarcode -> dim_brand.barcode'
            AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN b.barcode IS NOT NULL THEN 1 ELSE 0 END) AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN b.barcode IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN dim_brand AS b ON rri.originalmetabritebarcode = b.barcode
    WHERE rri.originalmetabritebarcode IS NOT NULL


    UNION ALL

    SELECT
        'fact_receipt_item.userFlaggedBarcode -> dim_brand.barcode'
            AS relationship,
        COUNT(*) AS total_keys,
        SUM(CASE WHEN b.barcode IS NOT NULL THEN 1 ELSE 0 END) AS matching_keys,
        ROUND(
            100.0
            * SUM(CASE WHEN b.barcode IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN dim_brand AS b ON rri.userflaggedbarcode = b.barcode
    WHERE rri.userflaggedbarcode IS NOT NULL

    UNION ALL

    SELECT
        'fact_receipt_item.brandCode/.barcode -> dim_brand.brandCode/.barcode'
            AS relationship,
        COUNT(*) AS total_keys,
        SUM(
            CASE
                WHEN COALESCE(b.brandcode, b2.barcode) IS NOT NULL THEN 1 ELSE 0
            END
        ) AS matching_keys,
        ROUND(
            100.0
            * SUM(
                CASE
                    WHEN
                        COALESCE(b.barcode, b2.barcode) IS NOT NULL
                        THEN 1
                    ELSE 0
                END
            )
            / COUNT(*),
            2
        ) AS match_percentage
    FROM fact_receipt_item AS rri
    LEFT JOIN dim_brand AS b ON rri.brandcode = b.brandcode
    LEFT JOIN dim_brand AS b2 ON rri.barcode = b2.barcode
    WHERE COALESCE(rri.barcode, rri.brandcode) IS NOT NULL




)

SELECT *
FROM match_stats
ORDER BY match_percentage DESC
