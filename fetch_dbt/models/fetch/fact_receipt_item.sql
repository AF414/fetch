{{
  config(
    materialized = 'table',
    )
}}

with receipt_base as (
    select
        _id."$oid" as receipt_id,
        purchasedItemCount,
        epoch_ms(createdate."$date")::timestamp as createdate,
        epoch_ms(datescanned."$date")::timestamp as datescanned,
        epoch_ms(finisheddate."$date")::timestamp as finisheddate,
        epoch_ms(modifydate."$date")::timestamp as modifydate,
        epoch_ms(pointsawardeddate."$date")::timestamp as pointsawardeddate,
        epoch_ms(purchasedate."$date")::timestamp as purchasedate,
        pointsearned::float as total_receipt_points_earned,
        totalspent::float as total_receipt_spent,
        unnest(coalesce(rewardsReceiptItemList,'[{}]'), recursive := true)
    from read_json('https://fetch-hiring.s3.amazonaws.com/analytics-engineer/ineeddata-data-modeling/receipts.json.gz',format='newline_delimited', ignore_errors=True)
)
select 
* replace (itemPrice::decimal(8,2) as itemPrice),
receipt_id || '_' || row_number() over (partition by receipt_id order by barcode) as receipt_item_id,
sum(quantityPurchased) over (partition by receipt_id) as items_in_receipt_list,
sum(quantityPurchased) over (partition by receipt_id) - purchasedItemCount as summary_list_difference_count
from receipt_base
