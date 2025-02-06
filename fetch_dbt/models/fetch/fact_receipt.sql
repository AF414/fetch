{{
  config(
    materialized = 'table',
    )
}}
select _id as receipt_id, * EXCLUDE (_id) from (
    select
        * replace (
            _id."$oid" as _id,
            epoch_ms(createdate."$date")::timestamp as createdate,
            epoch_ms(datescanned."$date")::timestamp as datescanned,
            epoch_ms(finisheddate."$date")::timestamp as finisheddate,
            epoch_ms(modifydate."$date")::timestamp as modifydate,
            epoch_ms(pointsawardeddate."$date")::timestamp as pointsawardeddate,
            epoch_ms(purchasedate."$date")::timestamp as purchasedate,
            pointsearned::float as pointsearned,
            totalspent::float as totalspent

        )
    from
        read_json(
            'https://fetch-hiring.s3.amazonaws.com/analytics-engineer/ineeddata-data-modeling/receipts.json.gz',
            format = 'newline_delimited',
            ignore_errors = True
        )
)
