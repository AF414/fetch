with agg as (

    select
        r.rewardsreceiptstatus,
        date_trunc('month', rri.datescanned) as month_scanned,
        coalesce(
            b.name,
            case
                when
                    rri.brandcode = 'BRAND'
                    then split_part(rri.description, ' ', 1)
                else rri.brandcode
            end
        ) as brand_name, -- attempting to account for generic BRAND brandcode
        count(distinct rri.receipt_id) as receipt_count,
        sum(rri.itemprice)
            as total_spent,
        sum(rri.quantitypurchased) as total_items,
        sum(
            case
                when
                    u.createddate > date_trunc('month', rri.datescanned)
                    - interval '6 months'
                    then
                        rri.itemprice
            end
        ) as user_within_last_6mo_total_spent,
        count(
            distinct
            case
                when
                    u.createddate > date_trunc('month', rri.datescanned)
                    - interval '6 months'
                    then rri.receipt_id
            end
        ) as user_within_last_6mo_total_transactions
    from {{ ref('fact_receipt_item') }} as rri
    left join {{ ref('dim_brand') }} as b
        on
            rri.brandcode = b.brandcode
            or rri.barcode = b.barcode
            or (rri.description = b.brandcode)
    left join
        {{ ref('fact_receipt') }} as r
        on rri.receipt_id = r.receipt_id
    left join {{ ref('dim_user') }} as u on r.userid = u._id
    where
        len(r.rewardsreceiptitemlist) > 0
        and r.rewardsreceiptstatus not in ('REJECTED')
        and r.userid not in (
            select _id from {{ ref('dim_user') }} where role = 'fetch-staff'
        )
    group by month_scanned, brand_name, rewardsreceiptstatus
),

ext as (

    select
        *,
        dense_rank()
            over (partition by month_scanned,rewardsReceiptStatus order by receipt_count desc)
            as month_receipt_count_rank,
        dense_rank()
            over (partition by month_scanned,rewardsReceiptStatus order by total_spent desc)
            as month_total_spent_rank,
        dense_rank()
            over (partition by month_scanned,rewardsReceiptStatus order by total_items desc)
            as month_total_items_rank
    from agg
)

select
    *,
    lag(month_receipt_count_rank, 1)
        over (partition by brand_name,rewardsReceiptStatus order by month_scanned)
    - month_receipt_count_rank
        as receipt_count_rank_change_mom,
    lag(month_total_spent_rank, 1)
        over (partition by brand_name,rewardsReceiptStatus order by month_scanned)
    - month_total_spent_rank
        as spend_rank_change_mom
from ext

order by month_scanned, rewardsReceiptStatus, month_receipt_count_rank
